terraform {
  required_providers {
    kubectl = {
      source  = "alekc/kubectl"
      version = "2.0.1"
    }
  }
}

resource "helm_release" "argocd" {

  name              = var.name
  namespace         = var.namespace
  repository        = var.chart_repository
  chart             = var.chart_name
  version           = var.chart_version
  dependency_update = true
  force_update      = true
  create_namespace  = true
  atomic            = true
  wait              = true
  cleanup_on_fail   = true
  max_history       = 5
  timeout           = 600

  values = [
    file("./charts/argo-cd/values.yaml")
  ]

}


resource "kubectl_manifest" "gitlab_external_secret" {

  yaml_body = templatefile("${path.module}/github-repo-external-secrets.yaml", {
    github_repo_url = var.github_repo_url,
  })

  depends_on = [
    helm_release.argocd,
  ]
}

resource "kubectl_manifest" "argocd_vsvc" {

  yaml_body = templatefile("${path.module}/argocd-vsvc.yaml", {
    domain = var.public_zone_name,
  })

  depends_on = [
    helm_release.argocd,
  ]
}