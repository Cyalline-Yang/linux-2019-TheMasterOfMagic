#!/usr/bin/env bash

set -e

declare server
[[ "${server}" != "" ]] || exit_because "\${server} needs to be specified"

cd "$(dirname "$0")" || (exit 0)
source ../functions.sh
[[ "$(whoami)" == root ]] || exit_because "root previledge is required"

[[ "$(dig +short @${server} example.sec.cuc.edu.cn 2> /dev/null)" == "192.168.0.175" ]] || exit_because "dns answer is not correct"