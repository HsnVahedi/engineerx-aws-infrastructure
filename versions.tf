terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.28.1"
    }

    random = {
      source  = "hashicorp/random"
      # version = "3.0.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 1.2"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 2.1"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.1"
    }
    kustomization = {
      source  = "kbst/kustomize"
      version = "0.2.0-beta.3"
    }
  }
  required_version = ">= 0.12.0"
}
