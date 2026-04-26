#!/usr/bin/env bash
# Build + run the Agent Smith container locally.
set -euo pipefail

AGENT_COUNT=${AGENT_COUNT:-10}
IMAGE=${IMAGE:-agent_smith:dev}
CONTAINER=${CONTAINER:-agent-smith}
WORKSPACE=${WORKSPACE:-$(pwd)/workspace}

mkdir -p "${WORKSPACE}"

docker build -t "${IMAGE}" -f docker/Dockerfile .

docker run -it --rm \
  --name "${CONTAINER}" \
  -e AGENT_COUNT="${AGENT_COUNT}" \
  -v "${WORKSPACE}:/agents/workspace" \
  "${IMAGE}"
