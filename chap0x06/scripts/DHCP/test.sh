#!/usr/bin/env bash

set -e

cd "$(dirname "$0")" || (exit 0)
source ../functions.sh

declare server
[[ "${server}" != "" ]] || exit_because "\${server} needs to be specified"
[[ "$(whoami)" == root ]] || exit_because "root previledge is required"
