variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "project" {
  description = "Project name used for resource naming and tagging"
  type        = string
  default     = "boardgames"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "component" {
  description = "Component name used for tagging"
  type        = string
  default     = "lbc"
}

variable "oidc_provider_arn" {
  description = "ARN of the EKS OIDC provider (from eks module output)"
  type        = string
}

variable "oidc_issuer" {
  description = "OIDC issuer URL without https:// prefix (from eks module output)"
  type        = string
}
