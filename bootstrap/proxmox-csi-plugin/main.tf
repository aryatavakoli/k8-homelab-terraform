resource "kubernetes_namespace" "csi-proxmox" {
  metadata {
    name = "csi-proxmox"
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/audit"   = "baseline"
      "pod-security.kubernetes.io/warn"    = "baseline"
    }
  }
}

resource "kubernetes_secret" "proxmox-csi-plugin" {
  metadata {
    name      = "proxmox-csi-plugin"
    namespace = kubernetes_namespace.csi-proxmox.id
  }

  data = {
    "config.yaml" = <<EOF
clusters:
- url: "${var.proxmox.endpoint}/api2/json"
  insecure: ${var.proxmox.insecure}
  token_id: "${proxmox_virtual_environment_user_token.kubernetes-csi-token.id}"
  token_secret: "${element(split("=", proxmox_virtual_environment_user_token.kubernetes-csi-token.value), length(split("=", proxmox_virtual_environment_user_token.kubernetes-csi-token.value)) - 1)}"
  region: ${var.proxmox.cluster_name}
EOF
  }
}

resource "helm_release" "proxmox-csi-plugin" {
  depends_on       = [kubernetes_secret.proxmox-csi-plugin, kubernetes_namespace.csi-proxmox]
  name             = "proxmox-csi-plugin"
  repository       = "oci://ghcr.io/sergelogvinov/charts"
  chart            = "proxmox-csi-plugin"
  version          = "0.2.9"
  namespace        = "csi-proxmox"
  create_namespace = "true"

  values = [
    file("${path.module}/values.yaml")
  ]
}