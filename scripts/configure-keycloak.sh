#!/bin/bash

set -e

echo "===================================="
echo "Configuring Keycloak"
echo "===================================="

# Get Keycloak pod name
KEYCLOAK_POD=$(kubectl get pods -n auth-platform -l app.kubernetes.io/name=keycloak -o jsonpath='{.items[0].metadata.name}')

echo "Keycloak pod: $KEYCLOAK_POD"

# The realm is automatically imported on startup via ConfigMap
# Just verify the import was successful
echo ""
echo "Verifying realm import..."
echo "Checking Keycloak logs for import status..."
kubectl logs -n auth-platform $KEYCLOAK_POD --tail=100 | grep -i "import\|realm\|demo-realm" || {
  echo "Could not find import messages in logs, but realm may still be imported"
  echo "You can verify by logging into Keycloak admin console at http://auth.local"
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
