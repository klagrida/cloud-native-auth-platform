#!/bin/bash

set -e

echo "Waiting for Keycloak to be ready..."
echo "This can take 5-10 minutes on first startup."
echo ""

MAX_ATTEMPTS=60
ATTEMPT=0
SLEEP_SECONDS=10

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
  ATTEMPT=$((ATTEMPT + 1))

  echo "Attempt $ATTEMPT/$MAX_ATTEMPTS..."

  # Check if pod exists
  POD_STATUS=$(kubectl get pods -n auth-platform -l app.kubernetes.io/name=keycloak -o jsonpath='{.items[0].status.phase}' 2>/dev/null || echo "NotFound")

  if [ "$POD_STATUS" == "NotFound" ]; then
    echo "  ⏳ Keycloak pod not found yet"
  elif [ "$POD_STATUS" == "Pending" ]; then
    echo "  ⏳ Keycloak pod is pending..."
    REASON=$(kubectl get pods -n auth-platform -l app.kubernetes.io/name=keycloak -o jsonpath='{.items[0].status.conditions[?(@.type=="PodScheduled")].reason}' 2>/dev/null || echo "Unknown")
    echo "     Reason: $REASON"
  elif [ "$POD_STATUS" == "Running" ]; then
    # Check if container is ready
    READY=$(kubectl get pods -n auth-platform -l app.kubernetes.io/name=keycloak -o jsonpath='{.items[0].status.conditions[?(@.type=="Ready")].status}' 2>/dev/null || echo "False")

    if [ "$READY" == "True" ]; then
      echo "  ✅ Keycloak is ready!"
      kubectl get pods -n auth-platform -l app.kubernetes.io/name=keycloak
      exit 0
    else
      echo "  🔄 Keycloak pod is running but not ready yet..."

      # Show container status
      CONTAINER_READY=$(kubectl get pods -n auth-platform -l app.kubernetes.io/name=keycloak -o jsonpath='{.items[0].status.containerStatuses[0].ready}' 2>/dev/null || echo "false")
      RESTART_COUNT=$(kubectl get pods -n auth-platform -l app.kubernetes.io/name=keycloak -o jsonpath='{.items[0].status.containerStatuses[0].restartCount}' 2>/dev/null || echo "0")

      echo "     Container Ready: $CONTAINER_READY"
      echo "     Restart Count: $RESTART_COUNT"

      # If restarting too much, show logs
      if [ "$RESTART_COUNT" -gt "3" ]; then
        echo "  ⚠️  Warning: Keycloak has restarted $RESTART_COUNT times"
        echo "     Recent logs:"
        kubectl logs -n auth-platform -l app.kubernetes.io/name=keycloak --tail=20 2>/dev/null || echo "     Could not fetch logs"
      fi
    fi
  elif [ "$POD_STATUS" == "Failed" ] || [ "$POD_STATUS" == "CrashLoopBackOff" ]; then
    echo "  ❌ Keycloak pod failed!"
    kubectl get pods -n auth-platform -l app.kubernetes.io/name=keycloak
    kubectl describe pod -n auth-platform -l app.kubernetes.io/name=keycloak
    kubectl logs -n auth-platform -l app.kubernetes.io/name=keycloak --tail=100 2>/dev/null || echo "Could not fetch logs"
    exit 1
  else
    echo "  ⏳ Keycloak pod status: $POD_STATUS"
  fi

  if [ $ATTEMPT -lt $MAX_ATTEMPTS ]; then
    echo "     Waiting ${SLEEP_SECONDS}s before next check..."
    sleep $SLEEP_SECONDS
  fi
done

echo ""
echo "❌ Timeout waiting for Keycloak to be ready after $((MAX_ATTEMPTS * SLEEP_SECONDS)) seconds"
echo ""
echo "Final status:"
kubectl get pods -n auth-platform -l app.kubernetes.io/name=keycloak
echo ""
echo "Pod description:"
kubectl describe pod -n auth-platform -l app.kubernetes.io/name=keycloak
echo ""
echo "Recent logs:"
kubectl logs -n auth-platform -l app.kubernetes.io/name=keycloak --tail=100 2>/dev/null || echo "Could not fetch logs"

exit 1
