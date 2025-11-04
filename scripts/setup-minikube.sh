#!/bin/bash

set -e

echo "===================================="
echo "Setting up Minikube for Auth Platform"
echo "===================================="

# Check if minikube is installed
if ! command -v minikube &> /dev/null; then
    echo "Error: minikube is not installed"
    exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "Error: kubectl is not installed"
    exit 1
fi

# Start minikube with appropriate resources
echo "Starting Minikube..."

# Detect if running in CI
if [ -n "$CI" ] || [ -n "$GITHUB_ACTIONS" ]; then
    echo "CI environment detected, using reduced resources"
    minikube start \
        --cpus=2 \
        --memory=6144 \
        --disk-size=20g \
        --driver=docker
else
    echo "Local environment detected, using full resources"
    minikube start \
        --cpus=4 \
        --memory=8192 \
        --disk-size=20g \
        --driver=docker
fi

# Enable required addons
echo "Enabling ingress addon..."
minikube addons enable ingress

# Wait for ingress controller to be ready
echo "Waiting for ingress controller..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

# Configure Docker environment
echo "Configuring Docker environment..."
eval $(minikube docker-env)

# Get Minikube IP
MINIKUBE_IP=$(minikube ip)
echo "Minikube IP: $MINIKUBE_IP"

# Add entries to /etc/hosts (requires sudo)
echo ""
echo "Adding entries to /etc/hosts..."

HOSTS_ENTRIES=(
    "app.local"
    "api.local"
    "auth.local"
)

for HOST in "${HOSTS_ENTRIES[@]}"; do
    # Remove old entries first
    sudo sed -i.bak "/$HOST/d" /etc/hosts 2>/dev/null || true

    # Add new entry
    echo "$MINIKUBE_IP $HOST" | sudo tee -a /etc/hosts > /dev/null
    echo "Added $HOST to /etc/hosts -> $MINIKUBE_IP"
done

echo ""
echo "Current /etc/hosts entries:"
grep -E "(app|api|auth)\.local" /etc/hosts || echo "No entries found"

# Set kubectl context
echo ""
echo "Setting kubectl context..."
kubectl config use-context minikube

echo ""
echo "===================================="
echo "Minikube setup complete!"
echo "===================================="
echo ""
echo "Cluster Info:"
kubectl cluster-info
echo ""
echo "Access URLs:"
echo "  Frontend: http://app.local"
echo "  Backend:  http://api.local"
echo "  Keycloak: http://auth.local"
echo ""
echo "Next step: Run ./scripts/deploy-all.sh"
