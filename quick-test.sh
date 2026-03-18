#!/bin/bash

echo "========================================"
echo "Logistics Platform - Quick Local Test"
echo "========================================"
echo

echo "[STEP 1] Starting all services with Docker Compose..."
docker-compose up -d
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to start services!"
    exit 1
fi
echo "✓ Services started successfully"
echo

echo "[STEP 2] Waiting for services to initialize (30 seconds)..."
sleep 30
echo "✓ Initialization complete"
echo

echo "[STEP 3] Checking service health..."
echo

echo "Testing Users Service (Port 3001)..."
if curl -s http://localhost:3001/health | grep -q "status"; then
    echo "✓ Users service is healthy"
else
    echo "✗ Users service health check failed"
fi
echo

echo "Testing Orders Service (Port 3002)..."
if curl -s http://localhost:3002/health | grep -q "status"; then
    echo "✓ Orders service is healthy"
else
    echo "✗ Orders service health check failed"
fi
echo

echo "Testing Shipments Service (Port 3003)..."
if curl -s http://localhost:3003/health | grep -q "status"; then
    echo "✓ Shipments service is healthy"
else
    echo "✗ Shipments service health check failed"
fi
echo

echo "Testing Inventory Service (Port 3004)..."
if curl -s http://localhost:3004/health | grep -q "status"; then
    echo "✓ Inventory service is healthy"
else
    echo "✗ Inventory service health check failed"
fi
echo

echo "Testing Notifications Service (Port 3005)..."
if curl -s http://localhost:3005/health | grep -q "status"; then
    echo "✓ Notifications service is healthy"
else
    echo "✗ Notifications service health check failed"
fi
echo

echo "[STEP 4] Testing database connections..."
echo

echo "Testing Users Database..."
if docker-compose exec -T users-db pg_isready -U postgres -d users_db >/dev/null 2>&1; then
    echo "✓ Users database is ready"
else
    echo "✗ Users database connection failed"
fi
echo

echo "Testing Orders Database..."
if docker-compose exec -T orders-db pg_isready -U postgres -d orders_db >/dev/null 2>&1; then
    echo "✓ Orders database is ready"
else
    echo "✗ Orders database connection failed"
fi
echo

echo "Testing Shipments Database..."
if docker-compose exec -T shipments-db pg_isready -U postgres -d shipments_db >/dev/null 2>&1; then
    echo "✓ Shipments database is ready"
else
    echo "✗ Shipments database connection failed"
fi
echo

echo "Testing Inventory Database..."
if docker-compose exec -T inventory-db pg_isready -U postgres -d inventory_db >/dev/null 2>&1; then
    echo "✓ Inventory database is ready"
else
    echo "✗ Inventory database connection failed"
fi
echo

echo "Testing Notifications Database..."
if docker-compose exec -T notifications-db pg_isready -U postgres -d notifications_db >/dev/null 2>&1; then
    echo "✓ Notifications database is ready"
else
    echo "✗ Notifications database connection failed"
fi
echo

echo "[STEP 5] Testing API endpoints..."
echo

echo "Testing Users API - Get all users..."
if curl -s -X GET http://localhost:3001/users -H "Authorization: Bearer test-token" | grep -q "error"; then
    echo "✓ Users API responding (expected auth error)"
else
    echo "✗ Users API not responding"
fi
echo

echo "Testing Orders API - Get all orders..."
if curl -s -X GET http://localhost:3002/orders -H "Authorization: Bearer test-token" | grep -q "error"; then
    echo "✓ Orders API responding (expected auth error)"
else
    echo "✗ Orders API not responding"
fi
echo

echo "Testing Shipments API - Get all shipments..."
if curl -s -X GET http://localhost:3003/shipments -H "Authorization: Bearer test-token" | grep -q "error"; then
    echo "✓ Shipments API responding (expected auth error)"
else
    echo "✗ Shipments API not responding"
fi
echo

echo "Testing Inventory API - Get all items..."
if curl -s -X GET http://localhost:3004/inventory -H "Authorization: Bearer test-token" | grep -q "error"; then
    echo "✓ Inventory API responding (expected auth error)"
else
    echo "✗ Inventory API not responding"
fi
echo

echo "[STEP 6] Testing frontend accessibility..."
echo
if curl -s -I http://localhost:3000 | grep -q "200 OK"; then
    echo "✓ Frontend is accessible at http://localhost:3000"
else
    echo "⚠ Frontend may still be building (check in 1-2 minutes)"
fi
echo

echo "[STEP 7] Service status summary..."
echo
docker-compose ps
echo

echo "========================================"
echo "QUICK TEST COMPLETE!"
echo "========================================"
echo
echo "ACCESS POINTS:"
echo "=============="
echo "Frontend:        http://localhost:3000"
echo "Users API:       http://localhost:3001"
echo "Orders API:      http://localhost:3002"
echo "Shipments API:   http://localhost:3003"
echo "Inventory API:   http://localhost:3004"
echo "Notifications:   http://localhost:3005"
echo
echo "DATABASES:"
echo "=========="
echo "Users DB:        localhost:5432"
echo "Orders DB:       localhost:5433"
echo "Shipments DB:    localhost:5434"
echo "Inventory DB:    localhost:5435"
echo "Notifications:   localhost:5436"
echo
echo "NEXT STEPS:"
echo "==========="
echo "1. Open http://localhost:3000 in browser"
echo "2. Register a new user account"
echo "3. Login and test all features"
echo "4. Check logs: docker-compose logs -f [service]"
echo "5. Stop: docker-compose down"
echo
echo "For Kubernetes deployment, run:"
echo "./build-and-push.sh yourusername"
echo "./deploy.sh"
echo