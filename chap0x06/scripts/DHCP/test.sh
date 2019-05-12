#!/usr/bin/env bash

set -e

declare server
[[ "${server}" != "" ]] || exit_because "\${server} needs to be specified"

cd "$(dirname "$0")" || (exit 0)
source ../functions.sh
[[ "$(whoami)" == root ]] || exit_because "root previledge is required"

warn "not implemented"

# do not influence the original route
dhclient enp0s8 &> /dev/null || (exit 0)
route delete default gw 10.20.50.1 enp0s8