#!/usr/bin/env bash

# Copyright (C) 2023 johaj10
# Licensed under GPL v3.0

FILE=/etc/netplan/00-installer-config.yaml

# Function to create file nested in directories
createfile() {
  mkdir -p "$(dirname "$1")" && touch "$1" ;
}


echo "This script will give your server a dynamic IP Address using DHCP."
sleep 0.5

# Checks to see if script is run as root
if [ "$EUID" -ne 0 ]; then 
	echo "Please run as root, exiting"
	exit
fi

echo "Making sure netplan is installed" 
sudo apt update
sudo apt install netplan.io


if [ -f "$FILE" ]; then
	echo "$FILE - Netplan config yaml file exists, overwriting..."
	rm $FILE
	createfile $FILE
else
	createfile $FILE
	echo "Created config file at $FILE"
fi


# Change enp2s0 to the name of the ethernet adapter for your system
cat << EOF > $FILE
# Config file for static ip
network:
  version: 2
  renderer: networkd
  ethernets:
    enp2s0:
      dhcp4: true
EOF

echo "Updated network configuration in $FILE"
echo "Running netplan apply..."

netplan apply

echo "Networking set to DHCP (Dynamic IP). Please reboot (run sudo reboot)!"
