terraform {
  required_providers {
    aws = {
      source    =   "hashicorp/aws"
      version   =   "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region        =   "us-east-1"
}

# Create IAM policy for lambda IAM role
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Create role for lambda permissions
resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Create lambda function itself
resource "aws_lambda_function" "tf_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  role             = aws_iam_role.iam_for_lambda.arn
  s3_bucket        = "test-lambda-layers-bucket"
  s3_key           = "lambdas/hello-world.zip"
  function_name    = "test-lambda"              # This is the function name as it appears in AWS Console
  handler          = "index.handler"
  runtime          = "nodejs16.x"
  timeout          = 180

}

resource "aws_lambda_layer_version" "test_run_lambda_layer" {
  s3_bucket        = "test-lambda-layers-bucket"
  s3_key           = "layers/test-layer.zip"
  layer_name       = "test_layer"

  compatible_runtimes = ["nodejs16.x"]
}

# Create lambda function itself
resource "aws_lambda_function" "tf_lambda_layers_test" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  role             = aws_iam_role.iam_for_lambda.arn
  s3_bucket        = "test-lambda-layers-bucket"
  s3_key           = "lambdas/base-lambda.zip"
  function_name    = "base-lambda"              # This is the function name as it appears in AWS Console
  layers           = [aws_lambda_layer_version.test_run_lambda_layer.arn]
  handler          = "index.handler"
  runtime          = "nodejs16.x"
  timeout          = 180

}
