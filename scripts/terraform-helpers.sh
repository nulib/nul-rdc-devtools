TF=$(which terraform)
# if which tofu &> /dev/null; then
# 	TF=$(which tofu)
# fi

function aws_environment () {
	cut -d "-" -f 1 <<< $AWS_PROFILE
}

function tfwhich() {
	echo $TF
}

function tfselect () {
	export AWS_PROFILE=$1-admin
	aws sts get-caller-identity --no-cli-pager > /dev/null 2>&1 || aws sso login
	$TF workspace select $1 || $TF workspace new $1
}

function tfconsole () {
	$TF console -var-file $(aws_environment).tfvars
}

function tfplan () {
	$TF plan -var-file $(aws_environment).tfvars -out $(aws_environment).plan
}

function tfapply () {
	$TF apply $(aws_environment).plan
}
