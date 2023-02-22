function aws_environment () {
	cut -d "-" -f 1 <<< $AWS_PROFILE
}

function tfselect () {
	export AWS_PROFILE=$1-admin
	aws sts get-caller-identity --no-cli-pager > /dev/null 2>&1 || aws sso login
	terraform workspace select $1 || terraform workspace new $1
}

function tfplan () {
	terraform plan -var-file $(aws_environment).tfvars -out $(aws_environment).plan
}

function tfapply () {
	terraform apply $(aws_environment).plan
}
