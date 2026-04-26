# Persistent Storage for PostgreSQL

Replaces the `emptyDir` volume on the `db` Deployment with a PersistentVolumeClaim
backed by AWS EBS gp3. Data now survives pod restarts, rescheduling, and node replacement.

## How it works

```
StorageClass (gp3)
  └── PersistentVolumeClaim (db-storage, 5Gi)
        └── Deployment (db) mounts at /var/lib/postgresql/data
              └── EBS CSI driver provisions gp3 EBS volume
```

1. `StorageClass` tells Kubernetes to use the EBS CSI driver with gp3 volume type
2. `PersistentVolumeClaim` requests 5Gi of storage
3. The `db` Deployment mounts the PVC instead of an `emptyDir`
4. EBS CSI driver (EKS add-on) dynamically provisions an EBS volume on first pod schedule

## Prerequisites

- EKS cluster with the `aws-ebs-csi-driver` add-on (provisioned by `infra/terraform/modules/eks`)
- EKS node role with `AmazonEBSCSIDriverPolicy` attached
- `kubectl` configured for the EKS cluster

## Files

| File | Purpose |
|---|---|
| `storage-class.yaml` | gp3 StorageClass — EBS CSI provisioner, Retain policy, WaitForFirstConsumer |
| `db-pvc.yaml` | 5Gi PVC in `boardgames` namespace |
| `db-deployment.yaml` | Updated — `db-storage` volume uses PVC instead of emptyDir |

## Apply

```bash
kubectl apply -f infra/k8s/storage-class.yaml
kubectl apply -f infra/k8s/db-pvc.yaml
kubectl apply -f infra/k8s/db-deployment.yaml
```

## Verify

```bash
# PVC should show Bound status
kubectl get pvc -n boardgames

# EBS volume should be visible
kubectl get pv

# Test data persistence
kubectl exec -n boardgames deploy/db -- psql -U postgres -c "CREATE TABLE persist_test(id int);"
kubectl rollout restart deployment/db -n boardgames
kubectl wait --for=condition=ready pod -l app=db -n boardgames --timeout=60s
kubectl exec -n boardgames deploy/db -- psql -U postgres -c "SELECT tablename FROM pg_tables WHERE tablename='persist_test';"
# Should return: persist_test
```

## StorageClass details

| Setting | Value | Why |
|---|---|---|
| `provisioner` | `ebs.csi.aws.com` | EKS-native EBS CSI driver |
| `type` | `gp3` | Better baseline IOPS/throughput than gp2, same cost |
| `reclaimPolicy` | `Retain` | EBS volume preserved after PVC deletion — prevents accidental data loss |
| `volumeBindingMode` | `WaitForFirstConsumer` | Volume created in the same AZ as the pod — avoids cross-AZ mount failures |
| `allowVolumeExpansion` | `true` | PVC can be resized without recreating |

## Expanding storage

```bash
kubectl patch pvc db-storage -n boardgames -p '{"spec":{"resources":{"requests":{"storage":"10Gi"}}}}'
# Pod restart required for filesystem resize
kubectl rollout restart deployment/db -n boardgames
```

## Cleanup

Deleting the PVC does **not** delete the EBS volume (`reclaimPolicy: Retain`).
To fully clean up:

```bash
kubectl delete -f infra/k8s/db-pvc.yaml
# Then manually delete the Released PV and EBS volume
kubectl get pv  # find the Released PV
kubectl delete pv <pv-name>
# Delete EBS volume from AWS console or CLI
```
