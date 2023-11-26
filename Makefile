STATE_FILE_BUCKET ?= avolent-terraform-state
AWS_REGION ?= ap-southeast-2
APP_ENV ?= dev
GIT_REPO ?= $(shell basename `git rev-parse --show-toplevel`)

# Terraform
fmt:
	cd infrastructure/ && terraform fmt -check

init:
	cd infrastructure/ && terraform init \
		-backend-config="bucket=${STATE_FILE_BUCKET}" \
		-backend-config="key=${GIT_REPO}-${APP_ENV}.tfstate" \
		-backend-config="region=${AWS_REGION}"

validate:
	cd infrastructure/ && terraform validate -no-color

plan:
	cd infrastructure/ && terraform plan \
		-no-color \
		-out=tfplan \
		-input=false \
		-var="git_repo=${GIT_REPO}" \
		-var="app_env=${APP_ENV}"

apply:
	cd infrastructure/ && terraform apply \
		-no-color \
		-input=false \
		-auto-approve \
		"tfplan"

plan_destroy:
	cd infrastructure/ && terraform plan \
		-destroy \
		-no-color \
		-out=tfplan_destroy \
		-input=false \
		-var="git_repo=${GIT_REPO}" \
		-var="app_env=${APP_ENV}"

apply_destroy:
	cd infrastructure/ && terraform apply \
		-no-color \
		-input=false \
		-auto-approve \
		"tfplan_destroy"

checkov:
	cd infrastructure/ && checkov -d .
