FROM debian:stable-slim

COPY bootstrap.sh bootstrap.sh
RUN chmod +x bootstrap.sh

# Prereq
RUN apt-get update && apt-get install -y uidmap kmod dbus-user-session fuse-overlayfs sudo rsyslog gnupg ca-certificates software-properties-common curl wget apt-transport-https iptables

## Add kubectl
RUN curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list

## Add google-sdk
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add -

## Add terraform
RUN curl https://apt.releases.hashicorp.com/gpg | gpg --dearmor > /tmp/hashicorp.gpg \
    && install -o root -g root -m 644 /tmp/hashicorp.gpg /etc/apt/trusted.gpg.d/ \
    && apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com focal main"

## Add helm
RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get > /tmp/get_helm.sh \
    && chmod +x /tmp/get_helm.sh \
    && /tmp/get_helm.sh

## Install golang 1.19.2
RUN wget https://go.dev/dl/go1.19.2.linux-amd64.tar.gz -P /tmp/ \
    && tar -zxvf /tmp/go1.19.2.linux-amd64.tar.gz -C /usr/local/ \
    && chmod +x /usr/local/go/bin/go \
    && echo "export PATH=/usr/local/go/bin:${PATH}" | tee /etc/profile.d/go.sh \
    && chmod +x /etc/profile.d/go.sh

## Install code-server
RUN curl -fsSL https://code-server.dev/install.sh > /tmp/code_server.sh \
    && chmod +x /tmp/code_server.sh \
    && /tmp/code_server.sh

## Install apps
RUN apt-get update
RUN apt-get install -y docker.io docker-compose bash-completion vim net-tools dnsutils ssh google-cloud-cli iproute2 openssh-server lsof python3 python3-pip lftp npm git wget kubectl dnsutils iputils-ping nmap nmon s3cmd jq tldr terraform nano

## Add completion
RUN kubectl completion bash | tee /etc/bash_completion.d/kubectl > /dev/null

## Clean up
RUN rm -rvf /tmp/*
RUN apt autoremove -y && apt autoclean -y

EXPOSE 80
ENTRYPOINT ["/bootstrap.sh"]
