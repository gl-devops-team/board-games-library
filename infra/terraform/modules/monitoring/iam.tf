# --- Grafana IRSA Role ---

resource "aws_iam_role" "grafana" {
  name = "${local.name_prefix}-grafana-role"
  assume_role_policy = templatefile("${path.module}/policies/grafana-irsa-trust.json.tftpl", {
    oidc_provider_arn = var.oidc_provider_arn
    oidc_issuer       = var.oidc_issuer
  })

  tags = { Name = "${local.name_prefix}-grafana-role" }
}

resource "aws_iam_policy" "grafana_cloudwatch" {
  name   = "${local.name_prefix}-grafana-cloudwatch"
  policy = file("${path.module}/policies/cloudwatch-read.json")

  tags = { Name = "${local.name_prefix}-grafana-cloudwatch" }
}

resource "aws_iam_role_policy_attachment" "grafana" {
  role       = aws_iam_role.grafana.name
  policy_arn = aws_iam_policy.grafana_cloudwatch.arn
}
