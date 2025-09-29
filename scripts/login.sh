if [[ -e ~/.aws/credentials ]] && grep 'if this file is modified' ~/.aws/credentials >/dev/null; then
  echo -n "" > ~/.aws/credentials
fi

if [[ -f $HOME/.asdf/asdf.sh ]]; then
  . $HOME/.asdf/asdf.sh
elif asdf > /dev/null 2>&1; then
  export PATH="$HOME/.asdf/shims:$PATH"
fi

if [[ -f ~/.local/bin/mise ]]; then
  eval "$(~/.local/bin/mise activate $(basename $SHELL))"
fi

dir=$(dirname $0)
source $dir/environment.sh
source $dir/asdf-helpers.sh
source $dir/terraform-helpers.sh
source $dir/with-aws-role.sh

$dir/show-uptime.sh

eval "$(direnv hook $(basename $SHELL))"
