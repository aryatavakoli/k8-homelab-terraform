resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argocd"
  version          = "7.5.2"
  namespace        = "argocd"
  create_namespace = "true"

  values = [
    file("${path.module}/values.yaml")
  ]
}