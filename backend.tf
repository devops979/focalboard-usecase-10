terraform {
  required_version = ">= 1.12.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.99.1"
    }
  }

  backend "s3" {
    bucket       = "demo-usecases-bucket-new"
    key          = "usecase-10/terraform.tftstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}