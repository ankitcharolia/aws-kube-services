terraform {
  required_providers {
    kubectl = {
      source  = "alekc/kubectl"
      version = "2.0.1"
    }
  }
}

resource "kubectl_manifest" "argocd_application" {

  dynamic "wait_for" {
    for_each = try(var.wait_for, [])
      content {
        field {
          key   = wait_for.key
          value = wait_for.value
        }
      }
  }

  yaml_body         = templatefile("${path.module}/templates/application.yaml", {

    name              = var.name
    namespace         = var.namespace
    prune             = var.prune
    chart             = var.chart
    selfHeal          = var.self_heal
    repoURL           = var.repo_url
    targetRevision    = var.target_revision
    path              = var.path
    values            = var.values
    valueFiles        = var.value_files
    ignoreDifferences = var.ignore_differences

  })
}
