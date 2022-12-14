locals {
  grafana_dashboards = var.enable_grafana_dashboards ? concat(
  tolist(fileset(path.module, "../dashboards/applications/*.json")), tolist(fileset(path.module, "../dashboards/infrastructure/*.json"))
  ) : tolist([])
}

resource "kubernetes_config_map" "grafana_dashboards" {
  for_each = toset(local.grafana_dashboards)

  metadata {
    annotations = {
      k8s-sidecar-target-directory: "/tmp/dashboards/${trimsuffix(basename(each.key), "-grafana-dashboard.json")}"
    }
    name        = "${trimsuffix(basename(each.key), ".json")}"
    namespace   = "default"
    labels = {
      grafana_dashboard = "1"
    }
  }

  data = {
    "${basename(each.key)}" = file(each.key)
  }
}
