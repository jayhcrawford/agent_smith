# Agent Smith base image
# Provides a minimal environment for running multiple OpenClaw-like agents in isolation.

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=UTC \
    AGENT_COUNT=10

# Install OS packages (curl/git/python/etc.)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    openssh-client \
    python3 \
    python3-pip \
    python3-yaml \
    tmux \
    sudo \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Add non-root user for running agents
RUN useradd -ms /bin/bash agent && echo "agent ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Copy supervisor + scripts into image
COPY --chown=agent:agent supervisor /agent_smith/supervisor
COPY --chown=agent:agent scripts /agent_smith/scripts
COPY --chown=agent:agent docker/entrypoint.sh /agent_smith/entrypoint.sh

# Workspace mount point (bind mount from host)
RUN mkdir -p /agents/workspace && chown -R agent:agent /agents
VOLUME /agents/workspace

USER agent
WORKDIR /home/agent

ENTRYPOINT ["/agent_smith/entrypoint.sh"]
