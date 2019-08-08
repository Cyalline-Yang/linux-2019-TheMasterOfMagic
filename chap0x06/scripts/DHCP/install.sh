#!/usr/bin/env bash

cd "$(dirname "$0")" || (exit 0)
source ../functions.sh
[[ "$(whoami)" == root ]] || exit_because "root previledge is required"

# make sure isc-dhcp-server is installed
apt-get install -y isc-dhcp-server &> /dev/null || exit_because "failed to install isc-dhcp-server"

# set ip addr
cp 01-netcfg.yaml /etc/netplan/01-netcfg.yaml
cat >> /etc/netplan/01-netcfg.yaml << EOF
    enp0s8:
      addresses: [10.20.50.1/24]
      dhcp4: no
EOF
netplan apply || exit_because "failed to apply netplan"

# modify dhcp config files
echo INTERFACESv4=\"enp0s8\" > /etc/default/isc-dhcp-server
cp ./dhcpd.conf /etc/dhcp/dhcpd.conf
cat >> /etc/dhcp/dhcpd.conf << EOF
subnet 10.20.50.0 netmask 255.255.255.0 {
    range 10.20.50.2 10.20.50.254;
    option subnet-mask 255.255.255.0;
    option broadcast-address 10.20.50.255;
    default-lease-time 600;
    max-lease-time 7200;
}
EOF

# restart the service to apply the lastest config
systemctl restart isc-dhcp-server
