# Define provider
provider "aws" {
  region = "us-west-2"  # Replace with your desired region
}

# Create S3 bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-bucket-name"  # Replace with your desired bucket name
  acl    = "private"
}

# Create DynamoDB table
resource "aws_dynamodb_table" "my_table" {
  name           = "my-table-name"  # Replace with your desired table name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"
  attribute {
    name = "id"
    type = "N"
  }
}

# Create Lambda function
resource "aws_lambda_function" "my_lambda" {
  filename         = "lambda_function.zip"  # Replace with your actual Lambda function code
  function_name    = "my-lambda-function"  # Replace with your desired function name
  role             = aws_iam_role.my_lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs14.x"
}

# Create IAM role for Lambda function
resource "aws_iam_role" "my_lambda_role" {
  name = "my-lambda-role"  # Replace with your desired role name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Create Amplify app
resource "aws_amplify_app" "my_amplify_app" {
  name   = "my-amplify-app"  # Replace with your desired app name
  environment {
    name  = "production"
    variables = {
      "BUCKET_NAME" = aws_s3_bucket.my_bucket.bucket
      "TABLE_NAME"  = aws_dynamodb_table.my_table.name
    }
  }
}

# Create API Gateway
resource "aws_api_gateway_rest_api" "my_api_gateway" {
  name        = "my-api-gateway"  # Replace with your desired API Gateway name
  description = "My API Gateway"
}

# Create Rekognition collection
resource "aws_rekognition_collection" "my_rekognition_collection" {
  name = "my-rekognition-collection"  # Replace with your desired collection name
}

# Outputs
output "amplify_app_url" {
  value = aws_amplify_app.my_amplify_app.app_url
}

output "api_gateway_url" {
  value = aws_api_gateway_rest_api.my_api_gateway.invoke_url
}
