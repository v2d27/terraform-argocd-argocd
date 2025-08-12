# examples.tf: Usage examples for the ArgoCD Terraform Module

# =============================================================================
# EXAMPLE 1: SSH Authentication (Most Common)
# =============================================================================
module "app_ssh_auth" {
  source = "./terraform-argocd-module"

  # Required variables
  app_name        = "web-app-prod"
  app_namespace   = "production"
  project_name    = "web-applications"
  repo_url        = "git@github.com:myorg/kustomize-apps.git"
  kustomize_path  = "overlays/production/web-app"

  # SSH Authentication (default)
  repo_auth_type      = "ssh"
  git_ssh_private_key = file("~/.ssh/argocd_rsa")

  # Optional: Enhanced Kustomize configuration
  kustomize_name_prefix = "prod-"
  kustomize_images = [
    "myapp=myregistry.io/myapp:v1.2.3"
  ]
  kustomize_common_labels = {
    environment = "production"
    team        = "platform"
  }

  # Optional: Application labels
  app_labels = {
    "app.kubernetes.io/component" = "web-app"
    "app.kubernetes.io/part-of"   = "ecommerce-platform"
  }
}

# =============================================================================
# EXAMPLE 2: HTTPS Authentication with Personal Access Token
# =============================================================================
module "app_https_auth" {
  source = "./terraform-argocd-module"

  # Required variables
  app_name        = "api-service-staging"
  app_namespace   = "staging"
  project_name    = "api-services"
  repo_url        = "https://github.com/myorg/api-manifests.git"
  kustomize_path  = "environments/staging"

  # HTTPS Authentication
  repo_auth_type = "https"
  git_username   = "myusername"
  git_password   = var.github_pat # Use a variable for security

  # Custom sync policy
  sync_policy_automated   = true
  sync_policy_prune      = false # Don't auto-delete in staging
  sync_policy_self_heal  = false # Allow manual changes in staging
  
  # Custom sync options
  sync_options = [
    "CreateNamespace=true",
    "ServerSideApply=true"
  ]
}

# =============================================================================
# EXAMPLE 3: GitHub App Authentication (Enterprise)
# =============================================================================
module "app_github_app" {
  source = "./terraform-argocd-module"

  # Required variables
  app_name        = "security-scanner"
  app_namespace   = "security"
  project_name    = "security-tools"
  repo_url        = "https://github.enterprise.corp/security/scanner-config.git"
  kustomize_path  = "deployments/prod"

  # GitHub App Authentication
  repo_auth_type                = "github_app"
  github_app_id                = var.github_app_id
  github_app_installation_id   = var.github_app_installation_id
  github_app_private_key       = var.github_app_private_key
  github_enterprise_base_url   = "https://api.github.enterprise.corp"

  # Project configuration for security workloads
  project_description = "Security tools and scanners project"
  project_cluster_resource_whitelist = [
    {
      group = "rbac.authorization.k8s.io"
      kind  = "ClusterRole"
    },
    {
      group = "security.istio.io"
      kind  = "PeerAuthentication"
    }
  ]
}

# =============================================================================
# EXAMPLE 4: Multi-Repository Project with Advanced Configuration
# =============================================================================
module "app_advanced" {
  source = "./terraform-argocd-module"

  # Required variables
  app_name        = "microservice-platform"
  app_namespace   = "platform"
  project_name    = "microservices"
  repo_url        = "git@github.com:myorg/platform-base.git"
  kustomize_path  = "platform/overlays/production"

  # SSH Authentication with host key verification
  repo_auth_type              = "ssh"
  git_ssh_private_key        = file("~/.ssh/platform_deploy_key")
  insecure_ignore_host_key   = false # Secure setup

  # Multiple source repositories for the project
  project_source_repos = [
    "git@github.com:myorg/microservice-configs.git",
    "git@github.com:myorg/shared-manifests.git",
    "https://charts.bitnami.com/bitnami" # Helm repo
  ]

  # Multiple destinations
  project_destinations = [
    {
      server    = "https://prod-east.k8s.corp"
      namespace = "platform"
    },
    {
      server    = "https://prod-west.k8s.corp"
      namespace = "platform"
    }
  ]

  # Advanced Kustomize configuration
  kustomize_name_prefix = "platform-"
  kustomize_name_suffix = "-v2"
  kustomize_images = [
    "gateway=registry.corp/platform/gateway:v2.1.0",
    "auth-service=registry.corp/platform/auth:v1.5.2"
  ]
  kustomize_common_labels = {
    platform    = "v2"
    environment = "production"
    managed-by  = "argocd"
  }
  kustomize_common_annotations = {
    "deployment.kubernetes.io/revision" = "2"
  }

  # Ignore certain differences to reduce noise
  ignore_differences = [
    {
      group = "apps"
      kind  = "Deployment"
      json_pointers = [
        "/spec/replicas",
        "/spec/template/spec/containers/0/image"
      ]
    },
    {
      group = ""
      kind  = "Secret"
      name  = "platform-tls"
      jq_path_expressions = [".data"]
    }
  ]

  # Custom retry policy for critical applications
  sync_retry_limit               = 10
  sync_retry_backoff_duration    = "10s"
  sync_retry_backoff_max_duration = "5m"

  # Application metadata
  app_labels = {
    "app.kubernetes.io/name"       = "microservice-platform"
    "app.kubernetes.io/version"    = "v2.0.0"
    "app.kubernetes.io/component"  = "platform"
    "app.kubernetes.io/part-of"    = "microservice-ecosystem"
    "app.kubernetes.io/managed-by" = "argocd"
    "platform.corp/team"           = "platform-engineering"
    "platform.corp/criticality"    = "high"
  }

  app_annotations = {
    "argocd.argoproj.io/sync-wave"           = "0"
    "notifications.argoproj.io/subscribe.on-sync-succeeded.slack" = "platform-alerts"
    "platform.corp/documentation"            = "https://docs.corp/platform"
    "platform.corp/runbook"                 = "https://runbooks.corp/platform"
  }
}

# =============================================================================
# EXAMPLE 5: Development Environment with Manual Sync
# =============================================================================
module "app_dev_manual" {
  source = "./terraform-argocd-module"

  # Required variables
  app_name        = "feature-branch-test"
  app_namespace   = "development"
  project_name    = "development-apps"
  repo_url        = "git@github.com:myorg/app-configs.git"
  kustomize_path  = "overlays/development"

  # SSH Authentication
  repo_auth_type      = "ssh"
  git_ssh_private_key = file("~/.ssh/dev_deploy_key")

  # Manual sync for development (no automation)
  sync_policy_automated = false
  
  # Allow empty applications (useful for testing)
  sync_policy_allow_empty = true

  # Development-specific sync options
  sync_options = [
    "CreateNamespace=true",
    "Validate=false", # Skip validation in dev
    "ApplyOutOfSyncOnly=true"
  ]

  # Faster retries for development
  sync_retry_limit               = 3
  sync_retry_backoff_duration    = "5s"
  sync_retry_backoff_max_duration = "30s"

  # Lower revision history for development
  revision_history_limit = 3

  # Development labels
  app_labels = {
    environment = "development"
    temporary   = "true"
  }
}
