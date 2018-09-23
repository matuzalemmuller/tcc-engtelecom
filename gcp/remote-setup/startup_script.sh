#!/bin/bash

USERNAME="matuzalemmuller"

# Install docker
sudo apt update
wget -O docker.deb https://download.docker.com/linux/debian/dists/stretch/pool/stable/amd64/docker-ce_17.03.3~ce-0~debian-stretch_amd64.deb
sudo dpkg -i docker.deb
sudo apt -f -y install
rm -rf docker*

# Create file with command to add permission for user to run docker
cd /home
touch docker_setup.sh
echo "#!/bin/bash" >> docker_setup.sh
echo "sudo usermod -aG docker $USERNAME" >> docker_setup.sh

# Create file to delete monitor files from rook
touch clear_rook_dataDir.sh
echo "#!/bin/bash" >> clear_rook_dataDir.sh
echo "sudo rm -rf /var/lib/rook/*" >> clear_rook_dataDir.sh
chmod +x clear_rook_dataDir.sh
