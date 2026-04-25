#!/usr/bin/env bash
# Increment the running agent count inside the container.
set -euo pipefail

CONTAINER=${CONTAINER:-agent-smith}
INCREMENT=${INCREMENT:-1}

docker exec "${CONTAINER}" python3 /agent_smith/supervisor/supervisor.py \
  --signal add \
  --count "${INCREMENT}" && \
  echo "[Agent Smith] Requested ${INCREMENT} additional agent(s)."
