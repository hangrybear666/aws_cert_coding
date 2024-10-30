terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "hangrybear-tf-backend-state-bucket"
    key = "aws_iam/state.tfstate"
    region = "eu-central-1"
    encrypt = true
  }
}