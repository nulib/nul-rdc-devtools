. $DEVTOOLS_HOME/scripts/imdsv2.sh
INSTANCE_ID=$(imdsv2 latest/meta-data/instance-id)

for tag in $(imdsv2 latest/meta-data/tags/instance/); do
  key=$(echo $tag | tr -d '[:space:]' | tr '[:lower:]' '[:upper:]' | tr -c '[:alnum:]' '_')
  value=$(imdsv2 latest/meta-data/tags/instance/$tag)
  export INSTANCE_TAG_$key=$value
done
