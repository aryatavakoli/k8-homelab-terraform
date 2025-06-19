resource "helm_release" "argocd" {
  name             = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "7.5.2"
  namespace        = "argocd"
  create_namespace = "true"

  values = [
    file("${path.module}/values.yaml")
  ]
}