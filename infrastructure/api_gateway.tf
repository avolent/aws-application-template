data "aws_iam_policy_document" "api_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "cloudwatch" {
  name               = "api_gateway_cloudwatch_global"
  assume_role_policy = data.aws_iam_policy_document.api_assume_role.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
  ]
}

resource "aws_api_gateway_account" "api" {
  cloudwatch_role_arn = aws_iam_role.cloudwatch.arn
}

resource "aws_cloudwatch_log_group" "api" {
  #checkov:skip=CKV_AWS_338:Log retention doesnt need to be 1 year yet
  name              = "${var.app_name}-api-${var.app_env}"
  retention_in_days = 14
  kms_key_id        = data.aws_kms_key.default.arn
}

resource "aws_api_gateway_rest_api" "api" {
  name = "${var.app_name}-api"

  endpoint_configuration {
    types = ["EDGE"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_resource" "api" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "api" {
  #checkov:skip=CKV_AWS_59:Authoriser not required yet
  #checkov:skip=CKV2_AWS_53:Will be enabled in the future
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.api.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_method_settings" "all" {
  #checkov:skip=CKV_AWS_308:Disable the need caching encryption
  #checkov:skip=CKV_AWS_225:Disable the need caching
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_stage.api.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "ERROR"
  }
}

resource "aws_api_gateway_integration" "api" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.api.id
  http_method             = aws_api_gateway_method.api.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "api" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.api.id,
      aws_api_gateway_method.api.id,
      aws_api_gateway_integration.api.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "api" {
  #checkov:skip=CKV2_AWS_51:Will be enabled in the future
  #checkov:skip=CKV2_AWS_29:Will be enabled in the future
  deployment_id = aws_api_gateway_deployment.api.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = var.app_env
  #checkov:skip=CKV_AWS_120:Will be used when required. Comment out section below
  # cache_cluster_enabled = true
  # cache_cluster_size = 0.5
  xray_tracing_enabled = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api.arn
    format = jsonencode(
      {
        caller         = "$context.identity.caller"
        httpMethod     = "$context.httpMethod"
        ip             = "$context.identity.sourceIp"
        protocol       = "$context.protocol"
        requestId      = "$context.requestId"
        requestTime    = "$context.requestTime"
        resourcePath   = "$context.resourcePath"
        responseLength = "$context.responseLength"
        status         = "$context.status"
        user           = "$context.identity.user"
      }
    )
  }
}
