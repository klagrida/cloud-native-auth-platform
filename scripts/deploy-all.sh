#!/bin/bash

set -e

echo "===================================="
echo "Deploying Auth Platform to Kubernetes"
echo "===================================="

# Check if minikube is running
if ! minikube status &>/dev/null; then
    echo "Error: Minikube is not running. Please run setup-minikube.sh first."
    exit 1
fi

# Ensure we're using minikube docker environment
echo "Configuring Docker environment..."
eval $(minikube docker-env)

# Verify docker is accessible
if ! docker info &>/dev/null; then
    echo "Error: Cannot connect to Docker. Make sure Docker is running."
    exit 1
fi

echo "Docker environment configured successfully"

# Build Docker images
echo ""
echo "Building Docker images..."

echo "Building frontend image..."
if [ -d "frontend" ]; then
    cd frontend
    docker build -t auth-platform/angular-frontend:latest . || {
        echo "Error: Failed to build frontend image"
        exit 1
    }
    cd ..
    echo "✓ Frontend image built"
else
    echo "Error: frontend directory not found"
    exit 1
fi

echo ""
echo "Building backend image..."
if [ -d "backend" ]; then
    cd backend
    docker build -t auth-platform/spring-backend:latest . || {
        echo "Error: Failed to build backend image"
        exit 1
    }
    cd ..
    echo "✓ Backend image built"
else
    echo "Error: backend directory not found"
    exit 1
fi

echo ""
echo "Docker images built successfully!"
docker images | grep auth-platform || echo "Warning: Could not list images"

# Deploy to Kubernetes
echo ""
echo "Deploying to Kubernetes..."

# Verify kubectl can reach cluster
echo "Verifying Kubernetes cluster connectivity..."
if ! kubectl cluster-info &>/dev/null; then
    echo "Error: Cannot connect to Kubernetes cluster"
    exit 1
fi
echo "✓ Connected to Kubernetes cluster"

echo ""
echo "1. Creating namespace..."
kubectl apply -f k8s/namespace.yaml
kubectl get namespace auth-platform

echo "2. Deploying PostgreSQL..."
kubectl apply -f k8s/postgres/secret.yaml
kubectl apply -f k8s/postgres/pvc.yaml
kubectl apply -f k8s/postgres/deployment.yaml
kubectl apply -f k8s/postgres/service.yaml

echo "Waiting for PostgreSQL to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=postgres -n auth-platform --timeout=120s

echo "3. Deploying Keycloak..."
kubectl apply -f k8s/keycloak/configmap.yaml
kubectl apply -f k8s/keycloak/realm-configmap.yaml
kubectl apply -f k8s/keycloak/deployment.yaml
kubectl apply -f k8s/keycloak/service.yaml
kubectl apply -f k8s/keycloak/ingress.yaml

echo "Waiting for Keycloak to be ready (this may take 5-8 minutes in CI environments)..."
echo "Checking Keycloak pod status..."
kubectl get pods -n auth-platform -l app.kubernetes.io/name=keycloak

# In CI, skip the wait as we do it separately in the workflow
if [ -z "$CI" ] && [ -z "$GITHUB_ACTIONS" ]; then
  # Local environment - wait for Keycloak
  kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=keycloak -n auth-platform --timeout=600s || {
    echo "Keycloak readiness check timed out. Checking pod status and logs..."
    kubectl get pods -n auth-platform -l app.kubernetes.io/name=keycloak
    kubectl describe pod -n auth-platform -l app.kubernetes.io/name=keycloak
    kubectl logs -n auth-platform -l app.kubernetes.io/name=keycloak --tail=100
    exit 1
  }
else
  # CI environment - just deploy and let the workflow wait
  echo "CI environment detected - skipping wait in script (workflow will wait)"
  sleep 5  # Brief pause to let pod start creating
  kubectl get pods -n auth-platform -l app.kubernetes.io/name=keycloak
fi

echo "4. Deploying Backend..."
kubectl apply -f k8s/backend/configmap.yaml
kubectl apply -f k8s/backend/deployment.yaml
kubectl apply -f k8s/backend/service.yaml
kubectl apply -f k8s/backend/ingress.yaml

echo "Waiting for Backend to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=backend -n auth-platform --timeout=180s

echo "5. Deploying Frontend..."
kubectl apply -f k8s/frontend/configmap.yaml
kubectl apply -f k8s/frontend/deployment.yaml
kubectl apply -f k8s/frontend/service.yaml
kubectl apply -f k8s/frontend/ingress.yaml

echo "Waiting for Frontend to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=frontend -n auth-platform --timeout=120s

echo ""
echo "===================================="
echo "Deployment Complete!"
echo "===================================="
echo ""
echo "Pods:"
kubectl get pods -n auth-platform
echo ""
echo "Services:"
kubectl get services -n auth-platform
echo ""
echo "Ingress:"
kubectl get ingress -n auth-platform
echo ""
echo "Access URLs:"
echo "  Frontend:      http://app.local"
echo "  Backend API:   http://api.local/api/public/hello"
echo "  Keycloak:      http://auth.local"
echo ""
echo "Keycloak Admin Credentials:"
echo "  Username: admin"
echo "  Password: admin"
echo ""
echo "Test Users:"
echo "  Admin:   admin / admin123"
echo "  User:    user / user123"
echo ""
echo "Next step: Run ./scripts/configure-keycloak.sh to import realm configuration"
