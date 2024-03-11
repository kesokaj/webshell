#!/bin/bash

mkdir -p $XDG_RUNTIME_DIR
mkdir -p $WORKSPACE

dockerd-rootless.sh &
code-server --bind-addr=0.0.0.0:3000 --disable-telemetry --auth=none --user-data-dir=$HOME/.config ${WORKSPACE}
