locals {
  project_vars              = yamldecode(file("${path.module}/argo-apps.yaml"))
}

resource "kubectl_manifest" "argocd_projects" {
  for_each              = { for project in local.project_vars.projects : project.name => project }
  yaml_body             = templatefile("${path.module}/templates/projects.yaml", {

    project_name        = each.value.name
    project_namespace   = each.value.namespace
    project_description = each.value.description
    sourceRepos         = each.value.sourceRepos
    roles               = each.value.roles
    destinations        = each.value.destinations
  })
}
