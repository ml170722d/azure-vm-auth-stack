
# Architecture & Component Justification

This document explains:

1. Azure infrastructure layout (provisioned by Terraform).
2. Container environment choice and design.
3. Network configuration and security considerations.
4. Why each component was chosen over alternatives.

---

## 1. Azure Infrastructure Overview

All Azure resources are provisioned via Terraform. We create:

1. **Resource Group (`hylastix-rg`)**
   - Logical container for all resources.
   - Simplifies cleanup: deleting the RG removes everything inside.

2. **Virtual Network & Subnet**
   - **VNet**: `hylastix-vnet` with address space `10.0.0.0/16`.
   - **Subnet**: `hylastix-subnet` within that VNet, CIDR `10.0.1.0/24`.
   - Keeps all VM and related resources isolated.

3. **Network Security Group (`hylastix-nsg`)**
   - Attached to the VM’s NIC.
   - Only allows:
     - **SSH (TCP/22)** from any source (for administration).
     - **HTTP (TCP/80)** from any source (to serve the web page).
   - Implicitly denies all other inbound traffic, following “deny by default.”

4. **Public IP (`hylastix-pub-ip`)**
   - A static IPv4 address assigned to the VM’s NIC.
   - Used by admins (SSH) and users (HTTP).

5. **Network Interface (`hylastix-nic`)**
   - Joined to `hylastix-subnet`.
   - Receives the public IP and is associated with `hylastix-nsg`.

6. **Linux Virtual Machine (`hylastix-vm`)**
   - Ubuntu 22.04 LTS image (official Canonical).
   - Size: `Standard_B2ls_v2` (kept small to stay within free‐tier or low cost).
   - Admin user: `luka`, configured via SSH public key.
   - Docker and Docker Compose installed by Ansible after provisioning.

When complete, we have one VM in a secured VNet, reachable over SSH (port 22) and HTTP (port 80).

![Infrastructure Diagram](docs/assets/infrastructure_resource_setup.png)

> **Figure:**
> Resource Group → VNet → Subnet → NIC + NSG → VM + Public IP

---

## 2. Container Environment Choice

We chose **Docker CE** (installed via Ansible) rather than Podman, Kubernetes, or AKS because:

- **Simplicity & Speed**: Docker is familiar and quick to set up on a single VM.
- **Docker Compose**: Allows us to define Keycloak, Postgres, and Nginx services in one `docker-compose.yaml`.
- **Lightweight**: Less overhead than running a Kubernetes control plane on a small VM.
- **Future migration**: If needed, these same images can move to AKS or another orchestrator with minimal changes.

Ansible’s **install** role takes care of:
- Installing Docker Engine (`docker-ce`), CLI, and dependencies.
- Installing the `docker-compose` plugin.
- Ensuring the Docker daemon is running and enabled.

---

## 3. Software Components & Justification

| Component              | Purpose                                            | Image (Source)            | Rationale / Alternatives                                   |
|------------------------|----------------------------------------------------|---------------------------|-------------------------------------------------------------|
| **Keycloak**           | OAuth2/OpenID Connect auth server                  | `jboss/keycloak:latest`   | Keycloak is open‐source, full‐featured. Alternatives like Auth0/Okta are SaaS or commercial. |
| **PostgreSQL**         | Persistent user store for Keycloak                 | `postgres:15-alpine`      | Alpine‐based image keeps footprint small. MySQL could be used but Keycloak defaults to Postgres. |
| **Nginx**              | Serves static web page + enforces Keycloak auth    | `nginx:stable`            | Apache or Caddy are alternatives; Nginx is lightweight and widely documented. |
| **Docker CE & Compose**| Runs and orchestrates the three containers on the VM| Installed via Apt & pip   | Podman or containerd are alternatives, but Docker Compose is simpler for multi‐container orchestration on one host. |

### Container Networking

- All containers—Keycloak, Postgres, and Nginx—run on a user‐defined Docker network `hylastix_net` (defined in `docker-compose.yaml.j2`).
- **Keycloak ⇄ Postgres**: Keycloak connects to `postgres:5432` using environment variables in the Compose file.
- **Nginx ⇄ Keycloak**: Nginx’s `default.conf.j2` uses an auth proxy block to redirect unauthenticated users to Keycloak’s `/auth` endpoints.

---

## 4. Network & Security Configuration

- **NSG Rules** (defined in `modules/network`):
  1. **Allow-SSH** (Priority 1001):
     - Protocol: TCP
     - Port: 22
     - Source: `*`
  2. **Allow-HTTP** (Priority 1002):
     - Protocol: TCP
     - Port: 80
     - Source: `*`

  All other inbound traffic is denied by default.
  We attach this NSG to the VM’s NIC (in `modules/network_interface`), providing host‐level security.

- **Subnet**: `10.0.1.0/24` within VNet `10.0.0.0/16`.
  We keep a single subnet for simplicity; future expansions (e.g., separate “frontend” and “backend” subnets) can be added to the map in Terraform variables.

- **VM Exposure**:
  - SSH (22) and HTTP (80) are the only open ports.
  - Keycloak listens on port 8080 internally; Nginx proxies port 80 → 8080 for auth and serves a static page when authenticated.

---

## 5. Ansible Configuration

### 5.1. Role: `install` (Ansible)

Installs Docker Engine & Docker Compose on the VM.

### 5.2. Role: `deploy` (Ansible)

Copies templates files for application configuration and starts applications.
