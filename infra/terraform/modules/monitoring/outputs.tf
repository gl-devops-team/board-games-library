output "grafana_irsa_role_arn" {
  description = "ARN of the IRSA role for Grafana — set this as the eks.amazonaws.com/role-arn annotation on the grafana ServiceAccount"
  value       = aws_iam_role.grafana.arn
}
