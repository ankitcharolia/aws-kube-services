resource "kubernetes_secret" "kubernetes_certificate" {
  metadata {
    name = "kubernetes-pod-certificate"
  }

  data = {
    "wildcard-default.svc.cluster.local.crt" = file("${path.module}/default.svc.cluster.local/wildcard-default.svc.cluster.local.crt")
    "wildcard-default.svc.cluster.local.key" = file("${path.module}/default.svc.cluster.local/wildcard-default.svc.cluster.local.key")
    "rootCA.crt"                             = file("${path.module}/default.svc.cluster.local/rootCA.crt")
  }

  type = "Opaque"
}
