TF=$(which terraform)
# if which tofu &> /dev/null; then
# 	TF=$(which tofu)
# fi

function aws_environment () {
	cut -d "-" -f 1 <<< $AWS_PROFILE
}

function workspace () {
	$TF workspace show
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
	echo "==> $(basename $TF) console -var-file $(workspace).tfvars"
	$TF console -var-file $(workspace).tfvars
}

function tfplan () {
	echo "==> $(basename $TF) plan -var-file $(workspace).tfvars -out $(workspace).plan"
	$TF plan -var-file $(workspace).tfvars -out $(workspace).plan
}

function tfapply () {
	echo "==> $(basename $TF) apply $(workspace).plan"
	$TF apply $(workspace).plan
}
