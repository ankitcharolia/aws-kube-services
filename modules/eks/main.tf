resource "aws_cloudwatch_log_group" "cluster" {
  # Reference: https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html
  name              = "/eks/${var.project}-kube-cluster/cluster"
  retention_in_days = 0
}

# EKS Cluster Security Group
resource "aws_security_group" "eks_master" {
  name        = "${var.project}-eks-cluster-sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project}-cluster-sg"
  }
}

resource "aws_security_group_rule" "master_inbound" {
  description              = "Allow worker nodes to communicate with the cluster API Server"
  to_port                  = 443
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_master.id
  source_security_group_id = aws_security_group.eks_nodes.id
  type                     = "ingress"
}

resource "aws_security_group_rule" "master_outbound" {
  description              = "Allow cluster API Server to communicate with the worker nodes"
  from_port                = 1024
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_master.id
  source_security_group_id = aws_security_group.eks_nodes.id
  type                     = "egress"
}

# Create EKS Cluster
resource "aws_eks_cluster" "this" {
  name                      = "${var.project}-kube-cluster"
  role_arn                  = aws_iam_role.master.arn
  version                   = var.kubernetes_version
  enabled_cluster_log_types = ["api", "audit", "controllerManager", "scheduler", "authenticator"]

  vpc_config {
    security_group_ids      = [aws_security_group.eks_master.id, aws_security_group.eks_nodes.id]
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project}-kube-cluster"
  }

  depends_on = [
    aws_iam_role_policy_attachment.master_cluster_policy,
    aws_iam_role_policy_attachment.master_service_policy,
    aws_cloudwatch_log_group.cluster
  ]
}


################
# WORKER NODES #
################

# EKS Node Groups
resource "aws_eks_node_group" "this" {
  for_each      = { for node_group in var.eks_node_groups : node_group.capacity_type => node_group }

  cluster_name    = aws_eks_cluster.this.name
  version         = aws_eks_cluster.this.version
  node_group_name = each.value.node_group_name
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = each.value.desired_size
    max_size     = each.value.max_size
    min_size     = each.value.min_size
  }

  ami_type       = "AL2_x86_64" # AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64, CUSTOM
  capacity_type  = try(each.value.capacity_type, var.capacity_type)
  disk_size      = try(each.value.disk_size, 50)
  instance_types = each.value.instance_types

  dynamic "taint" {
    for_each = try(each.value.taints, [])

    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }

  update_config {
    max_unavailable = each.value.max_unavailable
  }

  labels = each.value.labels

  tags = {
    Name        = "${var.project}-kube-cluster"
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_policy,
    aws_iam_role_policy_attachment.node_cni_policy,
    aws_iam_role_policy_attachment.node_container_registry_ro,
  ]

  # when autoscaler is enabled, desired_size needs to be ignored
  # better would be to handle this in the resource and not require
  # desired_size, min_size and max_size in scaling_config
  lifecycle {
    create_before_destroy = true
    ignore_changes = [scaling_config[0].desired_size]
  }
}

# EKS Node Security Group
resource "aws_security_group" "eks_nodes" {
  name        = "${var.project}-node-sg"
  description = "Security group for all nodes in the cluster"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "${var.project}-eks-node-sg"
    "kubernetes.io/cluster/${var.project}-kube-cluster" = "owned"
  }
}

resource "aws_security_group_rule" "nodes_internal" {
  description              = "Allow nodes to communicate with each other"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_nodes.id
  type                     = "ingress"
}

resource "aws_security_group_rule" "nodes_cluster_inbound" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_master.id
  type                     = "ingress"
}

# install AWS EKS add-ons
resource "aws_eks_addon" "this" {
  for_each          = var.aws_eks_addons

  cluster_name      = aws_eks_cluster.this.name
  addon_name        = each.value
  resolve_conflicts = "NONE"
}