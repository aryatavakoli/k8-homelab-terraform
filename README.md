
# k8-homelab-terraform

## Project Overview

**k8-homelab-terraform** is a Terraform-based project designed to automate the creation of a Talos Linux cluster running on Proxmox bare-metal infrastructure. This project leverages Terraform's capabilities with the Helm, Kubernetes, and Proxmox providers to streamline the process of setting up and managing your homelab environment.

## Features

- **Automated Talos Cluster**: Easily deploy a Talos Linux-based Kubernetes cluster.
- **Proxmox Integration**: Utilize the Proxmox provider to manage VMs and resources on your bare-metal Proxmox server.
- **Helm Chart Deployments**: Deploy applications using Helm on your Kubernetes cluster.
- **Persistent Storage**: Integration with Proxmox CSI plugin for Kubernetes persistent volumes.

## Getting Started

### Prerequisites

- [Terraform](https://www.terraform.io/downloads)
- Proxmox server with API access
- Talos Linux image and Kubernetes knowledge
- SSH key pair (public key added to the Proxmox server)
- Helm installed on your local machine

### Proxmox API Token Setup

**Generate API Token**: 
   - Navigate to `Datacentre -> Permissions -> API Tokens` in Proxmox.
   - Generate an API token for the Proxmox user (e.g., `root`).

**Assign API Token Permissions**:
   - Go to `Datacentre -> Permissions -> Add`.
   - Assign the necessary permissions to the API token. For simplicity, you can assign full admin permissions if using the `root` user.

**Create `proxmox.auto.tfvars` File**:
   - In the root directory of the project, create a file named `proxmox.auto.tfvars`.
   - Populate it with the following values, replacing `<API token>` with the actual token:
     ```hcl
     proxmox = {
       name         = "pve"
       cluster_name = "homelab"
       endpoint     = "https://192.168.0.69:8006"
       insecure     = true
       username     = "root"
       api_token    = "root@pam!terraform=<API token>"
     }

**SSH Key Pair**:
   - Ensure you have an SSH key pair.
   - Add the public key to the Proxmox server for access during deployment.

### Important Configuration Notes
 
**Network Bridge Configuration**:
   In `talos/config/vm.tf`, ensure that the `network_device` block is using the correct network bridge for your Proxmox setup. By default, the line looks like this:
   ```hcl
   network_device {
     bridge      = "vmbr4"
     mac_address = each.value.mac_address
   }
   ```
   Change the `bridge` value to the one you want to use, such as `vmbr0`, which is the default for Proxmox:
   ```hcl
   bridge = "vmbr0"
   ```

**Initial Terraform Run**:
   In `talos/config.tf`, the following block manages the Talos cluster health check:
   ```hcl
   data "talos_cluster_health" "this" {
     depends_on = [
       talos_machine_configuration_apply.this,
       talos_machine_bootstrap.this
     ]
     skip_kubernetes_checks = false # set to true on first run
     client_configuration   = data.talos_client_configuration.this.client_configuration
     control_plane_nodes    = [for k, v in var.nodes : v.ip if v.machine_type == "controlplane"]
     worker_nodes           = [for k, v in var.nodes : v.ip if v.machine_type == "worker"]
     endpoints              = data.talos_client_configuration.this.endpoints
     timeouts = {
       read = "10m"
     }
   }
   ```
   Before running `terraform apply` for the first time, make sure to change `skip_kubernetes_checks` to `true`:
   ```hcl
   skip_kubernetes_checks = true
   ```
   This ensures that the cluster will be set up properly before the Kubernetes checks are performed. Once the cluster is operational, you can set it back to `false`.

**Network Configuration**:
   Network configuration must be modified with the desired values in `main.tf`. Additionally, the following resources in `bootstrap/helm/helm.tf` need to be uncommented and applied after the first run:
   ```hcl
   # resource "kubernetes_manifest" "CiliumL2AnnouncementPolicy" {
   #   depends_on = [helm_release.cilium]
   #   manifest = {
   #     "apiVersion" = "cilium.io/v2alpha1"
   #     "kind"       = "CiliumL2AnnouncementPolicy"
   #     "metadata" = {
   #       "name"      = "default-l2-announcement-policy"
   #     }
   #     "spec" = {
   #       "externalIPs"     = "true"
   #       "loadBalancerIPs" = "true"
   #     }
   #   }
   # }

   # resource "kubernetes_manifest" "CiliumLoadBalancerIPPool" {
   #   depends_on = [helm_release.cilium]
   #   manifest = {
   #     "apiVersion" = "cilium.io/v2alpha1"
   #     "kind"       = "CiliumLoadBalancerIPPool"
   #     "metadata" = {
   #       "name"      = "primary-pool"
   #     }
   #     "spec" = {
   #       "blocks" = [{
   #         "start" = "172.16.1.220"
   #         "stop"  = "172.16.1.254"
   #       }]
   #     }
   #   }
   # }
   ```
   Be sure to adjust the IP addresses in these resources to match those in `main.tf`.

### Installation

1. Clone this repository to your local machine:
   ```bash
   git clone https://github.com/yourusername/k8-homelab-terraform.git
   cd k8-homelab-terraform
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Apply the Terraform configuration:
   ```bash
   terraform apply
   ```

## Usage

Once the Terraform configuration has been applied, your Talos Linux cluster will be ready, and you can manage Kubernetes deployments via Helm. The Proxmox CSI plugin will manage persistent volumes within the cluster.

## Credits
This project is heavily inspired by this project https://github.com/vehagn/homelab