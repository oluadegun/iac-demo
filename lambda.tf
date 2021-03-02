resource "aws_iam_role" "iam_for_lambda" {
  name = "demo_role_lambda"

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

data "archive_file" "init" {
  type        = "zip"
  source_file = "${path.module}/hello_world"
  output_path = "${path.module}/files/hello_world.zip"
}

resource "aws_lambda_function" "test_lambda" {
  filename      = "hello_world.zip"
  function_name = "trading_point_demo"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = "${path.module}/filebase64sha256(\"hello_world.zip\")"

  runtime = "python3.7"

#   environment {
#     variables = {
#       foo = "bar"
#     }
#   }
}