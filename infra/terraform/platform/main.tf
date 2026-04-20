data "terraform_remote_state" "core" {
  backend = "s3"
  config = {
    bucket = "${local.name_prefix}-tfstate"
    key    = "core/${var.environment}/terraform.tfstate"
    region = var.aws_region
  }
}

data "aws_iam_role" "github_platform_role" {
  name = local.github_platform_role_name
}

resource "aws_iam_policy" "github_platform_tfstate_access" {
  name        = "${local.name_prefix}-github-platform-tfstate-access"
  description = "Least-privilege access for GitHub Terraform platform workflow to Terraform state bucket"
  policy = templatefile("${path.module}/policies/tfstate-access.json.tftpl", {
    bucket_arn  = data.terraform_remote_state.core.outputs.tfstate_bucket_arn
    tfstate_key = local.tfstate_key
    environment = var.environment
  })
}

resource "aws_iam_role_policy_attachment" "github_platform_tfstate_access" {
  role       = data.aws_iam_role.github_platform_role.name
  policy_arn = aws_iam_policy.github_platform_tfstate_access.arn
}
