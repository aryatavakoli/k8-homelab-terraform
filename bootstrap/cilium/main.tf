resource "helm_release" "cilium" {
  name             = "cilium"
  repository       = "https://helm.cilium.io/"
  chart            = "cilium"
  version          = "1.18.3"
  namespace        = "kube-system"
  create_namespace = "true"

  values = [
    file("${path.module}/values.yaml")
  ]
}