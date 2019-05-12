#!/usr/bin/env bash

cd "$(dirname "$0")" || (exit 0)
source ./functions.sh

# check if server and client is scpecified and can be connected as root
declare server
declare client
[[ "${server}" != "" && "${client}" != "" ]] || exit_because "both \${server} and \${client} need to be specified"
info "testing ssh connections..."
ssh "${server}" "exit 0" || exit_because "cannot establish ssh connections with ${server}"
ssh "${client}" "exit 0" || exit_because "cannot establish ssh connections with ${client}"
info "ssh connections can be established."
info "testing root privilege..."
ssh "${server}" "[[ \$(whoami) == root ]]" || exit_because "root privilege is required on ${server}"
ssh "${client}" "[[ \$(whoami) == root ]]" || exit_because "root privilege is required on ${client}"
info "root privilege is guaranteed."

# do apt-get update once and forever
info "updating apt"
ssh "${server}" "apt-get update" &> /dev/null || exit_because "failed to do apt-get update on server"
ssh "${client}" "apt-get update" &> /dev/null || exit_because "failed to do apt-get update on client"
info "successfully updated apt"

# make sure script files exists on server and client
script_dir="\$HOME/scripts"
info "scp-ing script files..."
ssh "${server}" "[[ -d ${script_dir} ]] && rm -r ${script_dir}; mkdir -p ${script_dir}"
ssh "${client}" "[[ -d ${script_dir} ]] && rm -r ${script_dir}; mkdir -p ${script_dir}"
scp -r ../scripts/* "${server}":"${script_dir}" > /dev/null || exit_because "failed to scp scripts to server"
scp -r ../scripts/* "${client}":"${script_dir}" > /dev/null || exit_because "failed to scp scripts to client"
info "successfully scp-ed script files."

# iteratively install and test each service
rc=0
read -ra services < <(echo FTP NFS DNS Samba DHCP)
for service in "${services[@]}"
do
    install_file="${script_dir}"/"${service}"/install.sh
    info "installing ${service} on ${server}"
    if ! ssh "${server}" "[[ -f ${install_file} ]]"
    then
        error "${install_file} on ${server} not found"
        rc=1
    else
        if ! ssh "${server}" "${install_file}"
        then
            error "failed to install ${service} on ${server}"
            rc=1
        else
            info "successfully installed ${service} on ${server}"
            test_file="${script_dir}"/"${service}"/test.sh
            info "testing ${service} from ${client}"
            if ! ssh "${client}" "[[ -f ${test_file} ]]"
            then
                error "${test_file} on ${client} not found"
                rc=1
            else
                if ! ssh "${client}" "server=${server} ${test_file}"
                then
                    error "${service} failed to pass tests from ${client}"
                    rc=1
                else
                    info "${service} successfully passed tests from ${client}"
                fi
            fi
        fi
    fi
done

if [[ "${rc}" -eq 1 ]]
then
    echo "exit 1 due to some previous error(s)"
else
    echo "all services are successfully installed and pass tests"
fi
exit "${rc}"