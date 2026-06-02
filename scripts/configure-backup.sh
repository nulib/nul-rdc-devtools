. $DEVTOOLS_HOME/scripts/imdsv2.sh
. $DEVTOOLS_HOME/scripts/instance-info.sh
BACKUP_CONFIG=$(aws secretsmanager get-secret-value --secret-id "dev-environment/terraform/common" --query "SecretString" --output text)
BACKUP_BUCKET=$(jq -r .shared_bucket_arn <<< $BACKUP_CONFIG | rev | cut -d ':' -f1 | rev)
export RESTIC_REPOSITORY="s3:s3.amazonaws.com/$BACKUP_BUCKET/ide-backups/$DEV_PREFIX"
export RESTIC_PASSWORD=$(jq -r .backup_key <<< $BACKUP_CONFIG)
