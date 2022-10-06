# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

#!/bin/bash
set -euo pipefail
CONFIG=$(cat $(dirname $0)/autoshutdown-configuration)
SHUTDOWN_TIMEOUT=${CONFIG#*=}
if ! [[ $SHUTDOWN_TIMEOUT =~ ^[0-9]*$ ]]; then
    echo "shutdown timeout is invalid"
    exit 1
fi
is_shutting_down() {
    is_shutting_down_ubuntu &> /dev/null || is_shutting_down_al1 &> /dev/null || is_shutting_down_al2 &> /dev/null
}
is_shutting_down_ubuntu() {
    local TIMEOUT
    TIMEOUT=$(busctl get-property org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager ScheduledShutdown)
    if [ "$?" -ne "0" ]; then
        return 1
    fi
    if [ "$(echo $TIMEOUT | awk "{print \$3}")" == "0" ]; then
        return 1
    else
        return 0
    fi
}
is_shutting_down_al1() {
    pgrep shutdown
}
is_shutting_down_al2() {
    local FILE
    FILE=/run/systemd/shutdown/scheduled
    if [[ -f "$FILE" ]]; then
        return 0
    else
        return 1
    fi
}
is_vfs_connected() {
    pgrep -f vfs-worker >/dev/null
}

is_vscode_connected() {
    # pgrep -u ec2-user -f .vscode-server/bin/ >/dev/null
    VSCODE_PIDS=$(pgrep -u ec2-user -f .vscode-server/bin/ | tr "\n" ',')
    if [[ -n $VSCODE_PIDS ]] && /usr/sbin/lsof -p $VSCODE_PIDS | grep '(LISTEN)' >/dev/null; then
        return 0
    else
        return 1
    fi
}

keepalive_file_exists() {
    local FILE
    FILE=/home/ec2-user/.keep-alive
    if [[ -f "$FILE" ]]; then
        return 0
    else
        return 1
    fi
}

prevent_shutddown() {
    if [[ ! $SHUTDOWN_TIMEOUT =~ ^[0-9]+$ ]]; then
        echo "stop-if-inactive.sh: No timeout set." >&2
        return 0
    elif keepalive_file_exists; then
        echo "stop-if-inactive.sh: ~/.keep-alive detected." >&2
        return 0
    elif is_vscode_connected; then
        echo "stop-if-inactive.sh: VS Code is connected." >&2
        return 0
    elif is_vfs_connected; then
        echo "stop-if-inactive.sh: Cloud9 VFS is connected." >&2
        return 0
    else
        return 1
    fi
}

if is_shutting_down; then
    if prevent_shutddown; then
        echo "stop-if-inactive.sh: Canceling shutdown." >&2
        sudo shutdown -c
    fi
else
    if ! prevent_shutddown; then
        echo "stop-if-inactive.sh: Scheduling shutdown in $SHUTDOWN_TIMEOUT minutes." >&2
        sudo shutdown -h $SHUTDOWN_TIMEOUT
    fi
fi