locals {
  app_vars          = yamldecode(file("${path.module}/argo-apps.yaml"))
}

resource "kubectl_manifest" "argocd_applications" {
  for_each          = { for app in local.app_vars.applications : app.name => app if app.enabled }
  yaml_body         = templatefile("${path.module}/templates/applications.yaml", {

    name            = each.value.name
    namespace       = each.value.namespace
    project         = each.value.project
    server          = try(each.value.server,"https://kubernetes.default.svc")
    repoURL         = each.value.source.repoURL
    targetRevision  = each.value.source.targetRevision
    path            = each.value.source.path
    chart           = try(each.value.source.chart, "")
    values          = try(each.value.source.values, "")
#    valueFiles      = try(each.value.source.valueFiles, "")

    valueFiles      = try(templatefile("${each.value.source.valueFiles}", {
      for_each      = var.valueFilesVars
      pod_name      = each.value.pod_name
      service_name  = each.value.service_name

    }), "")

  })
}
