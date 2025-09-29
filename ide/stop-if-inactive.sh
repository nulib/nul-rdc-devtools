# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

#!/bin/bash
set -euo pipefail
source $(dirname $0)/../scripts/imdsv2.sh
SHUTDOWN_SCRIPT="$(dirname $0)/ec2-shutdown.sh"

is_shutting_down() {
    $SHUTDOWN_SCRIPT check
}

is_vscode_connected() {
    OLD_PATH=$PATH
    PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
    PGREP=$(which pgrep)
    LSOF=$(which lsof)
    PATH=$OLD_PATH
    VSCODE_PIDS=$($PGREP -u ec2-user -f ".(cursor|vscod(e|ium))-server(-insiders)?/(bin|cli/servers)/" | tr "\n" ',')
    if [[ -n $VSCODE_PIDS ]] && $LSOF -p $VSCODE_PIDS 2>/dev/null | grep '(LISTEN)' >/dev/null; then
        return 0
    else
        return 1
    fi
}

instance_state() {
    instance_id=$(imdsv2 latest/meta-data/instance-id)
    /usr/local/bin/aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[*].Instances[*].State.Name' --output text --no-cli-pager
}

is_ssm_session_active() {
    instance_id=$(imdsv2 latest/meta-data/instance-id)
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
    if file_exists /tmp/maintenance; then
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

CURRENT_STATE=$(instance_state)
if [[ $CURRENT_STATE != "running" ]]; then
    echo "stop-if-inactive.sh: System in '$CURRENT_STATE' state"
elif is_shutting_down; then
    if prevent_shutddown; then
        echo -n "stop-if-inactive.sh: " >&2
        $SHUTDOWN_SCRIPT cancel
        wall "System shutdown canceled."
    fi
else
    if ! prevent_shutddown; then
        echo -n "stop-if-inactive.sh: " >&2
        $SHUTDOWN_SCRIPT schedule
        $SHUTDOWN_SCRIPT notify
    fi
fi
touch $HOME/.last_inactive_check
