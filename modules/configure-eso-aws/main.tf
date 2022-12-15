# configure service account permission to access all secrets within the project.
resource "google_project_iam_member" "project_iam_policy_binding" {
  project = var.project
  role    = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:${var.external_secrets_email}"
}

# Read the data from google secret manager
data "google_secret_manager_secret_version" "service_account_json_key_secret" {
  secret = var.external_secrets_secret_id
}

# create kubernetes secret from gcp secret manager secret
resource "kubernetes_secret" "gcpsm_secret" {
  metadata {
    name = "gcpsm-secret"
  }

  data = {
    "secret-access-credentials" = data.google_secret_manager_secret_version.service_account_json_key_secret.secret_data
  }

  type = "Opaque"
}


# Create Cluster Secret Store
# Reference: https://medium.com/@danieljimgarcia/dont-use-the-terraform-kubernetes-manifest-resource-6c7ff4fe629a
resource "kubectl_manifest" "external_secrets_vault_store" {
  yaml_body  = <<-EOF
    apiVersion: external-secrets.io/v1beta1
    kind: ClusterSecretStore
    metadata:
      name: gcp-backend
    spec:
      provider:
          gcpsm:
            auth:
              secretRef:
                secretAccessKeySecretRef:
                  name: gcpsm-secret              # secret name containing SA key
                  key: secret-access-credentials  # key name containing SA key
                  namespace: default
            projectID: ${var.project}             # name of Google Cloud project
    EOF
}
