module "aws_kms" {
 source = "./modules/aws-kms"

 kms_alias              = var.kms_alias
 use_aws_key_material   = var.use_aws_key_material
}