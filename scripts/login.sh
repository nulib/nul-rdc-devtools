export DEVTOOLS_HOME="$HOME/.nul-rdc-devtools"

if [[ -e ~/.aws/credentials ]] && grep 'if this file is modified' ~/.aws/credentials >/dev/null; then
  echo -n "" > ~/.aws/credentials
fi

if [[ -f $HOME/.asdf/asdf.sh ]]; then
  . $HOME/.asdf/asdf.sh
elif asdf > /dev/null 2>&1; then
  export PATH="$HOME/.asdf/shims:$PATH"
fi

if [[ -f ~/.local/bin/mise ]]; then
  if ! typeset -f mise > /dev/null; then
    eval "$(~/.local/bin/mise activate $(basename $SHELL))"
  fi
fi

source $DEVTOOLS_HOME/scripts/environment.sh
source $DEVTOOLS_HOME/scripts/asdf-helpers.sh
source $DEVTOOLS_HOME/scripts/terraform-helpers.sh
source $DEVTOOLS_HOME/scripts/with-aws-role.sh

$DEVTOOLS_HOME/scripts/show-uptime.sh

eval "$(direnv hook $(basename $SHELL))"
