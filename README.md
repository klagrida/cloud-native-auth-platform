# Cloud-Native Authentication Platform

A complete authentication and authorization system using OIDC/OAuth2 with Keycloak, Angular, Spring Boot, and Kubernetes.

## Architecture

```
┌────────────────────────────────────────────────────────────┐
│                    Minikube Cluster                        │
│                                                            │
│  ┌─────────────┐         ┌──────────────────────────┐      │
│  │   Angular   │◄───────►│      Keycloak            │      │
│  │   Frontend  │  OIDC   │   Identity Provider      │      │
│  │             │         │   - Realm: demo-realm    │      │
│  └──────┬──────┘         │   - Users & Roles        │      │
│         │                └──────────┬───────────────┘      │
│         │ HTTP + JWT              │                        │
│         │                          │ JDBC                  │
│         ▼                          ▼                       │
│  ┌─────────────┐         ┌──────────────────────────┐      │
│  │ Spring Boot │         │     PostgreSQL           │      │
│  │   REST API  │         │  - Keycloak DB           │      │
│  │  (Resource  │         │  - App DB (optional)     │      │
│  │   Server)   │         └──────────────────────────┘      │
│  └─────────────┘                                           │
│                                                            │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              NGINX Ingress Controller                │  │
│  │  Routes:                                             │  │
│  │  - app.local        → Angular                        │  │
│  │  - api.local        → Spring Boot                    │  │
│  │  - auth.local       → Keycloak                       │  │
│  └──────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────┘
```

## Tech Stack

- **Frontend**: Angular 17+ with TypeScript
- **Backend**: Spring Boot 3+ with Java 17+
- **Identity Provider**: Keycloak (latest stable)
- **Database**: PostgreSQL 15+
- **Container Orchestration**: Kubernetes (Minikube for local)
- **CI/CD**: GitHub Actions

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) 20.10+
- [Minikube](https://minikube.sigs.k8s.io/docs/start/) 1.30+
- [kubectl](https://kubernetes.io/docs/tasks/tools/) 1.28+
- [Node.js](https://nodejs.org/) 20+
- [Java](https://adoptium.net/) 17+
- [Maven](https://maven.apache.org/) 3.8+

## Quick Start

### 1. Setup Minikube

```bash
chmod +x scripts/setup-minikube.sh
./scripts/setup-minikube.sh
```

### 2. Deploy All Components

```bash
chmod +x scripts/deploy-all.sh
./scripts/deploy-all.sh
```

### 3. Configure Keycloak

```bash
chmod +x scripts/configure-keycloak.sh
./scripts/configure-keycloak.sh
```

### 4. Access Applications

- **Angular Frontend**: http://app.local
- **Spring Boot API**: http://api.local
- **Keycloak Admin**: http://auth.local (admin/admin)

## Test Users

- **Admin User**
  - Username: `admin`
  - Password: `admin123`
  - Roles: USER, ADMIN

- **Regular User**
  - Username: `user`
  - Password: `user123`
  - Roles: USER

## Development

### Frontend Development

```bash
cd frontend
npm install
npm start
# Access at http://localhost:4200
```

### Backend Development

```bash
cd backend
mvn spring-boot:run
# Access at http://localhost:8080
```

## Documentation

- [Setup Guide](docs/SETUP.md) - Detailed setup instructions
- [Deployment Guide](docs/DEPLOYMENT.md) - Kubernetes deployment
- [API Documentation](docs/API.md) - API endpoints and usage

## Project Structure

```
auth-platform/
├── frontend/          # Angular application
├── backend/           # Spring Boot API
├── k8s/              # Kubernetes manifests
├── keycloak/         # Keycloak configuration
├── scripts/          # Deployment scripts
├── .github/          # CI/CD workflows
└── docs/             # Documentation
```

## Security

This project implements:
- OIDC/OAuth2 Authorization Code Flow with PKCE
- JWT token validation
- Role-based access control (RBAC)
- CORS protection
- Kubernetes secrets management

## License

MIT
