terraform {
  required_version = "~> 1.14.0" 
  required_providers {              
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28.0"
    }
    okta = {
      source  = "okta/okta"
      version = "~> 4.10.0"
    }
  }
}