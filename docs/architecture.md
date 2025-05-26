## Azure Resources

- Resource Group: Logical container for all resources.
- Virtual Network & Subnet: Isolated network for VM.
- Network Security Group: Restricts inbound/outbound traffic to VM ports (HTTP, SSH).
- Virtual Machine: Ubuntu VM for container host.
- Managed Identity: (Pre-assumed) For potential future automation.

## Container Environment Choice

- Docker: Lightweight, widely supported, simple CLI. Chosen over Podman or containerd for ecosystem maturity and community support.

## Components & Justification

| Component            | Purpose                                       | Alternative Considered        | Reason for Choice                      |
| -------------------- | --------------------------------------------- | ----------------------------- | -------------------------------------- |
| Keycloak Container   | Identity and Access Management (IAM)          | Azure AD B2C                  | Self-hosted, full control, open source |
| PostgreSQL Container | Persistent storage for Keycloak users/clients | Azure Database for PostgreSQL | Simplifies management, but adds cost   |
| Nginx Container      | Static web server                             | Azure App Service             | Simplicity, full control on VM         |
| Ubuntu VM            | Host for container runtime                    | AKS or ACI                    | Minimal overhead, fine-grained control |

## Network Configuration

- Inbound Rules (NSG):

  - TCP 80 (HTTP) from Internet
  - TCP 22 (SSH) from trusted IPs

- Outbound Rules:

  - Allow all for package updates and container pulls

## Security Considerations

- Use NSG to limit management access to SSH.
- All container images sourced from official Docker Hub repositories and pinned to stable tags.
- TLS offloading could be added in future via Azure Application Gateway.

## Terraform Structure

- modules/vnet: VNet and subnet
- modules/vm: VM and NSG
- main.tf: Calls modules, defines variables and outputs

## Ansible Playbooks

- azure-vm-setup.yml:

  - Installs Docker engine
  - Deploys containers using docker_container module
  - Configures Keycloak realm and client via CLI

## CI/CD Workflow

- deploy.yml:

  - Checkout code
  - Terraform init & apply
  - Run Ansible playbook

- destroy.yml:

  - Checkout code
  - Terraform destroy

## Future Enhancements

- TLS/SSL: Integrate Let's Encrypt or Azure Key Vault certificates.
- High Availability: Use AKS for container orchestration.
- Monitoring & Logging: Add Azure Monitor and Log Analytics.
- Auto-scaling: Implement VM Scale Sets or container auto-scaling.
- Backup & DR: Automated backups for PostgreSQL and VM snapshots.
