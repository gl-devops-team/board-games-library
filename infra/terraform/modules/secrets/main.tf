# --- DB Secret ---

resource "aws_secretsmanager_secret" "db" {
  name        = "${local.name_prefix}-db"
  description = "PostgreSQL credentials for ${local.name_prefix} application"

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
  name        = "${local.name_prefix}-app"
  description = "Application secrets for ${local.name_prefix}"

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-app" })
}

resource "aws_secretsmanager_secret_version" "app" {
  secret_id = aws_secretsmanager_secret.app.id
  secret_string = jsonencode({
    secret_key = var.app_secret_key
  })
}
