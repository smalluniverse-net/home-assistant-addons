#!/usr/bin/env python3
"""1Password Prometheus metrics exporter.

Exposes onepassword_* metrics on :9101/metrics.
Requires OP_SERVICE_ACCOUNT_TOKEN in environment (set by run.sh from add-on options).
Refreshes every 5 minutes.
"""

import json
import subprocess
import sys
import threading
import time
from datetime import datetime, timezone
from http.server import BaseHTTPRequestHandler, HTTPServer

OP_BIN = "/usr/local/bin/op"
PORT = 9101
REFRESH_INTERVAL = 300  # 5 minutes

_metrics_cache = b""
_metrics_lock = threading.Lock()


def run_op(*args):
    result = subprocess.run(
        [OP_BIN, *args],
        capture_output=True,
        text=True,
        stdin=subprocess.DEVNULL,
    )
    if result.returncode != 0:
        raise RuntimeError(f"op {' '.join(args)} failed: {result.stderr.strip()}")
    return result.stdout


def collect_metrics() -> str:
    items = json.loads(run_op("item", "list", "--format", "json"))

    now = datetime.now(timezone.utc).timestamp()
    one_year_ago = now - 365 * 86400
    two_years_ago = now - 2 * 365 * 86400
    thirty_days_ago = now - 30 * 86400

    vault_total: dict[str, int] = {}
    vault_updated_30d: dict[str, int] = {}
    stale_1y = 0
    stale_2y = 0
    passwords_changed = 0

    for item in items:
        vault = item.get("vault", {}).get("name", "unknown")
        vault_total[vault] = vault_total.get(vault, 0) + 1

        updated_at = item.get("updated_at", "")
        try:
            ts = datetime.fromisoformat(updated_at.replace("Z", "+00:00")).timestamp()
        except (ValueError, AttributeError):
            ts = 0.0

        if ts >= thirty_days_ago:
            vault_updated_30d[vault] = vault_updated_30d.get(vault, 0) + 1

        if ts < one_year_ago:
            stale_1y += 1
        if ts < two_years_ago:
            stale_2y += 1

        if item.get("category") == "LOGIN" and ts >= thirty_days_ago:
            passwords_changed += 1

    lines: list[str] = []

    lines += [
        "# HELP onepassword_items_total Total items per vault",
        "# TYPE onepassword_items_total gauge",
    ]
    for vault, count in sorted(vault_total.items()):
        lines.append(f'onepassword_items_total{{vault="{_esc(vault)}"}} {count}')

    lines += [
        "# HELP onepassword_items_updated_30d Items updated in the last 30 days per vault",
        "# TYPE onepassword_items_updated_30d gauge",
    ]
    for vault in sorted(vault_total):
        count = vault_updated_30d.get(vault, 0)
        lines.append(f'onepassword_items_updated_30d{{vault="{_esc(vault)}"}} {count}')

    lines += [
        "# HELP onepassword_items_stale_1y Items not updated in over 1 year",
        "# TYPE onepassword_items_stale_1y gauge",
        f"onepassword_items_stale_1y {stale_1y}",
        "# HELP onepassword_items_stale_2y Items not updated in over 2 years",
        "# TYPE onepassword_items_stale_2y gauge",
        f"onepassword_items_stale_2y {stale_2y}",
        "# HELP onepassword_passwords_changed_total Login items updated in the last 30 days",
        "# TYPE onepassword_passwords_changed_total gauge",
        f"onepassword_passwords_changed_total {passwords_changed}",
        "# HELP onepassword_weak_passwords Weak passwords flagged by 1Password (requires Watchtower access)",
        "# TYPE onepassword_weak_passwords gauge",
        "onepassword_weak_passwords 0",
    ]

    return "\n".join(lines) + "\n"


def _esc(s: str) -> str:
    return s.replace("\\", "\\\\").replace('"', '\\"')


def _refresh_loop() -> None:
    while True:
        try:
            text = collect_metrics()
            with _metrics_lock:
                global _metrics_cache
                _metrics_cache = text.encode()
        except Exception as exc:
            print(f"[op-metrics] collect error: {exc}", flush=True)
        time.sleep(REFRESH_INTERVAL)


class _Handler(BaseHTTPRequestHandler):
    def do_GET(self) -> None:
        if self.path == "/metrics":
            with _metrics_lock:
                body = _metrics_cache
            self.send_response(200)
            self.send_header("Content-Type", "text/plain; version=0.0.4; charset=utf-8")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
        else:
            self.send_response(404)
            self.end_headers()

    def log_message(self, fmt, *args) -> None:  # noqa: ARG002
        pass


if __name__ == "__main__":
    try:
        initial = collect_metrics()
        with _metrics_lock:
            _metrics_cache = initial.encode()
    except Exception as exc:
        print(f"[op-metrics] initial collect error: {exc}", flush=True)

    t = threading.Thread(target=_refresh_loop, daemon=True)
    t.start()

    server = HTTPServer(("0.0.0.0", PORT), _Handler)
    print(f"[op-metrics] listening on 0.0.0.0:{PORT}", flush=True)
    server.serve_forever()
