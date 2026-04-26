data "aws_caller_identity" "current" {}

# --- EKS Cluster Role ---

resource "aws_iam_role" "cluster" {
  name               = "${local.name_prefix}-eks-cluster-role"
  assume_role_policy = file("${path.module}/policies/cluster-trust.json.tftpl")

  tags = { Name = "${local.name_prefix}-eks-cluster-role" }
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# --- EKS Node Role ---

resource "aws_iam_role" "node" {
  name               = "${local.name_prefix}-eks-node-role"
  assume_role_policy = file("${path.module}/policies/node-trust.json.tftpl")

  tags = { Name = "${local.name_prefix}-eks-node-role" }
}

resource "aws_iam_role_policy_attachment" "node_worker" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_cni" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_ecr" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "node_ebs_csi" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# --- IRSA Role ---

resource "aws_iam_role" "irsa" {
  name = "${local.name_prefix}-irsa-role"
  assume_role_policy = templatefile("${path.module}/policies/irsa-trust.json.tftpl", {
    oidc_provider_arn = aws_iam_openid_connect_provider.eks.arn
    oidc_issuer       = replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")
  })

  tags = { Name = "${local.name_prefix}-irsa-role" }
}

resource "aws_iam_policy" "irsa" {
  name = "${local.name_prefix}-irsa-permissions"
  policy = templatefile("${path.module}/policies/irsa-permissions.json.tftpl", {
    ecr_repository_arns = jsonencode(var.ecr_repository_arns)
    aws_region          = var.aws_region
    account_id          = data.aws_caller_identity.current.account_id
    name_prefix         = local.name_prefix
  })

  tags = { Name = "${local.name_prefix}-irsa-permissions" }
}

resource "aws_iam_role_policy_attachment" "irsa" {
  role       = aws_iam_role.irsa.name
  policy_arn = aws_iam_policy.irsa.arn
}
