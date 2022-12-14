resource "helm_release" "argocd" {

  name              = var.name
  namespace         = var.namespace
  repository        = var.chart_repository
  chart             = var.chart_name
  version           = var.chart_version
  dependency_update = true
  force_update      = true
  create_namespace  = true

  values = [
    file("${path.module}/values.yaml")
  ]

}
