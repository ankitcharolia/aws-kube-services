module "aws_eks" {
  source = "./modules/eks"

  vpc_id             = module.aws_vpc.vpc_id
  subnet_ids         = module.aws_vpc.private_subnet_id
  kubernetes_version = var.kubernetes_version
  project            = var.project
  eks_node_groups    = var.eks_node_groups
  aws_eks_addons     = var.aws_eks_addons
}