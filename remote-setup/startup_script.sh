#!/bin/bash

# Install docker-ce 17.03.3
if [ ! -f /usr/bin/docker ]; then
  apt update
  wget -O docker.deb https://download.docker.com/linux/debian/dists/stretch/pool/stable/amd64/docker-ce_17.03.3~ce-0~debian-stretch_amd64.deb
  dpkg -i docker.deb
  apt -f -y install
  rm -rf docker*
fi

# Delete dataDir for rook monitors
rm -rf /var/lib/rook/*

# Enable rdb module for ceph
echo "rbd" >> /etc/modules
