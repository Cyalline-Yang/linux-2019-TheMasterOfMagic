#!/usr/bin/env bash

cd "$(dirname "$0")" || return 0
source ../functions.sh
[[ "$(whoami)" == root ]] || exit_because "root previledge is required"

warn "not implemented"