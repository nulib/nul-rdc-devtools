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
    shutdown --show 2> >(grep "^Shutdown scheduled for " > /dev/null)
}

is_vscode_connected() {
    OLD_PATH=$PATH
    PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
    PGREP=$(which pgrep)
    LSOF=$(which lsof)
    PATH=$OLD_PATH
    VSCODE_PIDS=$($PGREP -u ec2-user -f ".(cursor|vscod(e|ium))-server(-insiders)?/bin/" | tr "\n" ',')
    if [[ -n $VSCODE_PIDS ]] && $LSOF -p $VSCODE_PIDS 2>/dev/null | grep '(LISTEN)' >/dev/null; then
        return 0
    else
        return 1
    fi
}

is_ssm_session_active() {
    instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
    session_count=$(/usr/local/bin/aws ssm describe-sessions --state Active --filter key=Target,value=$instance_id | jq '.Sessions | length')
    if [[ $session_count -gt 0 ]]; then
        return 0
    else
        return 1
    fi
}

file_exists() {
    if [[ -f "$1" ]]; then
        return 0
    else
        return 1
    fi
}

is_tmux_session_active() {
    PGREP=$(which pgrep)
    $PGREP tmux > /dev/null
    return $?
}

prevent_shutddown() {
    if [[ ! $SHUTDOWN_TIMEOUT =~ ^[0-9]+$ ]]; then
        echo "stop-if-inactive.sh: No timeout set." >&2
        return 0
    elif file_exists /tmp/maintenance; then
        echo "stop-if-inactive.sh: system maintenance in progress." >&2
        return 0
    elif file_exists /home/ec2-user/.keep-alive; then
        echo "stop-if-inactive.sh: ~/.keep-alive detected." >&2
        return 0
    elif is_tmux_session_active; then
        echo "stop-if-inactive.sh: tmux session active" >&2
        return 0
    elif is_vscode_connected && is_ssm_session_active; then
        echo "stop-if-inactive.sh: VS Code is connected." >&2
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
touch $HOME/.last_inactive_check
