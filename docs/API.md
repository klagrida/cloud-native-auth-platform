# API Documentation

This document describes the REST API endpoints provided by the Spring Boot backend.

## Base URL

- Development: `http://localhost:8080/api`
- Kubernetes: `http://api.local/api`

## Authentication

Most endpoints require authentication via JWT Bearer token obtained from Keycloak.

**Authorization Header:**
```
Authorization: Bearer <access_token>
```

## Endpoints

### Public Endpoints

#### GET /api/public/hello

Returns a public message. No authentication required.

**Request:**
```bash
curl http://api.local/api/public/hello
```

**Response:**
```json
{
  "message": "Hello from public endpoint!",
  "timestamp": 1234567890,
  "authenticated": false
}
```

**Status Codes:**
- `200 OK` - Success

---

### User Endpoints

Requires authentication. Accessible by any authenticated user.

#### GET /api/user/info

Returns information about the authenticated user extracted from JWT token.

**Request:**
```bash
curl -H "Authorization: Bearer <token>" http://api.local/api/user/info
```

**Response:**
```json
{
  "username": "user",
  "email": "user@example.com",
  "name": "Regular User",
  "roles": ["USER"]
}
```

**Status Codes:**
- `200 OK` - Success
- `401 Unauthorized` - Missing or invalid token

---

#### GET /api/user/data

Returns user-specific data.

**Request:**
```bash
curl -H "Authorization: Bearer <token>" http://api.local/api/user/data
```

**Response:**
```json
{
  "message": "User-specific data",
  "username": "user",
  "timestamp": 1234567890,
  "data": {
    "subscription": "Premium",
    "accountStatus": "Active",
    "joinDate": "2024-01-01"
  }
}
```

**Status Codes:**
- `200 OK` - Success
- `401 Unauthorized` - Missing or invalid token

---

### Admin Endpoints

Requires authentication with ADMIN role.

#### GET /api/admin/users

Returns a list of users. Only accessible by users with ADMIN role.

**Request:**
```bash
curl -H "Authorization: Bearer <admin-token>" http://api.local/api/admin/users
```

**Response:**
```json
[
  {
    "id": 1,
    "username": "admin",
    "email": "admin@example.com",
    "roles": ["USER", "ADMIN"]
  },
  {
    "id": 2,
    "username": "user",
    "email": "user@example.com",
    "roles": ["USER"]
  },
  {
    "id": 3,
    "username": "manager",
    "email": "manager@example.com",
    "roles": ["USER", "MANAGER"]
  }
]
```

**Status Codes:**
- `200 OK` - Success
- `401 Unauthorized` - Missing or invalid token
- `403 Forbidden` - User doesn't have ADMIN role

---

#### GET /api/admin/stats

Returns system statistics. Only accessible by users with ADMIN role.

**Request:**
```bash
curl -H "Authorization: Bearer <admin-token>" http://api.local/api/admin/stats
```

**Response:**
```json
{
  "totalUsers": 42,
  "activeUsers": 38,
  "totalRequests": 1523,
  "avgResponseTime": "125ms",
  "uptime": "99.9%",
  "timestamp": 1234567890,
  "usersByRole": {
    "ADMIN": 3,
    "USER": 42,
    "MANAGER": 5
  }
}
```

**Status Codes:**
- `200 OK` - Success
- `401 Unauthorized` - Missing or invalid token
- `403 Forbidden` - User doesn't have ADMIN role

---

## Role-Based Access Control

| Endpoint | Roles Required | Description |
|----------|---------------|-------------|
| `/api/public/**` | None | Public access |
| `/api/user/**` | Any authenticated user | User endpoints |
| `/api/admin/**` | ADMIN | Admin-only endpoints |

## Error Responses

### 401 Unauthorized

```json
{
  "timestamp": "2024-01-01T12:00:00.000+00:00",
  "status": 401,
  "error": "Unauthorized",
  "message": "Full authentication is required to access this resource",
  "path": "/api/user/info"
}
```

### 403 Forbidden

```json
{
  "timestamp": "2024-01-01T12:00:00.000+00:00",
  "status": 403,
  "error": "Forbidden",
  "message": "Access Denied",
  "path": "/api/admin/users"
}
```

## Authentication Flow

### 1. Obtain Access Token from Keycloak

**Token Endpoint:**
```
POST http://auth.local/realms/demo-realm/protocol/openid-connect/token
```

**Request Body (using password grant - for testing only):**
```
grant_type=password
&client_id=angular-app
&username=user
&password=user123
&scope=openid profile email
```

**Response:**
```json
{
  "access_token": "eyJhbGciOiJSUzI1NiIs...",
  "token_type": "Bearer",
  "expires_in": 300,
  "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
  "scope": "openid profile email"
}
```

### 2. Use Access Token

```bash
curl -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  http://api.local/api/user/info
```

## Testing with cURL

### Public Endpoint
```bash
curl http://api.local/api/public/hello
```

### User Endpoint
```bash
# Get token first (replace with your credentials)
TOKEN=$(curl -s -X POST http://auth.local/realms/demo-realm/protocol/openid-connect/token \
  -d "grant_type=password" \
  -d "client_id=angular-app" \
  -d "username=user" \
  -d "password=user123" \
  | jq -r '.access_token')

# Call API
curl -H "Authorization: Bearer $TOKEN" http://api.local/api/user/info
```

### Admin Endpoint
```bash
# Get admin token
ADMIN_TOKEN=$(curl -s -X POST http://auth.local/realms/demo-realm/protocol/openid-connect/token \
  -d "grant_type=password" \
  -d "client_id=angular-app" \
  -d "username=admin" \
  -d "password=admin123" \
  | jq -r '.access_token')

# Call admin API
curl -H "Authorization: Bearer $ADMIN_TOKEN" http://api.local/api/admin/users
```

## Health Check Endpoint

### GET /actuator/health

Returns application health status. No authentication required.

**Request:**
```bash
curl http://api.local/actuator/health
```

**Response:**
```json
{
  "status": "UP"
}
```

## CORS Configuration

The API is configured to accept requests from:
- `http://localhost:4200` (local development)
- `http://app.local` (Kubernetes deployment)

**Allowed Methods:**
- GET, POST, PUT, DELETE, OPTIONS, PATCH

**Allowed Headers:**
- All headers (`*`)

## Rate Limiting

Currently, no rate limiting is implemented. Consider adding rate limiting for production deployments.

## Versioning

Current API version: v1

Future versions may be introduced with path prefix:
- `/api/v2/...`

## Additional Resources

- [Spring Security OAuth2 Resource Server](https://docs.spring.io/spring-security/reference/servlet/oauth2/resource-server/jwt.html)
- [Keycloak Documentation](https://www.keycloak.org/documentation)
- [OAuth 2.0 RFC](https://tools.ietf.org/html/rfc6749)
