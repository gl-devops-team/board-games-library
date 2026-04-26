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
  default     = "eks"
}

variable "vpc_id" {
  description = "VPC ID where the EKS cluster is deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for EKS nodes"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for load balancers"
  type        = list(string)
}

variable "ecr_repository_arns" {
  description = "ARNs of ECR repositories the IRSA role can pull from"
  type        = list(string)
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.32"
}

variable "node_instance_types" {
  description = "EC2 instance types for the managed node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 3
}

variable "irsa_namespace" {
  description = "Kubernetes namespace of the ServiceAccount allowed to assume the IRSA role"
  type        = string
  default     = "boardgames"
}

variable "irsa_service_account_name" {
  description = "Kubernetes ServiceAccount name allowed to assume the IRSA role"
  type        = string
  default     = "external-secrets-sa"
}
