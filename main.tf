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

# Resource: Create a comprehensive Argo CD Project
resource "argocd_project" "app_project" {
  metadata {
    name        = var.project_name
    namespace   = var.argocd_namespace
    labels      = local.project_labels
    annotations = var.app_annotations
  }

  spec {
    description   = local.project_description
    source_repos  = local.all_source_repos

    # Configure all destinations
    dynamic "destination" {
      for_each = local.all_destinations
      content {
        server    = destination.value.server
        namespace = destination.value.namespace
      }
    }

    # Cluster-level resource whitelist
    dynamic "cluster_resource_whitelist" {
      for_each = local.default_cluster_resources
      content {
        group = cluster_resource_whitelist.value.group
        kind  = cluster_resource_whitelist.value.kind
      }
    }

    # Namespace-level resource configuration
    namespace_resource_whitelist {
      group = "*"
      kind  = "*"
    }

    dynamic "namespace_resource_blacklist" {
      for_each = var.project_namespace_resource_blacklist
      content {
        group = namespace_resource_blacklist.value.group
        kind  = namespace_resource_blacklist.value.kind
      }
    }

    # Default orphaned resources configuration
    orphaned_resources {
      warn = true
    }
  }
}

# Resource: Register the Git repository with flexible authentication
resource "argocd_repository" "app_repo" {
  repo    = var.repo_url
  project = argocd_project.app_project.metadata[0].name

  # SSH Authentication
  ssh_private_key          = try(local.repo_config.ssh_private_key, null)

  # HTTPS/Token Authentication
  username = try(local.repo_config.username, null)
  password = try(local.repo_config.password, null)

  # GitHub App Authentication
  githubapp_id                     = try(local.repo_config.githubapp_id, null)
  githubapp_installation_id        = try(local.repo_config.githubapp_installation_id, null)
  githubapp_private_key           = try(local.repo_config.githubapp_private_key, null)
  githubapp_enterprise_base_url   = try(local.repo_config.githubapp_enterprise_base_url, null)

  # Additional repository settings
  enable_lfs = var.enable_git_lfs
}

# Resource: Create the comprehensive Argo CD Application
resource "argocd_application" "kustomize_app" {
  metadata {
    name        = var.app_name
    namespace   = var.argocd_namespace
    labels      = local.app_labels
    annotations = var.app_annotations
  }

  spec {
    project                = argocd_project.app_project.metadata[0].name
    revision_history_limit = var.revision_history_limit

    source {
      repo_url        = argocd_repository.app_repo.repo
      path            = var.kustomize_path
      target_revision = var.repo_target_revision

      # Enhanced Kustomize configuration
      kustomize {
        name_prefix        = var.kustomize_name_prefix
        name_suffix        = var.kustomize_name_suffix
        images             = var.kustomize_images
        common_labels      = local.final_kustomize_labels
        common_annotations = var.kustomize_common_annotations
        version           = var.kustomize_version != "" ? var.kustomize_version : null
      }
    }

    destination {
      server    = var.destination_server
      namespace = var.app_namespace
    }

    # Enhanced sync policy configuration
    sync_policy {
      # Automated sync policy (conditional)
      dynamic "automated" {
        for_each = local.sync_config.automated ? [1] : []
        content {
          prune       = local.sync_config.prune
          self_heal   = local.sync_config.self_heal
          allow_empty = local.sync_config.allow_empty
        }
      }

      # Sync options
      sync_options = local.final_sync_options

      # Retry configuration
      retry {
        limit = tostring(var.sync_retry_limit)
        backoff {
          duration     = var.sync_retry_backoff_duration
          factor       = var.sync_retry_backoff_factor
          max_duration = var.sync_retry_backoff_max_duration
        }
      }
    }

    # Ignore differences configuration
    dynamic "ignore_difference" {
      for_each = var.ignore_differences
      content {
        group               = ignore_difference.value.group
        kind                = ignore_difference.value.kind
        name                = ignore_difference.value.name
        namespace           = ignore_difference.value.namespace
        json_pointers       = ignore_difference.value.json_pointers
        jq_path_expressions = ignore_difference.value.jq_path_expressions
      }
    }
  }

  # Wait for the application to be healthy before considering the resource created
  wait = true

  # Validate the application configuration
  validate = true

  # Lifecycle management
  lifecycle {
    ignore_changes = [
      metadata[0].annotations["argocd.argoproj.io/sync-wave"]
    ]
  }
}