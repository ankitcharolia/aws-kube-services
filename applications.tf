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