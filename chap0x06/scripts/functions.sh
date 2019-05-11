#!/usr/bin/env bash

function info() {
    echo "[INFO] $0: $1"
}

function warn() {
    echo "[WARN] $0: $1"
}

function error() {
    echo "[ERRO] $0: $1" >&2
}

function exit_because() {
    error "$1"
    error "exit 1"
    exit 1
}
