resource "kubernetes_namespace" "sealed-secrets" {
  metadata {
    name = "sealed-secrets"
  }
}

resource "kubernetes_secret" "sealed-secrets-key" {
  depends_on = [kubernetes_namespace.sealed-secrets]
  type       = "kubernetes.io/tls"

  metadata {
    name      = "sealed-secrets-bootstrap-key"
    namespace = "sealed-secrets"
    labels = {
      "sealedsecrets.bitnami.com/sealed-secrets-key" = "active"
    }
  }

  data = {
    "tls.crt" = var.cert.cert
    "tls.key" = var.cert.key
  }
}

resource "helm_release" "sealed-secrets" {
  depends_on       = [kubernetes_namespace.sealed-secrets, kubernetes_secret.sealed-secrets-key]
  name             = "sealed-secrets"
  repository       = "oci://registry-1.docker.io/bitnamicharts"
  chart            = "sealed-secrets-controller"
  version          = "2.4.5"
  namespace        = "sealed-secrets"
  create_namespace = "true"

  values = [
    file("${path.module}/values.yaml")
  ]
}