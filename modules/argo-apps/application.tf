terraform {
  required_providers {
    kubectl = {
      source  = "alekc/kubectl"
      version = "2.0.4"
    }
  }
}

resource "kubectl_manifest" "argocd_application" {

  dynamic "wait_for" {
    for_each = length(var.wait_for) > 0 ? [1] : []
    content {
      dynamic "field" {
        for_each = var.wait_for
        content {
          key   = field.key
          value = field.value
        }
      }
    }
  }

  yaml_body = templatefile("${path.module}/templates/application.yaml", {

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
    multiSources      = var.enable_multi_sources

  })

  ignore_fields = [
    "metadata.annotations",
    "status",
    "metadata.finalizers",
    "metadata.initializers",
    "metadata.ownerReferences",
    "metadata.creationTimestamp",
    "metadata.generation",
    "metadata.resourceVersion",
    "metadata.uid",
    "metadata.annotations.kubectl.kubernetes.io/last-applied-configuration",
  ]
}
