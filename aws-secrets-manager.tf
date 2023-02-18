module "aws_secrets_manager" {
 source = "./modules/aws-secrets-manager"

 environment  = var.environment
}