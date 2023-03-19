locals {
  yaml_data = yamldecode(file("${path.module}/etc/charts.yaml"))
}

# FYI: https://www.sheldonhull.com/how-to-iterate-through-a-list-of-objects-with-terraforms-for-each-function/
resource "helm_release" "this" {
  for_each = { for chart in local.yaml_data.helm_charts : chart.name => chart }

  name              = each.value.name
  namespace         = try(each.value.namespace, null)
  repository        = try(each.value.repository, null)
  chart             = can(each.value.repository) ? each.value.chart : "./etc/${each.value.name}"
  version           = try(each.value.version, null)
  dependency_update = true
  force_update      = true
  create_namespace  = true

  values = [
    # chart name and folder names can't be kept same in the root helm folder. Terrafrom is throwing error for missing Charts.yaml
    try(file("./etc/${each.value.chart}/values.yaml"), "")
  ]

  dynamic "set" {
    #  for_each = can(each.value.values) ? each.value.values : []
    for_each = try(each.value.values, [])
    content {
      name  = set.key
      value = set.value
    }
  }
}

#### Retrieve Ingress Nginx Loadbalacer External IP ####
data "kubernetes_service" "nginx_ingress_controller" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
  depends_on = [
    helm_release.this["argo-apps"]
  ]
}
