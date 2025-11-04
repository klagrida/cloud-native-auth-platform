# CI/CD Pipeline Documentation

This document describes the CI/CD pipeline for the Cloud-Native Authentication Platform.

## Overview

The project uses GitHub Actions for continuous integration and deployment testing. The pipeline validates that all components work together correctly using a local Minikube cluster.

## Workflows

### 1. CI Workflow (`.github/workflows/ci.yml`)

Comprehensive end-to-end testing workflow with two jobs:

#### Job 1: `test-scripts`
Tests all deployment scripts in order:

**Steps:**
1. **Preflight Checks (Before Setup)** - Validates environment
2. **Setup Minikube** - Runs `setup-minikube.sh`
3. **Preflight Checks (After Setup)** - Confirms setup succeeded
4. **Deploy All** - Runs `deploy-all.sh`
5. **Configure Keycloak** - Runs `configure-keycloak.sh`
6. **Integration Tests** - Validates all services
7. **Cleanup** - Runs `cleanup.sh`

**Duration:** ~25-30 minutes

#### Job 2: `test-full-deployment`
Manual step-by-step deployment (runs after `test-scripts`):

**Steps:**
1. Build frontend and backend
2. Create Docker images in Minikube
3. Deploy each component individually
4. Run health checks
5. Run smoke tests
6. Cleanup

**Duration:** ~25-30 minutes

**Total CI Runtime:** ~50-60 minutes

### 2. Frontend CI (`.github/workflows/frontend-ci.yml`)

**Triggers:**
- Push to `main` with changes in `frontend/**`
- Pull requests to `main` with frontend changes

**Steps:**
1. Setup Node.js 20
2. Install dependencies (`npm install`)
3. Run linter (optional)
4. Run tests (optional)
5. Build application
6. Build Docker image
7. Push to registry (on main branch only)

**Duration:** ~5-10 minutes

### 3. Backend CI (`.github/workflows/backend-ci.yml`)

**Triggers:**
- Push to `main` with changes in `backend/**`
- Pull requests to `main` with backend changes

**Steps:**
1. Setup JDK 17
2. Build with Maven
3. Run tests
4. Build Docker image
5. Push to registry (on main branch only)

**Duration:** ~5-10 minutes

### 4. Deploy Workflow (`.github/workflows/deploy.yml`)

**Triggers:**
- Manual trigger via `workflow_dispatch`

**Steps:**
1. Setup kubectl with kubeconfig
2. Deploy all Kubernetes manifests
3. Wait for rollout completion
4. Run smoke tests
5. Send notifications (optional)

**Duration:** ~15-20 minutes

## Scripts

### `scripts/preflight-check.sh`

Validates environment before deployment:
- Checks required commands (docker, kubectl, minikube)
- Verifies services are running
- Confirms Minikube addons enabled
- Validates project structure
- Checks Kubernetes manifests exist
- Tests Docker environment

**Usage:**
```bash
./scripts/preflight-check.sh
```

### `scripts/setup-minikube.sh`

Sets up Minikube cluster:
- Starts Minikube with appropriate resources
- Enables ingress addon
- Configures /etc/hosts
- Sets kubectl context

**Resource Allocation:**
- **CI:** 2 CPUs, 6GB RAM
- **Local:** 4 CPUs, 8GB RAM

**Usage:**
```bash
./scripts/setup-minikube.sh
```

### `scripts/deploy-all.sh`

Deploys complete platform:
- Builds Docker images
- Creates namespace
- Deploys PostgreSQL
- Deploys Keycloak (10 min timeout)
- Deploys Backend
- Deploys Frontend
- Displays status

**Usage:**
```bash
./scripts/deploy-all.sh
```

### `scripts/configure-keycloak.sh`

Configures Keycloak realm:
- Waits for Keycloak to be ready
- Copies realm configuration
- Imports realm

**Usage:**
```bash
./scripts/configure-keycloak.sh
```

### `scripts/wait-for-keycloak.sh`

Monitors Keycloak startup:
- Checks pod status every 10 seconds
- Shows progress updates
- Detects and reports failures
- 10-minute timeout

**Usage:**
```bash
./scripts/wait-for-keycloak.sh
```

### `scripts/cleanup.sh`

Removes all resources:
- Deletes namespace
- Optionally removes /etc/hosts entries
- Optionally stops/deletes Minikube

**Usage:**
```bash
./scripts/cleanup.sh
```

## Timeouts and Resource Limits

### Keycloak
- **Deployment timeout:** 600s (10 minutes)
- **CPU:** 500m request, 2000m limit
- **Memory:** 512Mi request, 2Gi limit
- **Liveness probe:** 180s initial delay
- **Readiness probe:** 120s initial delay

### PostgreSQL
- **Deployment timeout:** 120s (2 minutes)
- **CPU:** 250m request, 500m limit
- **Memory:** 256Mi request, 512Mi limit

### Backend
- **Deployment timeout:** 240s (4 minutes)
- **CPU:** 250m request, 500m limit
- **Memory:** 512Mi request, 1Gi limit

### Frontend
- **Deployment timeout:** 180s (3 minutes)
- **CPU:** 100m request, 200m limit
- **Memory:** 128Mi request, 256Mi limit

## Debugging CI Failures

### 1. Check Logs
All jobs collect logs on failure:
```bash
kubectl logs -n auth-platform <pod-name>
kubectl describe pod -n auth-platform <pod-name>
kubectl get events -n auth-platform
```

### 2. Common Issues

**Keycloak Timeout:**
- Increase timeout in deployment manifest
- Check resource limits
- Verify PostgreSQL is ready
- Check database connectivity

**Build Failures:**
- Check Docker daemon is accessible
- Verify source code compiles
- Check network connectivity for dependencies

**Pod Not Starting:**
- Check image pull policy
- Verify resource limits
- Check node resources
- Review pod events

### 3. Local Reproduction

To reproduce CI failures locally:
```bash
# Run the same scripts as CI
./scripts/setup-minikube.sh
./scripts/preflight-check.sh
./scripts/deploy-all.sh

# Check status
kubectl get pods -n auth-platform
kubectl logs -n auth-platform <pod-name>

# Cleanup
./scripts/cleanup.sh
```

## Best Practices

### 1. Testing Changes
- Always test locally before pushing
- Run preflight checks before deployment
- Monitor pod logs during startup
- Verify health endpoints after deployment

### 2. Resource Management
- Use appropriate limits for environment
- Monitor resource usage
- Scale resources for production

### 3. Error Handling
- Check exit codes
- Collect logs on failure
- Provide clear error messages
- Use timeouts appropriately

## Continuous Improvement

### Monitoring
- Track CI run times
- Monitor failure rates
- Identify slow steps
- Optimize bottlenecks

### Optimization
- Cache dependencies
- Parallelize independent steps
- Reduce Docker image sizes
- Use incremental builds

## Related Documentation

- [Setup Guide](SETUP.md) - Local development setup
- [Deployment Guide](DEPLOYMENT.md) - Production deployment
- [API Documentation](API.md) - API endpoints
- [Main README](../README.md) - Project overview
