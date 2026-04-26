# Terraform EKS Module

This directory contains the reusable Terraform module for provisioning an AWS EKS
cluster with managed node groups. It is not a root module — it is called from
`environments/dev/` and does not define a backend or run `terraform init` directly.

## Purpose

The `eks` module creates the Kubernetes runtime environment for the application,
replacing the current docker-compose based deployment. EKS nodes run in private
subnets and pull images from ECR. The module also provisions IAM roles for the
control plane, worker nodes, and pod-level access (IRSA).

## Structure

```
modules/eks/
├── main.tf       - EKS cluster, node group, OIDC provider, security groups, access entries
├── iam.tf        - IAM roles (cluster, node, IRSA) and policy attachments
├── policies/
│   ├── cluster-trust.json.tftpl   - EKS service trust policy
│   ├── node-trust.json.tftpl      - EC2 service trust policy
│   ├── irsa-trust.json.tftpl      - OIDC federation trust policy
│   └── irsa-permissions.json.tftpl - ECR pull + Secrets Manager read
├── locals.tf     - name prefix, common tags
├── variables.tf  - input variables
├── outputs.tf    - cluster endpoint, role ARNs, security group IDs
├── providers.tf  - AWS provider with default tags
└── versions.tf   - Terraform, AWS, and TLS provider version constraints
```

## Resources created

| Resource | Count | Notes |
|---|---|---|
| `aws_eks_cluster` | 1 | Private + public endpoint, all 5 control plane log types enabled |
| `aws_eks_node_group` | 1 | t3.medium, 1–3 nodes in private subnets |
| `aws_iam_openid_connect_provider` | 1 | OIDC for IRSA |
| `aws_iam_role` | 3 | cluster-role, node-role, irsa-role |
| `aws_iam_policy` | 1 | IRSA permissions (ECR pull, Secrets Manager) |
| `aws_iam_role_policy_attachment` | 6 | AWS managed + custom policies |
| `aws_security_group` | 2 | Control plane, nodes |
| `aws_security_group_rule` | 4 | Egress, node↔cluster, node↔node |
| `aws_eks_access_entry` | 1 | Platform role → cluster admin |
| `aws_eks_access_policy_association` | 1 | AmazonEKSClusterAdminPolicy |
| `aws_eks_addon` | 1 | EBS CSI driver for persistent volumes |

Total: **22 resources**

## Security groups

- **Cluster SG** — allows inbound 443 from nodes, all outbound
- **Node SG** — allows inbound from cluster (1025–65535), inbound from self (all), all outbound

## IAM roles

| Role | Trust | Policies |
|---|---|---|
| `eks-cluster-role` | `eks.amazonaws.com` | AmazonEKSClusterPolicy |
| `eks-node-role` | `ec2.amazonaws.com` | AmazonEKSWorkerNodePolicy, AmazonEKS_CNI_Policy, AmazonEC2ContainerRegistryReadOnly, AmazonEBSCSIDriverPolicy |
| `irsa-role` | OIDC federation | ECR pull, Secrets Manager read (scoped to `boardgames-dev-*`) |

## Usage

This module is not run directly. It is called from `environments/dev/main.tf`:

```hcl
module "eks" {
  source = "../../modules/eks"

  project     = "boardgames"
  environment = "dev"

  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  public_subnet_ids  = module.networking.public_subnet_ids
  ecr_repository_arns = values(module.ecr.repository_arns)
}
```

Run Terraform from `environments/dev/`, not from this directory.

## Outputs

Downstream modules and CI/CD consume outputs from this module:

- `cluster_name` — used by kubectl and Helm
- `cluster_endpoint` — API server URL
- `cluster_certificate_authority` — for kubeconfig
- `oidc_provider_arn` — for additional IRSA roles
- `cluster_role_arn`, `node_role_arn`, `irsa_role_arn` — for IAM reference
- `cluster_security_group_id`, `node_security_group_id` — for additional ingress rules

## kubectl access

After apply, configure kubectl:

```bash
aws eks update-kubeconfig --name boardgames-dev-eks --region eu-central-1
kubectl get nodes
```

The platform role has cluster admin access via EKS access entries.
