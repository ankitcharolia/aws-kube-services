locals {
  secrets           = yamldecode(file("${path.module}/external-secrets.yaml"))
}

resource "kubectl_manifest" "external_secrets" {
  for_each          = { for externalsecret in local.secrets.externalsecrets : externalsecret.name => externalsecret }
  yaml_body         = templatefile("${path.module}/templates/ExternalSecret.yaml", {

    secret_name     = each.value.name
    namespace       = try(each.value.namespace, "default")
    secrets         = each.value.secrets
  })
}
