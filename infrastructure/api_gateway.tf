resource "aws_api_gateway_rest_api" "api" {
  body = templatefile(
    "./api.json",
    {
      app_name        = var.app_name
      app_version     = var.app_env
      region          = var.aws_region
      account_id      = data.aws_caller_identity.current.account_id
      lambda_function = aws_lambda_function.api_lambda.arn
    }
  )

  name = "${var.app_name}-api"

  endpoint_configuration {
    types = ["EDGE"]
  }
}

resource "aws_api_gateway_deployment" "api" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "api" {
  deployment_id = aws_api_gateway_deployment.api.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = var.app_env
}