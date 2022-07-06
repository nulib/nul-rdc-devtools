#!/bin/bash

region=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')
instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
profile=$1
role_arn=$2
net_id=$(aws ec2 describe-tags --filters Name=resource-id,Values=$instance_id --query "Tags[?Key=='NetID'].Value" --output text)

cat >> ~/.aws/config <<__EOC__

[profile $profile]
region = $region
output = json
credential_process = aws-adfs login --region=$region --role-arn=$role_arn --adfs-host=ads-fed.northwestern.edu --stdout
adfs_config.ssl_verification = True
adfs_config.role_arn = $role_arn
adfs_config.adfs_host = ads-fed.northwestern.edu
adfs_config.session_duration = 3600
adfs_config.provider_id = urn:amazon:webservices
adfs_config.sspi = False
adfs_config.u2f_trigger_default = True
adfs_config.adfs_user = ads\\$net_id
__EOC__
