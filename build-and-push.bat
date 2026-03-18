@echo off
setlocal enabledelayedexpansion

if "%1"=="" (
    echo Usage: build-and-push.bat docker-username
    exit /b 1
)

set DOCKER_USERNAME=%1

echo Building and pushing Docker images...

echo Building frontend...
cd frontend
docker build -t %DOCKER_USERNAME%/logistics-frontend:latest .
docker push %DOCKER_USERNAME%/logistics-frontend:latest
cd ..

echo Building users-service...
cd services\users-service
docker build -t %DOCKER_USERNAME%/logistics-users-service:latest .
docker push %DOCKER_USERNAME%/logistics-users-service:latest
cd ..\..

echo Building orders-service...
cd services\orders-service
docker build -t %DOCKER_USERNAME%/logistics-orders-service:latest .
docker push %DOCKER_USERNAME%/logistics-orders-service:latest
cd ..\..

echo Building shipments-service...
cd services\shipments-service
docker build -t %DOCKER_USERNAME%/logistics-shipments-service:latest .
docker push %DOCKER_USERNAME%/logistics-shipments-service:latest
cd ..\..

echo Building inventory-service...
cd services\inventory-service
docker build -t %DOCKER_USERNAME%/logistics-inventory-service:latest .
docker push %DOCKER_USERNAME%/logistics-inventory-service:latest
cd ..\..

echo Building notifications-service...
cd services\notifications-service
docker build -t %DOCKER_USERNAME%/logistics-notifications-service:latest .
docker push %DOCKER_USERNAME%/logistics-notifications-service:latest
cd ..\..

echo All images built and pushed successfully!
echo Update the Kubernetes deployment files with: %DOCKER_USERNAME%
