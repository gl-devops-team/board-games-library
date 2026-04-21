# Terraform Networking Module

This directory contains the reusable Terraform module for provisioning VPC networking
infrastructure. It is not a root module — it is called from `environments/dev/` and
does not define a backend or run `terraform init` directly.

## Purpose

The `networking` module creates the foundational AWS network layer required by all
application workloads (EKS nodes, RDS, load balancers):

- VPC with DNS resolution enabled (required by EKS)
- Public subnets for load balancers and NAT Gateways
- Private subnets for EKS nodes and application workloads
- Internet Gateway for public subnet outbound traffic
- NAT Gateways (one per AZ) for private subnet outbound traffic
- Route tables with appropriate routing rules

## Structure

```
modules/networking/
├── main.tf       - all network resources (VPC, subnets, IGW, EIP, NAT GW, route tables)
├── locals.tf     - CIDR blocks, AZ list, name prefix, common tags
├── variables.tf  - input variables (aws_region, project, environment, component)
├── outputs.tf    - vpc_id, public_subnet_ids, private_subnet_ids, nat_gateway_ids
└── versions.tf   - Terraform and provider version constraints (no backend block)
```

## Resources created

| Resource | Count | Notes |
|---|---|---|
| `aws_vpc` | 1 | 10.0.0.0/16, DNS hostnames enabled |
| `aws_subnet` (public) | 2 | eu-central-1a/b, map_public_ip_on_launch |
| `aws_subnet` (private) | 2 | eu-central-1a/b, no public IPs |
| `aws_internet_gateway` | 1 | VPC ↔ internet |
| `aws_eip` | 2 | Static IPs for NAT Gateways |
| `aws_nat_gateway` | 2 | One per AZ — fault isolation |
| `aws_route_table` (public) | 1 | Shared: 0.0.0.0/0 → IGW |
| `aws_route_table` (private) | 2 | Per AZ: 0.0.0.0/0 → local NAT GW |
| `aws_route_table_association` | 4 | Binds subnets to route tables |

Total: **17 resources**

## Why one NAT Gateway per AZ

A single NAT Gateway would introduce a single point of failure — if its AZ goes down,
private subnets in the other AZ lose internet access. Two NAT Gateways cost more but
provide proper fault isolation: each AZ routes through its own NAT.

## CIDR layout

```
VPC: 10.0.0.0/16

Public:   10.0.1.0/24  (eu-central-1a)
          10.0.2.0/24  (eu-central-1b)

Private:  10.0.10.0/24 (eu-central-1a)
          10.0.11.0/24 (eu-central-1b)
```

The gap between public (`10.0.1-2.x`) and private (`10.0.10-11.x`) is intentional —
it makes the address space easier to read and leaves room for additional subnets.

## Usage

This module is not run directly. It is called from `environments/dev/main.tf`:

```hcl
module "networking" {
  source      = "../../modules/networking"
  project     = "boardgames"
  environment = "dev"
}
```

Run Terraform from `environments/dev/`, not from this directory.

## Outputs

Downstream modules (EKS, RDS) consume outputs from this module:

- `vpc_id` — required by EKS cluster and security groups
- `private_subnet_ids` — where EKS nodes run
- `public_subnet_ids` — where load balancers are placed
- `nat_gateway_ids` — for reference/validation
