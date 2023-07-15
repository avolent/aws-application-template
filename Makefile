STATE_FILE_BUCKET ?= avolent-terraform-state
GIT_REPO ?= $(shell basename `git rev-parse --show-toplevel`)

# Terraform
fmt:
	cd infrastructure/ && terraform fmt -check

init:
	cd infrastructure/ && terraform init \
		-backend-config="bucket=${STATE_FILE_BUCKET}" \
		-backend-config="key=${GIT_REPO}.tfstate" \
		-backend-config="region=${AWS_REGION}"

validate:
	cd infrastructure/ && terraform validate -no-color

plan:
	cd infrastructure/ && terraform plan \
		-no-color \
		-out=tfplan \
		-input=false \
		-var="git_repo=${GIT_REPO}"

apply:
	cd infrastructure/ && terraform apply \
		-no-color \
		-input=false \
		-auto-approve \
		"tfplan"

