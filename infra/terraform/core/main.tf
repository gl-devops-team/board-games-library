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

data "aws_iam_policy_document" "github_core_tfstate_access" {
  statement {
    sid    = "ListStateBucket"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.tfstate.arn,
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:prefix"
      values = [
        local.tfstate_key,
        "${local.tfstate_key}.tflock"
      ]
    }
  }

  statement {
    sid    = "ReadWriteStateFile"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.tfstate.arn}/${local.tfstate_key}",
    ]
  }

  statement {
    sid    = "ReadWriteDeleteLockFile"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]

    resources = [
      "${aws_s3_bucket.tfstate.arn}/${local.tfstate_key}.tflock",
    ]
  }
}

resource "aws_iam_policy" "github_core_tfstate_access" {
  name        = "${local.name_prefix}-github-core-tfstate-access"
  description = "Least-privilege access for GitHub Terraform core workflow to Terraform state bucket"
  policy      = data.aws_iam_policy_document.github_core_tfstate_access.json
}

resource "aws_iam_role_policy_attachment" "github_core_tfstate_access" {
  role       = data.aws_iam_role.github_core_role.name
  policy_arn = aws_iam_policy.github_core_tfstate_access.arn
}
