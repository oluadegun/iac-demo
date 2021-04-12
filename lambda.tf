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

resource "aws_lambda_function" "test_lambda" {
  # filename      = var.filename == null ? "${path.module}/files/${env.TF_VAR_env}hello_world.zip" : var.filename
  s3_bucket     = env.TF_VAR_lambda_pkg
  s3_object_version = env.TF_VAR_appversion
  function_name = env.TF_VAR_appname
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
    #    source_code_hash = "${path.module}/files/hello_world.zip"

  runtime = "python3.7"

#   environment {
#     variables = {
#       foo = "bar"
#     }
#   }
}