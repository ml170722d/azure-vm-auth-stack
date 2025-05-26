# Project Overview

This repository demonstrates the deployment of a secured static web application environment on Microsoft Azure. It provisions a VM hosting a minimal container runtime, runs Keycloak (for authentication) alongside a PostgreSQL database, and an Nginx web server serving a static page protected by Keycloak.

---

## Features

- Infrastructure as Code: Azure resources defined with Terraform.
- Configuration Management: VM and container setup automated with Ansible.
- Container Environment: Docker chosen for simplicity and ubiquity.
- Authentication: Keycloak container for OAuth2/OpenID Connect.
- Database: PostgreSQL container for Keycloak user store.
- Web Server: Nginx serving a static website secured behind Keycloak.
- CI/CD: GitHub Actions pipelines to deploy, configure, and teardown.

---

## Repository Structure

```txt
├── .github/workflows     # GitHub Actions definitions
├── ansible/              # Ansible playbooks and roles
├── terraform/            # Terraform modules and root configs
├── docs/                 # Architecture diagrams and documentation
│   └── infrastructure.md
└── README.md             # Project overview and quickstart
```

---

## Prerequisites

- Azure subscription (free trial or pay-as-you-go)
- Terraform v1.0+
- Ansible 2.9+
- Docker installed on target VM
- GitHub account with Actions enabled

## Quickstart

1. Clone repository

```bash
git clone https://github.com/<your-org>/azure-secure-web.git
cd azure-secure-web
```

2. Provision Azure Infrastructure

```bash
cd terraform
terraform init
terraform apply --auto-approve
```

3. Configure VM and Containers

```bash
python3 -m venv .venv
source .venv/bin/activate
cd ../ansible
ansible-playbook -i inventory azure-vm-setup.yml
```

4. Access the Application

- Open http://<VM_PUBLIC_IP>/ in a browser.
- You will be redirected to Keycloak for authentication.

## GitHub Actions

- deploy.yml: Runs Terraform apply and Ansible to roll out.
- destroy.yml: Runs Terraform destroy for cleanup.

## Next Steps

- Refer to docs/infrastructure.md for detailed architecture and justification of components.
