resource "proxmox_virtual_environment_role" "csi" {
  role_id = "CSI"
  privileges = [
    "VM.Audit",
    "VM.Config.Disk",
    "Datastore.Allocate",
    "Datastore.AllocateSpace",
    "Datastore.Audit"
  ]
}

resource "proxmox_virtual_environment_user" "kubernetes-csi" {
  user_id = "kubernetes-csi@pve"
  comment = "User for Proxmox CSI Plugin"
  acl {
    path      = "/"
    propagate = true
    role_id   = proxmox_virtual_environment_role.csi.role_id
  }
}

resource "proxmox_virtual_environment_user_token" "kubernetes-csi-token" {
  comment               = "Token for Proxmox CSI Plugin"
  token_name            = "csi"
  user_id               = proxmox_virtual_environment_user.kubernetes-csi.user_id
  privileges_separation = false
}