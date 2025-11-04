#!/bin/bash

echo "===================================="
echo "Pre-flight Checks"
echo "===================================="
echo ""

CHECKS_PASSED=0
CHECKS_FAILED=0

# Function to check command
check_command() {
    if command -v $1 &> /dev/null; then
        echo "✓ $1 is installed"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
        return 0
    else
        echo "✗ $1 is NOT installed"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
        return 1
    fi
}

# Function to check service
check_service() {
    if $2 &> /dev/null; then
        echo "✓ $1"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
        return 0
    else
        echo "✗ $1"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
        return 1
    fi
}

echo "1. Checking required commands..."
check_command docker
check_command kubectl
check_command minikube

echo ""
echo "2. Checking services..."
check_service "Docker is running" "docker info"
check_service "Minikube is running" "minikube status"
check_service "Kubectl can reach cluster" "kubectl cluster-info"

echo ""
echo "3. Checking Minikube addons..."
if minikube addons list | grep -q "ingress.*enabled"; then
    echo "✓ Ingress addon is enabled"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    echo "✗ Ingress addon is NOT enabled"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
fi

echo ""
echo "4. Checking project structure..."
for dir in frontend backend k8s scripts keycloak; do
    if [ -d "$dir" ]; then
        echo "✓ $dir/ directory exists"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        echo "✗ $dir/ directory NOT found"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
done

echo ""
echo "5. Checking Kubernetes manifests..."
for manifest in k8s/namespace.yaml k8s/postgres/deployment.yaml k8s/keycloak/deployment.yaml k8s/backend/deployment.yaml k8s/frontend/deployment.yaml; do
    if [ -f "$manifest" ]; then
        echo "✓ $manifest exists"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        echo "✗ $manifest NOT found"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
done

echo ""
echo "6. Checking Docker environment..."
eval $(minikube docker-env)
if docker info &> /dev/null; then
    echo "✓ Docker environment configured for Minikube"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    echo "✗ Cannot configure Docker for Minikube"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
fi

echo ""
echo "===================================="
echo "Pre-flight Check Summary"
echo "===================================="
echo "Checks passed: $CHECKS_PASSED"
echo "Checks failed: $CHECKS_FAILED"
echo ""

if [ $CHECKS_FAILED -eq 0 ]; then
    echo "✅ All checks passed! Ready to deploy."
    exit 0
else
    echo "❌ Some checks failed. Please fix the issues above before deploying."
    exit 1
fi
