# Helm Charts
module "prometheus_operator_crds" {
  source = "./modules/prometheus-operator-crds"

  name                = "prometheus-operator-crds"
  namespace           = "monitoring"
  chart_repository    = "https://prometheus-community.github.io/helm-charts"
  chart_name          = "prometheus-operator-crds"
  chart_version       = "2.0.0"

  depends_on    = [
    module.aws_eks,
  ]
}

module "argocd" {
  source = "./modules/argo-cd"

  name                = "argo-cd"
  namespace           = "argocd"
  chart_repository    = "https://argoproj.github.io/argo-helm"
  chart_name          = "argo-cd"
  chart_version       = "5.27.1"
  github_repo_url     = var.github_repo_url

  depends_on =  [
    module.prometheus_operator_crds,
  ]
    
}

module "external_secrets" {
  source = "./modules/external-secrets"

  name              = "external-secrets"
  chart_name        = "external-secrets"
  namespace         = "external-secrets"
  chart_repository  = "https://charts.external-secrets.io"
  chart_version     = "0.7.2"
  region            = var.region
  cluster_identity_oidc_issuer_arn  = module.aws_eks.cluster_identity_oidc_issuer_arn
  cluster_identity_oidc_issuer_url  = module.aws_eks.cluster_identity_oidc_issuer_url

  depends_on =  [
    module.aws_eks,
  ]
}

# ArgoCD Apps
module "istio_base" {
  source = "./modules/argo-apps"

  name                     = "istio-base"
  chart                    = "base"
  namespace                = "istio-system"
  repo_url                 = "https://istio-release.storage.googleapis.com/charts"
  target_revision          = "1.17.1"
  ignore_differences = [
    {
      group = "admissionregistration.k8s.io"
      kind  = "ValidatingWebhookConfiguration"
      name  = "istiod-default-validator"
      jsonPointers = [
        "/webhooks/0/failurePolicy",
      ]
    }
  ]

  depends_on =  [
    module.argocd,
  ]
}

# module "istiod" {
#   source = "./modules/argo-apps"

#   name                      = "istiod"
#   chart                     = "istiod"
#   namespace                 = "istio-system"
#   repo_url                  = "https://istio-release.storage.googleapis.com/charts"
#   target_revision           = "1.17.1"
#   enable_multi_sources      = true
#   value_files = [
#     "$gitRepo/charts/istiod/values.yaml",
#   ]

#   depends_on =  [
#     module.istio_base,
#   ]
# }
