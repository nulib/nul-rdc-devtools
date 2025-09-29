imdsv2() {
  IMDS_PATH=$1
  TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 300")
  curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/$IMDS_PATH
}
