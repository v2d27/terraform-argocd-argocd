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

# === APPLICATION OUTPUTS ===
output "application_name" {
  description = "The name of the created Argo CD application."
  value       = argocd_application.kustomize_app.metadata[0].name
}

output "application_namespace" {
  description = "The namespace where the Argo CD application is deployed."
  value       = argocd_application.kustomize_app.metadata[0].namespace
}

output "application_uid" {
  description = "The unique identifier of the Argo CD application."
  value       = argocd_application.kustomize_app.metadata[0].uid
}

output "application_labels" {
  description = "The labels applied to the Argo CD application."
  value       = argocd_application.kustomize_app.metadata[0].labels
}

output "application_sync_status" {
  description = "The current sync status of the application."
  value       = try(argocd_application.kustomize_app.status[0].sync[0].status, "Unknown")
}

output "application_health_status" {
  description = "The current health status of the application."
  value       = try(argocd_application.kustomize_app.status[0].health[0].status, "Unknown")
}

# === PROJECT OUTPUTS ===
output "project_name" {
  description = "The name of the created Argo CD project."
  value       = argocd_project.app_project.metadata[0].name
}

output "project_uid" {
  description = "The unique identifier of the Argo CD project."
  value       = argocd_project.app_project.metadata[0].uid
}

# === REPOSITORY OUTPUTS ===
output "repository_url" {
  description = "The URL of the registered repository."
  value       = argocd_repository.app_repo.repo
}

output "repository_id" {
  description = "The unique identifier of the repository."
  value       = argocd_repository.app_repo.id
}

output "repository_connection_status" {
  description = "The connection status of the repository."
  value       = try(argocd_repository.app_repo.connection_state_status, "Unknown")
}

# === CONFIGURATION OUTPUTS ===
output "destination_server" {
  description = "The target Kubernetes cluster URL."
  value       = var.destination_server
}

output "target_namespace" {
  description = "The target deployment namespace."
  value       = var.app_namespace
}

output "kustomize_path" {
  description = "The path to the Kustomize overlay in the repository."
  value       = var.kustomize_path
}

output "target_revision" {
  description = "The Git revision being synced."
  value       = var.repo_target_revision
}

output "authentication_type" {
  description = "The authentication method used for repository access."
  value       = var.repo_auth_type
}

# === URLS AND LINKS ===
output "application_url" {
  description = "Direct URL to view the application in ArgoCD UI (requires ArgoCD server URL)."
  value       = "applications/${argocd_application.kustomize_app.metadata[0].namespace}/${argocd_application.kustomize_app.metadata[0].name}"
}

output "project_url" {
  description = "Direct URL to view the project in ArgoCD UI (requires ArgoCD server URL)."
  value       = "settings/projects/${argocd_project.app_project.metadata[0].name}"
}