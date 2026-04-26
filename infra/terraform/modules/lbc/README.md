# Module: lbc

Creates the IAM infrastructure required to run the [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/) on EKS.

## What it creates

- **IAM policy** (`boardgames-dev-lbc-policy`) — official AWS LBC policy allowing the controller to manage ALBs, target groups, security groups and related resources
- **IRSA role** (`boardgames-dev-lbc-role`) — assumed by the `aws-load-balancer-controller` ServiceAccount in `kube-system` via OIDC

## Usage

```hcl
module "lbc" {
  source = "../../modules/lbc"

  project     = "boardgames"
  environment = "dev"

  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_issuer       = module.eks.oidc_issuer
}
```

## Inputs

| Name | Description | Default |
|---|---|---|
| `project` | Project name | `boardgames` |
| `environment` | Deployment environment | `dev` |
| `aws_region` | AWS region | `eu-central-1` |
| `oidc_provider_arn` | ARN of the EKS OIDC provider | required |
| `oidc_issuer` | OIDC issuer URL without `https://` | required |

## Outputs

| Name | Description |
|---|---|
| `lbc_role_arn` | ARN of the LBC IRSA role — used when applying `infra/k8s/lbc/service-account.yaml` |

## After apply

The controller itself is installed via Helm in `cluster_setup.yml`. The ServiceAccount referencing this role is applied via envsubst:

```bash
export LBC_ROLE_ARN=$(terraform -chdir=infra/terraform/environments/dev output -raw lbc_role_arn)
envsubst < infra/k8s/lbc/service-account.yaml | kubectl apply -f -
```
