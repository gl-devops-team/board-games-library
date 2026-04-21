output "tfstate_bucket_name" {
  description = "Name of the S3 bucket used for storing Terraform state"
  value       = data.terraform_remote_state.core.outputs.tfstate_bucket_name
}

output "github_platform_tfstate_policy_arn" {
  description = "ARN of the IAM policy granting GitHub platform workflow access to Terraform state bucket"
  value       = aws_iam_policy.github_platform_tfstate_access.arn
}
