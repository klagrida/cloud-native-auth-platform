# Quick Start Guide

Get the Cloud-Native Authentication Platform running in 3 commands.

## Prerequisites

- Docker
- Minikube
- kubectl
- Node.js 20+
- Java 17+

## Deploy in 3 Commands

```bash
# 1. Setup Minikube cluster
./scripts/setup-minikube.sh

# 2. Deploy all components
./scripts/deploy-all.sh

# 3. Configure Keycloak
./scripts/configure-keycloak.sh
```

## Access the Application

After deployment (wait ~5-10 minutes for Keycloak):

- **Frontend**: http://app.local
- **Backend API**: http://api.local/api/public/hello
- **Keycloak Admin**: http://auth.local (admin/admin)

## Test Users

| Username | Password   | Roles       |
|----------|------------|-------------|
| admin    | admin123   | USER, ADMIN |
| user     | user123    | USER        |
| manager  | manager123 | USER, MANAGER |

## Monitor Deployment

```bash
# Watch pod status
watch kubectl get pods -n auth-platform

# Monitor deployment progress
./scripts/monitor-deployment.sh auth-platform 600

# Check Keycloak specifically
./scripts/wait-for-keycloak.sh
```

## Verify Everything Works

```bash
# Check all pods are running
kubectl get pods -n auth-platform

# Test public API
curl http://api.local/api/public/hello

# Check Keycloak
curl http://auth.local/health/ready
```

## Troubleshooting

### Keycloak taking too long?

```bash
# Check status
kubectl get pods -n auth-platform -l app.kubernetes.io/name=keycloak

# View logs
kubectl logs -n auth-platform -l app.kubernetes.io/name=keycloak --tail=100

# Describe pod
kubectl describe pod -n auth-platform -l app.kubernetes.io/name=keycloak
```

### Build failures?

```bash
# Verify Docker environment
eval $(minikube docker-env)
docker info

# Check Minikube status
minikube status
```

### Start fresh?

```bash
./scripts/cleanup.sh
minikube delete
./scripts/setup-minikube.sh
./scripts/deploy-all.sh
```

## Development

### Frontend Development

```bash
cd frontend
npm install
npm start
# Access at http://localhost:4200
```

### Backend Development

```bash
cd backend
mvn spring-boot:run
# Access at http://localhost:8080
```

## Cleanup

```bash
# Delete all resources
./scripts/cleanup.sh

# Stop Minikube
minikube stop

# Delete Minikube cluster
minikube delete
```

## More Information

- [Full Setup Guide](docs/SETUP.md)
- [Deployment Guide](docs/DEPLOYMENT.md)
- [API Documentation](docs/API.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [CI/CD Guide](docs/CI-CD.md)
