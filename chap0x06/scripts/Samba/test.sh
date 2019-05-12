#!/usr/bin/env bash

set -e

cd "$(dirname "$0")" || (exit 0)
source ../functions.sh

declare server
[[ "${server}" != "" ]] || exit_because "\${server} needs to be specified"
[[ "$(whoami)" == root ]] || exit_because "root previledge is required"

# make sure smbclient is installed
apt-get install -y smbclient &> /dev/null || exit_because "failed to install smbclient"

# test
## normal user part
smbclient -c ls //"${server}"/norm -U samba_user%samba_password 2>/dev/null | grep welcome_file_for_norm &> /dev/null || exit_because "ls as normal user in smbclient failed or the result is not correct"
## anonymous user part
smbclient -c ls //"${server}"/anon -U % 2>/dev/null | grep welcome_file_for_anon &> /dev/null || exit_because "ls as anonymous user in smbclient failed or the result is not correct"
## get the whole directory
smbclient -c "lcd /tmp; prompt; recurse; mget *" //"${server}"/anon -U % &> /dev/null || exit_because "failed to get the whole directory"
[[ "$(ls /tmp/welcome_file_for_anon)" == "/tmp/welcome_file_for_anon" ]] || exit_because "got the whole directory but the result is not correct"