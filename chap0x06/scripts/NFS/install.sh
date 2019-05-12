#!/usr/bin/env bash

set -e

cd "$(dirname "$0")" || (exit 0)
source ../functions.sh
[[ "$(whoami)" == root ]] || exit_because "root previledge is required"

# make sure nfs-kernel-server is installed
apt-get install -y nfs-kernel-server &> /dev/null || exit_because "failed to install nfs-kernel-server"

# make sure sharing directories and files exist
mkdir -p /var/nfs/readonly_dir
echo > /var/nfs/readonly_dir/readonly_file
mkdir -p /var/nfs/writable_dir
echo > /var/nfs/writable_dir/writable_file
chmod -R 777 /var/nfs/writable_dir

# make sure sharing dierctories and files are exported
tee /etc/exports > /dev/null << EOF
/var/nfs/readonly_dir *(ro,sync,no_subtree_check,insecure)
/var/nfs/writable_dir *(rw,sync,no_subtree_check,insecure)
EOF

# restart the service to apply
systemctl restart nfs-server