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

locals {
  # Common tags applied to all resources
  common_labels = {
    "app.kubernetes.io/managed-by" = "terraform"
    "terraform.io/module"          = "terraform-argocd-module"
  }

  # Validation helpers
  auth_type_requires_ssh_key = var.repo_auth_type == "ssh" && var.git_ssh_private_key == ""
  auth_type_requires_username_password = contains(["https", "token"], var.repo_auth_type) && (var.git_username == "" || var.git_password == "")
  auth_type_requires_github_app = var.repo_auth_type == "github_app" && (var.github_app_id == "" || var.github_app_installation_id == "" || var.github_app_private_key == "")

  # Repository type detection
  is_ssh_repo = can(regex("^git@", var.repo_url))
  is_https_repo = can(regex("^https://", var.repo_url))

  # Authentication configuration per type
  repo_auth_config = {
    ssh = {
      ssh_private_key = var.git_ssh_private_key
      username        = null
      password        = null
    }
    https = {
      ssh_private_key = null
      username        = var.git_username
      password        = var.git_password
    }
    github_app = {
      ssh_private_key               = null
      username                      = null
      password                      = null
      githubapp_id                 = var.github_app_id
      githubapp_installation_id    = var.github_app_installation_id
      githubapp_private_key        = var.github_app_private_key
      githubapp_enterprise_base_url = var.github_enterprise_base_url != "" ? var.github_enterprise_base_url : null
    }
    token = {
      ssh_private_key = null
      username        = "git"
      password        = var.git_password
    }
  }

  # Project destinations (combine main destination with additional ones)
  all_destinations = concat(
    [{
      server    = var.destination_server
      namespace = var.app_namespace
    }],
    var.project_destinations
  )

  # Project source repositories (combine main repo with additional ones)
  all_source_repos = distinct(concat([var.repo_url], var.project_source_repos))

  # Project description with intelligent defaults
  project_description = var.project_description != "" ? var.project_description : "ArgoCD project for ${var.app_name} application - managed by Terraform"

  # Sync options with defaults
  default_sync_options = ["CreateNamespace=true"]
  final_sync_options = length(var.sync_options) > 0 ? var.sync_options : local.default_sync_options

  # Application labels (merge user-provided with defaults)
  app_labels = merge(
    local.common_labels,
    {
      "app.kubernetes.io/name"      = var.app_name
      "app.kubernetes.io/instance"  = var.app_name
      "argocd.argoproj.io/instance" = var.app_name
    },
    var.app_labels
  )

  # Project labels
  project_labels = merge(
    local.common_labels,
    {
      "argocd.argoproj.io/project" = var.project_name
    },
    var.app_labels # Use same labels for consistency
  )

  # Default cluster resource whitelist for better security
  default_cluster_resources = var.project_cluster_resource_whitelist

  # Kustomize configuration validation
  has_kustomize_config = (
    var.kustomize_name_prefix != "" ||
    var.kustomize_name_suffix != "" ||
    length(var.kustomize_images) > 0 ||
    length(var.kustomize_common_labels) > 0 ||
    length(var.kustomize_common_annotations) > 0 ||
    var.kustomize_version != ""
  )

  # Final Kustomize labels (merge common with user-provided)
  final_kustomize_labels = merge(
    {
      "kustomize.config.k8s.io/managed" = "true"
    },
    var.kustomize_common_labels
  )

  # Repository configuration based on authentication type
  repo_config = local.repo_auth_config[var.repo_auth_type]

  # Sync policy configuration
  sync_config = {
    automated   = var.sync_policy_automated
    prune      = var.sync_policy_prune
    self_heal  = var.sync_policy_self_heal
    allow_empty = var.sync_policy_allow_empty
  }
}
