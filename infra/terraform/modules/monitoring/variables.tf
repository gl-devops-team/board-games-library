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
  default     = "monitoring"
}

variable "cluster_name" {
  description = "EKS cluster name — used to construct Container Insights log group paths"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the EKS OIDC provider for IRSA"
  type        = string
}

variable "oidc_issuer" {
  description = "OIDC issuer hostname without the https:// prefix (e.g. oidc.eks.eu-central-1.amazonaws.com/id/…)"
  type        = string
}