INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
eval $(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" | jq -r '.Tags[] | .["Key"] = (.Key | ascii_upcase | gsub("[^A-Z0-9_]"; "_")) | "INSTANCE_TAG_\(.Key)=\(.Value)"')
