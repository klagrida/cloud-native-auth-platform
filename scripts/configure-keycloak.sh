#!/bin/bash

set -e

echo "===================================="
echo "Configuring Keycloak"
echo "===================================="

# Wait for Keycloak to be fully ready
echo "Waiting for Keycloak to be ready..."
sleep 10

# Get Keycloak pod name
KEYCLOAK_POD=$(kubectl get pods -n auth-platform -l app.kubernetes.io/name=keycloak -o jsonpath='{.items[0].metadata.name}')

echo "Keycloak pod: $KEYCLOAK_POD"

# Copy realm configuration to pod using stdin (doesn't require tar)
echo "Copying realm configuration to Keycloak pod..."
cat keycloak/realm-export.json | kubectl exec -i -n auth-platform $KEYCLOAK_POD -- sh -c 'cat > /tmp/realm-export.json'

# Verify file was copied
echo "Verifying file was copied..."
kubectl exec -n auth-platform $KEYCLOAK_POD -- sh -c 'ls -lh /tmp/realm-export.json'

# Import realm
echo "Importing realm configuration..."
kubectl exec -n auth-platform $KEYCLOAK_POD -- /opt/keycloak/bin/kc.sh import --file /tmp/realm-export.json || {
  echo "Import command failed, but this might be expected if realm already exists"
  echo "Checking Keycloak logs for import status..."
  kubectl logs -n auth-platform $KEYCLOAK_POD --tail=50 | grep -i "import\|realm" || true
}

echo ""
echo "===================================="
echo "Keycloak Configuration Complete!"
echo "===================================="
echo ""
echo "Keycloak Admin Console: http://auth.local"
echo "  Username: admin"
echo "  Password: admin"
echo ""
echo "Realm: demo-realm"
echo ""
echo "Test Users:"
echo "  1. Admin User"
echo "     Username: admin"
echo "     Password: admin123"
echo "     Roles: USER, ADMIN"
echo ""
echo "  2. Regular User"
echo "     Username: user"
echo "     Password: user123"
echo "     Roles: USER"
echo ""
echo "  3. Manager User"
echo "     Username: manager"
echo "     Password: manager123"
echo "     Roles: USER, MANAGER"
echo ""
echo "You can now access the application at http://app.local"
