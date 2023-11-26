data "aws_caller_identity" "current" {}

data "aws_kms_key" "default" {
  key_id = "alias/default"
}
