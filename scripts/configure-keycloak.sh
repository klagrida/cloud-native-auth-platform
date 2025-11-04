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

# Copy realm configuration to pod
echo "Copying realm configuration to Keycloak pod..."
kubectl cp keycloak/realm-export.json auth-platform/$KEYCLOAK_POD:/tmp/realm-export.json

# Import realm
echo "Importing realm configuration..."
kubectl exec -n auth-platform $KEYCLOAK_POD -- /opt/keycloak/bin/kc.sh import --file /tmp/realm-export.json || true

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
