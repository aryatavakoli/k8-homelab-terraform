module "talos" {
  source = "./talos"

  providers = {
    proxmox = proxmox
  }

  image = {
    version        = "v1.7.6"
    update_version = "v1.7.6" # renovate: github-releases=siderolabs/talos
    schematic      = file("${path.module}/talos/image/schematic.yaml")
  }

  cluster = {
    name            = "talos"
    endpoint        = "172.16.1.100"
    gateway         = "172.16.1.1"
    talos_version   = "v1.7.6"
    proxmox_cluster = "homelab"
  }

  nodes = {
    "talos-0" = {
      host_node     = "talos-node-0"
      machine_type  = "controlplane"
      ip            = "172.16.1.100"
      mac_address   = "BC:24:11:2E:C8:00"
      vm_id         = 800
      cpu           = 4
      ram_dedicated = 4096
    }

    "talos-1" = {
      host_node     = "talos-node-1"
      machine_type  = "worker"
      ip            = "172.16.1.102"
      mac_address   = "BC:24:11:2E:C8:02"
      vm_id         = 802
      cpu           = 2
      ram_dedicated = 2048
    }
    "talos-2" = {
      host_node     = "talos-node-2"
      ip            = "172.16.1.103"
      mac_address   = "BC:24:11:2E:C8:02"
      vm_id         = 803
      cpu           = 2
      ram_dedicated = 2048
    }

  }

}

# module "sealed_secrets" {
#   depends_on = [module.talos]
#   source = "./bootstrap/sealed-secrets"

#   providers = {
#     kubernetes = kubernetes
#   }

#   // openssl req -x509 -days 365 -nodes -newkey rsa:4096 -keyout sealed-secrets.key -out sealed-secrets.cert -subj "/CN=sealed-secret/O=sealed-secret"
#   cert = {
#     cert = file("${path.module}/bootstrap/sealed-secrets/certificate/sealed-secrets.cert")
#     key = file("${path.module}/bootstrap/sealed-secrets/certificate/sealed-secrets.key")
#   }
# }

module "proxmox_csi_plugin" {
  depends_on = [module.talos]
  source     = "./bootstrap/proxmox-csi-plugin"

  providers = {
    proxmox    = proxmox
    kubernetes = kubernetes
  }

  proxmox = var.proxmox
}

module "volumes" {
  depends_on = [module.proxmox_csi_plugin]
  source     = "./bootstrap/volumes"

  providers = {
    restapi    = restapi
    kubernetes = kubernetes
  }
  proxmox_api = var.proxmox
  volumes = {
    pv-mini-io = {
      node = "talos-node-2"
      size = "60G"
    }
  }
}

module "helm" {
  depends_on = [module.volume]
  source     = "./bootstrap/helm"

  providers = {
    helm       = helm
    kubernetes = kubernetes
  }

}