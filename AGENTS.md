# AGENTS -- haos-addons-work

> Canonical agent rules: `~/GitHub/project/AGENTS.md` (authoritative).
> Full project operating protocol: `~/GitHub/project/CLAUDE.md`.
> This file describes conventions specific to the `haos-addons-work` repo.
> Replaces the earlier short AGENTS.md (agent-lane summary only); lanes are now covered canonically in the project repo.

---

## What belongs here

Home Assistant addon customizations and overlays for the `smalluniverse.net` HAOS instance:

- `grafana/` -- self-hosted Grafana addon scaffolding.
- `grafana_cloud/` -- Grafana Cloud Alloy bridge addon (Alloy config, Dockerfile, rootfs).
- `op_metrics/` -- custom Prometheus metrics collectors for local services.
- Addon `config.yaml`, `build.yaml`, rootfs services, schemas, translations.

NOT here: live HAOS state, dashboard JSON (that lives in `~/GitHub/tools/monitoring/dashboards/`), canonical observability rules (`~/GitHub/project/Memory/reference_observability_config_change_rule.md`).

## Secret discipline (MANDATORY)

Addon options and `info`/`options` API responses contain `access_token`, `password`, and similar values verbatim. NEVER dump them to stdout. Required filters before display:

| Command | Required filter |
|---|---|
| `curl .../addons/<slug>/info` | pipe through `jq 'del(.data.options) \| del(.data.schema)'` |
| `ha apps info <slug>` / `ha addons info <slug>` | pipe through `awk '/^options:/{stop=1} !stop{print}'` |
| `ha apps options <slug> --raw-json` | BANNED. Use `ha apps options <slug> --key <name>` for a single field, or `POST /addons/<slug>/options` without reading first. |
| Reading `/addon_configs/*/config.alloy`, `/addon_configs/*/settings.js`, `prometheus.yaml` | pipe through the redaction sed in `~/GitHub/project/CLAUDE.md` §RULE 2 #5 |

Full rule: `~/GitHub/project/CLAUDE.md` §RULE 2.

## Config change rule (MANDATORY)

Any addon config write that changes deployed behavior (Alloy config edit, schema delta, scrape target add, retention change, alert rule semantics, addon version bump) requires the pre/post snapshot protocol. Recovery operations (cache deletes, transient restarts that come back identical, log rotation) do NOT trigger the protocol -- log a one-line `RECOVERED YYYY-MM-DD PT: <action> after <cause>` in `~/GitHub/project/Status/Observability Status.md` instead. Canonical: `~/GitHub/project/Memory/reference_observability_config_change_rule.md` + `~/GitHub/project/Memory/feedback_recovery_vs_config_change.md`.

## Branch convention

- Never push to `main` directly. Work on a feature branch (`claude/<topic>`, `cursor/<topic>`, `codex/<topic>`), push, open PR for Claude review.
- Mechanical hygiene (`.gitignore` updates, `.DS_Store` cleanup) MAY land on `main` if user-approved.
- Editing files in this repo does NOT deploy them. Deployment of changed config to the live HAOS instance is user-gated and runs through the standard HAOS update path, not by file move.

## Pointers

- Repo manifest: `REPO.md`
- Repo-local operating notes: `CLAUDE.md`
- Active audit reports: `~/GitHub/project/Reports/Security/Grafana Cloud Addon Security Review 2026-05-07.md` (and follow-on reports in the same directory).
