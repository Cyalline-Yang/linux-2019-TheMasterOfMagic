#!/usr/bin/env bash

set -e

cd "$(dirname "$0")" || (exit 0)
source ../functions.sh
[[ "$(whoami)" == root ]] || exit_because "root previledge is required"

# make sure bind9 is installed
apt-get install -y bind9 &> /dev/null || exit_because "failed to install bind9"

# make sure config files is modified as expected
cat > /etc/bind/named.conf.local << EOF
zone "cuc.edu.cn"{
    type master;
    file "/etc/bind/db.cuc.edu.cn";
};
EOF
cat > /etc/bind/db.cuc.edu.cn << EOF
\$TTL    604800
@       IN      SOA     cuc.edu.cn. root.cuc.edu.cn. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL

@      IN      NS      localhost.
@      IN      A       127.0.0.1
@      IN      AAAA    ::1
example.sec.cuc.edu.cn.  IN       A      192.168.0.175
EOF

# restart the service to apply the latest config
systemctl restart bind9