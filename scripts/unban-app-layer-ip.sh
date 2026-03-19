#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 --service <systemd-unit> --state-file <path> --ip <address>"
  echo
  echo "Safely removes one IP from the persisted app-layer ban state."
  echo "Required flow: stop service -> modify state file -> start service."
}

SERVICE=""
STATE_FILE=""
TARGET_IP=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --service)
      SERVICE="${2:-}"
      shift 2
      ;;
    --state-file)
      STATE_FILE="${2:-}"
      shift 2
      ;;
    --ip)
      TARGET_IP="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ -z "$SERVICE" || -z "$STATE_FILE" || -z "$TARGET_IP" ]]; then
  usage >&2
  exit 1
fi

if [[ ! -f "$STATE_FILE" ]]; then
  echo "State file not found: $STATE_FILE" >&2
  exit 1
fi

echo "Stopping service: $SERVICE"
systemctl stop "$SERVICE"

echo "Removing ban for IP: $TARGET_IP"
python3 - "$STATE_FILE" "$TARGET_IP" <<'PY'
import json
import pathlib
import sys

state_path = pathlib.Path(sys.argv[1])
target_ip = sys.argv[2]

with state_path.open("r", encoding="utf-8") as fh:
    data = json.load(fh)

bans = data.get("bans", [])
before = len(bans)
data["bans"] = [item for item in bans if item.get("ip") != target_ip]
after = len(data["bans"])

with state_path.open("w", encoding="utf-8") as fh:
    json.dump(data, fh, indent=2, sort_keys=True)
    fh.write("\n")

print(f"Removed {before - after} matching ban record(s) for {target_ip}")
PY

chmod 600 "$STATE_FILE"

echo "Starting service: $SERVICE"
systemctl start "$SERVICE"

echo "Done."
