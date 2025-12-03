#!/bin/bash

COMMAND=$1
shift
source $DEVTOOLS_HOME/scripts/imdsv2.sh
source $DEVTOOLS_HOME/ide/autoshutdown-configuration

if ! [[ $SHUTDOWN_TIMEOUT =~ ^[0-9]*$ ]]; then
    echo "shutdown timeout is invalid"
    exit 1
fi
INSTANCE_ID=$(imdsv2 /latest/meta-data/instance-id)
SHUTDOWN_COMMAND="/usr/local/bin/aws ec2 stop-instances --instance-ids $INSTANCE_ID >>/var/log/ec2-shutdown.log 2>&1"

find_shutdown_tasks() {
    tasks=$(sudo atq | awk '{ print $1 }')
    for task in $tasks; do
        if $(sudo at -c $task | grep "$SHUTDOWN_COMMAND" >/dev/null); then
            echo $task
        fi
    done
}

case $COMMAND in
    schedule)
        echo "Scheduling shutdown in $SHUTDOWN_TIMEOUT minutes." >&2
        at now + $SHUTDOWN_TIMEOUT minutes <<< "wall 'System is going down for poweroff NOW' && $SHUTDOWN_COMMAND" >/dev/null 2>&1
        ;;
    cancel)
        echo "Canceling shutdown." >&2
        for task in $(find_shutdown_tasks); do
            atrm $task
        done
        ;;
    check)
        if [[ -n $(find_shutdown_tasks) ]]; then
            exit 0
        else
            exit 1
        fi
        ;;
    notify)
        for task in $(find_shutdown_tasks); do
            shutdown_time=$(atq $task | awk '{ print $2,$3,$4,$5,$6 }')
            wall "Shutdown scheduled for $shutdown_time UTC"
        done
        ;;
    *)
        echo "Usage: ec2-shutdown.sh <schedule|cancel|check>"
        ;;
esac
