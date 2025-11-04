#!/bin/bash

# Monitor deployment progress in real-time
# Usage: ./monitor-deployment.sh [namespace] [duration]

NAMESPACE="${1:-auth-platform}"
DURATION="${2:-600}"  # 10 minutes default
INTERVAL=15

echo "Monitoring deployment in namespace: $NAMESPACE"
echo "Duration: ${DURATION}s, Interval: ${INTERVAL}s"
echo "========================================"
echo ""

ELAPSED=0

while [ $ELAPSED -lt $DURATION ]; do
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$TIMESTAMP] Status update (${ELAPSED}s / ${DURATION}s)"
    echo ""

    # Check if namespace exists
    if ! kubectl get namespace $NAMESPACE &>/dev/null; then
        echo "⚠️  Namespace $NAMESPACE does not exist yet"
        echo ""
    else
        # Pod status
        echo "Pods:"
        kubectl get pods -n $NAMESPACE -o wide 2>/dev/null || echo "  No pods found"
        echo ""

        # Deployment status
        echo "Deployments:"
        kubectl get deployments -n $NAMESPACE 2>/dev/null || echo "  No deployments found"
        echo ""

        # Node resources
        echo "Node Resources:"
        kubectl top nodes 2>/dev/null || echo "  Metrics not available"
        echo ""

        # Pod resources (if available)
        echo "Pod Resources:"
        kubectl top pods -n $NAMESPACE 2>/dev/null || echo "  Metrics not available"
        echo ""

        # Recent events
        echo "Recent Events:"
        kubectl get events -n $NAMESPACE --sort-by='.lastTimestamp' 2>/dev/null | tail -5 || echo "  No events"
        echo ""

        # Check if all deployments are ready
        TOTAL_DEPLOYMENTS=$(kubectl get deployments -n $NAMESPACE --no-headers 2>/dev/null | wc -l)
        READY_DEPLOYMENTS=$(kubectl get deployments -n $NAMESPACE --no-headers 2>/dev/null | awk '$2 == $3 {print}' | wc -l)

        if [ "$TOTAL_DEPLOYMENTS" -gt 0 ] && [ "$TOTAL_DEPLOYMENTS" -eq "$READY_DEPLOYMENTS" ]; then
            echo "✅ All deployments are ready! ($READY_DEPLOYMENTS/$TOTAL_DEPLOYMENTS)"
            exit 0
        else
            echo "⏳ Deployments ready: $READY_DEPLOYMENTS/$TOTAL_DEPLOYMENTS"
        fi
    fi

    echo "========================================"
    echo ""

    sleep $INTERVAL
    ELAPSED=$((ELAPSED + INTERVAL))
done

echo "⏰ Monitoring timeout reached after ${DURATION}s"
echo ""
echo "Final status:"
kubectl get pods -n $NAMESPACE -o wide
echo ""
kubectl get deployments -n $NAMESPACE

exit 1
