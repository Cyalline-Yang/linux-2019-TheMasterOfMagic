#!/usr/bin/env bash

set -e

declare server
[[ "${server}" != "" ]] || exit_because "\${server} needs to be specified"

cd "$(dirname "$0")" || (exit 0)
source ../functions.sh
[[ "$(whoami)" == root ]] || exit_because "root previledge is required"

# make sure nfs-common is installed
apt-get install -y nfs-common &> /dev/null || exit_because "failed to install nfs-common"

# make sure sharing directories exist and are mounted
## umount and rm if necesssary
##################################
## 32: no mount point specified ##
## 64: not mounted              ##
##################################
umount /var/nfs/* &> /dev/null || [[ $? -eq 32 || $? -eq 64 ]] || exit_because "failed to umount existing mount point"
rm -rf /var/nfs/*
## mkdir and mount
mkdir -p /var/nfs/readonly_dir
mkdir -p /var/nfs/writable_dir
mount -o nfsvers=3 "${server}":/var/nfs/readonly_dir /var/nfs/readonly_dir &> /dev/null || exit_because "failed to mount the readonly directory"
mount -o nfsvers=3 "${server}":/var/nfs/writable_dir /var/nfs/writable_dir &> /dev/null || exit_because "failed to mount the writable directory"

# test
## readonly part
cd /var/nfs/readonly_dir &> /dev/null || exit_because "failed to cd the readonly_dir"
[[ "$(ls readonly_file 2> /dev/null)" == readonly_file ]] || exit_because "failed to do ls in the readonly_dir"
cat readonly_file &> /dev/null || exit_because "failed to read content of the readonly_file"
touch new_file 2> /dev/null && exit_because "failed to prevent writing to the readonly_dir"
## writable part
cd /var/nfs/writable_dir &> /dev/null || exit_because "failed to cd the writable_dir"
[[ "$(ls writable_file 2> /dev/null)" == writable_file ]] || exit_because "failed to do ls in the writable_dir"
cat writable_file &> /dev/null || exit_because "failed to read content of the writable_file"
touch new_file 2> /dev/null || exit_because "failed to create file in the writable_dir"
echo >> writable_file || exit_because "failed to write into the writable_file"