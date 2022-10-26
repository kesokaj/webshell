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
echo "${SHELL_USER}:231072:65536" > /etc/subuid
echo "${SHELL_USER}:231072:65536" > /etc/subgid

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

### Start code server as
su - ${SHELL_USER} -c "/usr/bin/code-server --bind-addr=0.0.0.0:80 --auth=none" > /dev/null 2>&1 &

## Start output logging
sleep 5
tail -f /var/log/* -f /home/${SHELL_USER}/.local/share/code-server/coder-logs/*.log
