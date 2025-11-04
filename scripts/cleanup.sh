#!/bin/bash

set -e

echo "===================================="
echo "Cleaning up Auth Platform"
echo "===================================="

# Delete namespace (this will delete all resources in the namespace)
echo "Deleting namespace and all resources..."
kubectl delete namespace auth-platform --ignore-not-found=true

echo "Waiting for namespace to be deleted..."
kubectl wait --for=delete namespace/auth-platform --timeout=120s || true

echo ""
echo "===================================="
echo "Cleanup Complete!"
echo "===================================="
echo ""
echo "All Kubernetes resources have been deleted."
echo ""
echo "To remove /etc/hosts entries, run:"
echo "  sudo sed -i.bak '/app.local/d; /api.local/d; /auth.local/d' /etc/hosts"
echo ""
echo "To stop Minikube, run:"
echo "  minikube stop"
echo ""
echo "To delete Minikube cluster, run:"
echo "  minikube delete"
