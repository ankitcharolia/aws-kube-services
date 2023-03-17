terraform {
  required_providers {
    kubectl = {
      source  = "alekc/kubectl"
      version = "2.0.1"
    }
  }
}

resource "helm_release" "cert_manager" {

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
}

# Create Cluster Secret Store
# Reference: https://medium.com/@danieljimgarcia/dont-use-the-terraform-kubernetes-manifest-resource-6c7ff4fe629a
resource "kubectl_manifest" "cert_manager_cluster_issuer" {
  yaml_body  = <<-EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ${var.environment == "prod" ? "letsencrypt-prod" : "letsencrypt-stage"}
  namespace: cert-manager
spec:
  acme:
    # The ACME server URL
    server: ${var.environment == "prod" ? "https://acme-v02.api.letsencrypt.org/directory" : "https://acme-staging-v02.api.letsencrypt.org/directory"}
    # Email address used for ACME registration
    email: ankitcharolia@gmail.com
    # Name of a secret used to store the ACME account private key
    privateKeySecretRef:
      name: ${var.environment == "prod" ? "letsencrypt-prod" : "letsencrypt-stage"}
    # Enable the DNS-01 challenge provider
    solvers:
    - dns01:
        cloudDNS:
          project: ${var.project}
          serviceAccountSecretRef:
            name: clouddns-dns01-solver-svc-acct
            key: key.json
    EOF
}
