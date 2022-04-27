source ./environment.sh
source ./asdf-helpers.sh

. $HOME/.asdf/asdf.sh
if [[ -e ~/.aws/credentials ]]; then
  rm -f ~/.aws/credentials
fi
