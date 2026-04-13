resource "aws_s3_bucket" "tfstate" {
  bucket = local.tfstate_bucket_name

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

# TODO: handle the rest core infra stuff (policies handling, iam roles, etc.)