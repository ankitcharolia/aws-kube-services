terraform {
  required_providers {
    kubectl = {
      source  = "alekc/kubectl"
      version = "2.0.3"
    }
  }
}

module "istio_base" {

  source          = "../argo-apps"
  name            = "istio-base"
  chart           = "base"
  namespace       = "istio-system"
  repo_url        = "https://istio-release.storage.googleapis.com/charts"
  target_revision = var.target_revision

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

}

module "istiod" {

  source          = "../argo-apps"
  name            = "istiod"
  chart           = "istiod"
  namespace       = "istio-system"
  repo_url        = "https://istio-release.storage.googleapis.com/charts"
  target_revision = var.target_revision

  value_files = [
    "$gitRepo/charts/istiod/values.yaml",
  ]

  depends_on = [
    module.istio_base,
  ]
}

module "istio_ingressgateway" {

  source          = "../argo-apps"
  name            = "istio-ingressgateway"
  chart           = "gateway"
  namespace       = "istio-ingress"
  repo_url        = "https://istio-release.storage.googleapis.com/charts"
  target_revision = var.target_revision

  #   values = yamldecode(templatefile("${path.module}/values.yaml.tftpl", {
  #     loadBalancerIP = var.istio_ingress_loadbalancer_ip
  #   }))
  value_files = [
    "$gitRepo/charts/istio-ingressgateway/values.yaml",
  ]

  depends_on = [
    module.istiod,
  ]
}

# For application pods in the Istio service mesh, all traffic to/from the pods needs to go through the sidecar proxies (istio-proxy containers).
# This istio-cni Container Network Interface (CNI) plugin will set up the pods' networking to fulfill this requirement in place of the current Istio injected pod initContainers istio-init approach.
module "istio_cni" {

  source          = "../argo-apps"
  name            = "istio-cni"
  chart           = "cni"
  namespace       = "kube-system"  # Installation in kube-system is recommended to ensure the  priorityClassName can be used.
  repo_url        = "https://istio-release.storage.googleapis.com/charts"
  target_revision = var.target_revision

  depends_on = [
    module.istiod,
  ]
}

# Hide server response header
resource "kubectl_manifest" "external_secrets" {

  yaml_body = <<YAML
apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
  name: hide-server-response-header
  namespace: istio-system
spec:
  workloadSelector:
    labels:
      istio: ingressgateway
  configPatches:
  - applyTo: NETWORK_FILTER
    match:
      context: GATEWAY
      listener:
        filterChain:
          filter:
            name: "envoy.filters.network.http_connection_manager"
    patch:
      operation: MERGE
      value:
        typed_config:
          "@type": "type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager"
          server_header_transformation: PASS_THROUGH
  - applyTo: ROUTE_CONFIGURATION
    match:
      context: GATEWAY
    patch:
      operation: MERGE
      value:
        response_headers_to_remove:
        - "x-envoy-upstream-service-time"
        - "server"

YAML

  depends_on = [
    module.istio_ingressgateway,
  ]
}