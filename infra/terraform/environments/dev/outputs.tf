output "irsa_role_arn" {
  description = "ARN of the IRSA role — use when applying infra/k8s/eso/service-account.yaml"
  value       = module.eks.irsa_role_arn
}
