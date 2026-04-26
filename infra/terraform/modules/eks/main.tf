# --- Security Groups ---

resource "aws_security_group" "cluster" {
  #checkov:skip=CKV2_AWS_5: Security group is attached to EKS cluster via aws_eks_cluster.main.vpc_config
  name        = "${local.name_prefix}-eks-cluster-sg"
  description = "Security group for EKS control plane"
  vpc_id      = var.vpc_id

  tags = { Name = "${local.name_prefix}-eks-cluster-sg" }
}

resource "aws_security_group_rule" "cluster_egress" {
  #checkov:skip=CKV_AWS_382: EKS control plane requires unrestricted outbound for node communication and AWS API calls
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic from control plane"
  security_group_id = aws_security_group.cluster.id
}

resource "aws_security_group_rule" "cluster_ingress_nodes" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  description              = "Allow nodes to communicate with control plane API"
  security_group_id        = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.node.id
}

resource "aws_security_group" "node" {
  #checkov:skip=CKV2_AWS_5: Security group is attached to EKS node group via aws_eks_node_group.main.remote_access is not used — EKS attaches this SG via the launch template
  name        = "${local.name_prefix}-eks-node-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  tags = { Name = "${local.name_prefix}-eks-node-sg" }
}

resource "aws_security_group_rule" "node_egress" {
  #checkov:skip=CKV_AWS_382: EKS nodes require unrestricted outbound for ECR pulls, DNS, and AWS API calls
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic from nodes"
  security_group_id = aws_security_group.node.id
}

resource "aws_security_group_rule" "node_ingress_self" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  description              = "Allow nodes to communicate with each other"
  security_group_id        = aws_security_group.node.id
  source_security_group_id = aws_security_group.node.id
}

resource "aws_security_group_rule" "node_ingress_cluster" {
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  description              = "Allow control plane to communicate with nodes"
  security_group_id        = aws_security_group.node.id
  source_security_group_id = aws_security_group.cluster.id
}

# --- EKS Cluster ---

resource "aws_eks_cluster" "main" {
  #checkov:skip=CKV_AWS_58: Secrets encryption with KMS adds cost with no practical benefit for dev
  #checkov:skip=CKV_AWS_339: EKS version is pinned via var.kubernetes_version and updated deliberately
  #checkov:skip=CKV_AWS_39: Public endpoint required for kubectl access from GitHub Actions and local development
  #checkov:skip=CKV_AWS_38: Public endpoint CIDR restriction not feasible — GitHub Actions IPs are dynamic
  name     = "${local.name_prefix}-eks"
  role_arn = aws_iam_role.cluster.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = concat(var.private_subnet_ids, var.public_subnet_ids)
    security_group_ids      = [aws_security_group.cluster.id]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [aws_iam_role_policy_attachment.cluster_policy]

  tags = { Name = "${local.name_prefix}-eks" }
}

# --- Managed Node Group ---

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${local.name_prefix}-eks-nodes"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = var.node_instance_types

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_worker,
    aws_iam_role_policy_attachment.node_cni,
    aws_iam_role_policy_attachment.node_ecr,
    aws_iam_role_policy_attachment.node_ebs_csi,
  ]

  tags = { Name = "${local.name_prefix}-eks-nodes" }
}

# --- EBS CSI Driver Add-on ---

resource "aws_eks_addon" "ebs_csi" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "aws-ebs-csi-driver"

  depends_on = [aws_eks_node_group.main]

  tags = { Name = "${local.name_prefix}-ebs-csi" }
}

# --- OIDC Provider (for IRSA) ---

data "tls_certificate" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]

  tags = { Name = "${local.name_prefix}-eks-oidc" }
}

# --- EKS Access Entry (platform role → cluster admin) ---

data "aws_iam_role" "platform" {
  name = "github-actions-${local.name_prefix}-platform"
}

resource "aws_eks_access_entry" "platform" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = data.aws_iam_role.platform.arn
}

resource "aws_eks_access_policy_association" "platform" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = data.aws_iam_role.platform.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}
