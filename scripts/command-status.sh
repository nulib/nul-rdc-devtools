white="\033[0m"
red="\033[31m"
green="\033[32m"
yellow="\033[33m"

start_status() {
  _status_msg=$1
  [[ $- == *i* ]] && echo -en "${yellow}…${white} ${_status_msg}\r"
}

stop_status() {
  if [ $? -eq 0 ]; then
    [[ $- == *i* ]] && echo -e "${green}✓${white} ${_status_msg}"
  else
    [[ $- == *i* ]] && echo -e "${red}✗${white} ${_status_msg}"
  fi
  unset _status_msg
}
