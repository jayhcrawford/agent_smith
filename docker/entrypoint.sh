#!/usr/bin/env bash
set -euo pipefail

AGENT_COUNT=${AGENT_COUNT:-10}
SUPERVISOR_CONFIG=${SUPERVISOR_CONFIG:-/agent_smith/supervisor/config.yaml}

echo "[Agent Smith] Starting supervisor with ${AGENT_COUNT} agents"
python3 /agent_smith/supervisor/supervisor.py \
  --config "${SUPERVISOR_CONFIG}" \
  --agent-count "${AGENT_COUNT}"
