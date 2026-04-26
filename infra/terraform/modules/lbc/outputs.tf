output "lbc_role_arn" {
  description = "ARN of the LBC IRSA role — use when applying infra/k8s/lbc/service-account.yaml"
  value       = aws_iam_role.lbc.arn
}
