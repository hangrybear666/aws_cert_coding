resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role_${var.function_purpose}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "execute_lambda_policy" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "create_payload_zip" {
  type        = "zip"
  source_dir  = "${path.module}/payload/${var.function_purpose}/"
  output_path = "${path.module}/payload/${var.function_purpose}/payload.zip"
}

resource "aws_lambda_function" "api_gw_func" {
  filename                 = "${path.module}/payload/${var.function_purpose}/payload.zip"
  function_name            = "${var.service_name}-${var.function_purpose}"
  role                     = aws_iam_role.lambda_execution_role.arn
  handler                  = "index.handler"
  runtime                  = var.runtime_env
  depends_on               = [aws_iam_role_policy_attachment.execute_lambda_policy]
}