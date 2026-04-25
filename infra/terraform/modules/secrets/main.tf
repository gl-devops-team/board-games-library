data "aws_caller_identity" "current" {}

# --- KMS Key ---

resource "aws_kms_key" "secrets" {
  description             = "KMS key for ${local.name_prefix} Secrets Manager encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy = templatefile("${path.module}/policies/secrets-kms-policy.json.tftpl", {
    account_id = data.aws_caller_identity.current.account_id
  })

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-secrets-kms" })
}

resource "aws_kms_alias" "secrets" {
  name          = "alias/${local.name_prefix}-secrets"
  target_key_id = aws_kms_key.secrets.key_id
}

# --- DB Secret ---

resource "aws_secretsmanager_secret" "db" {
  #checkov:skip=CKV2_AWS_57: Automatic rotation requires Lambda-based rotator coordinating with the database — out of scope for PoC
  name        = "${local.name_prefix}-db"
  description = "PostgreSQL credentials for ${local.name_prefix} application"
  kms_key_id  = aws_kms_key.secrets.arn

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-db" })
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    user     = var.db_user
    password = var.db_password
    dbname   = var.db_name
    url      = local.db_url
  })
}

# --- App Secret ---

resource "aws_secretsmanager_secret" "app" {
  #checkov:skip=CKV2_AWS_57: Automatic rotation requires Lambda-based rotator — out of scope for PoC
  name        = "${local.name_prefix}-app"
  description = "Application secrets for ${local.name_prefix}"
  kms_key_id  = aws_kms_key.secrets.arn

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-app" })
}

resource "aws_secretsmanager_secret_version" "app" {
  secret_id = aws_secretsmanager_secret.app.id
  secret_string = jsonencode({
    secret_key = var.app_secret_key
  })
}
