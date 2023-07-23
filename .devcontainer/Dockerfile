ARG NODE_VERSION="20"
ARG DEBIAN_VERSION="bullseye"
ARG UBUNTU_VERSION="focal"
FROM mcr.microsoft.com/vscode/devcontainers/typescript-node:0-${NODE_VERSION}-${UBUNTU_VERSION}
# Need to redeclare this build arg so it's available after FROM again
ARG DEBIAN_VERSION="bullseye"
ARG UBUNTU_VERSION="focal"

# Ansible
RUN echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu focal main" | \
    tee /etc/apt/sources.list.d/ansible.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367 && \
    apt update \
    && apt install ansible -y \
    && rm -rf /var/lib/apt/lists/* \
;

RUN npm install -g @go-task/cli

# Add Cloudflare Repository
RUN mkdir -p --mode=0755 /usr/share/keyrings
RUN curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null
RUN echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared' "${DEBIAN_VERSION}" 'main' | tee /etc/apt/sources.list.d/cloudflared.list
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive && apt-get install -y --no-install-recommends cloudflared