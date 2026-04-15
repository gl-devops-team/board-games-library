output "tfstate_bucket_name" {
  description = "Name of the S3 bucket used for storing Terraform state"
  value       = aws_s3_bucket.tfstate.bucket
}

output "tfstate_bucket_arn" {
  description = "ARN of the S3 bucket used for storing Terraform state"
  value       = aws_s3_bucket.tfstate.arn
}

output "github_core_tfstate_policy_arn" {
  description = "ARN of the IAM policy granting GitHub core workflow access to Terraform state bucket"
  value       = aws_iam_policy.github_core_tfstate_access.arn

}