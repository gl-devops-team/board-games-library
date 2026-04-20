resource "aws_s3_bucket" "tfstate" {
  bucket = local.tfstate_bucket_name

  #checkov:skip=CKV_AWS_18:Access logging requires a dedicated logging bucket, which is out of scope for the core module
  #checkov:skip=CKV2_AWS_62:Event notifications are not applicable for a Terraform state bucket
  #checkov:skip=CKV_AWS_144:Cross-region replication is not required for a PoC environment; versioning provides sufficient state recovery

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    id     = "expire-noncurrent-state-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_role" "github_core_role" {
  name = local.github_core_role_name
}

resource "aws_iam_policy" "github_core_tfstate_access" {
  name        = "${local.name_prefix}-github-core-tfstate-access"
  description = "Least-privilege access for GitHub Terraform core workflow to Terraform state bucket"
  policy = templatefile("${path.module}/policies/tfstate-access.json.tftpl", {
    bucket_arn  = aws_s3_bucket.tfstate.arn
    tfstate_key = local.tfstate_key
  })
}

resource "aws_iam_role_policy_attachment" "github_core_tfstate_access" {
  role       = data.aws_iam_role.github_core_role.name
  policy_arn = aws_iam_policy.github_core_tfstate_access.arn
}
