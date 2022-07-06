function aws_environment () {
	cut -d "-" -f 1 <<< $AWS_PROFILE
}

function tfselect () {
	export AWS_PROFILE=$1-admin
	aws-adfs login --profile $AWS_PROFILE
	terraform workspace select $1 || terraform workspace new $1
}

function tfplan () {
	terraform plan -var-file $(aws_environment).tfvars -out $(aws_environment).plan
}

function tfapply () {
	terraform apply $(aws_environment).plan
}
