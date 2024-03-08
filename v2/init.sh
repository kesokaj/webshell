#!/bin/bash

# Set variables
local_user="${LOCAL_USER:-user}"
local_password="${LOCAL_PASSWORD:-password}"

# Setup user environment
useradd -rm -d /home/$local_user -s /bin/bash -G sudo,docker -u 666 $local_user

# Settings password
echo "$local_user:$local_password" | chpasswd

# Adding to sudo
echo "$local_user ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers

# Adding rootless groups
echo "$local_user:100000:65536" > /etc/subuid
echo "$local_user:100000:65536" > /etc/subgid

# Send off to user script
su - $local_user /opt/user.sh