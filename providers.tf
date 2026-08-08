terraform {
  required_version = ">= 1.5.0" # modern Terraform CLI version

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.58.0" # Locks configuration to v6.58.x and allows minor patch updates
    }
  }
}

# Default AWS provider configuration
provider "aws" {
  region = "ap-southeast-1"
}
