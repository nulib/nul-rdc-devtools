#!/bin/bash

ok=14400
warn=28800

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NOCOLOR='\033[0m'

function pluralize() {
  echo -n "$1 $2"
  if (( $1 >= 2 )); then echo -n "s"; fi
}

function secondsToHumanReadable() {
    local seconds=$1
    local days=$((seconds / 86400))
    seconds=$((seconds % 86400))
    local hours=$((seconds / 3600))
    seconds=$((seconds % 3600))
    local minutes=$((seconds / 60))
    seconds=$((seconds % 60))

    local space=0

    if (( days >= 1 )); then
      space=1
      pluralize $days "day"
    fi

    if (( hours >= 1 )); then
      if (( space == 1 )); then echo -n " "; else space=1; fi
      pluralize $hours "hour"
    fi

    if (( minutes >= 1 )); then
      if (( space == 1 )); then echo -n " "; else space=1; fi
      pluralize $minutes "minute"
    fi

    if (( seconds >= 1 )); then
      if (( space == 1 )); then echo -n " "; else space=1; fi
      pluralize $seconds "second"
    fi
}


running_seconds=$(awk '{ print $1 }' < /proc/uptime | cut -d . -f 1)
running_human=$(secondsToHumanReadable "$running_seconds")

if (( running_seconds > $warn )); then
  COLOR=$RED
elif (( running_seconds > $ok )); then
  COLOR=$YELLOW
else
  COLOR=$GREEN
fi

echo -e "System up for ${COLOR}${running_human}${NOCOLOR}"

procs=()
if (pgrep -u ec2-user -f ".vscod(e|ium)-server(-insiders)?/bin/" > /dev/null); then procs+=("vscode"); fi
if (pgrep -u ec2-user -f "tmux" > /dev/null); then procs+=("tmux"); fi
if [[ -f /home/ec2-user/.keep-alive ]]; then procs+=("~/.keep-alive"); fi
if [[ -z $procs ]]; then procs=("none"); fi

printf -v display_procs '%s, ' "${procs[@]}"
echo -e "Conditions preventing shutdown: ${COLOR}${display_procs%, }${NOCOLOR}"
