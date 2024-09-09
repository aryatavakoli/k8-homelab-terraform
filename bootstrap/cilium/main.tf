resource "helm_release" "cilium" {
  name             = "cilium"
  repository       = "https://helm.cilium.io/"
  chart            = "cilium"
  version          = "1.16.1"
  namespace        = "kube-system"
  create_namespace = "true"

  values = [
    file("${path.module}/values.yaml")
  ]
}

resource "kubernetes_manifest" "CiliumL2AnnouncementPolicy" {
  depends_on = [helm_release.cilium]
  manifest = {
    "apiVersion" = "cilium.io/v2alpha1"
    "kind"       = "CiliumL2AnnouncementPolicy"
    "metadata" = {
      "name" = "default-l2-announcement-policy"
    }
    "spec" = {
      "externalIPs"     = "true"
      "loadBalancerIPs" = "true"
    }
  }
}

resource "kubernetes_manifest" "CiliumLoadBalancerIPPool" {
  depends_on = [helm_release.cilium]
  manifest = {
    "apiVersion" = "cilium.io/v2alpha1"
    "kind"       = "CiliumLoadBalancerIPPool"
    "metadata" = {
      "name" = "primary-cilium-ip-pool"
    }
    "spec" = {
      "blocks" = [{
        "start" = "${var.ip-subnet}.220"
        "stop"  = "${var.ip-subnet}.254"
      }]
    }
  }
}
