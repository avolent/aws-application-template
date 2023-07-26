<h1 align="center">AWS Application Template</h1>

Repository for a simple AWS serverless web application which can be deployed via Terraform.

## Repository Structure

- **.github/**: All github related settings.
  - **template_workflows/**: Template workflow files you can use for deploying.
  - **workflows/**: This repositories workflow files for linting and validating the infrastructure.
- **infrastructure/**: Infrastructure files in terraform.
- **Makefile**: Local and Pipeline commands.

## Environment Variables

```bash
export AWS_REGION=ap-southeast-2
export APP_ENV=dev
export STATE_FILE_BUCKET=Your-tf-state-bucket
```

## Makefile Commands

- **fmt**: Terraform fmt
- **init**: Terraform init (Backend is dependent on environment variables)
- **validate**: Terraform validate
- **plan**: Terraform Plan (no input, outputs "tfplan", var git_repo)
- **apply** Terraform Apply (no input, auto approve, applies "tfplan")
