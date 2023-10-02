if [[ -e ~/.aws/credentials ]] && grep 'if this file is modified' ~/.aws/credentials >/dev/null; then
  echo -n "" > ~/.aws/credentials
fi

dir=$(dirname $0)
source $dir/environment.sh
source $dir/asdf-helpers.sh
source $dir/terraform-helpers.sh

$dir/show-uptime.sh

. $HOME/.asdf/asdf.sh
eval "$(direnv hook $(basename $SHELL))"
