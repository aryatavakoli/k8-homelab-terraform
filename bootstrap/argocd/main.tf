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

resource "kubernetes_manifest" "ArgoCdBootStrapProject" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "AppProject"
    metadata = {
      name      = "project-bootstrap"
      namespace = "argocd"
      finalizers = [
        "resources-finalizer.argocd.argoproj.io"
      ]
    }
    spec = {
      description = "Homelab Bootstrap Charts"
      sourceRepos = ["*"]
    }
  }
}
