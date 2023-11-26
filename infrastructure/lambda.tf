data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda" {
  name               = "${var.app_name}_api_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/${var.app_env}/*"
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "lambda"
  output_path = "lambda_function_payload.zip"
}

resource "aws_lambda_function" "api_lambda" {
  #checkov:skip=CKV_AWS_272:Disable the need for code signing for now
  #checkov:skip=CKV_AWS_117:Do not want to implement VPC access yet
  #checkov:skip=CKV_AWS_116:Do not want to implement DLQ yet
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename                       = "lambda_function_payload.zip"
  function_name                  = "${var.app_name}_api"
  role                           = aws_iam_role.lambda.arn
  handler                        = "entrypoint.lambda_handler"
  reserved_concurrent_executions = 10

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.10"

  tracing_config {
    mode = "Active"
  }
}