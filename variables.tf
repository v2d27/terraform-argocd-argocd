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

# === REQUIRED VARIABLES ===
variable "app_name" {
  description = "The name of the Argo CD application."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]{1,63}$", var.app_name))
    error_message = "App name must be lowercase alphanumeric characters and hyphens only, max 63 characters."
  }
}

variable "app_namespace" {
  description = "The Kubernetes namespace where the application will be deployed."
  type        = string
}

variable "project_name" {
  description = "The name of the Argo CD project to associate with the application."
  type        = string
}

variable "repo_url" {
  description = "The URL of the Git repository (SSH: git@github.com:org/repo.git, HTTPS: https://github.com/org/repo.git)."
  type        = string
}

variable "kustomize_path" {
  description = "The path within the repository to the Kustomize overlay."
  type        = string
}

# === AUTHENTICATION CONFIGURATION ===
variable "repo_auth_type" {
  description = "The authentication method for the repository. Options: ssh, https, github_app, token"
  type        = string
  default     = "ssh"
  validation {
    condition     = contains(["ssh", "https", "github_app", "token"], var.repo_auth_type)
    error_message = "Repository auth type must be one of: ssh, https, github_app, token."
  }
}

# SSH Authentication
variable "git_ssh_private_key" {
  description = "The SSH private key for accessing the Git repository. Required when repo_auth_type is 'ssh'."
  type        = string
  default     = ""
  sensitive   = true
}

# HTTPS Authentication  
variable "git_username" {
  description = "Username for HTTPS authentication. Required when repo_auth_type is 'https'."
  type        = string
  default     = ""
}

variable "git_password" {
  description = "Password/PAT for HTTPS authentication. Required when repo_auth_type is 'https'."
  type        = string
  default     = ""
  sensitive   = true
}

# GitHub App Authentication
variable "github_app_id" {
  description = "GitHub App ID for GitHub App authentication. Required when repo_auth_type is 'github_app'."
  type        = string
  default     = ""
}

variable "github_app_installation_id" {
  description = "GitHub App Installation ID for GitHub App authentication. Required when repo_auth_type is 'github_app'."
  type        = string
  default     = ""
}

variable "github_app_private_key" {
  description = "GitHub App private key (PEM format) for GitHub App authentication. Required when repo_auth_type is 'github_app'."
  type        = string
  default     = ""
  sensitive   = true
}

variable "github_enterprise_base_url" {
  description = "GitHub Enterprise base URL for GitHub App authentication."
  type        = string
  default     = ""
}

# === REPOSITORY CONFIGURATION ===
variable "repo_target_revision" {
  description = "The Git branch, tag, or commit hash to sync from."
  type        = string
  default     = "HEAD"
}

variable "insecure_ignore_host_key" {
  description = "Whether to ignore SSH host key verification (not recommended for production)."
  type        = bool
  default     = false
}

variable "enable_git_lfs" {
  description = "Enable Git LFS support for the repository."
  type        = bool
  default     = false
}

# === DESTINATION CONFIGURATION ===
variable "destination_server" {
  description = "The target Kubernetes cluster URL for the deployment."
  type        = string
  default     = "https://kubernetes.default.svc"
}

variable "argocd_namespace" {
  description = "The namespace where Argo CD is installed."
  type        = string
  default     = "argocd"
}

# === PROJECT CONFIGURATION ===
variable "project_description" {
  description = "Description for the Argo CD project."
  type        = string
  default     = ""
}

variable "project_source_repos" {
  description = "List of additional source repositories allowed for the project. The main repo_url is automatically included."
  type        = list(string)
  default     = []
}

variable "project_destinations" {
  description = "Additional destinations for the project beyond the main application destination."
  type = list(object({
    server    = string
    namespace = string
  }))
  default = []
}

variable "project_cluster_resource_whitelist" {
  description = "Cluster-level resources that are allowed to be managed by the project."
  type = list(object({
    group = string
    kind  = string
  }))
  default = [
    {
      group = "rbac.authorization.k8s.io"
      kind  = "ClusterRole"
    },
    {
      group = "rbac.authorization.k8s.io"
      kind  = "ClusterRoleBinding"
    }
  ]
}

variable "project_namespace_resource_blacklist" {
  description = "Namespace-level resources that are NOT allowed to be managed by the project."
  type = list(object({
    group = string
    kind  = string
  }))
  default = []
}

# === KUSTOMIZE CONFIGURATION ===
variable "kustomize_name_prefix" {
  description = "An optional prefix to add to all resources deployed by Kustomize."
  type        = string
  default     = ""
}

variable "kustomize_name_suffix" {
  description = "An optional suffix to add to all resources deployed by Kustomize."
  type        = string
  default     = ""
}

variable "kustomize_images" {
  description = "List of Kustomize image override specifications."
  type        = list(string)
  default     = []
}

variable "kustomize_common_labels" {
  description = "Common labels to add to all resources via Kustomize."
  type        = map(string)
  default     = {}
}

variable "kustomize_common_annotations" {
  description = "Common annotations to add to all resources via Kustomize."
  type        = map(string)
  default     = {}
}

variable "kustomize_version" {
  description = "Version of Kustomize to use for rendering manifests."
  type        = string
  default     = ""
}

# === SYNC POLICY CONFIGURATION ===
variable "sync_policy_automated" {
  description = "Enable automated sync policy."
  type        = bool
  default     = true
}

variable "sync_policy_prune" {
  description = "If true, resources removed from Git will be pruned from the cluster."
  type        = bool
  default     = true
}

variable "sync_policy_self_heal" {
  description = "If true, Argo CD will automatically correct any detected drift from the Git state."
  type        = bool
  default     = true
}

variable "sync_policy_allow_empty" {
  description = "Allow applications to have zero live resources (useful for app-of-apps pattern)."
  type        = bool
  default     = false
}

variable "sync_options" {
  description = "List of sync options for the application."
  type        = list(string)
  default     = ["CreateNamespace=true"]
}

variable "sync_retry_limit" {
  description = "Maximum number of sync retry attempts."
  type        = number
  default     = 5
  validation {
    condition     = var.sync_retry_limit >= 0 && var.sync_retry_limit <= 10
    error_message = "Sync retry limit must be between 0 and 10."
  }
}

variable "sync_retry_backoff_duration" {
  description = "Initial backoff duration for sync retries."
  type        = string
  default     = "5s"
}

variable "sync_retry_backoff_factor" {
  description = "Multiplier for backoff duration on subsequent retries."
  type        = string
  default     = "2"
}

variable "sync_retry_backoff_max_duration" {
  description = "Maximum backoff duration for sync retries."
  type        = string
  default     = "3m"
}

# === APPLICATION CONFIGURATION ===
variable "app_labels" {
  description = "Labels to apply to the Argo CD application."
  type        = map(string)
  default     = {}
}

variable "app_annotations" {
  description = "Annotations to apply to the Argo CD application."
  type        = map(string)
  default     = {}
}

variable "revision_history_limit" {
  description = "Number of old ReplicaSets to retain to allow rollback."
  type        = number
  default     = 10
  validation {
    condition     = var.revision_history_limit >= 0
    error_message = "Revision history limit must be non-negative."
  }
}

# === IGNORE DIFFERENCES CONFIGURATION ===
variable "ignore_differences" {
  description = "List of resource fields to ignore during comparison."
  type = list(object({
    group             = optional(string)
    kind              = optional(string)
    name              = optional(string)
    namespace         = optional(string)
    json_pointers     = optional(list(string))
    jq_path_expressions = optional(list(string))
  }))
  default = []
}