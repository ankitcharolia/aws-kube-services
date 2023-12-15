terraform {
  required_providers {
    kubectl = {
      source  = "alekc/kubectl"
      version = "2.0.4"
    }
  }
}

data "aws_iam_policy_document" "cert_manager" {
  statement {
    actions = [
      "route53:GetChange",
    ]
    resources = ["arn:aws:route53:::change/*"]
    effect    = "Allow"
  }

  statement {
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets",
    ]
    resources = ["arn:aws:route53:::hostedzone/*"]
    effect    = "Allow"
  }

  statement {
    actions = [
      "route53:ListHostedZonesByName",
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "cert_manager_policy" {
  name        = "cert-manager-policy"
  path        = "/"
  description = "Policy, which allows CertManager to create Route53 records"
  policy      = data.aws_iam_policy_document.cert_manager.json
}

# AWS Authentication using IAM Role based Service Account 
module "cert_manager_irsa" {
  source               = "../iam-assumable-role-with-oidc"
  role_name            = "cert-manager"
  namespace            = "cert-manager"
  service_account_name = "cert-manager"
  role_policy_arns     = aws_iam_policy.cert_manager_policy.arn

  cluster_identity_oidc_issuer_url = var.cluster_identity_oidc_issuer_url
  cluster_identity_oidc_issuer_arn = var.cluster_identity_oidc_issuer_arn
}

module "cert_manager" {

  source          = "../argo-apps"
  name            = "cert-manager"
  chart           = "cert-manager"
  namespace       = "cert-manager"
  repo_url        = "https://charts.jetstack.io"
  target_revision = var.target_revision

  values = yamldecode(templatefile("${path.module}/values.yaml.tftpl", {
    cert_manager_iam_role_arn = module.cert_manager_irsa.iam_role_arn
  }))
  value_files = [
    "$gitRepo/charts/cert-manager/values.yaml",
  ]

  depends_on = [
    module.cert_manager_irsa,
  ]
}

# Create Cluster Secret Store
# Reference: https://medium.com/@danieljimgarcia/dont-use-the-terraform-kubernetes-manifest-resource-6c7ff4fe629a
resource "kubectl_manifest" "cert_manager_cluster_issuer" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt
  namespace: cert-manager
spec:
  acme:
    # The ACME server URL
    server: "https://acme-v02.api.letsencrypt.org/directory"
    # Email address used for ACME registration
    email: ankitcharolia@gmail.com
    # Name of a secret used to store the ACME account private key
    privateKeySecretRef:
      name: letsencrypt
    # Enable the DNS-01 challenge provider
    solvers:
    - dns01:
        route53:
          region: ${var.region}
YAML

  depends_on = [
    module.cert_manager,
  ]
}
