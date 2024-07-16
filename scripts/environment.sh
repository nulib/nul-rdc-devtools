. $(dirname $0)/instance-info.sh
. $(dirname $0)/command-status.sh

start_status "Retrieving secrets"
secrets=$(aws secretsmanager get-secret-value --secret-id dev-environment/config/meadow --query SecretString --output text)
stop_status

start_status "Retrieving developer certificate"
$(dirname $0)/../bin/refresh-dev-cert
stop_status

RETURN=$PWD
if [[ ! -e $HOME/environment/miscellany ]]; then
  start_status "Cloning nulib/miscellany"
  git clone git@github.com:nulib/miscellany.git $HOME/environment/miscellany >/dev/null 2>&1
  cd $HOME/environment/miscellany >/dev/null 2>&1
else
  start_status "Refreshing nulib/miscellany"
  cd $HOME/environment/miscellany >/dev/null 2>&1
  git remote update origin >/dev/null 2>&1
  if git status -uno | grep behind >/dev/null 2>&1; then
    git pull origin >/dev/null 2>&1
  fi
fi
stop_status
start_status "Initializing environment"
. ./secrets/dev_environment.sh >/dev/null 2>&1
cd $RETURN 2>&1
stop_status

export AWS_DEV_ENVIRONMENT=true
export AWS_REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')
export AWS_SDK_LOAD_CONFIG=1
export DEV_ENV=dev
export DEV_PREFIX=$INSTANCE_TAG_OWNER
export ERL_AFLAGS="-kernel shell_history enabled"
#export NUSSO_API_KEY=$(jq -r .nusso.api_key <<< $secrets)
#export NUSSO_BASE_URL=$(jq -r .nusso.base_url <<< $secrets)
export SECRET_KEY_BASE=$(openssl rand -hex 32)
export SECRETS_PATH=dev-environment/config
export SHARED_BUCKET=nul-shared-prod-staging
export SSL_CERT=$HOME/.dev_cert/dev.rdc.cert.pem
export SSL_KEY=$HOME/.dev_cert/dev.rdc.key.pem
if ! grep .nul-rdc-devtools/bin <<< $PATH >/dev/null 2>&1; then
  export PATH=$HOME/.nul-rdc-devtools/bin:$PATH
fi
export JWT_TOKEN_SECRET=$SECRET_KEY_BASE

start_status "Configuring backup"
BACKUP_CONFIG=$(aws secretsmanager get-secret-value --secret-id "dev-environment/terraform/common" --query "SecretString" --output text)
BACKUP_BUCKET=$(jq -r .shared_bucket_arn <<< $BACKUP_CONFIG | rev | cut -d ':' -f1 | rev)
echo -e "${green}✓${white}\n"
export RESTIC_REPOSITORY="s3:s3.amazonaws.com/$BACKUP_BUCKET/ide-backups/$DEV_PREFIX"
export RESTIC_PASSWORD=$(jq -r .backup_key <<< $BACKUP_CONFIG)
