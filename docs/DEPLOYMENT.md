# Deployment Guide

This guide covers deploying the Auth Platform to different environments.

## Deployment Overview

The application consists of four main components:

1. **PostgreSQL** - Database for Keycloak
2. **Keycloak** - Identity Provider
3. **Spring Boot Backend** - OAuth2 Resource Server
4. **Angular Frontend** - Web Application

## Deployment Architecture

```
Internet → Ingress Controller → Services → Pods
                                    ↓
                              PostgreSQL (PVC)
```

## Environment Configuration

### Development (Minikube)

Use the provided scripts:

```bash
./scripts/setup-minikube.sh
./scripts/deploy-all.sh
./scripts/configure-keycloak.sh
```

### Production Considerations

#### 1. PostgreSQL

**For Production:**
- Use managed database service (AWS RDS, Azure Database, GCP Cloud SQL)
- Enable SSL/TLS connections
- Configure automatic backups
- Set up replication for high availability

**Configuration:**
```yaml
# Update k8s/keycloak/configmap.yaml
KC_DB_URL: jdbc:postgresql://your-db-host:5432/keycloak?ssl=true
```

#### 2. Keycloak

**Production Settings:**
- Use production mode (not start-dev)
- Enable HTTPS
- Configure clustering for high availability
- Use external database (not in-cluster)
- Set proper resource limits
- Configure session persistence

**Example Production Deployment:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: keycloak
spec:
  replicas: 3
  template:
    spec:
      containers:
      - name: keycloak
        image: quay.io/keycloak/keycloak:23.0
        args:
        - start
        env:
        - name: KC_HOSTNAME
          value: auth.yourdomain.com
        - name: KC_PROXY
          value: edge
        - name: KC_HTTPS_CERTIFICATE_FILE
          value: /etc/certs/tls.crt
        - name: KC_HTTPS_CERTIFICATE_KEY_FILE
          value: /etc/certs/tls.key
```

#### 3. Backend

**Production Settings:**
- Set `spring.profiles.active=prod`
- Configure proper logging
- Set resource limits
- Enable health checks
- Use secrets for sensitive data

**application-prod.yml:**
```yaml
spring:
  security:
    oauth2:
      resourceserver:
        jwt:
          issuer-uri: https://auth.yourdomain.com/realms/demo-realm

logging:
  level:
    root: INFO
    org.springframework.security: WARN
```

#### 4. Frontend

**Production Settings:**
- Build with production configuration
- Enable gzip compression
- Configure CDN for assets
- Set proper cache headers

**Production Build:**
```bash
cd frontend
npm run build -- --configuration=production
```

## SSL/TLS Configuration

### Using cert-manager

1. **Install cert-manager:**
```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml
```

2. **Create ClusterIssuer:**
```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: your-email@example.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
```

3. **Update Ingress:**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: frontend-ingress
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  tls:
  - hosts:
    - app.yourdomain.com
    secretName: frontend-tls
  rules:
  - host: app.yourdomain.com
    # ... rest of config
```

## Resource Limits

### Recommended Production Resources

**PostgreSQL:**
```yaml
resources:
  requests:
    cpu: 1000m
    memory: 2Gi
  limits:
    cpu: 2000m
    memory: 4Gi
```

**Keycloak:**
```yaml
resources:
  requests:
    cpu: 1000m
    memory: 1Gi
  limits:
    cpu: 2000m
    memory: 2Gi
```

**Backend:**
```yaml
resources:
  requests:
    cpu: 500m
    memory: 1Gi
  limits:
    cpu: 1000m
    memory: 2Gi
```

**Frontend:**
```yaml
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 200m
    memory: 256Mi
```

## Scaling

### Horizontal Pod Autoscaling

**Backend HPA:**
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: backend-hpa
  namespace: auth-platform
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: backend
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

## Monitoring

### Prometheus & Grafana

1. **Install Prometheus Operator:**
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
```

2. **Create ServiceMonitor:**
```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: backend-metrics
  namespace: auth-platform
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: backend
  endpoints:
  - port: http
    path: /actuator/prometheus
```

## Backup & Recovery

### PostgreSQL Backups

**Using CronJob:**
```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: postgres-backup
  namespace: auth-platform
spec:
  schedule: "0 2 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: postgres:15-alpine
            command:
            - /bin/sh
            - -c
            - pg_dump -h postgres -U keycloak keycloak > /backup/backup-$(date +%Y%m%d).sql
            volumeMounts:
            - name: backup
              mountPath: /backup
          volumes:
          - name: backup
            persistentVolumeClaim:
              claimName: backup-pvc
```

## CI/CD Pipeline

### GitHub Actions Workflow

The project includes three workflows:

1. **frontend-ci.yml** - Build and test frontend
2. **backend-ci.yml** - Build and test backend
3. **deploy.yml** - Deploy to Kubernetes

### Required Secrets

Configure these in GitHub repository settings:

- `DOCKERHUB_USERNAME` - Docker registry username
- `DOCKERHUB_TOKEN` - Docker registry token
- `KUBECONFIG` - Base64-encoded kubeconfig file

### Deployment Process

1. Code is pushed to main branch
2. CI workflows run tests and build images
3. Images are pushed to container registry
4. Deploy workflow applies Kubernetes manifests
5. Pods are rolled out with new images

## Security Best Practices

1. **Secrets Management:**
   - Use Kubernetes Secrets
   - Consider using external secret managers (Vault, AWS Secrets Manager)
   - Rotate secrets regularly

2. **Network Policies:**
   - Restrict pod-to-pod communication
   - Only allow necessary ingress/egress

3. **RBAC:**
   - Use least privilege principle
   - Create specific service accounts

4. **Image Security:**
   - Scan images for vulnerabilities
   - Use minimal base images
   - Keep images updated

## Health Checks

All components have:
- **Liveness Probes** - Restart unhealthy pods
- **Readiness Probes** - Route traffic only to ready pods

## Rollback Strategy

If deployment fails:

```bash
# Rollback deployment
kubectl rollout undo deployment/backend -n auth-platform

# Check rollout status
kubectl rollout status deployment/backend -n auth-platform

# View rollout history
kubectl rollout history deployment/backend -n auth-platform
```

## Multi-Environment Setup

Create separate namespaces for each environment:

```bash
# Development
kubectl create namespace auth-platform-dev

# Staging
kubectl create namespace auth-platform-staging

# Production
kubectl create namespace auth-platform-prod
```

Use separate ConfigMaps and Secrets for each environment.

## Next Steps

- Configure monitoring and alerting
- Set up log aggregation (ELK, Loki)
- Implement network policies
- Configure backup automation
- Set up disaster recovery plan
