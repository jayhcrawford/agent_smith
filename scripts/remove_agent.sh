#!/usr/bin/env bash
# Gracefully stop one or more agents inside the running container.
set -euo pipefail

CONTAINER=${CONTAINER:-agent-smith}
COUNT=${COUNT:-1}

docker exec "${CONTAINER}" python3 /agent_smith/supervisor/supervisor.py \
  --signal remove \
  --count "${COUNT}" && \
  echo "[Agent Smith] Requested removal of ${COUNT} agent(s)."
