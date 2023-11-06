#!/bin/bash

sudo chown -R 666:docker /usr/local/workspace
mkdir -p /usr/local/workspace/.config
mkdir -p /usr/local/workspace/.docker/run

dockerd-rootless.sh &
code-server --bind-addr=0.0.0.0:3000 --disable-telemetry --auth=none --user-data-dir=/usr/local/workspace/.config "${DEFAULT_WORKSPACE:-/usr/local/workspace}"
