# Logistics Microservices Platform - Documentation Index

## Quick Navigation

### 🚀 Getting Started (Read First)
1. **[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)** - Complete deployment guide with all steps
2. **[README.md](README.md)** - Project overview and setup instructions
3. **[QUICK_START.md](QUICK_START.md)** - Quick start checklist

### 📋 For Development
4. **[ARCHITECTURE.md](ARCHITECTURE.md)** - System architecture and design patterns
5. **[API_DOCUMENTATION.md](API_DOCUMENTATION.md)** - Complete API reference for all services
6. **[PROJECT_MANIFEST.yaml](PROJECT_MANIFEST.yaml)** - Project specifications and metadata

### ✅ For Deployment
7. **[DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md)** - Step-by-step deployment checklist
8. **[docker-compose.yml](docker-compose.yml)** - Local development setup

### 🔧 Utility Scripts
- **build-and-push.sh/.bat** - Build Docker images and push to DockerHub
- **deploy.sh/.bat** - One-command Kubernetes deployment
- **cleanup.sh/.bat** - Remove all Kubernetes resources
- **local-test.sh/.bat** - Test locally with Docker Compose

---

## Project Structure

```
logistics-platform/
├── frontend/                    React UI Application
├── services/
│   ├── users-service/          User Management & Auth
│   ├── orders-service/         Order Processing
│   ├── shipments-service/      Shipment Tracking
│   ├── inventory-service/      Warehouse Management
│   └── notifications-service/  Event Notifications
├── databases/                   DB Initialization Scripts
├── kubernetes/                  K8s Deployment Manifests
└── [Documentation Files]
```

---

## Quick Command Reference

### Local Testing
```bash
docker-compose up -d          # Start all services
docker-compose logs -f        # View logs
docker-compose down           # Stop services
```

### Docker Image Building
```bash
./build-and-push.bat yourusername    # Windows
./build-and-push.sh yourusername     # Linux/Mac
```

### Kubernetes Deployment
```bash
./deploy.bat                  # Deploy to K8s (Windows)
./deploy.sh                   # Deploy to K8s (Linux/Mac)
./cleanup.bat                 # Remove all resources (Windows)
./cleanup.sh                  # Remove all resources (Linux/Mac)
```

### Kubernetes Status Checks
```bash
kubectl get pods              # Check all pods
kubectl get services          # Check services
kubectl get all               # Check all resources
kubectl logs deployment/<service>   # View service logs
```

---

## Services Overview

| Service | Port | Purpose | Database |
|---------|------|---------|----------|
| Frontend | 3000 | React UI | None |
| Users | 3001 | Authentication & Users | users_db |
| Orders | 3002 | Order Management | orders_db |
| Shipments | 3003 | Shipment Tracking | shipments_db |
| Inventory | 3004 | Stock Management | inventory_db |
| Notifications | 3005 | Event Alerts | notifications_db |

---

## Authentication

Default test credentials (after registering):
- Email: `test@logistics.com`
- Password: Create via frontend registration

JWT token required for most API endpoints:
```
Authorization: Bearer <your_jwt_token>
```

---

## Deployment Phases

### Phase 1: Preparation
- Prerequisites: Docker, Kubernetes, kubectl
- Build and push images to DockerHub
- Update K8s manifests with image names

### Phase 2: Infrastructure
- Deploy Kubernetes secrets and ConfigMaps
- Deploy database StatefulSets
- Deploy database services
- Wait for databases to be ready

### Phase 3: Application
- Deploy microservice deployments
- Deploy microservice services
- Deploy frontend deployment
- Deploy frontend service

### Phase 4: Verification
- Check all pods are running
- Access frontend via LoadBalancer IP
- Test authentication and basic operations
- Review logs for any errors

---

## Key Features

✓ 5 Independent Microservices
✓ Three-Tier Architecture (Frontend, Backend, Database)
✓ JWT-Based Authentication
✓ Kubernetes-Native Design
✓ Docker Containerization
✓ Horizontal Scaling Support
✓ Persistent Data Storage
✓ Health Checks & Probes
✓ Comprehensive Documentation
✓ Production-Ready Code

---

## Scaling

Scale any service to N replicas:
```bash
kubectl scale deployment <service-name> --replicas=N
```

Example:
```bash
kubectl scale deployment users-service --replicas=3
kubectl scale deployment frontend --replicas=4
```

---

## Troubleshooting

### Pod won't start
```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Service not accessible
```bash
kubectl get endpoints <service-name>
kubectl port-forward service/<service-name> 8080:3000
```

### Database connection issues
```bash
kubectl exec -it <db-pod> -- psql -U postgres -d <db-name>
```

---

## Performance Considerations

- Frontend: 2 replicas (configurable)
- Microservices: 2 replicas each (configurable)
- Notifications: 1 replica
- Resources: 128Mi memory request, 100m CPU request
- Limits: 256Mi memory, 500m CPU

---

## Security Checklist

✓ JWT tokens for authentication
✓ Password hashing with bcryptjs
✓ Secrets stored in Kubernetes Secrets
✓ No hardcoded credentials in code
✓ CORS enabled for frontend
✓ Health endpoints without auth

---

## Future Enhancement Points

- API Gateway (Kong/Nginx)
- Service Registry
- Message Queue (RabbitMQ/Kafka)  
- Monitoring (Prometheus/Grafana)
- Centralized Logging (ELK Stack)
- Service Mesh (Istio)
- Circuit Breaker Pattern
- Distributed Caching (Redis)
- Database Replication

---

## Support Files

### Documentation
- README.md - Project overview
- ARCHITECTURE.md - System design
- API_DOCUMENTATION.md - API reference
- DEPLOYMENT_CHECKLIST.md - Step-by-step guide
- DEPLOYMENT_GUIDE.md - Complete guide
- QUICK_START.md - Quick start guide
- PROJECT_MANIFEST.yaml - Project specs

### Scripts
- build-and-push.sh/.bat - Build and push images
- deploy.sh/.bat - Deploy to Kubernetes
- cleanup.sh/.bat - Clean up resources
- local-test.sh/.bat - Local Docker Compose test

### Configuration
- docker-compose.yml - Local development
- kubernetes/deployments/ - K8s deployment manifests
- kubernetes/services/ - K8s service manifests
- databases/ - Database initialization SQL scripts

---

## Getting Help

1. Check DEPLOYMENT_CHECKLIST.md for step-by-step guidance
2. Review ARCHITECTURE.md to understand the design
3. Check API_DOCUMENTATION.md for endpoint details
4. Look at logs: `kubectl logs <pod-name>`
5. Verify services: `kubectl get all`

---

## Quick Checklist Before Presentation

- [ ] All Docker images built and pushed to DockerHub
- [ ] K8s manifests updated with correct image names
- [ ] Kubernetes cluster is running and accessible
- [ ] All pods are running: `kubectl get pods`
- [ ] Frontend is accessible via LoadBalancer IP
- [ ] Can login to frontend
- [ ] Can create/view users
- [ ] Can create/view orders
- [ ] Can view shipments
- [ ] Inventory management works
- [ ] Notifications are being sent
- [ ] Database persistence verified
- [ ] All logs are clean (no errors)

---

**Last Updated**: March 18, 2026
**Project Status**: Production Ready
**Deployment Method**: Kubernetes
**Container Platform**: Docker
**Frontend Framework**: React 18
**Backend Framework**: Express.js
**Database**: PostgreSQL 15
