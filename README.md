# Logistics Microservices Platform

A comprehensive microservice-based logistics platform built with React, Express.js, and PostgreSQL, deployable on Kubernetes.

## Project Structure

```
logistics-platform/
├── frontend/                   # React frontend application
├── services/
│   ├── users-service/         # User management and authentication
│   ├── orders-service/        # Order management
│   ├── shipments-service/     # Shipment tracking
│   ├── inventory-service/     # Warehouse inventory
│   └── notifications-service/ # Notification system
├── databases/                 # Database initialization scripts
└── kubernetes/                # Kubernetes deployment manifests
```

## Services

- **Frontend**: React-based UI on port 3000
- **Users Service**: Authentication and user management on port 3001
- **Orders Service**: Order processing on port 3002
- **Shipments Service**: Shipment tracking on port 3003
- **Inventory Service**: Stock management on port 3004
- **Notifications Service**: Event notifications on port 3005
- **Databases**: Separate PostgreSQL instances for each service

## Prerequisites

- Docker and Docker Desktop
- Kubernetes cluster (minikube, Docker Desktop K8s, or cloud provider)
- kubectl command-line tool
- Node.js (optional, for local development)
- DockerHub account

## Building Docker Images

Replace `yourdockerhubusername` with your actual DockerHub username.

### Build Frontend
```bash
cd frontend
docker build -t yourdockerhubusername/logistics-frontend:latest .
```

### Build Microservices
```bash
cd services/users-service
docker build -t yourdockerhubusername/logistics-users-service:latest .

cd ../orders-service
docker build -t yourdockerhubusername/logistics-orders-service:latest .

cd ../shipments-service
docker build -t yourdockerhubusername/logistics-shipments-service:latest .

cd ../inventory-service
docker build -t yourdockerhubusername/logistics-inventory-service:latest .

cd ../notifications-service
docker build -t yourdockerhubusername/logistics-notifications-service:latest .
```

## Pushing Images to DockerHub

Login to DockerHub:
```bash
docker login
```

Push all images:
```bash
docker push yourdockerhubusername/logistics-frontend:latest
docker push yourdockerhubusername/logistics-users-service:latest
docker push yourdockerhubusername/logistics-orders-service:latest
docker push yourdockerhubusername/logistics-shipments-service:latest
docker push yourdockerhubusername/logistics-inventory-service:latest
docker push yourdockerhubusername/logistics-notifications-service:latest
```

## Deploying to Kubernetes

### 1. Update Deployment Manifests

Update image references in all deployment YAML files in `kubernetes/deployments/` to use your DockerHub username.

### 2. Create Kubernetes Namespace (Optional)
```bash
kubectl create namespace logistics
```

### 3. Apply Configuration and Secrets
```bash
kubectl apply -f kubernetes/services/secrets.yaml
kubectl apply -f kubernetes/services/configmaps.yaml
```

### 4. Deploy Databases
```bash
kubectl apply -f kubernetes/deployments/users-db-statefulset.yaml
kubectl apply -f kubernetes/deployments/orders-db-statefulset.yaml
kubectl apply -f kubernetes/deployments/shipments-db-statefulset.yaml
kubectl apply -f kubernetes/deployments/inventory-db-statefulset.yaml
kubectl apply -f kubernetes/deployments/notifications-db-statefulset.yaml
```

### 5. Deploy Database Services
```bash
kubectl apply -f kubernetes/services/users-db-service.yaml
kubectl apply -f kubernetes/services/orders-db-service.yaml
kubectl apply -f kubernetes/services/shipments-db-service.yaml
kubectl apply -f kubernetes/services/inventory-db-service.yaml
kubectl apply -f kubernetes/services/notifications-db-service.yaml
```

### 6. Deploy Microservices
```bash
kubectl apply -f kubernetes/deployments/users-service-deployment.yaml
kubectl apply -f kubernetes/deployments/orders-service-deployment.yaml
kubectl apply -f kubernetes/deployments/shipments-service-deployment.yaml
kubectl apply -f kubernetes/deployments/inventory-service-deployment.yaml
kubectl apply -f kubernetes/deployments/notifications-service-deployment.yaml
```

### 7. Deploy Microservice Services
```bash
kubectl apply -f kubernetes/services/users-service.yaml
kubectl apply -f kubernetes/services/orders-service.yaml
kubectl apply -f kubernetes/services/shipments-service.yaml
kubectl apply -f kubernetes/services/inventory-service.yaml
kubectl apply -f kubernetes/services/notifications-service.yaml
```

### 8. Deploy Frontend
```bash
kubectl apply -f kubernetes/deployments/frontend-deployment.yaml
kubectl apply -f kubernetes/services/frontend-service.yaml
```

## Verifying Deployment

Check deployment status:
```bash
kubectl get deployments
kubectl get pods
kubectl get services
kubectl get statefulsets
```

Wait for all pods to be running:
```bash
kubectl get pods -w
```

## Accessing the Application

If using a LoadBalancer:
```bash
kubectl get service frontend
```

The frontend will be available at the external IP shown under LoadBalancer EXTERNAL-IP.

For minikube:
```bash
minikube service frontend
```

## Default Test Credentials

Email: test@logistics.com
Password: password123

## Scaling Services

Scale users service to 3 replicas:
```bash
kubectl scale deployment users-service --replicas=3
```

## Monitoring Logs

View logs from a service:
```bash
kubectl logs deployment/users-service -f
```

View logs from specific pod:
```bash
kubectl logs <pod-name> -f
```

## Cleaning Up

Delete all resources:
```bash
kubectl delete deployment --all
kubectl delete service --all
kubectl delete statefulset --all
kubectl delete pvc --all
kubectl delete secret --all
kubectl delete configmap --all
```

## Future Enhancements

- API Gateway for request routing
- Service Registry for dynamic service discovery
- Load balancing strategies
- Circuit breaker pattern
- Message queue integration (RabbitMQ/Kafka)
- Advanced monitoring and logging (Prometheus/ELK)
- Service mesh implementation (Istio)
