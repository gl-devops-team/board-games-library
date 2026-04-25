# External Secrets Operator

External Secrets Operator (ESO) syncs secrets from AWS Secrets Manager into Kubernetes Secrets. Instead of storing credentials in K8s (where they are only base64-encoded, not encrypted), secrets live in Secrets Manager and ESO pulls them on a regular interval via IRSA.

## How it works

```
AWS Secrets Manager          Kubernetes
  boardgames-dev-db    →  Secret: db-credentials
  boardgames-dev-app   →  Secret: app-credentials
        ↑
   IRSA role (boardgames-dev-irsa-role)
   ServiceAccount: external-secrets-sa
```

1. The ESO pod uses a ServiceAccount annotated with IRSA → receives temporary AWS credentials
2. `SecretStore` defines where to fetch secrets (Secrets Manager, region eu-central-1)
3. `ExternalSecret` maps specific keys from Secrets Manager to a K8s Secret
4. Sync every 1 hour — changes in Secrets Manager propagate to K8s automatically

## Prerequisites

- EKS cluster with OIDC provider (`infra/terraform/modules/eks`)
- Secrets created in AWS Secrets Manager (`infra/terraform/modules/secrets`)
- IRSA role `boardgames-dev-irsa-role` with `secretsmanager:GetSecretValue` permission
- `kubectl` configured for the EKS cluster

## Install ESO

```bash
helm repo add external-secrets https://charts.external-secrets.io
helm repo update

helm install external-secrets external-secrets/external-secrets \
  --namespace external-secrets \
  --create-namespace \
  --set installCRDs=true

# Verify ESO is running
kubectl get pods -n external-secrets
```

## Apply manifests

```bash
# ServiceAccount with IRSA annotation
kubectl apply -f infra/k8s/eso/service-account.yaml

# SecretStore — connection to AWS Secrets Manager
kubectl apply -f infra/k8s/eso/secret-store.yaml

# ExternalSecret — secret mapping
kubectl apply -f infra/k8s/eso/external-secrets.yaml
```

## Verify sync

```bash
# Check sync status (should show Ready=True)
kubectl get externalsecret -n boardgames

# Describe for troubleshooting
kubectl describe externalsecret db-credentials -n boardgames

# Verify K8s Secrets were created
kubectl get secret db-credentials -n boardgames
kubectl get secret app-credentials -n boardgames

# Inspect values (base64-decoded)
kubectl get secret db-credentials -n boardgames -o jsonpath='{.data.DATABASE_URL}' | base64 -d
```

## File overview

| File | Purpose |
|---|---|
| `service-account.yaml` | ServiceAccount with IRSA annotation (`eks.amazonaws.com/role-arn`) |
| `secret-store.yaml` | SecretStore pointing to AWS Secrets Manager in eu-central-1 |
| `external-secrets.yaml` | Two ExternalSecrets: `db-credentials` and `app-credentials` |

## Secrets in AWS Secrets Manager

| Secret name | Keys | Synced to K8s Secret |
|---|---|---|
| `boardgames-dev-db` | `user`, `password`, `dbname`, `url` | `db-credentials` |
| `boardgames-dev-app` | `secret_key` | `app-credentials` |

## Updating secrets

To rotate credentials:

```bash
# Via AWS CLI
aws secretsmanager put-secret-value \
  --secret-id boardgames-dev-db \
  --secret-string '{"user":"boardgames","password":"new_password","dbname":"boardgames","url":"postgresql://boardgames:new_password@db-service:5432/boardgames"}'

# Via Terraform (re-apply with updated variable value)
# TF_VAR_db_password=new_password terraform apply

# ESO picks up the new value on the next sync (up to 1h)
# To force immediate sync:
kubectl annotate externalsecret db-credentials \
  force-sync=$(date +%s) \
  --overwrite \
  -n boardgames
```
