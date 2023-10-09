#!/usr/bin/env bash

FILE=/etc/netplan/00-installer-config.yaml

# Function to create file nested in directories
createfile() {
  mkdir -p "$(dirname "$1")" && touch "$1" ;
}


echo "Welcome to the network setup script for Ubuntu Server. This script will give your server a static IP Address"
sleep 0.5

# Checks to see if script is run as root
if [ "$EUID" -ne 0 ]; then 
	echo "Please run as root, exiting"
	exit
fi

echo "Please enter a static ip address to set below. Make sure this IP address is available on your network!"
read ip_address


if [ -f "$FILE" ]; then
	echo "$FILE - Netplan config yaml file exists, overwriting..."
	rm $FILE
	createfile $FILE
else
	createfile $FILE
	echo "Created config file at $FILE"
fi



cat << EOF > $FILE
# Config file for static ip
network:
  version: 2
  renderer: networkd
  ethernets:
    enp2s0:
      dhcp4: no
      addresses: [$ip_address/24]
      gateway4: 192.168.1.1
      nameservers:
        addresses: [8.8.8.8,8.8.4.4]
      optional: true
EOF

echo "Updated network configuration in $FILE"
echo "Running netplan apply..."

netplan apply

echo "Static IP address set to $ip_address. DNS set to 8.8.8.8 (Google DNS). Please reboot (run sudo reboot)"