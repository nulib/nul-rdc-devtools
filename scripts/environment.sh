. $(dirname $0)/instance-info.sh
secrets=$(aws secretsmanager get-secret-value --secret-id dev-environment/config/meadow --query SecretString --output text)

if [[ ! -e $HOME/.dev_cert/dev.rdc.cert.pem ]] || ! openssl x509 -in $HOME/.dev_cert/dev.rdc.cert.pem -noout -checkend 0 >/dev/null; then
  ssl_secret=$(aws secretsmanager get-secret-value --secret-id dev-environment/config/wildcard_ssl --query SecretString --output text)
  mkdir -p $HOME/.dev_cert
  jq -r .certificate <<< $ssl_secret > $HOME/.dev_cert/dev.rdc.cert.pem
  jq -r .key <<< $ssl_secret > $HOME/.dev_cert/dev.rdc.key.pem
fi

if [[ ! -e $HOME/environment/miscellany ]]; then
  git clone git@github.com:nulib/miscellany.git $HOME/environment/miscellany
fi

RETURN=$PWD
cd $HOME/environment/miscellany
git remote update origin >/dev/null 2>&1
if git status -uno | grep behind >/dev/null 2>&1; then
  git pull origin >/dev/null 2>&1
fi
source ./secrets/dev_environment.sh >/dev/null 2>&1
cd $RETURN

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

BACKUP_CONFIG=$(aws secretsmanager get-secret-value --secret-id "dev-environment/terraform/common" --query "SecretString" --output text)
BACKUP_BUCKET=$(jq -r .shared_bucket_arn <<< $BACKUP_CONFIG | rev | cut -d ':' -f1 | rev)
export RESTIC_REPOSITORY="s3:s3.amazonaws.com/$BACKUP_BUCKET/ide-backups/$DEV_PREFIX"
export RESTIC_PASSWORD=$(jq -r .backup_key <<< $BACKUP_CONFIG)
