#!/usr/bin/env bash

cd "$(dirname "$0")" || (exit 0)
source ../functions.sh

declare server
[[ "${server}" != "" ]] || exit_because "\${server} needs to be specified"
[[ "$(whoami)" == root ]] || exit_because "root previledge is required"

# template command
function anon_do() {
    # do the specified command as anonymous users
    lftp -e "$1;exit" "${server}" -u anonymous,
}
function norm_do() {
    # do the specified command as normal users
    lftp -e "$1;exit" "${server}" -u ftp_user,ftp_pswd
}

# make sure lftp is installed
apt-get install -y lftp &> /dev/null || exit_because "failed to install lftp"

# disable ssl certificate verification
echo "set ssl:verify-certificate false" > /root/.lftprc

# test
## Part 1 - about anonymous user
[[ "$(anon_do cls | grep welcome_file_for_anon)" == welcome_file_for_anon ]] || exit_because "incorrect output of cls as anonymous user"
anon_do "mkdir impossible_dir" &> /dev/null && exit_because "failed to prevent anonymous user from writing"
## Part 2 - about normal user
[[ "$(norm_do cls | grep welcome_file_for_norm)" == welcome_file_for_norm ]] || exit_because "incorrect output of cls as normal user"
norm_do "mkdir new_dir" &> /dev/null || exit_because "failed to create a new directory as normal user"
## Part 3 was tested on the server side
## Part 4 - no exceed default root directory
[[ "$(norm_do ls)" == "$(norm_do ls\ ..)" ]] || exit_because "failed to prevent normal user from exceeding to outer directory"
## Part 5 - anonymous from white list(not tested)
## Part 5 - ftps(not tested)