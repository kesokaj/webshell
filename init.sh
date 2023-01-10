#!/bin/bash

## Start logging
service rsyslog start

## Create user
if [ "${SHELL_USER}" ] && [ "${SHELL_PASSWORD}" ]; then
  useradd -rm -d /home/${SHELL_USER} -s /bin/bash -G sudo,docker -u 666 ${SHELL_USER}
  echo "${SHELL_USER} ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers
  echo -e "${SHELL_PASSWORD}\n${SHELL_PASSWORD}" | passwd ${SHELL_USER}
else
  exit 1
fi

## Add to subuid & subgid
echo "${SHELL_USER}:666:65536" > /etc/subuid
echo "${SHELL_USER}:666:65536" > /etc/subgid

## Fix docker config
cat << EOF > /etc/docker/daemon.json
{
  "userns-remap": "${SHELL_USER}",
  "data-root": "/home/${SHELL_USER}/.docker"
}
EOF

## Start user services
service ssh start
service docker start

## Start code server as
su - ${SHELL_USER} -c "mkdir -p /home/${SHELL_USER}/workspace" > /dev/null 2>&1 &
su - ${SHELL_USER} -c '/usr/bin/code-server --bind-addr=0.0.0.0:80 --disable-telemetry --auth=none "${DEFAULT_WORKSPACE:-/home/${SHELL_USER}/workspace}"' > /dev/null 2>&1 &

## Set permissions
su - ${SHELL_USER} -c "docker ps" > /dev/null 2>&1 &
sleep 5
chmod -R 755 /home/${SHELL_USER}/.docker

## Fix coder logging
ln -s /var/log/ /home/${SHELL_USER}/.local/share/code-server/coder-logs/*

## Start output logging
sleep 5
tail -qf --retry /var/log/*.log
