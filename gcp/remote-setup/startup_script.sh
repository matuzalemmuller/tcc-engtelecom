#!/bin/bash

USERNAME="matuzalemmuller"

# Create script to install docker and give user permission to run it
cd /home
touch docker_setup.sh
echo "#!/bin/bash" >> docker_setup.sh
echo "cd $USERNAME"
echo "sudo apt update" >> docker_setup.sh
echo "wget -O docker.deb https://download.docker.com/linux/debian/dists/stretch/pool/stable/amd64/docker-ce_17.03.3~ce-0~debian-stretch_amd64.deb" >> docker_setup.sh
echo "sudo dpkg -i docker.deb" >> docker_setup.sh
echo "sudo apt -f -y install" >> docker_setup.sh
echo "sudo usermod -aG docker $USERNAME" >> docker_setup.sh
echo "rm -rf docker*" >> docker_setup.sh
echo "rm ../docker_setup.sh" >> docker_setup.sh

# Create file to delete monitor files from rook
touch clear_rook_dataDir.sh
echo "#!/bin/bash" >> clear_rook_dataDir.sh
echo "sudo rm -rf /var/lib/rook/*" >> clear_rook_dataDir.sh
chmod +x clear_rook_dataDir.sh
