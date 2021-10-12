#!/bin/bash
#

echo "=================================================================="
echo "Importing the public key that is used to sign the software release"
wget -qO - https://ppa.hornet.zone/pubkey.txt | sudo apt-key add -

echo "=================================================================="
echo "Adding the Hornet APT repository to your APT sources"
sh -c 'echo "deb http://ppa.hornet.zone stable main" >> /etc/apt/sources.list.d/hornet.list'

echo "=================================================================="
echo "Update apt package lists"
apt -y update && apt -y upgrade

echo "=================================================================="
echo "Install Hornet"
apt install hornet

echo "=================================================================="
echo "Setting static IP"
# Creates a backup
cp /etc/netplan/50-cloud-init.yaml /etc/netplan/50-cloud-init.yaml.bk_`date +%Y%m%d%H%M`

# Disable "cloud-init"
echo "network: {config: disabled}" >> /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg

END_CONFIG=/etc/netplan/50-cloud-init.yaml

generateAndApply() {
    sudo netplan generate
    sudo netplan apply
}

getInternetInfo() {
    local INTERNET_INFO=$( ip r | grep default )
    printf "%s" "$( echo $INTERNET_INFO | cut -f$1 -d' ' )"
}

#static information
NAMESERVERS=("127.0.0.53" "8.8.8.8" "8.8.4.4")
NETWORK_MANAGER="networkd"

# information that varies
IP="$( ip r | grep kernel | cut -f9 -d' ' )"
GATEWAY="$( getInternetInfo 3 )"
DEVICE_NAME="$( getInternetInfo 5 )"
METHOD="$( getInternetInfo 7 )"
PREFIX="$( ip r | grep kernel | cut -f1 -d' ' | cut -f2 -d'/' )"

createStaticYAML() {
   local YAML="network:\n"
    YAML+="    version: 2\n"
    YAML+="    renderer: $NETWORK_MANAGER\n"
    YAML+="    ethernets:\n"
    YAML+="        $DEVICE_NAME:\n"
    YAML+="            dhcp4: no\n"
    YAML+="            addresses: [$IP/$PREFIX]\n"
    YAML+="            gateway4: $GATEWAY\n"
    YAML+="            nameservers:\n"
    YAML+="                addresses: [${NAMESERVERS[0]},${NAMESERVERS[1]},${NAMESERVERS[2]}]"
    printf "%s" "$YAML"
}

clearConfigs() {
    [ -f $END_CONFIG ] && sudo rm $END_CONFIG
}

setYAML() {
    sudo echo -e "$(createStaticYAML)" > $END_CONFIG
}

clearConfigs
setYAML
generateAndApply

echo "=================================================================="
echo "Enable the systemd service"
systemctl enable hornet.service

echo "=================================================================="
echo "Open dashboard to LAN"
sed -i 's/localhost:8081/0.0.0.0:8081/g' /var/lib/hornet/config*.json

echo "=================================================================="
echo "Starting Hornet"
service hornet start && journalctl -fu hornet
