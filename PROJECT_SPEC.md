# Authentication & Authorization System - Project Specification

## 📋 Project Overview

**Project Name**: Cloud-Native Authentication Platform

**Goal**: Implement a complete authentication and authorization system using OIDC/OAuth2 with Keycloak as Identity Provider, deployed on Kubernetes with CI/CD automation.

**Stack**:
- **Frontend**: Angular 17+ with TypeScript
- **Backend**: Spring Boot 3+ with Java 17+
- **Identity Provider**: Keycloak (latest stable)
- **Database**: PostgreSQL 15+
- **Container Orchestration**: Kubernetes (Minikube for local)
- **CI/CD**: GitHub Actions

---

## 🎯 Project Goals

1. Deploy Keycloak as a centralized Identity Provider
2. Implement Angular frontend with OIDC authentication
3. Implement Spring Boot backend as OAuth2 Resource Server
4. Containerize all applications with Docker
5. Deploy complete stack on Minikube
6. Automate build and deployment with GitHub Actions
7. Implement proper security practices and RBAC

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Minikube Cluster                          │
│                                                               │
│  ┌─────────────┐         ┌──────────────────────────┐      │
│  │   Angular   │◄───────►│      Keycloak           │      │
│  │   Frontend  │  OIDC   │   Identity Provider     │      │
│  │             │         │   - Realm: demo-realm    │      │
│  └──────┬──────┘         │   - Users & Roles       │      │
│         │                └──────────┬───────────────┘      │
│         │ HTTP + JWT              │                        │
│         │                          │ JDBC                  │
│         ▼                          ▼                        │
│  ┌─────────────┐         ┌──────────────────────────┐      │
│  │ Spring Boot │         │     PostgreSQL          │      │
│  │   REST API  │         │  - Keycloak DB          │      │
│  │  (Resource  │         │  - App DB (optional)    │      │
│  │   Server)   │         └──────────────────────────┘      │
│  └─────────────┘                                            │
│                                                               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              NGINX Ingress Controller                 │   │
│  │  Routes:                                              │   │
│  │  - app.local        → Angular                        │   │
│  │  - api.local        → Spring Boot                    │   │
│  │  - auth.local       → Keycloak                       │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## 📁 Required Project Structure

```
auth-platform/
├── README.md
├── .gitignore
│
├── frontend/                           # Angular Application
│   ├── src/
│   │   ├── app/
│   │   │   ├── core/
│   │   │   │   ├── guards/
│   │   │   │   │   └── auth.guard.ts
│   │   │   │   ├── interceptors/
│   │   │   │   │   └── auth.interceptor.ts
│   │   │   │   └── services/
│   │   │   │       └── auth.service.ts
│   │   │   ├── components/
│   │   │   │   ├── home/
│   │   │   │   ├── login/
│   │   │   │   ├── dashboard/
│   │   │   │   ├── profile/
│   │   │   │   └── admin/
│   │   │   ├── app.config.ts
│   │   │   ├── app.routes.ts
│   │   │   └── app.component.ts
│   │   ├── environments/
│   │   │   ├── environment.ts
│   │   │   └── environment.prod.ts
│   │   └── index.html
│   ├── angular.json
│   ├── package.json
│   ├── tsconfig.json
│   ├── Dockerfile
│   └── nginx.conf
│
├── backend/                            # Spring Boot API
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/com/example/authapi/
│   │   │   │   ├── config/
│   │   │   │   │   ├── SecurityConfig.java
│   │   │   │   │   └── CorsConfig.java
│   │   │   │   ├── controller/
│   │   │   │   │   ├── PublicController.java
│   │   │   │   │   ├── UserController.java
│   │   │   │   │   └── AdminController.java
│   │   │   │   ├── dto/
│   │   │   │   │   └── UserInfo.java
│   │   │   │   └── AuthApiApplication.java
│   │   │   └── resources/
│   │   │       └── application.yml
│   │   └── test/
│   ├── pom.xml
│   └── Dockerfile
│
├── k8s/                                # Kubernetes Manifests
│   ├── namespace.yaml
│   ├── postgres/
│   │   ├── pvc.yaml
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── secret.yaml
│   ├── keycloak/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   ├── configmap.yaml
│   │   └── ingress.yaml
│   ├── frontend/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   ├── configmap.yaml
│   │   └── ingress.yaml
│   ├── backend/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   ├── configmap.yaml
│   │   └── ingress.yaml
│   └── ingress/
│       └── nginx-ingress.yaml
│
├── .github/
│   └── workflows/
│       ├── frontend-ci.yml
│       ├── backend-ci.yml
│       └── deploy.yml
│
├── scripts/
│   ├── setup-minikube.sh
│   ├── deploy-all.sh
│   ├── configure-keycloak.sh
│   └── cleanup.sh
│
├── keycloak/
│   └── realm-export.json             # Keycloak realm configuration
│
└── docs/
    ├── SETUP.md
    ├── DEPLOYMENT.md
    └── API.md
```

---

## 🔧 Component Specifications

### 1. Angular Frontend

**Requirements**:
- Angular 17+ with standalone components
- OIDC authentication using `angular-oauth2-oidc` library
- Protected routes with authentication guards
- HTTP interceptor for JWT token injection
- Role-based UI visibility
- Responsive design with Angular Material

**Key Features**:

1. **Authentication Service** (`auth.service.ts`):
   - Configure OIDC client for Keycloak
   - Handle login/logout flows
   - Token management (access token, refresh token)
   - User info retrieval
   - Role checking methods

2. **Auth Guard** (`auth.guard.ts`):
   - Protect routes requiring authentication
   - Role-based route protection
   - Redirect to login when unauthorized

3. **HTTP Interceptor** (`auth.interceptor.ts`):
   - Automatically add JWT Bearer token to API requests
   - Handle 401 responses (token refresh or redirect to login)

4. **Components**:
   - **Home**: Public landing page
   - **Login**: Trigger OIDC login flow
   - **Dashboard**: Protected user dashboard
   - **Profile**: Display user info from token
   - **Admin**: Admin-only page (requires ADMIN role)

5. **Configuration** (`environment.ts`):
```typescript
export const environment = {
  production: false,
  keycloakUrl: 'http://auth.local',
  keycloakRealm: 'demo-realm',
  keycloakClientId: 'angular-app',
  apiUrl: 'http://api.local/api'
};
```

**OIDC Configuration**:
- Flow: Authorization Code with PKCE
- Response Type: `code`
- Scope: `openid profile email`
- Redirect URI: `http://app.local/callback`
- Post Logout Redirect URI: `http://app.local`

**Dockerfile**:
- Multi-stage build
- Stage 1: Build Angular with Node 20
- Stage 2: Serve with nginx:alpine
- Copy custom nginx.conf for SPA routing
- Expose port 80

---

### 2. Spring Boot Backend

**Requirements**:
- Spring Boot 3.2+
- Java 17+
- OAuth2 Resource Server
- JWT validation against Keycloak
- CORS configuration for Angular
- RESTful API with different security levels

**Dependencies** (pom.xml):
```xml
- spring-boot-starter-web
- spring-boot-starter-security
- spring-boot-starter-oauth2-resource-server
- spring-boot-starter-validation
```

**Key Components**:

1. **SecurityConfig.java**:
   - Configure OAuth2 Resource Server
   - JWT decoder with Keycloak issuer URI
   - Security filter chain with endpoint authorization
   - Extract authorities from JWT `realm_access.roles`
   - CORS configuration

2. **Controllers**:

   **PublicController.java**:
   - `GET /api/public/hello` - No authentication required
   - Returns public message

   **UserController.java**:
   - `GET /api/user/info` - Requires authentication
   - Returns user info from JWT
   - `GET /api/user/data` - Returns user-specific data

   **AdminController.java**:
   - `GET /api/admin/users` - Requires ADMIN role
   - Returns list of users (mock data)
   - `GET /api/admin/stats` - Returns system statistics

3. **Configuration** (application.yml):
```yaml
spring:
  security:
    oauth2:
      resourceserver:
        jwt:
          issuer-uri: http://auth.local/realms/demo-realm
          jwk-set-uri: http://keycloak:8080/realms/demo-realm/protocol/openid-connect/certs

server:
  port: 8080

logging:
  level:
    org.springframework.security: DEBUG
```

**Security Rules**:
- `/api/public/**` - Permit all
- `/api/user/**` - Authenticated users only
- `/api/admin/**` - Users with ADMIN role
- All other requests - Authenticated

**Dockerfile**:
- Multi-stage build
- Stage 1: Build with Maven
- Stage 2: Run with Eclipse Temurin JRE 17
- Copy JAR file
- Expose port 8080
- Health check endpoint

---

### 3. Keycloak Configuration

**Realm Configuration**: `demo-realm`

**Clients**:

1. **angular-app** (Frontend):
   - Client Protocol: openid-connect
   - Access Type: public
   - Standard Flow Enabled: ON
   - Direct Access Grants: OFF
   - Valid Redirect URIs: `http://app.local/*`
   - Web Origins: `http://app.local`
   - PKCE: Required (S256)

2. **spring-api** (Backend - Optional):
   - Client Protocol: openid-connect
   - Access Type: confidential
   - Service Accounts Enabled: ON
   - Authorization Enabled: OFF

**Roles**:
- Create realm roles:
  - `USER` (default role)
  - `ADMIN`
  - `MANAGER`

**Users** (Create test users):
1. **admin**:
   - Username: admin
   - Email: admin@example.com
   - Password: admin123
   - Roles: USER, ADMIN

2. **user**:
   - Username: user
   - Email: user@example.com
   - Password: user123
   - Roles: USER

**Client Scopes**:
- Ensure `roles` are included in token claims
- Map `realm_access.roles` to token

**Realm Settings**:
- Login Theme: keycloak (default)
- Access Token Lifespan: 5 minutes
- SSO Session Idle: 30 minutes
- Require SSL: external requests

**Export Configuration**:
- Export realm configuration to `keycloak/realm-export.json`
- Include clients, roles, and users (without credentials)

---

### 4. PostgreSQL Database

**Purpose**: Backend database for Keycloak

**Configuration**:
- Image: postgres:15-alpine
- Database Name: keycloak
- Username: keycloak
- Password: keycloak_password (stored in Kubernetes Secret)
- Port: 5432
- Persistent Volume: 1Gi

**Kubernetes Resources**:
- PersistentVolumeClaim for data persistence
- Secret for credentials
- Service (ClusterIP)
- Deployment with single replica

---

### 5. Kubernetes Manifests

**Namespace**: `auth-platform`

**Common Labels**:
```yaml
app.kubernetes.io/name: <component>
app.kubernetes.io/part-of: auth-platform
```

**Resource Requirements**:

PostgreSQL:
- CPU: 250m / 500m (request/limit)
- Memory: 256Mi / 512Mi

Keycloak:
- CPU: 500m / 1000m
- Memory: 512Mi / 1Gi

Angular:
- CPU: 100m / 200m
- Memory: 128Mi / 256Mi

Spring Boot:
- CPU: 250m / 500m
- Memory: 512Mi / 1Gi

**Ingress Configuration**:
- Controller: NGINX Ingress
- Hosts:
  - `app.local` → Angular Service (port 80)
  - `api.local` → Spring Boot Service (port 8080)
  - `auth.local` → Keycloak Service (port 8080)

**ConfigMaps**:
- Frontend: API URL, Keycloak URL
- Backend: Keycloak issuer URI
- Keycloak: Database connection details

**Secrets**:
- PostgreSQL credentials
- Keycloak admin credentials (admin/admin for demo)

**Health Checks**:
- Liveness probes for all applications
- Readiness probes for all applications
- Initial delay: 30 seconds for Spring Boot, 60 seconds for Keycloak

---

## 🔐 Security Requirements

1. **OIDC/OAuth2**:
   - Use Authorization Code Flow with PKCE (no client secret in frontend)
   - Proper redirect URI validation
   - Token storage: sessionStorage or memory (not localStorage for sensitive apps)

2. **JWT Validation**:
   - Verify signature using Keycloak's public key
   - Validate issuer claim
   - Validate audience claim (if configured)
   - Check token expiration

3. **CORS**:
   - Backend must allow Angular origin
   - Proper preflight handling
   - Credentials support

4. **Secrets Management**:
   - Use Kubernetes Secrets for sensitive data
   - Never commit secrets to Git
   - Use environment variables

5. **Network Policies** (optional enhancement):
   - Restrict pod-to-pod communication
   - Only allow necessary connections

---

## 🐳 Docker Requirements

**Image Naming Convention**:
- Frontend: `auth-platform/angular-frontend:latest`
- Backend: `auth-platform/spring-backend:latest`

**Best Practices**:
- Multi-stage builds to minimize image size
- Non-root user in containers
- Health check endpoints
- Proper .dockerignore files
- Layer caching optimization

**Registry**: 
- Local for Minikube (use `eval $(minikube docker-env)`)
- GitHub Container Registry for CI/CD

---

## 🚀 CI/CD Requirements

### GitHub Actions Workflows

**1. Frontend CI** (`.github/workflows/frontend-ci.yml`):
- Trigger: Push to `main`, PR to `main`, changes in `frontend/**`
- Jobs:
  1. Build Angular application
  2. Run linting (ng lint)
  3. Run unit tests (ng test --watch=false)
  4. Build Docker image
  5. Push to container registry (on main branch)
  6. Tag with commit SHA and `latest`

**2. Backend CI** (`.github/workflows/backend-ci.yml`):
- Trigger: Push to `main`, PR to `main`, changes in `backend/**`
- Jobs:
  1. Build Spring Boot application
  2. Run unit tests
  3. Run integration tests (if any)
  4. Build Docker image
  5. Push to container registry (on main branch)
  6. Tag with commit SHA and `latest`

**3. Deploy Workflow** (`.github/workflows/deploy.yml`):
- Trigger: Manual (workflow_dispatch) or after successful CI
- Jobs:
  1. Setup kubectl with kubeconfig
  2. Apply Kubernetes manifests
  3. Wait for rollout completion
  4. Run smoke tests
  5. Notify on Slack/Email (optional)

**Required Secrets**:
- `DOCKERHUB_USERNAME` / `DOCKERHUB_TOKEN` or GitHub Container Registry token
- `KUBECONFIG` (for deployment)

**Build Matrix** (optional):
- Test on multiple Node/Java versions

---

## 📜 Scripts Requirements

### 1. setup-minikube.sh
```bash
# Start Minikube with appropriate resources
# Enable ingress addon
# Add entries to /etc/hosts
# Configure kubectl context
```

### 2. deploy-all.sh
```bash
# Build Docker images
# Apply Kubernetes manifests in order:
#   1. Namespace
#   2. Secrets
#   3. ConfigMaps
#   4. PVCs
#   5. PostgreSQL
#   6. Keycloak
#   7. Backend
#   8. Frontend
#   9. Ingress
# Wait for all deployments to be ready
# Display access URLs
```

### 3. configure-keycloak.sh
```bash
# Wait for Keycloak to be ready
# Import realm configuration
# Or configure realm via API:
#   - Create realm
#   - Create clients
#   - Create roles
#   - Create users
```

### 4. cleanup.sh
```bash
# Delete all Kubernetes resources
# Delete namespace
# Clean up /etc/hosts entries (optional)
```

---

## 📚 Documentation Requirements

### README.md
- Project overview and architecture diagram
- Prerequisites (Minikube, kubectl, Docker, Node.js, Java)
- Quick start guide
- Links to detailed documentation

### SETUP.md
- Detailed local development setup
- Minikube installation and configuration
- How to run each component individually
- Troubleshooting common issues

### DEPLOYMENT.md
- Kubernetes deployment steps
- How to configure different environments
- Scaling considerations
- Monitoring and logging setup

### API.md
- API endpoint documentation
- Request/response examples
- Authentication requirements
- Role-based access matrix

---

## ✅ Acceptance Criteria

### Functional Requirements:
1. ✅ User can access Angular application at `http://app.local`
2. ✅ User can log in via Keycloak authentication
3. ✅ After login, user is redirected back to Angular with tokens
4. ✅ Angular displays user profile information
5. ✅ Angular can call Spring Boot API with JWT token
6. ✅ Spring Boot validates JWT and returns data
7. ✅ Admin user can access admin endpoints
8. ✅ Regular user cannot access admin endpoints (403)
9. ✅ Public endpoints are accessible without authentication
10. ✅ User can log out and tokens are cleared

### Technical Requirements:
1. ✅ All components run in Kubernetes
2. ✅ Keycloak persists data in PostgreSQL
3. ✅ Ingress routes traffic correctly
4. ✅ CORS is properly configured
5. ✅ JWT signature validation works
6. ✅ Role-based access control works
7. ✅ Health checks pass for all pods
8. ✅ Docker images build successfully
9. ✅ CI/CD pipelines run without errors
10. ✅ Documentation is complete and accurate

### Non-Functional Requirements:
1. ✅ Application response time < 500ms
2. ✅ All passwords are stored securely
3. ✅ No sensitive data in logs
4. ✅ Proper error handling and user feedback
5. ✅ Clean, maintainable code with comments

---

## 🧪 Testing Strategy

### Unit Tests:
- Angular: Karma/Jest for components and services
- Spring Boot: JUnit 5 + Mockito for controllers and services

### Integration Tests:
- Test OIDC flow end-to-end
- Test API endpoints with valid/invalid tokens
- Test role-based access control

### Manual Testing Checklist:
- [ ] User can log in with correct credentials
- [ ] User cannot log in with wrong credentials
- [ ] Protected routes redirect to login
- [ ] JWT is included in API requests
- [ ] API validates JWT correctly
- [ ] Role-based endpoints enforce authorization
- [ ] Logout clears tokens and sessions
- [ ] Token refresh works (optional)
- [ ] CORS works from Angular to API
- [ ] All ingress routes work correctly

---

## 🔍 Monitoring & Observability (Optional Enhancements)

- Application logs (stdout/stderr)
- Prometheus metrics export
- Grafana dashboards
- Jaeger tracing integration
- ELK/EFK stack for log aggregation

---

## 🎓 Implementation Priority

### Phase 1: Foundation (Week 1-2)
1. Setup project structure
2. Implement Angular frontend with OIDC
3. Implement Spring Boot backend with OAuth2
4. Local testing with Keycloak in Docker

### Phase 2: Containerization (Week 3)
1. Create Dockerfiles
2. Build and test images locally
3. Create docker-compose for local testing (optional)

### Phase 3: Kubernetes (Week 4-5)
1. Create all Kubernetes manifests
2. Deploy to Minikube
3. Configure ingress and networking
4. Test end-to-end flow

### Phase 4: CI/CD (Week 6)
1. Setup GitHub Actions workflows
2. Configure secrets and permissions
3. Test automated deployments
4. Add deployment notifications

### Phase 5: Documentation & Refinement (Week 7-8)
1. Write comprehensive documentation
2. Add monitoring/logging
3. Security hardening
4. Performance optimization
5. Create demo video/presentation

---

## 🚨 Common Pitfalls to Avoid

1. **CORS Issues**: Ensure backend allows Angular origin and proper headers
2. **JWT Validation**: Use correct issuer URI (with `/realms/{realm}`)
3. **Token Claims**: Extract roles from correct path in JWT
4. **Redirect URIs**: Must match exactly in Keycloak client config
5. **Ingress DNS**: Add entries to `/etc/hosts` for local domains
6. **Resource Limits**: Keycloak needs sufficient memory (min 512Mi)
7. **Init Time**: Keycloak takes 60+ seconds to start, adjust health checks
8. **PKCE**: Must be enabled in Keycloak and Angular OIDC client
9. **Network**: Pods must resolve Keycloak by service name internally
10. **Secrets**: Never commit secrets; use Kubernetes Secrets or env vars

---

## 📞 Support & Resources

- **Keycloak Docs**: https://www.keycloak.org/documentation
- **Spring Security OAuth2**: https://docs.spring.io/spring-security/reference/servlet/oauth2/resource-server/jwt.html
- **angular-oauth2-oidc**: https://github.com/manfredsteyer/angular-oauth2-oidc
- **Kubernetes Docs**: https://kubernetes.io/docs/
- **Minikube Docs**: https://minikube.sigs.k8s.io/docs/

---

## 🎯 Success Metrics

- All acceptance criteria met
- Code coverage > 70%
- Zero critical security vulnerabilities
- Documentation completeness: 100%
- Successful CI/CD pipeline execution
- Deployable to production-like environment

---

**END OF SPECIFICATION**

This specification provides a complete blueprint for implementing the authentication platform. All components, configurations, and requirements are clearly defined for development.
