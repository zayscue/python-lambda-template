terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.53.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.0"
    }
  }
}