# Setup Guide

This guide provides detailed instructions for setting up the Auth Platform on your local machine.

## Prerequisites

Before you begin, ensure you have the following installed:

### Required Software

1. **Docker** (20.10+)
   - [Install Docker](https://docs.docker.com/get-docker/)
   - Verify: `docker --version`

2. **Minikube** (1.30+)
   - [Install Minikube](https://minikube.sigs.k8s.io/docs/start/)
   - Verify: `minikube version`

3. **kubectl** (1.28+)
   - [Install kubectl](https://kubernetes.io/docs/tasks/tools/)
   - Verify: `kubectl version --client`

4. **Node.js** (20+)
   - [Install Node.js](https://nodejs.org/)
   - Verify: `node --version`

5. **Java** (17+)
   - [Install Java](https://adoptium.net/)
   - Verify: `java --version`

6. **Maven** (3.8+)
   - [Install Maven](https://maven.apache.org/)
   - Verify: `mvn --version`

### System Requirements

- CPU: 4+ cores
- RAM: 8+ GB
- Disk: 20+ GB free space

## Local Development Setup

### 1. Frontend Development

```bash
# Navigate to frontend directory
cd frontend

# Install dependencies
npm install

# Start development server
npm start

# Application will be available at http://localhost:4200
```

#### Frontend Commands

- `npm start` - Start development server
- `npm run build` - Build for production
- `npm test` - Run unit tests
- `npm run lint` - Run linter

### 2. Backend Development

```bash
# Navigate to backend directory
cd backend

# Build the application
mvn clean package

# Run the application
mvn spring-boot:run

# Application will be available at http://localhost:8080
```

#### Backend Commands

- `mvn spring-boot:run` - Start Spring Boot application
- `mvn clean package` - Build JAR file
- `mvn test` - Run tests
- `mvn clean install` - Build and install to local Maven repository

### 3. Running Keycloak Locally

```bash
# Using Docker
docker run -d \
  --name keycloak \
  -p 8080:8080 \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  quay.io/keycloak/keycloak:23.0 \
  start-dev

# Access Keycloak at http://localhost:8080
```

## Kubernetes Setup

### 1. Setup Minikube

Run the setup script:

```bash
chmod +x scripts/setup-minikube.sh
./scripts/setup-minikube.sh
```

This script will:
- Start Minikube with appropriate resources
- Enable the ingress addon
- Configure Docker environment
- Add entries to `/etc/hosts`

### 2. Deploy All Components

```bash
chmod +x scripts/deploy-all.sh
./scripts/deploy-all.sh
```

This script will:
- Build Docker images
- Deploy all Kubernetes resources
- Wait for pods to be ready

### 3. Configure Keycloak

The Keycloak realm is automatically imported on startup via a ConfigMap. No manual configuration is needed!

You can verify the import:
```bash
chmod +x scripts/configure-keycloak.sh
./scripts/configure-keycloak.sh
```

This script will verify:
- Realm was successfully imported
- Test users and roles are available

## Accessing the Application

After deployment, you can access:

- **Frontend**: http://app.local
- **Backend API**: http://api.local/api/public/hello
- **Keycloak Admin**: http://auth.local (admin/admin)

## Test Users

1. **Admin User**
   - Username: `admin`
   - Password: `admin123`
   - Roles: USER, ADMIN

2. **Regular User**
   - Username: `user`
   - Password: `user123`
   - Roles: USER

3. **Manager User**
   - Username: `manager`
   - Password: `manager123`
   - Roles: USER, MANAGER

## Troubleshooting

### Minikube Issues

**Minikube won't start:**
```bash
minikube delete
minikube start --driver=docker
```

**Can't access ingress:**
```bash
minikube addons enable ingress
kubectl get pods -n ingress-nginx
```

### DNS Issues

**Can't resolve app.local, api.local, or auth.local:**

Check your `/etc/hosts` file:
```bash
cat /etc/hosts | grep local
```

Should contain:
```
<MINIKUBE_IP> app.local
<MINIKUBE_IP> api.local
<MINIKUBE_IP> auth.local
```

### Pod Issues

**Pods not starting:**
```bash
# Check pod status
kubectl get pods -n auth-platform

# Check pod logs
kubectl logs -n auth-platform <pod-name>

# Describe pod
kubectl describe pod -n auth-platform <pod-name>
```

### Keycloak Issues

**Keycloak taking too long to start:**

Keycloak needs at least 512Mi memory and can take 2-3 minutes to start. Check logs:
```bash
kubectl logs -n auth-platform -l app.kubernetes.io/name=keycloak
```

### Backend Issues

**Backend can't connect to Keycloak:**

Ensure Keycloak is ready and the JWK set URI is accessible from the pod:
```bash
kubectl exec -n auth-platform <backend-pod> -- curl http://keycloak:8080/realms/demo-realm/protocol/openid-connect/certs
```

### CORS Issues

**CORS errors in browser:**

Check that:
1. Backend CORS configuration allows Angular origin
2. Frontend is using correct API URL
3. Ingress annotations are correct

## Cleanup

To remove all resources:

```bash
chmod +x scripts/cleanup.sh
./scripts/cleanup.sh
```

To stop Minikube:
```bash
minikube stop
```

To delete Minikube cluster:
```bash
minikube delete
```

## Next Steps

- [Deployment Guide](DEPLOYMENT.md) - Production deployment
- [API Documentation](API.md) - API endpoints
- [Project README](../README.md) - Project overview
