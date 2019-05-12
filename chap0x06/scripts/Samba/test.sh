#!/usr/bin/env bash

set -e

declare server
[[ "${server}" != "" ]] || exit_because "\${server} needs to be specified"

cd "$(dirname "$0")" || (exit 0)
source ../functions.sh
[[ "$(whoami)" == root ]] || exit_because "root previledge is required"

warn "not implemented"