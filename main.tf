provider "aws" {
  region = "us-east-1"
}

resource "null_resource" "build_lambda_function" {
  triggers = {
    build_number = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "rm package.zip; rm -rf dist/; poetry build; poetry run pip install --upgrade -t dist/lambda dist/*.whl --use-pep517 --no-cache-dir"
  }
}

data "archive_file" "lambda_function_package" {
  type        = "zip"
  output_path = "${path.module}/package.zip"
  excludes = setunion(
    fileset("${path.module}/dist/lambda", "**/bin/*"),
    fileset("${path.module}/dist/lambda", "**/__pycache__/*")
  )
  source_dir = "${path.module}/dist/lambda/"

  depends_on = [
    null_resource.build_lambda_function
  ]
}

resource "aws_iam_role" "username_generator_function_role" {
  name = "username-generator-function-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
}


resource "aws_lambda_function" "username_generator_function" {
  filename         = data.archive_file.lambda_function_package.output_path
  function_name    = "username-generator"
  role             = aws_iam_role.username_generator_function_role.arn
  handler          = "username_generator/app.lambda_handler"
  source_code_hash = data.archive_file.lambda_function_package.output_base64sha256
  runtime          = "python3.9"
  memory_size      = 256
  timeout          = 600
  layers           = ["arn:aws:lambda:us-east-1:017000801446:layer:AWSLambdaPowertoolsPythonV2:20"]
}