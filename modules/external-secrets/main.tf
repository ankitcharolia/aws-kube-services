terraform {
  required_providers {
    kubectl = {
      source  = "alekc/kubectl"
      version = "2.0.2"
    }
  }
}

resource "helm_release" "external_secrets" {

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

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.external_secrets_irsa.iam_role_arn
  }
}

###########################################################
# AWS IAM roles for service accounts based authentication #
###########################################################
data "aws_iam_policy_document" "external_secrets" {
  statement {
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    actions = [
      "ssm:GetParameter*"
    ]
    resources = ["*"]
    effect    = "Allow"
  }

}

resource "aws_iam_policy" "external_secrets_policy" {

  name        = "external-secrets"
  path        = "/"
  description = "Policy for external secrets service"

  policy = data.aws_iam_policy_document.external_secrets.json
}

# AWS Authentication using IAM Role based Service Account
module "external_secrets_irsa" {
  source               = "../iam-assumable-role-with-oidc"
  role_name            = "external-secrets"
  namespace            = "external-secrets"
  service_account_name = "external-secrets"
  role_policy_arns     = aws_iam_policy.external_secrets_policy.arn

  cluster_identity_oidc_issuer_url = var.cluster_identity_oidc_issuer_url
  cluster_identity_oidc_issuer_arn = var.cluster_identity_oidc_issuer_arn
}

resource "kubectl_manifest" "external_secrets" {

  yaml_body = <<YAML
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: aws-backend
spec:
  provider:
    aws:
      service: SecretsManager
      region: ${var.region}
      auth:
        jwt:
          serviceAccountRef:
            name: ${var.service_account_name}
            namespace: ${var.namespace}
YAML

  depends_on = [
    helm_release.external_secrets,
  ]
}

#####################################
# AWS IAM User based authentication #
#####################################
# resource "aws_iam_user" "external_secrets" {
#   name = "external-secrets"
#   path = "/"
# }

# data "aws_iam_policy_document" "external_secrets" {
#   statement {
#     effect    = "Allow"
#     actions   = [
#         "secretsmanager:GetResourcePolicy",
#         "secretsmanager:GetSecretValue",
#         "secretsmanager:DescribeSecret",
#         "secretsmanager:ListSecretVersionIds"
#     ]
#     resources = ["*"]
#   }
# }

# resource "aws_iam_user_policy" "external_secrets" {
#   name   = "external-secrets-policy"
#   user   = aws_iam_user.external_secrets.name
#   policy = data.aws_iam_policy_document.external_secrets.json
# }

# resource "aws_iam_access_key" "external_secrets" {
#   user = aws_iam_user.external_secrets.name
# }

# resource "kubernetes_secret" "external_secrets" {
#   metadata {
#     name      = "external-secrets"
#     namespace = "external-secrets"
#   }

#   data = {
#     access-key = aws_iam_access_key.external_secrets.id
#     secret-key = aws_iam_access_key.external_secrets.secret
#   }

#   type = "Opaque"
# }


# resource "kubectl_manifest" "external_secrets" {

#   yaml_body = <<YAML
# apiVersion: external-secrets.io/v1beta1
# kind: ClusterSecretStore
# metadata:
#   name: aws-backend
# spec:
#   provider:
#     aws:
#       service: SecretsManager
#       region: ${var.region}
#       auth:
#         secretRef:
#           accessKeyIDSecretRef:
#             name: external-secrets
#             key: access-key
#             namespace: external-secrets
#           secretAccessKeySecretRef:
#             name: external-secrets
#             key: secret-key
#             namespace: external-secrets
# YAML

#   depends_on = [
#     helm_release.external_secrets,
#   ]
# }