. $(dirname $0)/imdsv2.sh
INSTANCE_ID=$(imdsv2 latest/meta-data/instance-id)
eval $(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" | jq -r '.Tags[] | .["Key"] = (.Key | ascii_upcase | gsub("[^A-Z0-9_]"; "_")) | "INSTANCE_TAG_\(.Key)=\"\(.Value)\""')
