#!/usr/bin/env bash
# Placeholder agent process: prints heartbeats and accepts commands via stdin (future IPC).
set -euo pipefail

AGENT_NAME=${AGENT_NAME:-"agent"}
WORKSPACE=${WORKSPACE:-$(pwd)}

LOG_FILE="${WORKSPACE}/agent.log"

echo "[$AGENT_NAME] starting in ${WORKSPACE}" | tee -a "$LOG_FILE"

i=0
while true; do
  echo "[$AGENT_NAME] heartbeat $i" | tee -a "$LOG_FILE"
  i=$((i + 1))
  sleep 30
done
