output "irsa_role_arn" {
  description = "ARN of the IRSA role — use when applying infra/k8s/eso/service-account.yaml"
  value       = module.eks.irsa_role_arn
}

output "lbc_role_arn" {
  description = "ARN of the LBC IRSA role — use when applying infra/k8s/lbc/service-account.yaml"
  value       = module.lbc.lbc_role_arn
}

output "vpc_id" {
  description = "VPC ID — used by AWS Load Balancer Controller"
  value       = module.networking.vpc_id
}

output "grafana_irsa_role_arn" {
  description = "ARN of the IRSA role for Grafana — set this as the eks.amazonaws.com/role-arn annotation on the grafana ServiceAccount"
  value       = module.monitoring.grafana_irsa_role_arn
}
