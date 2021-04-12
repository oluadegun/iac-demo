provider "aws" {
  region = "eu-west-2"
}


terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket         = "tf-state-1993"
    # key            = "global/s3/terraform.tfstate"
    region         =  "eu-west-2"
    # Replace this with your DynamoDB table name!
    encrypt        = true
  }
}

