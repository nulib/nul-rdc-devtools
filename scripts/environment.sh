instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
secrets=$(aws secretsmanager get-secret-value --secret-id dev-environment/config/meadow --query SecretString --output text)

openssl x509 -in $HOME/.dev_cert/dev.rdc.cert.pem -noout -checkend 0
cert_expiring=$?

if [[ ! -e $HOME/.dev_cert/dev.rdc.cert.pem || $cert_expiring == 1 ]]; then
  ssl_secret=$(aws secretsmanager get-secret-value --secret-id dev-environment/config/wildcard_ssl --query SecretString --output text)
  mkdir -p $HOME/.dev_cert
  jq -r .certificate <<< $ssl_secret > $HOME/.dev_cert/dev.rdc.cert.pem
  jq -r .key <<< $ssl_secret > $HOME/.dev_cert/dev.rdc.key.pem
fi

export AWS_DEV_ENVIRONMENT=true
export AWS_REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')
export DEV_ENV=dev
export DEV_PREFIX=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$instance_id" "Name=key,Values=Owner" | jq -r '.Tags[].Value')
export ERL_AFLAGS="-kernel shell_history enabled"
export NUSSO_API_KEY=$(jq -r .nusso.api_key <<< $secrets)
export NUSSO_BASE_URL=$(jq -r .nusso.base_url <<< $secrets)
export SECRET_KEY_BASE=$(openssl rand -hex 32)
export SECRETS_PATH=dev-environment/config
export SHARED_BUCKET=nul-shared-prod-staging
export SSL_CERT=$HOME/.dev_cert/dev.rdc.cert.pem
export SSL_KEY=$HOME/.dev_cert/dev.rdc.key.pem
export PATH=$HOME/.nul-rdc-devtools/bin:$PATH
