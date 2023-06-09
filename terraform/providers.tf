provider "aws" {
  region = var.aws_region
}

terraform {
  required_version = ">= 0.14"
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0.1"
    }
  }
}

terraform {
    backend "s3" {
        bucket = "code-bucket-rajesh"
        dynamodb_table = "terraform_state_lock"
        key = "secure-tf/terraform_state/tf_state.json"
        region = "us-east-1"
    }
}