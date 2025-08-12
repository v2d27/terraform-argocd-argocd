# Terraform ArgoCD Module

A Terraform module for creating and managing ArgoCD applications, projects, and repositories with support for multiple authentication methods and advanced configuration options.

***Note: This module is used to manage ArgoCD, not deploy ArgoCD***

## Features

- **Multiple Authentication Types**: SSH, HTTPS, GitHub App, and Token-based authentication
- **Project Management**: Create scoped ArgoCD projects with advanced RBAC
- **Advanced Kustomize Support**: Full Kustomize configuration including patches, images, and labels
- **Flexible Sync Policies**: Automated and manual sync with retry mechanisms
- **Security Best Practices**: Secure defaults with validation and proper secret handling
- **Enterprise Ready**: Support for GitHub Enterprise and advanced organizational features



## Providers

| Name | Version |
|------|---------|
| terraform | >= 1.12.2 |
| [argoproj-labs/argocd](https://registry.terraform.io/providers/argoproj-labs/argocd/latest) | >= 7.10.0 |

## Authentication Types Supported

### 1. SSH Authentication (Default)
```hcl
module "my_app" {
  source = "./terraform-argocd-module"
  
  repo_auth_type      = "ssh"
  git_ssh_private_key = file("~/.ssh/argocd_key")
  # ... other variables
}
```

### 2. HTTPS Authentication
```hcl
module "my_app" {
  source = "./terraform-argocd-module"
  
  repo_auth_type = "https"
  git_username   = "myusername"
  git_password   = var.github_token
  # ... other variables
}
```

### 3. GitHub App Authentication
```hcl
module "my_app" {
  source = "./terraform-argocd-module"
  
  repo_auth_type                = "github_app"
  github_app_id                = "123456"
  github_app_installation_id   = "78901234"
  github_app_private_key       = var.github_app_key
  github_enterprise_base_url   = "https://api.github.enterprise.com" # Optional
  # ... other variables
}
```

### 4. Token Authentication
```hcl
module "my_app" {
  source = "./terraform-argocd-module"
  
  repo_auth_type = "token"
  git_password   = var.access_token
  # ... other variables
}
```

## Basic Usage

```hcl
# Configure the ArgoCD provider (in your root configuration)
provider "argocd" {
  server_addr = "argocd.example.com:443"
  auth_token  = var.argocd_auth_token
}

# Use the module
module "web_app_production" {
  source = "./terraform-argocd-module"

  # Required variables
  app_name        = "web-app-prod"
  app_namespace   = "production"
  project_name    = "web-applications"
  repo_url        = "git@github.com:myorg/kustomize-configs.git"
  kustomize_path  = "overlays/production/web-app"

  # Authentication
  repo_auth_type      = "ssh"
  git_ssh_private_key = file("~/.ssh/argocd_deploy_key")

  # Optional: Kustomize configuration
  kustomize_name_prefix = "prod-"
  kustomize_images = [
    "web-app=registry.example.com/web-app:v2.1.0"
  ]
  kustomize_common_labels = {
    environment = "production"
    team        = "web"
  }
}
```

## Advanced Usage

### Multi-Repository Project

```hcl
module "platform_services" {
  source = "./terraform-argocd-module"

  # Basic configuration
  app_name        = "platform-core"
  app_namespace   = "platform"
  project_name    = "platform-services"
  repo_url        = "git@github.com:myorg/platform-base.git"
  kustomize_path  = "overlays/production"

  # SSH Authentication
  repo_auth_type              = "ssh"
  git_ssh_private_key        = file("~/.ssh/platform_key")
  insecure_ignore_host_key   = false

  # Multiple repositories for the project
  project_source_repos = [
    "git@github.com:myorg/shared-configs.git",
    "git@github.com:myorg/platform-addons.git",
    "https://charts.bitnami.com/bitnami"
  ]

  # Multiple deployment destinations
  project_destinations = [
    {
      server    = "https://prod-east.k8s.example.com"
      namespace = "platform"
    },
    {
      server    = "https://prod-west.k8s.example.com"
      namespace = "platform"
    }
  ]

  # Advanced sync configuration
  sync_policy_automated         = true
  sync_retry_limit             = 10
  sync_retry_backoff_duration  = "30s"
  
  # Ignore specific differences
  ignore_differences = [
    {
      group = "apps"
      kind  = "Deployment"
      json_pointers = ["/spec/replicas"]
    }
  ]
}
```

## Input Variables

### Required Variables

| Name | Description | Type |
|------|-------------|------|
| `app_name` | The name of the ArgoCD application | `string` |
| `app_namespace` | The Kubernetes namespace where the application will be deployed | `string` |
| `project_name` | The name of the ArgoCD project | `string` |
| `repo_url` | The URL of the Git repository | `string` |
| `kustomize_path` | The path within the repository to the Kustomize overlay | `string` |

### Authentication Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `repo_auth_type` | Authentication method: ssh, https, github_app, token | `string` | `"ssh"` |
| `git_ssh_private_key` | SSH private key for authentication | `string` | `""` |
| `git_username` | Username for HTTPS authentication | `string` | `""` |
| `git_password` | Password/PAT for HTTPS/token authentication | `string` | `""` |
| `github_app_id` | GitHub App ID | `string` | `""` |
| `github_app_installation_id` | GitHub App Installation ID | `string` | `""` |
| `github_app_private_key` | GitHub App private key | `string` | `""` |
| `github_enterprise_base_url` | GitHub Enterprise API base URL | `string` | `""` |

### Kustomize Configuration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `kustomize_name_prefix` | Prefix for all resources | `string` | `""` |
| `kustomize_name_suffix` | Suffix for all resources | `string` | `""` |
| `kustomize_images` | List of image overrides | `list(string)` | `[]` |
| `kustomize_common_labels` | Common labels for all resources | `map(string)` | `{}` |
| `kustomize_common_annotations` | Common annotations for all resources | `map(string)` | `{}` |
| `kustomize_version` | Kustomize version to use | `string` | `""` |

### Sync Policy Configuration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `sync_policy_automated` | Enable automated sync | `bool` | `true` |
| `sync_policy_prune` | Enable pruning of deleted resources | `bool` | `true` |
| `sync_policy_self_heal` | Enable self-healing | `bool` | `true` |
| `sync_policy_allow_empty` | Allow empty applications | `bool` | `false` |
| `sync_options` | List of sync options | `list(string)` | `["CreateNamespace=true"]` |
| `sync_retry_limit` | Maximum sync retry attempts | `number` | `5` |

For a complete list of variables, see [variables.tf](./variables.tf).

## Outputs

| Name | Description |
|------|-------------|
| `application_name` | Name of the created ArgoCD application |
| `application_namespace` | Namespace of the ArgoCD application |
| `application_sync_status` | Current sync status of the application |
| `application_health_status` | Current health status of the application |
| `project_name` | Name of the created ArgoCD project |
| `repository_url` | URL of the registered repository |
| `repository_connection_status` | Connection status of the repository |
| `application_url` | Relative URL to view the application in ArgoCD UI |

For a complete list of outputs, see [outputs.tf](./outputs.tf).

## Security Considerations

1. **SSH Keys**: Store SSH private keys securely using Terraform variables or external secret management
2. **Access Tokens**: Use environment variables or secret management systems for tokens
3. **Host Key Verification**: Set `insecure_ignore_host_key = false` in production
4. **Project Scoping**: Use project-level restrictions to limit repository and destination access
5. **RBAC**: Configure appropriate cluster and namespace resource restrictions

## Best Practices

1. **Environment Separation**: Use different projects for different environments
2. **Naming Conventions**: Use consistent naming for applications and projects
3. **Resource Limits**: Configure appropriate cluster and namespace resource whitelists
4. **Monitoring**: Use the provided outputs for monitoring and alerting
5. **Validation**: Enable application validation in production environments
6. **Git Practices**: Use signed commits and protected branches for production applications

## Examples

See [examples.tf](./examples.tf) for comprehensive usage examples including:
- SSH authentication setup
- HTTPS with Personal Access Token
- GitHub App authentication for enterprises
- Multi-repository projects
- Development environment configurations

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests and examples
5. Submit a pull request

## License

This module is licensed under the Apache License 2.0. See [LICENSE](./LICENSE) for details.

## Support

For issues and questions:
1. Check the [examples](./examples.tf) for common patterns
2. Review the ArgoCD documentation for provider-specific details
3. Open an issue with detailed information about your use case