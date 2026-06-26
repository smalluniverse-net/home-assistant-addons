#!/usr/bin/with-contenv bash
set -euo pipefail

ROOT=/config/codex-matter-v3.2
PKG="$ROOT/matter-v3.2-patched-files-2026-06-26.tar.gz"
RUN_ID="$(date +%Y%m%d-%H%M%S)"
LOG="$ROOT/patcher-$RUN_ID.log"
BACKUP="$ROOT/backup-$RUN_ID"
WORK="/tmp/codex-matter-v3.2"

mkdir -p "$ROOT" "$BACKUP"
exec > >(tee -a "$LOG") 2>&1

log() {
  printf '[%s] %s\n' "$(date -Iseconds)" "$*"
}

api() {
  local method="$1"
  local path="$2"
  local data="${3:-}"
  if [ -n "$data" ]; then
    curl -fsS -X "$method" \
      -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" \
      -H "Content-Type: application/json" \
      -d "$data" \
      "http://supervisor${path}"
  else
    curl -fsS -X "$method" \
      -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" \
      "http://supervisor${path}"
  fi
}

wait_addon_started() {
  local slug="$1"
  local i state
  for i in $(seq 1 90); do
    state="$(api GET "/addons/${slug}/info" | jq -r '.data.state // .state // "unknown"')"
    log "${slug} state=${state}"
    if [ "$state" = "started" ]; then
      return 0
    fi
    sleep 2
  done
  log "ERROR: ${slug} did not reach started"
  return 1
}

self_info="$(api GET /addons/self/info)"
self_slug="$(printf '%s' "$self_info" | jq -r '.data.slug // .slug // "self"')"
self_protected="$(printf '%s' "$self_info" | jq -r '.data.protected // .protected // true')"
log "self slug=${self_slug} protected=${self_protected}"

if docker ps >/dev/null 2>&1; then
  log "docker access available; proceeding with patch"
elif [ "$self_protected" = "true" ]; then
  log "disabling self protection and restarting; second run will patch"
  api POST "/addons/${self_slug}/security" '{"protected":false}'
  api POST "/addons/${self_slug}/restart"
  exit 0
else
  log "ERROR: docker access unavailable although self protection is not reported enabled"
  exit 3
fi

if [ ! -f "$PKG" ]; then
  log "ERROR: package missing at $PKG"
  exit 2
fi

core_info="$(api GET /addons/core_matter_server/info)"
printf '%s\n' "$core_info" > "$ROOT/core_matter_server_pre_patch_$RUN_ID.json"
log "core_matter_server version=$(printf '%s' "$core_info" | jq -r '.data.version // .version // "unknown"') options=$(printf '%s' "$core_info" | jq -c '.data.options // .options // {}')"

log "setting core_matter_server beta=false to avoid npm install replacing patched files on restart"
api POST /addons/core_matter_server/options '{"options":{"log_level":"info","beta":false,"enable_test_net_dcl":false,"ble_proxy":true,"matter_server_env_vars":[]}}'

log "restarting core_matter_server before patch"
api POST /addons/core_matter_server/restart
wait_addon_started core_matter_server
sleep 5

cid="$(docker ps --format '{{.Names}}' | awk '$0=="addon_core_matter_server"{print; exit}')"
if [ -z "$cid" ]; then
  log "ERROR: addon_core_matter_server container not found"
  docker ps --format 'name={{.Names}} image={{.Image}} status={{.Status}}'
  exit 4
fi
log "target container=${cid}"

rm -rf "$WORK"
mkdir -p "$WORK"
tar -xzf "$PKG" -C "$WORK"

if [ ! -f "$WORK/target-paths.txt" ]; then
  log "ERROR: package target-paths.txt missing"
  exit 5
fi

while IFS= read -r rel; do
  [ -z "$rel" ] && continue
  mkdir -p "$BACKUP/$(dirname "$rel")"
  if docker cp "${cid}:/${rel}" "$BACKUP/$rel"; then
    log "backed up /${rel}"
  else
    log "missing before patch /${rel}"
    printf '%s\n' "$rel" >> "$BACKUP/missing.txt"
  fi
done < "$WORK/target-paths.txt"

while IFS= read -r rel; do
  [ -z "$rel" ] && continue
  docker cp "$WORK/files/$rel" "${cid}:/${rel}"
  log "patched /${rel}"
done < "$WORK/target-paths.txt"

docker exec "$cid" sh -c "node --check /app/node_modules/@matter-server/ble-proxy/dist/esm/ProxyBleChannel.js"
docker exec "$cid" sh -c "grep -q 'BLE candidate decision' /app/node_modules/@matter-server/ble-proxy/dist/esm/ProxyBleChannel.js"
docker exec "$cid" sh -c "grep -q 'outcome=\\${outcome}' /app/node_modules/@matter-server/ble-proxy/dist/esm/ProxyBleChannel.js"
docker exec "$cid" sh -c "grep -q 'btp_session' /app/node_modules/@matter-server/ble-proxy/src/ProxyBleChannel.ts"
docker exec "$cid" sh -c "grep -q 'getAlternateDiscoveredDevices' /app/node_modules/@matter/protocol/dist/esm/common/BleScanner.js"
docker exec "$cid" sh -c "grep -q 'proxyId' /app/node_modules/@matter-server/ble-proxy/dist/esm/ProxyBleClient.js"
log "patched marker checks passed"

log "restarting core_matter_server after patch"
docker restart "$cid"
wait_addon_started core_matter_server

api GET /addons/core_matter_server/info > "$ROOT/core_matter_server_post_patch_$RUN_ID.json"
printf '%s\n' "$BACKUP" > "$ROOT/latest-backup.txt"
printf '%s\n' "$LOG" > "$ROOT/latest-patcher-log.txt"
log "DONE backup=${BACKUP}"
