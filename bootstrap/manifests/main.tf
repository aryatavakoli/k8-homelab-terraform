resource "kubernetes_manifest" "CiliumL2AnnouncementPolicy" {
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
  manifest = {
    "apiVersion" = "cilium.io/v2alpha1"
    "kind"       = "CiliumLoadBalancerIPPool"
    "metadata" = {
      "name" = "primary-cilium-ip-pool"
    }
    "spec" = {
      "blocks" = [{
        "start" = "${var.ip-subnet}.200"
        "stop"  = "${var.ip-subnet}.254"
      }]
    }
  }
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

resource "kubernetes_manifest" "ArgoCdServicesProject" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "AppProject"
    metadata = {
      name      = "project-services"
      namespace = "argocd"
      finalizers = [
        "resources-finalizer.argocd.argoproj.io"
      ]
    }
    spec = {
      description = "Homelab Services Charts"
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

resource "kubernetes_manifest" "ArgoCdHomeLabServicesApplication" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "homelab-services"
      namespace = "argocd"
      finalizers = [
        "resources-finalizer.argocd.argoproj.io"
      ]
    }
    spec = {
      project = "project-services"
      destination = {
        namespace = "argocd"
        name      = "in-cluster"
      }
      source = {
        path           = "argocd/apps/services"
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
