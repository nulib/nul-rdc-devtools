. $(dirname -- $BASH_SOURCE[0])/imdsv2.sh

with-aws-role() {
  ROLE=$(imdsv2 latest/meta-data/iam/security-credentials/)
  CREDENTIALS=$(imdsv2 latest/meta-data/iam/security-credentials/$ROLE)
  AWS_ACCESS_KEY_ID=$(jq -r '.AccessKeyId' <<< $CREDENTIALS) \
  AWS_SECRET_ACCESS_KEY=$(jq -r '.SecretAccessKey' <<< $CREDENTIALS) \
  AWS_SESSION_TOKEN=$(jq -r '.Token' <<< $CREDENTIALS) \
  $@
}