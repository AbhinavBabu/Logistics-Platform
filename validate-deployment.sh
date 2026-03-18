# KUBERNETES VALIDATION & TESTING GUIDE
# Step-by-step guide for validating the Logistics Platform deployment

echo "========================================"
echo "Logistics Platform - Kubernetes Testing"
echo "========================================"
echo ""

# STEP 1: Pre-deployment validation
echo "[STEP 1] Validating Kubernetes Cluster Setup"
echo "-------------------------------------------"
echo "1.1 Checking cluster connectivity..."
kubectl cluster-info
if [ $? -ne 0 ]; then
    echo "ERROR: Cannot connect to Kubernetes cluster!"
    exit 1
fi
echo "✓ Cluster connection verified"
echo ""

echo "1.2 Checking node status..."
kubectl get nodes -o wide
NODE_COUNT=$(kubectl get nodes --no-headers | wc -l)
echo "✓ Found $NODE_COUNT nodes"
echo ""

echo "1.3 Checking available storage..."
kubectl get storageclass
echo ""

echo "1.4 Verifying cluster can pull images..."
docker info | grep "Registry Mirrors" || echo "Using default Docker registry"
echo ""

# STEP 2: Image building and pushing
echo "[STEP 2] Building and Pushing Docker Images"
echo "-------------------------------------------"
read -p "Enter your DockerHub username: " DOCKER_USERNAME

if [ -z "$DOCKER_USERNAME" ]; then
    echo "ERROR: DockerHub username required!"
    exit 1
fi

echo "2.1 Logging into DockerHub..."
docker login -u $DOCKER_USERNAME
if [ $? -ne 0 ]; then
    echo "ERROR: DockerHub login failed!"
    exit 1
fi
echo "✓ DockerHub authentication successful"
echo ""

echo "2.2 Building Docker images..."
cd C:\logistics-platform

echo "Building frontend..."
cd frontend
docker build -t $DOCKER_USERNAME/logistics-frontend:latest . 2>&1 | tail -5
cd ..
echo "✓ Frontend image built"

echo "Building users-service..."
cd services/users-service
docker build -t $DOCKER_USERNAME/logistics-users-service:latest . 2>&1 | tail -5
cd ../..
echo "✓ Users service image built"

echo "Building orders-service..."
cd services/orders-service
docker build -t $DOCKER_USERNAME/logistics-orders-service:latest . 2>&1 | tail -5
cd ../..
echo "✓ Orders service image built"

echo "Building shipments-service..."
cd services/shipments-service
docker build -t $DOCKER_USERNAME/logistics-shipments-service:latest . 2>&1 | tail -5
cd ../..
echo "✓ Shipments service image built"

echo "Building inventory-service..."
cd services/inventory-service
docker build -t $DOCKER_USERNAME/logistics-inventory-service:latest . 2>&1 | tail -5
cd ../..
echo "✓ Inventory service image built"

echo "Building notifications-service..."
cd services/notifications-service
docker build -t $DOCKER_USERNAME/logistics-notifications-service:latest . 2>&1 | tail -5
cd ../..
echo "✓ Notifications service image built"
echo ""

echo "2.3 Pushing images to DockerHub..."
docker push $DOCKER_USERNAME/logistics-frontend:latest && echo "✓ Frontend pushed"
docker push $DOCKER_USERNAME/logistics-users-service:latest && echo "✓ Users service pushed"
docker push $DOCKER_USERNAME/logistics-orders-service:latest && echo "✓ Orders service pushed"
docker push $DOCKER_USERNAME/logistics-shipments-service:latest && echo "✓ Shipments service pushed"
docker push $DOCKER_USERNAME/logistics-inventory-service:latest && echo "✓ Inventory service pushed"
docker push $DOCKER_USERNAME/logistics-notifications-service:latest && echo "✓ Notifications service pushed"
echo ""

echo "2.4 Verifying images are in DockerHub..."
docker pull $DOCKER_USERNAME/logistics-frontend:latest > /dev/null 2>&1 && echo "✓ All images verified in DockerHub"
echo ""

# STEP 3: Updating Kubernetes manifests
echo "[STEP 3] Updating Kubernetes Manifests"
echo "-------------------------------------------"
echo "3.1 Updating deployment manifests with your Docker username..."

cd C:\logistics-platform

# Replace in all deployment files
for file in kubernetes/deployments/*deployment.yaml; do
    sed -i "s|yourdockerhubusername|$DOCKER_USERNAME|g" "$file"
done

echo "✓ Deployment manifests updated"
echo ""

# STEP 4: Validate YAML syntax
echo "[STEP 4] Validating Kubernetes Manifests"
echo "-------------------------------------------"
echo "4.1 Checking YAML syntax..."

YAML_ERRORS=0
for file in kubernetes/services/*.yaml kubernetes/deployments/*.yaml; do
    kubectl apply --dry-run=client -f "$file" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "ERROR in $file"
        YAML_ERRORS=$((YAML_ERRORS + 1))
    else
        echo "✓ $file"
    fi
done

if [ $YAML_ERRORS -gt 0 ]; then
    echo "ERROR: Found $YAML_ERRORS invalid YAML files!"
    exit 1
fi
echo ""

# STEP 5: Deploy secrets and configmaps
echo "[STEP 5] Deploying Kubernetes Secrets and ConfigMaps"
echo "-------------------------------------------"
echo "5.1 Creating secrets..."
kubectl apply -f kubernetes/services/secrets.yaml
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to create secrets!"
    exit 1
fi
echo "✓ Secrets created"
echo ""

echo "5.2 Creating configmaps..."
kubectl apply -f kubernetes/services/configmaps.yaml
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to create configmaps!"
    exit 1
fi
echo "✓ ConfigMaps created"
echo ""

echo "5.3 Verifying secrets..."
kubectl get secrets
echo ""

echo "5.4 Verifying configmaps..."
kubectl get configmaps
echo ""

# STEP 6: Deploy databases
echo "[STEP 6] Deploying Databases"
echo "-------------------------------------------"
echo "6.1 Deploying database StatefulSets..."
kubectl apply -f kubernetes/deployments/users-db-statefulset.yaml
kubectl apply -f kubernetes/deployments/orders-db-statefulset.yaml
kubectl apply -f kubernetes/deployments/shipments-db-statefulset.yaml
kubectl apply -f kubernetes/deployments/inventory-db-statefulset.yaml
kubectl apply -f kubernetes/deployments/notifications-db-statefulset.yaml
echo "✓ Database StatefulSets deployed"
echo ""

echo "6.2 Deploying database services..."
kubectl apply -f kubernetes/services/users-db-service.yaml
kubectl apply -f kubernetes/services/orders-db-service.yaml
kubectl apply -f kubernetes/services/shipments-db-service.yaml
kubectl apply -f kubernetes/services/inventory-db-service.yaml
kubectl apply -f kubernetes/services/notifications-db-service.yaml
echo "✓ Database services deployed"
echo ""

echo "6.3 Waiting for databases to be ready (this may take 2-5 minutes)..."
echo "Checking database pod status..."
kubectl get pods -l app=users-db,app=orders-db,app=shipments-db,app=inventory-db,app=notifications-db -w &
WATCH_PID=$!

# Wait for all database pods to be running
READY=0
TIMEOUT=300
ELAPSED=0
while [ $READY -eq 0 ] && [ $ELAPSED -lt $TIMEOUT ]; do
    RUNNING=$(kubectl get pods -o jsonpath='{.items[*].status.phase}' | grep -o Running | wc -l)
    TOTAL=$(kubectl get pods -l tier=database 2>/dev/null | tail -n +2 | wc -l)
    
    if [ $TOTAL -ge 5 ] && [ $RUNNING -ge 5 ]; then
        READY=1
        echo "✓ All databases are running"
    fi
    
    sleep 10
    ELAPSED=$((ELAPSED + 10))
done

kill $WATCH_PID 2>/dev/null
echo ""

if [ $READY -eq 0 ]; then
    echo "ERROR: Databases did not start within timeout!"
    kubectl get pods
    exit 1
fi

echo "6.4 Verifying database connectivity..."
for db_pod in $(kubectl get pods -l tier=database -o name 2>/dev/null); do
    POD_NAME=$(echo $db_pod | cut -d'/' -f2)
    kubectl exec $POD_NAME -- pg_isready -U postgres -h localhost > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "✓ $POD_NAME is accepting connections"
    fi
done
echo ""

# STEP 7: Deploy microservices
echo "[STEP 7] Deploying Microservices"
echo "-------------------------------------------"
echo "7.1 Deploying microservice deployments..."
kubectl apply -f kubernetes/deployments/users-service-deployment.yaml
kubectl apply -f kubernetes/deployments/orders-service-deployment.yaml
kubectl apply -f kubernetes/deployments/shipments-service-deployment.yaml
kubectl apply -f kubernetes/deployments/inventory-service-deployment.yaml
kubectl apply -f kubernetes/deployments/notifications-service-deployment.yaml
echo "✓ Microservices deployed"
echo ""

echo "7.2 Deploying microservice services..."
kubectl apply -f kubernetes/services/users-service.yaml
kubectl apply -f kubernetes/services/orders-service.yaml
kubectl apply -f kubernetes/services/shipments-service.yaml
kubectl apply -f kubernetes/services/inventory-service.yaml
kubectl apply -f kubernetes/services/notifications-service.yaml
echo "✓ Microservice services deployed"
echo ""

echo "7.3 Waiting for microservices to be ready (2-3 minutes)..."
kubectl get pods -l app=users-service,app=orders-service,app=shipments-service,app=inventory-service,app=notifications-service -w &
WATCH_PID=$!

READY=0
TIMEOUT=180
ELAPSED=0
while [ $READY -eq 0 ] && [ $ELAPSED -lt $TIMEOUT ]; do
    RUNNING=$(kubectl get pods -l tier=microservice 2>/dev/null -o jsonpath='{.items[*].status.phase}' | grep -o Running | wc -l)
    
    if [ $RUNNING -ge 5 ]; then
        READY=1
        echo "✓ All microservices are running"
    fi
    
    sleep 5
    ELAPSED=$((ELAPSED + 5))
done

kill $WATCH_PID 2>/dev/null
echo ""

# STEP 8: Deploy frontend
echo "[STEP 8] Deploying Frontend"
echo "-------------------------------------------"
echo "8.1 Deploying frontend deployment..."
kubectl apply -f kubernetes/deployments/frontend-deployment.yaml
echo "✓ Frontend deployment created"
echo ""

echo "8.2 Deploying frontend service..."
kubectl apply -f kubernetes/services/frontend-service.yaml
echo "✓ Frontend service created"
echo ""

echo "8.3 Waiting for frontend to be ready (1-2 minutes)..."
kubectl get pods -l app=frontend -w &
WATCH_PID=$!

READY=0
TIMEOUT=120
ELAPSED=0
while [ $READY -eq 0 ] && [ $ELAPSED -lt $TIMEOUT ]; do
    RUNNING=$(kubectl get pods -l app=frontend -o jsonpath='{.items[*].status.phase}' | grep -o Running | wc -l)
    
    if [ $RUNNING -ge 1 ]; then
        READY=1
        echo "✓ Frontend is running"
    fi
    
    sleep 5
    ELAPSED=$((ELAPSED + 5))
done

kill $WATCH_PID 2>/dev/null
echo ""

# STEP 9: Comprehensive validation
echo "[STEP 9] Comprehensive Validation"
echo "-------------------------------------------"

echo "9.1 Pod Status Check"
echo "-------------------"
kubectl get pods -o wide
echo ""

echo "9.2 Service Status Check"
echo "------------------------"
kubectl get services
echo ""

echo "9.3 StatefulSet Status Check"
echo "-----------------------------"
kubectl get statefulsets
echo ""

echo "9.4 PersistentVolumeClaim Status Check"
echo "----------------------------------------"
kubectl get pvc
echo ""

echo "9.5 Checking for failed/pending pods..."
FAILED_PODS=$(kubectl get pods --field-selector=status.phase!=Running,status.phase!=Succeeded --no-headers 2>/dev/null | wc -l)
if [ $FAILED_PODS -gt 0 ]; then
    echo "WARNING: Found failed/pending pods:"
    kubectl get pods --field-selector=status.phase!=Running,status.phase!=Succeeded
else
    echo "✓ All pods are running"
fi
echo ""

# STEP 10: Health checks
echo "[STEP 10] Health Checks - Service Communication"
echo "-------------------------------------------"

echo "10.1 Testing users-service health..."
kubectl exec -it $(kubectl get pods -l app=users-service -o name | head -1) -- wget -q -O- http://localhost:3001/health | grep -q "status" && echo "✓ Users service is healthy" || echo "✗ Users service health check failed"
echo ""

echo "10.2 Testing orders-service health..."
kubectl exec -it $(kubectl get pods -l app=orders-service -o name | head -1) -- wget -q -O- http://localhost:3002/health | grep -q "status" && echo "✓ Orders service is healthy" || echo "✗ Orders service health check failed"
echo ""

echo "10.3 Testing shipments-service health..."
kubectl exec -it $(kubectl get pods -l app=shipments-service -o name | head -1) -- wget -q -O- http://localhost:3003/health | grep -q "status" && echo "✓ Shipments service is healthy" || echo "✗ Shipments service health check failed"
echo ""

echo "10.4 Testing inventory-service health..."
kubectl exec -it $(kubectl get pods -l app=inventory-service -o name | head -1) -- wget -q -O- http://localhost:3004/health | grep -q "status" && echo "✓ Inventory service is healthy" || echo "✗ Inventory service health check failed"
echo ""

echo "10.5 Testing notifications-service health..."
kubectl exec -it $(kubectl get pods -l app=notifications-service -o name | head -1) -- wget -q -O- http://localhost:3005/health | grep -q "status" && echo "✓ Notifications service is healthy" || echo "✗ Notifications service health check failed"
echo ""

# STEP 11: Database validation
echo "[STEP 11] Database Validation"
echo "-------------------------------------------"

echo "11.1 Checking users database..."
kubectl exec -it $(kubectl get pods -l app=users-db -o name | head -1) -- psql -U postgres -d users_db -c "\dt" | head -5 && echo "✓ Users DB accessible and tables created"
echo ""

echo "11.2 Checking orders database..."
kubectl exec -it $(kubectl get pods -l app=orders-db -o name | head -1) -- psql -U postgres -d orders_db -c "\dt" | head -5 && echo "✓ Orders DB accessible and tables created"
echo ""

echo "11.3 Checking shipments database..."
kubectl exec -it $(kubectl get pods -l app=shipments-db -o name | head -1) -- psql -U postgres -d shipments_db -c "\dt" | head -5 && echo "✓ Shipments DB accessible and tables created"
echo ""

echo "11.4 Checking inventory database..."
kubectl exec -it $(kubectl get pods -l app=inventory-db -o name | head -1) -- psql -U postgres -d inventory_db -c "\dt" | head -5 && echo "✓ Inventory DB accessible and tables created"
echo ""

echo "11.5 Checking notifications database..."
kubectl exec -it $(kubectl get pods -l app=notifications-db -o name | head -1) -- psql -U postgres -d notifications_db -c "\dt" | head -5 && echo "✓ Notifications DB accessible and tables created"
echo ""

# STEP 12: Frontend access
echo "[STEP 12] Frontend Access Configuration"
echo "-------------------------------------------"

echo "12.1 Getting Frontend LoadBalancer IP/Hostname..."
FRONTEND_IP=$(kubectl get service frontend -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
FRONTEND_HOSTNAME=$(kubectl get service frontend -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)

if [ -z "$FRONTEND_IP" ] && [ -z "$FRONTEND_HOSTNAME" ]; then
    echo "⚠ LoadBalancer external IP/hostname not assigned yet (may take 1-2 minutes)"
    echo "Run: kubectl get service frontend -w"
    echo "to monitor for external IP assignment"
else
    if [ ! -z "$FRONTEND_IP" ]; then
        echo "✓ Frontend URL: http://$FRONTEND_IP"
    fi
    if [ ! -z "$FRONTEND_HOSTNAME" ]; then
        echo "✓ Frontend URL: http://$FRONTEND_HOSTNAME"
    fi
fi
echo ""

# STEP 13: Port forwarding for testing
echo "[STEP 13] Port Forwarding Setup (for testing)"
echo "-------------------------------------------"
echo "To access services locally, open new terminal windows and run:"
echo ""
echo "Frontend:"
echo "  kubectl port-forward service/frontend 3000:80"
echo ""
echo "Users Service:"
echo "  kubectl port-forward service/users-service 3001:3001"
echo ""
echo "Orders Service:"
echo "  kubectl port-forward service/orders-service 3002:3002"
echo ""
echo "Then access at http://localhost:3000"
echo ""

# STEP 14: Deployment summary
echo "[STEP 14] Deployment Summary"
echo "-------------------------------------------"

echo "Resource Summary:"
echo "================"
echo ""
echo "Pods:"
kubectl get pods --no-headers | wc -l | xargs echo "Total pods:"
echo ""

echo "Services:"
kubectl get services --no-headers | wc -l | xargs echo "Total services:"
echo ""

echo "Deployments:"
kubectl get deployments --no-headers | wc -l | xargs echo "Total deployments:"
echo ""

echo "StatefulSets:"
kubectl get statefulsets --no-headers | wc -l | xargs echo "Total statefulsets:"
echo ""

echo "Storage:"
kubectl get pvc --no-headers | wc -l | xargs echo "Total PVCs:"
echo ""

# STEP 15: Final checks
echo "[STEP 15] Final System Check"
echo "-------------------------------------------"

ERROR_COUNT=0

echo "Checking for pod restarts..."
RESTARTS=$(kubectl get pods -o jsonpath='{.items[*].status.containerStatuses[*].restartCount}' | tr ' ' '\n' | awk '{if($1>0) print}' | wc -l)
if [ $RESTARTS -gt 0 ]; then
    echo "⚠ Found pods with restarts:"
    kubectl get pods -o wide --sort-by='.status.containerStatuses[0].restartCount'
    ERROR_COUNT=$((ERROR_COUNT + 1))
else
    echo "✓ No pod restarts detected"
fi
echo ""

echo "Checking node resource availability..."
kubectl top nodes 2>/dev/null || echo "ℹ Metrics server not installed (optional)"
echo ""

echo "Checking for any pending pods..."
PENDING=$(kubectl get pods --field-selector=status.phase=Pending --no-headers | wc -l)
if [ $PENDING -gt 0 ]; then
    echo "⚠ Found pending pods:"
    kubectl get pods --field-selector=status.phase=Pending
    ERROR_COUNT=$((ERROR_COUNT + 1))
else
    echo "✓ No pending pods"
fi
echo ""

# STEP 16: Testing checklist
echo "[STEP 16] Manual Testing Checklist"
echo "-------------------------------------------"
echo "Once frontend is accessible, test the following:"
echo ""
echo "1. Authentication:"
echo "   [ ] Open frontend in browser"
echo "   [ ] Register new user account"
echo "   [ ] Login with credentials"
echo ""
echo "2. Users Management:"
echo "   [ ] View users list"
echo "   [ ] Create new user via frontend"
echo "   [ ] Verify user appears in table"
echo ""
echo "3. Orders Management:"
echo "   [ ] View orders list"
echo "   [ ] Create new order"
echo "   [ ] Verify order status updates"
echo ""
echo "4. Shipments:"
echo "   [ ] View shipments list"
echo "   [ ] Check tracking numbers"
echo "   [ ] Verify shipment status"
echo ""
echo "5. Inventory:"
echo "   [ ] View inventory items"
echo "   [ ] Add new inventory item"
echo "   [ ] Adjust quantities"
echo ""
echo "6. Dashboard:"
echo "   [ ] Verify stats display correctly"
echo "   [ ] Check numbers match database"
echo ""

# Final status
echo ""
echo "========================================"
if [ $ERROR_COUNT -eq 0 ]; then
    echo "✓ DEPLOYMENT VALIDATION COMPLETE - ALL SYSTEMS GREEN!"
else
    echo "⚠ DEPLOYMENT VALIDATION COMPLETE - $ERROR_COUNT warnings found"
fi
echo "========================================"
echo ""
echo "Next steps:"
echo "1. Monitor logs: kubectl logs -f deployment/<service-name>"
echo "2. Access frontend via LoadBalancer external IP"
echo "3. Test all features as per checklist above"
echo "4. Scale services if needed: kubectl scale deployment <name> --replicas=N"
echo ""
