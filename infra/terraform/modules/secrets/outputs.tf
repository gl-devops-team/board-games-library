output "db_secret_arn" {
  description = "ARN of the database credentials secret"
  value       = aws_secretsmanager_secret.db.arn
}

output "app_secret_arn" {
  description = "ARN of the application secret"
  value       = aws_secretsmanager_secret.app.arn
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for Secrets Manager encryption"
  value       = aws_kms_key.secrets.arn
}
