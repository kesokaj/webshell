#!/bin/bash

## Create user
if [ "${SHELL_USER}" ] && [ "${SHELL_PASSWORD}" ]; then
  useradd -rm -d /home/${SHELL_USER} -s /bin/bash -G sudo -u 666 ${SHELL_USER}
  echo "${SHELL_USER} ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers
  echo -e "${SHELL_PASSWORD}\n${SHELL_PASSWORD}" | passwd ${SHELL_USER}
else
  exit 1
fi

## Start services
service rsyslog start
service ssh start
su - ${SHELL_USER} -c "/usr/bin/code-server --bind-addr=0.0.0.0:80 --auth=none" > /dev/null 2>&1 &

## Start output logging
tail -f /var/log/* -f /home/${SHELL_USER}/.local/share/code-server/coder-logs/*.log
