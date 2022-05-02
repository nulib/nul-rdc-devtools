instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

export AWS_DEV_ENVIRONMENT=true
export DEV_ENV=dev
export DEV_PREFIX=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$instance_id" "Name=key,Values=Owner" | jq -r '.Tags[].Value')
export ERL_AFLAGS="-kernel shell_history enabled"
export SECRETS_PATH=dev-environment
export PATH=$HOME/.nul-rdc-devtools/bin:$PATH
