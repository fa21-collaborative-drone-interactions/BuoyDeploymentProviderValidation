#
# This source file is part of the FA2021 open source project
#
# SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
#
# SPDX-License-Identifier: MIT
#

BUOYLETTER="${1:-A}"
WIFIPASSWORD="${2:-BuoyAP$BUOYLETTER}"

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

sudo DEBIAN_FRONTEND=noninteractive apt-get -y update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y upgrade

# Access point setup based on the instructions found at https://www.raspberrypi.com/documentation/computers/configuration.html#setting-up-a-routed-wireless-access-point

printf "DNSStubListener=no" | sudo tee -a /etc/systemd/resolved.conf
sudo systemctl restart systemd-resolved

sudo DEBIAN_FRONTEND=noninteractive apt-get -y install rfkill hostapd dnsmasq netfilter-persistent iptables-persistent

## dnsmasq

printf "interface=wlan0
dhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,24h" | sudo tee /etc/dnsmasq.conf

printf "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/routed-ap.conf
    
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo netfilter-persistent save

sudo sed -i "s/^Wants=nss-lookup.target/Wants=nss-lookup.target network-online.target/" /lib/systemd/system/dnsmasq.service
sudo sed -i "s/^After=network.target/After=network.target network-online.target/" /lib/systemd/system/dnsmasq.service

printf "# This file is generated from information provided by the datasource.  Changes
# to it will not persist across an instance reboot.  To disable cloud-init's
# network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
    version: 2
    ethernets:
        eth0:
            dhcp4: true
            optional: true
        wlan0:
            dhcp4: false
            addresses:
            - 192.168.4.1/24" | sudo tee /etc/netplan/50-cloud-init.yaml

printf "127.0.0.1 localhost
127.0.1.1 ubuntu RaspberryPi$BUOYLETTER

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters" | sudo tee /etc/hostname

sudo systemctl reload dnsmasq

## hostapd

printf "country_code=DE
interface=wlan0
ssid=BuoyAP$BUOYLETTER
hw_mode=g
channel=7
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=$WIFIPASSWORD
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP" | sudo tee /etc/hostapd/hostapd.conf

printf 'DAEMON_CONF="/etc/hostapd/hostapd.conf"' | sudo tee -a /etc/default/hostapd

sudo rfkill unblock wlan

sudo systemctl unmask hostapd
sudo systemctl enable hostapd
sudo systemctl start hostapd

# Download and start avahi 

sudo DEBIAN_FRONTEND=noninteractive apt-get -y install avahi-utils avahi-daemon

sudo sed -i "s/^publish-hinfo=.*/publish-hinfo=yes/" /etc/avahi/avahi-daemon.conf
sudo sed -i "s/^publish-workstation=.*/publish-workstation=yes/" /etc/avahi/avahi-daemon.conf

sudo systemctl enable avahi-daemon.service
sudo systemctl start avahi-daemon.service

# Install Docker

sudo DEBIAN_FRONTEND=noninteractive apt-get -y install linux-modules-extra-raspi ca-certificates curl gnupg lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo DEBIAN_FRONTEND=noninteractive gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo DEBIAN_FRONTEND=noninteractive apt-get -y update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install docker-ce docker-ce-cli containerd.io

sudo groupadd docker
sudo usermod -aG docker $USER
docker --version

sudo systemctl enable docker.service
sudo systemctl enable containerd.service

sudo DEBIAN_FRONTEND=noninteractive apt-get -y install docker-compose

# Create the Sensors JSON file

sudo mkdir /buoy && echo "[]" | sudo tee /buoy/available_sensors.json


# Reboot

sudo systemctl reboot