argocd_repository_certificate (Resource)
Manages custom TLS certificates used by ArgoCD for connecting Git repositories.

Example Usage
# HTTPS certificate
resource "argocd_repository_certificate" "private-git-repository" {
  https {
    server_name = "private-git-repository.local"
    cert_data   = <<EOT
-----BEGIN CERTIFICATE-----\nfoo\nbar\n-----END CERTIFICATE-----
EOT
  }
}

# SSH certificate
resource "argocd_repository_certificate" "private-git-repository" {
  ssh {
    server_name  = "private-git-repository.local"
    cert_subtype = "ssh-rsa"
    cert_data    = <<EOT
AAAAB3NzaC1yc2EAAAADAQABAAABgQCiPZAufKgxwRgxP9qy2Gtub0FI8qJGtL8Ldb7KatBeRUQQPn8QK7ZYjzYDvP1GOutFMaQT0rKIqaGImIBsztNCno...
EOT
  }
}
Copy
Schema
Optional
https (Block List) HTTPS certificate configuration (see below for nested schema)
ssh (Block List) SSH certificate configuration (see below for nested schema)
Read-Only
id (String) Repository certificate identifier

Nested Schema for https
Required:

cert_data (String) The actual certificate data, dependent on the certificate type
server_name (String) DNS name of the server this certificate is intended for
Read-Only:

cert_info (String) Additional certificate info, dependent on the certificate type (e.g. SSH fingerprint, X509 CommonName)
cert_subtype (String) The sub type of the cert, i.e. ssh-rsa

Nested Schema for ssh
Required:

cert_data (String) The actual certificate data, dependent on the certificate type
cert_subtype (String) The sub type of the cert, i.e. ssh-rsa
server_name (String) DNS name of the server this certificate is intended for
Read-Only:

cert_info (String) Additional certificate info, dependent on the certificate type (e.g. SSH fingerprint, X509 CommonName)