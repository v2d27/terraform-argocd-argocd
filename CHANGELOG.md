# Changelog

All notable changes to this terraform-argocd-module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2025-08-12

### 🚀 Major Features Added

#### Multiple Authentication Support
- **SSH Authentication**: Enhanced SSH key support with host key verification options
- **HTTPS Authentication**: Username/password and Personal Access Token support
- **GitHub App Authentication**: Full GitHub App integration with enterprise support
- **Token Authentication**: Generic token-based authentication for various Git providers

#### Enhanced Project Management
- **Multi-Repository Projects**: Support for multiple source repositories per project
- **Multi-Destination Support**: Deploy to multiple Kubernetes clusters from single project
- **Advanced RBAC**: Comprehensive cluster and namespace resource whitelisting/blacklisting
- **Project Metadata**: Rich labeling and annotation support

#### Advanced Kustomize Configuration
- **Image Overrides**: Comprehensive image replacement support
- **Name Transformations**: Prefix and suffix support for all resources
- **Common Labels/Annotations**: Apply consistent metadata across all resources
- **Version Pinning**: Specify exact Kustomize version for reproducible builds
- **Patch Support**: Ready for custom Kustomize patches (via ignore_differences)

#### Sophisticated Sync Policies
- **Conditional Automation**: Enable/disable automated sync per environment
- **Retry Mechanisms**: Configurable retry logic with exponential backoff
- **Selective Sync Options**: Granular control over sync behavior
- **Allow Empty Applications**: Support for app-of-apps patterns
- **Advanced Validation**: Application spec validation with override options

### 🔧 Enhanced Configuration

#### Security Improvements
- **Input Validation**: Comprehensive validation for all user inputs
- **Secure Defaults**: Security-first default configurations
- **Secret Handling**: Proper sensitive variable marking and handling
- **Host Key Verification**: Configurable SSH host key verification

#### Operational Excellence
- **Comprehensive Outputs**: 15+ outputs for monitoring and integration
- **Status Reporting**: Real-time application health and sync status
- **URL Generation**: Direct links to ArgoCD UI for applications and projects
- **Lifecycle Management**: Proper resource lifecycle and dependency management

#### Developer Experience
- **Rich Examples**: 5 comprehensive usage examples covering all scenarios
- **Validation Helpers**: Built-in validation for common configuration errors
- **Intelligent Defaults**: Smart defaults that work for most use cases
- **Comprehensive Documentation**: Detailed README with security best practices

### 📦 Provider Updates

#### ArgoCD Provider
- **Updated to >= 8.0.0**: Latest provider version with enhanced features
- **Terraform >= 1.9.0**: Support for latest Terraform features
- **Kubernetes >= 2.30.0**: Updated Kubernetes provider compatibility

### 🏗️ Infrastructure Improvements

#### Code Organization
- **locals.tf**: Centralized local value computations and validation
- **Modular Structure**: Clean separation of concerns across files
- **Type Safety**: Comprehensive variable type definitions and constraints
- **Error Handling**: Graceful handling of configuration errors

#### Testing & Validation
- **Input Validation**: Regex validation for critical inputs
- **Authentication Validation**: Runtime validation of auth configurations  
- **Dependency Validation**: Proper resource dependency management

### 📚 Documentation

#### Comprehensive Guides
- **README.md**: Complete usage guide with security considerations
- **examples.tf**: 5 real-world usage examples
- **terraform.tfvars.example**: Comprehensive configuration template
- **CHANGELOG.md**: Detailed change documentation

#### Best Practices
- **Security Guidelines**: Comprehensive security recommendations
- **Operational Best Practices**: Production-ready configuration guidance
- **Troubleshooting**: Common issues and solutions
- **Integration Patterns**: How to integrate with existing infrastructure

### 🔄 Migration Guide

#### From v1.x to v2.0

**Breaking Changes:**
1. `git_ssh_private_key` is now conditional based on `repo_auth_type`
2. `sync_option_create_namespace` replaced with `sync_options` array
3. Provider version requirements updated

**Migration Steps:**
1. Update provider versions in your `versions.tf`
2. Add `repo_auth_type = "ssh"` if using SSH (maintains compatibility)
3. Replace `sync_option_create_namespace = true` with `sync_options = ["CreateNamespace=true"]`
4. Update any pinned module versions

**New Required Variables:**
- None - all new features have sensible defaults

**Recommended Updates:**
- Review security settings (`insecure_ignore_host_key`)
- Consider using new labeling and annotation features
- Evaluate new sync policy options for your use case

### 🎯 Use Cases Now Supported

#### Enterprise Scenarios
- **GitHub Enterprise**: Full GitHub Enterprise integration
- **Multi-Cluster Deployments**: Deploy across multiple Kubernetes clusters
- **Advanced RBAC**: Fine-grained permission control
- **Compliance Requirements**: Security-first configurations

#### Development Workflows  
- **Feature Branch Testing**: Development-specific configurations
- **Staging Environments**: Staging-optimized sync policies
- **Production Deployments**: High-availability configurations
- **App-of-Apps Pattern**: Empty application support

#### Operational Patterns
- **GitOps at Scale**: Multi-repository project management
- **Progressive Delivery**: Advanced sync and rollback options
- **Observability Integration**: Rich outputs for monitoring
- **Disaster Recovery**: Multi-cluster deployment support

### 📊 Metrics & Observability

#### New Outputs Available
- Application health and sync status
- Repository connection status
- Project and application metadata
- Direct UI links for easy access
- Configuration summaries

#### Integration Ready
- **Monitoring Systems**: Status outputs for alerting
- **CI/CD Pipelines**: Validation and deployment status
- **Documentation Systems**: Automatic documentation generation
- **Audit Systems**: Comprehensive configuration tracking

## [1.0.0] - 2025-08-01

### Initial Release
- Basic ArgoCD application creation
- SSH authentication support
- Simple Kustomize configuration
- Basic sync policy support
- Single repository per project
