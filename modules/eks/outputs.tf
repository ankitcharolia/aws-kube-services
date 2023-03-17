output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "cluster_ca_certificate" {
  value = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_identity_oidc_issuer_url" {
  value = aws_iam_openid_connect_provider.default[0].url
}

output "cluster_identity_oidc_issuer_arn" {
  value = aws_iam_openid_connect_provider.default[0].arn
}
