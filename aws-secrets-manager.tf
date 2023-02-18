module "aws_kms" {
 source = "./modules/aws-secrets-manager"

 environment  = var.environment
}