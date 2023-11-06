FROM debian:testing-slim
LABEL org.opencontainers.image.source https://github.com/kesokaj/webshell

EXPOSE 3000

ENV RELEASE bookworm
ENV LOCAL_USER user
ENV LOCAL_PASSWORD user
ENV XDG_RUNTIME_DIR /usr/workspace/.docker/run

COPY init.sh init.sh
RUN chmod +x init.sh

# Prereq
RUN apt-get update && apt-get install -y \
    uidmap \
    kmod \
    dbus-user-session \
    fuse-overlayfs \
    sudo \
    rsyslog \
    gnupg \
    ca-certificates \
    software-properties-common \
    curl \ 
    wget \
    apt-transport-https \
    iptables

## Add kubectl
RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmour -o /etc/apt/trusted.gpg.d/cgoogle.gpg && apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"

## Add google-sdk
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add -

## Add terraform
RUN curl https://apt.releases.hashicorp.com/gpg | gpg --dearmor > /tmp/hashicorp.gpg \
    && install -o root -g root -m 644 /tmp/hashicorp.gpg /etc/apt/trusted.gpg.d/ \
    && apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com focal main"

## Add Docker CE
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
RUN echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $RELEASE stable" | tee -a /etc/apt/sources.list.d/docker-ce.list

## Add helm
RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get > /tmp/get_helm.sh \
    && chmod +x /tmp/get_helm.sh \
    && /tmp/get_helm.sh

## Install golang 1.21.3
RUN wget https://go.dev/dl/go1.21.3.linux-amd64.tar.gz -P /tmp/ \
    && tar -zxvf /tmp/go1.21.3.linux-amd64.tar.gz  -C /usr/local/ \
    && chmod +x /usr/local/go/bin/go \
    && echo "export PATH=/usr/local/go/bin:${PATH}" | tee /etc/profile.d/go.sh \
    && chmod +x /etc/profile.d/go.sh

## Install code-server
RUN curl -fsSL https://code-server.dev/install.sh > /tmp/code_server.sh \
    && chmod +x /tmp/code_server.sh \
    && /tmp/code_server.sh

## Install apps
RUN apt-get update && apt-get install -y \
    google-cloud-sdk-gke-gcloud-auth-plugin \
    docker-compose \
    bash-completion \
    vim \
    net-tools \
    dnsutils \
    ssh \
    google-cloud-cli \
    iproute2 \
    lsof \
    python3 \
    python3-pip \
    npm \
    git \
    wget \
    kubectl \
    dnsutils \
    iputils-ping \
    s3cmd \
    jq \
    tldr \
    terraform \
    nano \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin \
 && rm -rf /var/lib/apt/lists/*

## Clean up
RUN rm -rvf /tmp/*

## Setup user environment
RUN useradd -rm -d /home/$LOCAL_USER -s /bin/bash -G sudo,docker -u 666 $LOCAL_USER
# Adding to sudo
RUN echo "$LOCAL_USER ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers
# Settings password
RUN echo "$LOCAL_USER:$LOCAL_PASSWORD" | chpasswd
# Adding rootless groups
RUN echo "$LOCAL_USER:100000:65536" > /etc/subuid
RUN echo "$LOCAL_USER:100000:65536" > /etc/subgid
# Create workspace
RUN mkdir -p /usr/local/workspace

## Switch user
USER $LOCAL_USER

## Install docker
RUN dockerd-rootless-setuptool.sh install

ENTRYPOINT ["/init.sh"]
