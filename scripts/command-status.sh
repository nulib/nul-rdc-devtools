white="\033[0m"
red="\033[31m"
green="\033[32m"
yellow="\033[33m"

start_status() {
  _status_msg=$1
  if [[ -z "$CLAUDECODE" ]]; then
    echo -en "${yellow}…${white} ${_status_msg}\r"
  fi
}

stop_status() {
  if [[ -z "$CLAUDECODE" ]]; then
    if [ $? -eq 0 ]; then
      echo -e "${green}✓${white} ${_status_msg}"
    else
      echo -e "${red}✗${white} ${_status_msg}"
    fi
  fi
  unset _status_msg
}
