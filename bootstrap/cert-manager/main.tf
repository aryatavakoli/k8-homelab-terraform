resource "helm_release" "cert-manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "1.15.3"
  namespace        = "cert-manager"
  create_namespace = "true"

  values = [
    file("${path.module}/values.yaml")
  ]
}

resource "kubernetes_manifest" "CertManagerClusterIssuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "cloudflare-cluster-issuer"
    }
    spec = {
      acme = {
        server = "https://acme-v02.api.letsencrypt.org/directory"
        email  = "example@example.com"
        privateKeySecretRef = {
          name = "cloudflare-key"
        }
        solvers = [{
          dns01 = {
            cloudflare = {
              apiTokenSecretRef = {
                name = "cloudflare-api-token"
                key  = "api-token"
              }
            }
          }
        }]
      }
    }
  }
}
