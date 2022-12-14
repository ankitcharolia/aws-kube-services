# cert-manager needs to be able to add records to CloudDNS in order to solve the DNS01 challenge.
# To enable this, a GCP service account must be created with the dns.admin role.
resource "google_project_iam_member" "project_iam_policy_binding" {
  project = var.project
  role    = "roles/dns.admin"
  member = "serviceAccount:${var.cert_manager_email}"
}

# Read the data from google secret manager
data "google_secret_manager_secret_version" "service_account_json_key_secret" {
  secret = var.cert_manager_secret_id
}

# create kubernetes secret from gcp secret manager secret
resource "kubernetes_secret" "json_key" {
  metadata {
    name = "clouddns-dns01-solver-svc-acct"
    namespace = "cert-manager"
  }

  data = {
    "key.json" = data.google_secret_manager_secret_version.service_account_json_key_secret.secret_data
  }

  type = "Opaque"
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
