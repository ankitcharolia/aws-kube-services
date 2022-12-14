terraform {

  backend "s3" {
    bucket = "terraform-kube-state"
    key    = "global/s3/terraform.tfstate"
    region = "eu-west-1"
  }

  required_providers {
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
