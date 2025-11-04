# Troubleshooting Guide

This guide helps you debug common issues with the Cloud-Native Authentication Platform.

## Quick Diagnostic Commands

```bash
# Check cluster status
kubectl cluster-info
minikube status

# Check all pods
kubectl get pods -n auth-platform -o wide

# Check pod logs
kubectl logs -n auth-platform <pod-name>

# Describe pod for events
kubectl describe pod -n auth-platform <pod-name>

# Check resources
kubectl top nodes
kubectl top pods -n auth-platform

# View recent events
kubectl get events -n auth-platform --sort-by='.lastTimestamp'
```

## Common Issues

### 1. Keycloak Pod Not Starting

**Symptoms:**
- Pod stuck in `Pending`, `ContainerCreating`, or `CrashLoopBackOff`
- Readiness probe failures
- Timeouts during deployment

**Diagnosis:**
```bash
# Check pod status
kubectl get pods -n auth-platform -l app.kubernetes.io/name=keycloak

# Check pod details
kubectl describe pod -n auth-platform -l app.kubernetes.io/name=keycloak

# Check logs
kubectl logs -n auth-platform -l app.kubernetes.io/name=keycloak --tail=200

# Check if PostgreSQL is ready
kubectl get pods -n auth-platform -l app.kubernetes.io/name=postgres
```

**Solutions:**

**A. Insufficient Resources:**
```yaml
# Edit k8s/keycloak/deployment.yaml
resources:
  limits:
    memory: 2Gi  # Increase if needed
    cpu: 2000m
```

**B. PostgreSQL Not Ready:**
```bash
# Verify PostgreSQL is running
kubectl exec -n auth-platform -l app.kubernetes.io/name=postgres -- pg_isready -U keycloak

# Check PostgreSQL logs
kubectl logs -n auth-platform -l app.kubernetes.io/name=postgres
```

**C. Database Connection Issues:**
```bash
# Check environment variables
kubectl exec -n auth-platform -l app.kubernetes.io/name=keycloak -- env | grep KC_DB

# Test database connectivity from Keycloak pod
kubectl exec -n auth-platform -l app.kubernetes.io/name=keycloak -- \
  curl -v telnet://postgres:5432
```

**D. Increase Timeouts:**
```yaml
# Edit k8s/keycloak/deployment.yaml
readinessProbe:
  initialDelaySeconds: 180  # Increase
  failureThreshold: 20      # Increase
```

### 2. Backend Cannot Connect to Keycloak

**Symptoms:**
- Backend logs show JWT validation errors
- 401 Unauthorized on protected endpoints
- "Unable to obtain JWK Set" errors

**Diagnosis:**
```bash
# Check backend logs
kubectl logs -n auth-platform -l app.kubernetes.io/name=backend

# Test Keycloak from backend pod
kubectl exec -n auth-platform -l app.kubernetes.io/name=backend -- \
  curl http://keycloak:8080/realms/demo-realm/.well-known/openid-configuration

# Check service DNS
kubectl exec -n auth-platform -l app.kubernetes.io/name=backend -- \
  nslookup keycloak
```

**Solutions:**

**A. Keycloak Not Ready:**
```bash
# Wait for Keycloak
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=keycloak \
  -n auth-platform --timeout=600s
```

**B. Wrong Issuer URI:**
```yaml
# Edit k8s/backend/configmap.yaml
KEYCLOAK_ISSUER_URI: http://auth.local/realms/demo-realm  # External
KEYCLOAK_JWK_SET_URI: http://keycloak:8080/realms/demo-realm/protocol/openid-connect/certs  # Internal
```

**C. Network Policy Issues:**
```bash
# Check if network policies are blocking
kubectl get networkpolicies -n auth-platform

# Temporarily disable if exists
kubectl delete networkpolicy --all -n auth-platform
```

### 3. Frontend Cannot Authenticate

**Symptoms:**
- Redirect loop on login
- CORS errors in browser console
- "Invalid redirect URI" from Keycloak

**Diagnosis:**
```bash
# Check frontend logs
kubectl logs -n auth-platform -l app.kubernetes.io/name=frontend

# Check ingress
kubectl get ingress -n auth-platform

# Test from browser console
fetch('http://api.local/api/public/hello')
  .then(r => r.json())
  .then(console.log)
```

**Solutions:**

**A. CORS Issues:**
```java
// backend/src/main/java/com/example/authapi/config/CorsConfig.java
configuration.setAllowedOrigins(Arrays.asList(
    "http://localhost:4200",
    "http://app.local"  // Add your frontend URL
));
```

**B. Invalid Redirect URI:**
- Login to Keycloak admin: http://auth.local (admin/admin)
- Go to: Clients → angular-app → Settings
- Add to Valid Redirect URIs: `http://app.local/*`
- Add to Web Origins: `http://app.local`

**C. /etc/hosts Not Configured:**
```bash
# Add to /etc/hosts
sudo bash -c 'echo "$(minikube ip) app.local api.local auth.local" >> /etc/hosts'
```

### 4. Build Failures in CI

**Symptoms:**
- Docker build fails
- npm install errors
- Maven build errors

**Diagnosis:**
```bash
# Check if Docker daemon is accessible
docker info

# Check if using Minikube Docker
eval $(minikube docker-env)
docker info

# Verify source code compiles locally
cd frontend && npm install && npm run build
cd backend && mvn clean package
```

**Solutions:**

**A. Docker Not Accessible:**
```bash
# Ensure Minikube is running
minikube status

# Configure Docker environment
eval $(minikube docker-env)
```

**B. Node/npm Issues:**
```bash
# Clear npm cache
cd frontend
rm -rf node_modules package-lock.json
npm install
```

**C. Maven Issues:**
```bash
# Clear Maven cache
cd backend
mvn clean
mvn dependency:purge-local-repository
mvn package
```

### 5. Pods Stuck in Pending

**Symptoms:**
- Pods never start
- "Insufficient memory" or "Insufficient cpu" events

**Diagnosis:**
```bash
# Check pod events
kubectl describe pod -n auth-platform <pod-name>

# Check node resources
kubectl describe nodes

# Check resource requests
kubectl describe deployment -n auth-platform <deployment-name>
```

**Solutions:**

**A. Insufficient Cluster Resources:**
```bash
# Restart Minikube with more resources
minikube delete
minikube start --cpus=4 --memory=8192
```

**B. Reduce Resource Requests:**
```yaml
# Edit deployment YAML files
resources:
  requests:
    memory: 256Mi  # Reduce
    cpu: 100m      # Reduce
```

**C. PVC Issues:**
```bash
# Check PVC status
kubectl get pvc -n auth-platform

# Delete and recreate if bound to wrong PV
kubectl delete pvc postgres-pvc -n auth-platform
kubectl apply -f k8s/postgres/pvc.yaml
```

### 6. Ingress Not Working

**Symptoms:**
- Cannot access app.local, api.local, or auth.local
- 404 or 502 errors
- Connection refused

**Diagnosis:**
```bash
# Check ingress controller
kubectl get pods -n ingress-nginx

# Check ingress resources
kubectl get ingress -n auth-platform

# Check ingress details
kubectl describe ingress -n auth-platform
```

**Solutions:**

**A. Ingress Addon Not Enabled:**
```bash
minikube addons enable ingress

# Wait for controller
kubectl wait --for=condition=ready pod \
  -l app.kubernetes.io/component=controller \
  -n ingress-nginx --timeout=120s
```

**B. /etc/hosts Not Configured:**
```bash
echo "$(minikube ip) app.local api.local auth.local" | sudo tee -a /etc/hosts
```

**C. Service Not Found:**
```bash
# Check if services exist
kubectl get svc -n auth-platform

# Check service endpoints
kubectl get endpoints -n auth-platform
```

## Debugging Tools

### 1. Preflight Check
```bash
./scripts/preflight-check.sh
```
Validates all prerequisites before deployment.

### 2. Monitor Deployment
```bash
./scripts/monitor-deployment.sh auth-platform 600
```
Real-time monitoring of deployment progress.

### 3. Wait for Keycloak
```bash
./scripts/wait-for-keycloak.sh
```
Monitors Keycloak startup with detailed progress.

### 4. GitHub Actions Debug
Run the "Debug CI Issues" workflow from the Actions tab to get detailed logs for specific components.

## Complete Cleanup and Restart

If all else fails, start fresh:

```bash
# 1. Delete everything
./scripts/cleanup.sh

# 2. Delete Minikube
minikube delete

# 3. Start fresh
./scripts/setup-minikube.sh
./scripts/deploy-all.sh
./scripts/configure-keycloak.sh
```

## Known Issues

### kubectl cp fails with "tar not found"

**Symptoms:**
- Error: `exec: "tar": executable file not found in $PATH`
- Occurs when trying to copy files to Keycloak pod

**Solution:**
Use stdin instead of `kubectl cp`:

```bash
# Instead of:
kubectl cp file.json namespace/pod:/tmp/file.json

# Use:
cat file.json | kubectl exec -i -n namespace pod -- sh -c 'cat > /tmp/file.json'
```

This is because the Keycloak container image doesn't include `tar`, which `kubectl cp` requires.

## Getting Help

### Collect Diagnostic Information

```bash
# Save all diagnostics to file
{
  echo "=== Cluster Info ==="
  kubectl cluster-info

  echo "=== Nodes ==="
  kubectl get nodes -o wide

  echo "=== Pods ==="
  kubectl get pods -n auth-platform -o wide

  echo "=== Deployments ==="
  kubectl get deployments -n auth-platform

  echo "=== Services ==="
  kubectl get services -n auth-platform

  echo "=== Ingress ==="
  kubectl get ingress -n auth-platform

  echo "=== Events ==="
  kubectl get events -n auth-platform --sort-by='.lastTimestamp'

  echo "=== PostgreSQL Logs ==="
  kubectl logs -n auth-platform -l app.kubernetes.io/name=postgres --tail=100

  echo "=== Keycloak Logs ==="
  kubectl logs -n auth-platform -l app.kubernetes.io/name=keycloak --tail=200

  echo "=== Backend Logs ==="
  kubectl logs -n auth-platform -l app.kubernetes.io/name=backend --tail=100

  echo "=== Frontend Logs ==="
  kubectl logs -n auth-platform -l app.kubernetes.io/name=frontend --tail=100
} > diagnostics.txt

echo "Diagnostics saved to diagnostics.txt"
```

### Report Issues

When reporting issues, include:
1. Output from `diagnostics.txt`
2. Your environment (OS, Minikube version, kubectl version)
3. Steps to reproduce
4. Expected vs actual behavior

## Related Documentation

- [Setup Guide](SETUP.md)
- [Deployment Guide](DEPLOYMENT.md)
- [CI/CD Guide](CI-CD.md)
- [API Documentation](API.md)
