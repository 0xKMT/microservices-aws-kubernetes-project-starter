provider "aws" {
  region              = "ap-southeast-1"
  allowed_account_ids = [841135272578]
  default_tags {
    tags = {
      environment = var.env
      managedby   = "terraform"
    }
  }
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.udacity_cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.udacity_cluster.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.udacity_cluster.id]
      command     = "aws"
    }
  }
}

terraform {
  required_version = ">= 1.2.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.29.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0"
    }
    template = {
      source  = "hashicorp/template"
      version = ">= 2.2.0"
    }
  }
}
