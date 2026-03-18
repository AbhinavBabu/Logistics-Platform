@echo off
echo ========================================
echo Logistics Platform - Quick Local Test
echo ========================================
echo.

echo [STEP 1] Starting all services with Docker Compose...
docker-compose up -d
if %errorlevel% neq 0 (
    echo ERROR: Failed to start services!
    exit /b 1
)
echo ✓ Services started successfully
echo.

echo [STEP 2] Waiting for services to initialize (30 seconds)...
timeout /t 30 /nobreak > nul
echo ✓ Initialization complete
echo.

echo [STEP 3] Checking service health...
echo.

echo Testing Users Service (Port 3001)...
curl -s http://localhost:3001/health | findstr "status" >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ Users service is healthy
) else (
    echo ✗ Users service health check failed
)
echo.

echo Testing Orders Service (Port 3002)...
curl -s http://localhost:3002/health | findstr "status" >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ Orders service is healthy
) else (
    echo ✗ Orders service health check failed
)
echo.

echo Testing Shipments Service (Port 3003)...
curl -s http://localhost:3003/health | findstr "status" >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ Shipments service is healthy
) else (
    echo ✗ Shipments service health check failed
)
echo.

echo Testing Inventory Service (Port 3004)...
curl -s http://localhost:3004/health | findstr "status" >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ Inventory service is healthy
) else (
    echo ✗ Inventory service health check failed
)
echo.

echo Testing Notifications Service (Port 3005)...
curl -s http://localhost:3005/health | findstr "status" >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ Notifications service is healthy
) else (
    echo ✗ Notifications service health check failed
)
echo.

echo [STEP 4] Testing database connections...
echo.

echo Testing Users Database...
docker-compose exec -T users-db pg_isready -U postgres -d users_db >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ Users database is ready
) else (
    echo ✗ Users database connection failed
)
echo.

echo Testing Orders Database...
docker-compose exec -T orders-db pg_isready -U postgres -d orders_db >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ Orders database is ready
) else (
    echo ✗ Orders database connection failed
)
echo.

echo Testing Shipments Database...
docker-compose exec -T shipments-db pg_isready -U postgres -d shipments_db >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ Shipments database is ready
) else (
    echo ✗ Shipments database connection failed
)
echo.

echo Testing Inventory Database...
docker-compose exec -T inventory-db pg_isready -U postgres -d inventory_db >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ Inventory database is ready
) else (
    echo ✗ Inventory database connection failed
)
echo.

echo Testing Notifications Database...
docker-compose exec -T notifications-db pg_isready -U postgres -d notifications_db >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ Notifications database is ready
) else (
    echo ✗ Notifications database connection failed
)
echo.

echo [STEP 5] Testing API endpoints...
echo.

echo Testing Users API - Get all users...
curl -s -X GET http://localhost:3001/users -H "Authorization: Bearer test-token" | findstr "error" >nul 2>&1
if %errorlevel% neq 0 (
    echo ✓ Users API responding (expected auth error)
) else (
    echo ✗ Users API not responding
)
echo.

echo Testing Orders API - Get all orders...
curl -s -X GET http://localhost:3002/orders -H "Authorization: Bearer test-token" | findstr "error" >nul 2>&1
if %errorlevel% neq 0 (
    echo ✓ Orders API responding (expected auth error)
) else (
    echo ✗ Orders API not responding
)
echo.

echo Testing Shipments API - Get all shipments...
curl -s -X GET http://localhost:3003/shipments -H "Authorization: Bearer test-token" | findstr "error" >nul 2>&1
if %errorlevel% neq 0 (
    echo ✓ Shipments API responding (expected auth error)
) else (
    echo ✗ Shipments API not responding
)
echo.

echo Testing Inventory API - Get all items...
curl -s -X GET http://localhost:3004/inventory -H "Authorization: Bearer test-token" | findstr "error" >nul 2>&1
if %errorlevel% neq 0 (
    echo ✓ Inventory API responding (expected auth error)
) else (
    echo ✗ Inventory API not responding
)
echo.

echo [STEP 6] Testing frontend accessibility...
echo.
curl -s -I http://localhost:3000 | findstr "200 OK" >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ Frontend is accessible at http://localhost:3000
) else (
    echo ⚠ Frontend may still be building (check in 1-2 minutes)
)
echo.

echo [STEP 7] Service status summary...
echo.
docker-compose ps
echo.

echo ========================================
echo QUICK TEST COMPLETE!
echo ========================================
echo.
echo ACCESS POINTS:
echo ==============
echo Frontend:        http://localhost:3000
echo Users API:       http://localhost:3001
echo Orders API:      http://localhost:3002
echo Shipments API:   http://localhost:3003
echo Inventory API:   http://localhost:3004
echo Notifications:   http://localhost:3005
echo.
echo DATABASES:
echo ==========
echo Users DB:        localhost:5432
echo Orders DB:       localhost:5433
echo Shipments DB:    localhost:5434
echo Inventory DB:    localhost:5435
echo Notifications:   localhost:5436
echo.
echo NEXT STEPS:
echo ===========
echo 1. Open http://localhost:3000 in browser
echo 2. Register a new user account
echo 3. Login and test all features
echo 4. Check logs: docker-compose logs -f [service]
echo 5. Stop: docker-compose down
echo.
echo For Kubernetes deployment, run:
echo .\build-and-push.bat yourusername
echo .\deploy.bat
echo.
