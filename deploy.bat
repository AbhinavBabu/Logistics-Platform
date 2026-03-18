@echo off

echo Deploying Logistics Platform to Kubernetes...
echo.

echo Step 1: Creating secrets and configmaps...
kubectl apply -f kubernetes\services\secrets.yaml
kubectl apply -f kubernetes\services\configmaps.yaml
echo Done!
echo.

echo Step 2: Deploying databases...
kubectl apply -f kubernetes\deployments\users-db-statefulset.yaml
kubectl apply -f kubernetes\deployments\orders-db-statefulset.yaml
kubectl apply -f kubernetes\deployments\shipments-db-statefulset.yaml
kubectl apply -f kubernetes\deployments\inventory-db-statefulset.yaml
kubectl apply -f kubernetes\deployments\notifications-db-statefulset.yaml
echo Done!
echo.

echo Step 3: Deploying database services...
kubectl apply -f kubernetes\services\users-db-service.yaml
kubectl apply -f kubernetes\services\orders-db-service.yaml
kubectl apply -f kubernetes\services\shipments-db-service.yaml
kubectl apply -f kubernetes\services\inventory-db-service.yaml
kubectl apply -f kubernetes\services\notifications-db-service.yaml
echo Done!
echo.

echo Waiting for databases to be ready...
timeout /t 10 /nobreak

echo Step 4: Deploying microservices...
kubectl apply -f kubernetes\deployments\users-service-deployment.yaml
kubectl apply -f kubernetes\deployments\orders-service-deployment.yaml
kubectl apply -f kubernetes\deployments\shipments-service-deployment.yaml
kubectl apply -f kubernetes\deployments\inventory-service-deployment.yaml
kubectl apply -f kubernetes\deployments\notifications-service-deployment.yaml
echo Done!
echo.

echo Step 5: Deploying microservice services...
kubectl apply -f kubernetes\services\users-service.yaml
kubectl apply -f kubernetes\services\orders-service.yaml
kubectl apply -f kubernetes\services\shipments-service.yaml
kubectl apply -f kubernetes\services\inventory-service.yaml
kubectl apply -f kubernetes\services\notifications-service.yaml
echo Done!
echo.

echo Step 6: Deploying frontend...
kubectl apply -f kubernetes\deployments\frontend-deployment.yaml
kubectl apply -f kubernetes\services\frontend-service.yaml
echo Done!
echo.

echo Deployment completed!
echo.
echo Checking pod status...
kubectl get pods
echo.
echo Checking services...
kubectl get services
echo.
echo To access the frontend, use:
echo kubectl get service frontend
