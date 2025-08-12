#========================================================================
# 
# Terraform ArgoCD Module
# 
# This module provides a comprehensive setup for managing ArgoCD applications,
# projects, and repositories with flexible authentication options.
# It supports SSH, HTTPS, and GitHub App authentication methods.
#
# Author: Hercules
# License: Apache-2.0
# GitHub: https://github.com/v2d27/terraform-argocd-module
# =======================================================================

terraform {
  required_version = ">= 1.12.2"

  required_providers {
    argocd = {
      source  = "argoproj-labs/argocd"
      version = ">= 7.10.0"
    }
  }
}