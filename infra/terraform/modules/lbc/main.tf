data "aws_caller_identity" "current" {}

# --- LBC IAM Policy ---

resource "aws_iam_policy" "lbc" {
  name        = "${local.name_prefix}-lbc-policy"
  description = "IAM policy for AWS Load Balancer Controller"
  policy      = file("${path.module}/policies/lbc-policy.json")

  tags = { Name = "${local.name_prefix}-lbc-policy" }
}

# --- LBC IRSA Role ---

resource "aws_iam_role" "lbc" {
  name = "${local.name_prefix}-lbc-role"
  assume_role_policy = templatefile("${path.module}/policies/lbc-trust.json.tftpl", {
    oidc_provider_arn = var.oidc_provider_arn
    oidc_issuer       = var.oidc_issuer
  })

  tags = { Name = "${local.name_prefix}-lbc-role" }
}

resource "aws_iam_role_policy_attachment" "lbc" {
  role       = aws_iam_role.lbc.name
  policy_arn = aws_iam_policy.lbc.arn
}
