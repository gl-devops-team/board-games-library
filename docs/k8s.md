# Kubernetes – Local Development

## What is Kubernetes?

**Kubernetes (K8s)** is a container orchestration platform used to deploy, manage, and scale containerized applications.

In this project, Kubernetes is used to run the application locally in an environment similar to production.

---

## Prerequisites

Before starting, make sure you have installed and configured:

- **Docker**
- **kubectl**
- [**login to ghcr via kubectl**](#Login-to-GitHub-Container-Registry-(GHCR)-via-kubectl)
- [**create secret for db**](#Create-a-Kubernetes-docker-registry-Secret)

---

## Login to GitHub Container Registry (GHCR) via kubectl

1. Create a Personal Access Token in GitHub

    1. Go to GitHub → Settings.
    2. Navigate to:

    `Developer settings → Personal access tokens → Tokens (classic)`

    3. Click Generate new token (classic).
    4. Give the token a name (e.g., ghcr-kubernetes-access).
    5.  Select the required permissions:

    Required scopes:

    `read:packages – allows pulling images from GHCR
    write:packages – required only if pushing images
    delete:packages – optional`

    6. Click Generate token.
    7. Copy the generated token immediately (GitHub will not show it again).

2. Create a Kubernetes docker-registry Secret

    Use the generated token to create a secret that Kubernetes will use to authenticate with GHCR.
    
    Run the following command:

    `kubectl create secret docker-registry ghcr-secret \
    --docker-server=ghcr.io \
    --docker-username=<YOUR_GITHUB_USERNAME> \
    --docker-password=<YOUR_GITHUB_TOKEN>`

---

## Create secret for db (local)

    Backend pod needed secret-db value:

    `kubectl create secret generic db-secret --from-literal=DATABASE_URL="postgresql://<USER>:<PASSWORD>@db:5432 <PROJECT_NAME>"`

---

## Deploy the application

Kubernetes configuration files are stored in the k8s/ directory.

Apply them with:

    kubectl apply -f k8s/

Check if pods & services are running:

    kubectl get pods

    kubectl get services

---

## Useful commands

List pods:

    kubectl get pods

List services:

    kubectl get services

Check logs:

    kubectl logs <pod-name>

Describe resource:

    kubectl describe pod <pod-name>
