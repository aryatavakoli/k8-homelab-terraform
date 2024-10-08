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
  depends_on = [helm_release.argocd]
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
      destinations = [{
        namespace = "*"
        server    = "*"
      }]
      clusterResourceWhitelist = [{
        group = "*"
        kind  = "*"
      }]
    }
  }
}

resource "kubernetes_manifest" "ArgoCdHomeLabBootstrapApplication" {
  depends_on = [kubernetes_manifest.ArgoCdBootStrapProject]
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "homelab-bootstrap"
      namespace = "argocd"
      finalizers = [
        "resources-finalizer.argocd.argoproj.io"
      ]
    }
    spec = {
      project = "project-bootstrap"
      destination = {
        namespace = "argocd"
        name      = "in-cluster"
      }
      source = {
        path           = "argocd/apps/bootstrap"
        repoURL        = "https://github.com/aryatavakoli/k8-homelab-charts"
        targetRevision = "HEAD"
      }
      syncPolicy = {
        automated = {
          allowEmpty = true
          prune      = true
          selfHeal   = true
        }
        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
  }
}