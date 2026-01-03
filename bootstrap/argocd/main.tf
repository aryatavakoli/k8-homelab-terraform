resource "helm_release" "argocd" {
  name             = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "9.2.4"
  namespace        = "argocd"
  create_namespace = "true"

  values = [
    file("${path.module}/values.yaml")
  ]
}