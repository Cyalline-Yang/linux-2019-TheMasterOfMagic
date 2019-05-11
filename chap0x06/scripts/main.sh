#!/usr/bin/env bash

cd "$(dirname "$0")" || return 0
source ./functions.sh
[[ "$(whoami)" == root ]] || exit_because "root previledge is required"

# do apt-get update once and forever
apt-get update || exit_because "failed to apt-get update"

# iteratively install and test each service
rc=0
read -ra services < <(echo FTP NFS DHCP DNS Samba)
for service in "${services[@]}"
do
    install_file="${service}"/install.sh
    if ! [[ -f "${install_file}" ]]
    then
        error "install.sh for ${service} not found"
        rc=1
    else
        info "installing ${service}"
        if ! ${install_file}
        then
            error "failed to install ${service}"
            rc=1
        else
            info "installed ${service}"
            test_file="${service}"/test.sh
            if ! [[ -f "${test_file}" ]]
            then
                error "test.sh for ${service} not found"
                rc=1
            else
                info "testing ${service}"
                if ! ${test_file}
                then
                    error "failed to test ${service}"
                    rc=1
                else
                    info "tested ${service}"
                fi
            fi
        fi
    fi
done

if [[ "${rc}" -eq 1 ]]
then
    echo "exit 1 due to some previous error(s)"
fi
exit "${rc}"