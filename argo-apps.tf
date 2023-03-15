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
  chart_name          = "./charts/argo-cd"

  depends_on =  [
    module.prometheus_operator_crds,
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