resource "helm_release" "cilium" {
  name             = "cilium"
  repository       = "https://helm.cilium.io/"
  chart            = "cilium"
  version          = "1.16.1"
  namespace        = "kube-system"
  create_namespace = "true"

  values = [
    file("${path.module}/values/cilium.yaml")
  ]
}

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

resource "helm_release" "proxmox-csi-plugin" {
  name             = "proxmox-csi-plugin"
  repository       = "oci://ghcr.io/sergelogvinov/charts"
  chart            = "proxmox-csi-plugin"
  version          = "0.2.9"
  namespace        = "csi-proxmox"
  create_namespace = "true"

  values = [
    file("${path.module}/values/proxmox-csi-plugin.yaml")
  ]
}
