# Architecture Overview

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Load Balancer / Ingress                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │              Frontend (React - Port 3000)                │   │
│  │  - Dashboard                                             │   │
│  │  - Authentication                                        │   │
│  │  - User Management                                       │   │
│  │  - Orders View                                           │   │
│  │  - Shipments Tracking                                    │   │
│  │  - Inventory Management                                  │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                   │
│  ┌───────────────────┐  ┌──────────────────┐  ┌──────────────┐  │
│  │ Users Service     │  │ Orders Service   │  │ Shipments    │  │
│  │ (Port 3001)       │  │ (Port 3002)      │  │ Service      │  │
│  │                   │  │                  │  │ (Port 3003)  │  │
│  │ - Auth            │  │ - Order Mgmt     │  │ - Tracking   │  │
│  │ - User Profiles   │  │ - Order Status   │  │ - Status     │  │
│  │ - Roles           │  │                  │  │ - Carrier    │  │
│  └──────────┬────────┘  └────────┬─────────┘  └──────┬───────┘  │
│             │                    │                    │          │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │        Inter-Service Communication (Internal)             │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                   │
│  ┌───────────────────┐  ┌──────────────────┐  ┌──────────────┐  │
│  │ Inventory Service │  │ Notifications    │  │ PostgreSQL   │  │
│  │ (Port 3004)       │  │ Service          │  │ Databases    │  │
│  │                   │  │ (Port 3005)      │  │              │  │
│  │ - Stock Mgmt      │  │ - Email/SMS      │  │ - Users DB   │  │
│  │ - Warehouses      │  │ - In-App Notify  │  │ - Orders DB  │  │
│  │ - SKU             │  │ - Notifications  │  │ - Shipments  │  │
│  └────────┬──────────┘  └────────┬─────────┘  │ - Inventory  │  │
│           │                      │            │ - Notif DB   │  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │              Database Layer (Each Service)                  │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

## Technology Stack

### Frontend
- React 18.2
- Axios for HTTP requests
- CSS for styling
- Node.js 18 Alpine for containerization

### Backend Microservices
- Express.js 4.18
- Node.js 18 Alpine
- PostgreSQL 15 Alpine for databases
- JWT for authentication
- bcryptjs for password hashing
- CORS enabled for cross-origin requests

### Orchestration & Deployment
- Kubernetes for container orchestration
- Docker for containerization
- StatefulSets for persistent databases
- ConfigMaps for database initialization
- Secrets for sensitive data

## Deployment Architecture

### Three-Tier Architecture

1. **Presentation Tier (Frontend)**
   - React-based single-page application
   - Communicates with backend services via REST APIs
   - Deployed as Kubernetes Deployment with 2 replicas
   - LoadBalancer service for external access

2. **Application Tier (Microservices)**
   - 5 independent microservices
   - Each deployed as Kubernetes Deployment with 2 replicas (1 for notifications)
   - ClusterIP services for internal communication
   - JWT-based authentication
   - Health checks (liveness & readiness probes)

3. **Data Tier (Databases)**
   - 5 separate PostgreSQL databases
   - Each deployed as StatefulSet with persistent volumes
   - ConfigMaps for schema initialization
   - ClusterIP Headless services for StatefulSet communication

## Scaling Strategy

### Horizontal Scaling
- Frontend: 2 replicas
- Microservices: 2 replicas each (configurable)
- Can be scaled using: `kubectl scale deployment <name> --replicas=N`

### Vertical Scaling
- Resource requests and limits defined
- Database: 256Mi memory, 250m CPU (request), 512Mi/500m (limit)
- Services: 128Mi memory, 100m CPU (request), 256Mi/500m (limit)

## Future Enhancement Points

### API Gateway
Currently no API Gateway. Future addition would enable:
- Centralized request routing
- Rate limiting
- Request/response transformation

### Service Registry
Currently uses Kubernetes DNS. Future additions:
- Service discovery enhancements
- Health-based routing

### Message Queue
Future integration:
- Order event streaming
- Asynchronous notifications
- Event sourcing

### Logging & Monitoring
Future addition:
- Prometheus metrics
- ELK stack for centralized logging
- Grafana dashboards

### Service Mesh
Future implementation:
- Istio for advanced traffic management
- Circuit breaking
- Distributed tracing

## Security Features

- JWT-based authentication
- bcryptjs password hashing
- CORS configuration
- Database credentials in Kubernetes Secrets
- JWT secret stored as Kubernetes Secret
- No hardcoded credentials in code

## Data Persistence

- StatefulSets with persistent volumes
- 1Gi storage for main databases
- 500Mi for notifications database
- Automatic retention across pod restarts

## Service Communication

### Inter-Service Communication
- Internal ClusterIP services for service-to-service communication
- Orders service calls Notifications service asynchronously
- All communication within Kubernetes cluster network

### Client Communication
- Frontend communicates with backend services
- Environment variables for service URLs
- Localhost during development, service names in K8s

## Fault Tolerance

- Multiple replicas for automatic failover
- Liveness probes to detect and restart failed containers
- Readiness probes to prevent traffic to unready pods
- StatefulSet for persistent data layer

## Resource Management

- Resource requests ensure minimum allocation
- Resource limits prevent resource exhaustion
- Pod eviction policies for overload scenarios
- Proper cleanup scripts included
