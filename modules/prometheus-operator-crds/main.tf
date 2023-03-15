resource "helm_release" "prometheus_operator_crds" {

  name              = var.name
  namespace         = var.namespace
  repository        = var.chart_repository
  chart             = var.chart_name
  version           = var.chart_version
  dependency_update = true
  force_update      = true
  create_namespace  = true
  cleanup_on_fail   = true
  wait              = true
  timeout           = 500
}
