#!/bin/bash

sudo apt update
wget -o docker.deb https://download.docker.com/linux/debian/dists/stretch/pool/stable/amd64/docker-ce_17.03.3~ce-0~debian-stretch_amd64.deb
sudo dpkg -i docker-ce_17.03.3~ce-0~debian-stretch_amd64.deb
sudo apt -f -y install
rm -rf docker*
sudo usermod -aG docker $USER

touch clear_rook_dataDir.sh
echo "sudo rm -rf /var/lib/rook/*" >> clear_rook_dataDir.sh
chmod +x clear_rook_dataDir.sh
