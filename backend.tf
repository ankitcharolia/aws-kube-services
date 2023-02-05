terraform {

  backend "s3" {
    bucket                = "terraform-kube-state"
    key                   = "terraform.tfstate"
    workspace_key_prefix  = "environments"
    region                = "eu-west-1"
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.53.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.7.1"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.16.0"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-1"

  default_tags {
  tags = {
    environment = "stage"
    team        = "infrastructure"
    }
  }
}
