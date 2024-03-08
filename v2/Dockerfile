FROM debian:bookworm-slim

## Github
LABEL org.opencontainers.image.source https://github.com/kesokaj/webshell

## Expose port
EXPOSE 8080

## Environments
ENV ARCH="amd64"
ENV RELEASE="bookworm"
ENV CODE_VERSION="4.22.0"
ENV CODE_PORT="8080"

## Set workdir to /tmp
WORKDIR /tmp

# Pre-installation
RUN apt-get update && apt-get install -y apt-transport-https \
    ca-certificates \
    curl \
    wget \
    openssl \
    gnupg \
    lsb-release \
    software-properties-common \
    sudo

# Add docker-ce
RUN curl https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-ce.gpg && \
    echo "deb [arch=${ARCH} signed-by=/usr/share/keyrings/docker-ce.gpg] https://download.docker.com/linux/debian ${RELEASE} stable" | tee /etc/apt/sources.list.d/docker-ce.list

## Add google-sdk
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud-google.gpg && \
    echo "deb [arch=${ARCH} signed-by=/usr/share/keyrings/cloud-google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

## Add terraform
RUN curl https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
    echo "deb [arch=${ARCH} signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com ${RELEASE} main" | tee /etc/apt/sources.list.d/hashicorp.list

## Add helm
RUN curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg && \
    echo "deb [arch=${ARCH} signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list

## Post-installation
RUN apt-get update && apt-get install -y google-cloud-cli-gke-gcloud-auth-plugin \
    google-cloud-cli-skaffold \
    google-cloud-cli-kpt \
    google-cloud-cli \
    kubectl \
    python3 \
    python3-pip \
    python-is-python3 \
    golang \
    pv \
    nmon \
    htop \
    nano \
    vim \
    terraform \
    helm \
    sudo \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin \
    tldr \
    jq \
    dnsutils \
    lsof \
    git \
    uidmap \
    dbus-user-session \
    fuse-overlayfs \
    iproute2

## Add global env
RUN echo 'export GOPATH=$HOME/.go' >> /etc/profile.d/env.sh && \
    echo 'export XDG_RUNTIME_DIR=$HOME/.docker/run' >> /etc/profile.d/env.sh && \
    echo 'export PATH=$PATH:/usr/sbin/' >> /etc/profile.d/env.sh && \
    echo 'export DOCKER_HOST=unix://${XDG_RUNTIME_DIR}/docker.sock' >> /etc/profile.d/env.sh && \
    echo 'export WORKSPACE=$HOME/workspace' >> /etc/profile.d/env.sh && \
    echo 'export CODE_PORT=${CODE_PORT}' >> /etc/profile.d/env.sh && \
    echo 'export CODE_VERSION=${CODE_VERSION}' >> /etc/profile.d/env.sh && \
    chmod a+x /etc/profile.d/env.sh

## Install code-server
RUN curl -fOL https://github.com/coder/code-server/releases/download/v${CODE_VERSION}/code-server_${CODE_VERSION}_amd64.deb && \
    dpkg -i code-server_${CODE_VERSION}_amd64.deb

## Change workdir
WORKDIR /opt

## Copy init and set permissions
COPY init.sh init.sh
COPY user.sh user.sh
RUN chmod a+x init.sh user.sh

ENTRYPOINT [ "/opt/init.sh" ]