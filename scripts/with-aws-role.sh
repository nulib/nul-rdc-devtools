with-aws-role() {
  ROLE=$(curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/)
  CREDENTIALS=$(curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/$ROLE)
  AWS_ACCESS_KEY_ID=$(jq -r '.AccessKeyId' <<< $CREDENTIALS) \
  AWS_SECRET_ACCESS_KEY=$(jq -r '.SecretAccessKey' <<< $CREDENTIALS) \
  AWS_SESSION_TOKEN=$(jq -r '.Token' <<< $CREDENTIALS) \
  $@
}