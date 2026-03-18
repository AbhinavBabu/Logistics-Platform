#!/bin/bash

echo "Quick Local Testing with Docker Compose"
echo "========================================"
echo ""
echo "Starting all services..."
docker-compose up -d

echo ""
echo "Waiting for services to start..."
sleep 10

echo ""
echo "Services started! Accessing points:"
echo "- Frontend: http://localhost:3000"
echo "- Users Service: http://localhost:3001/health"
echo "- Orders Service: http://localhost:3002/health"
echo "- Shipments Service: http://localhost:3003/health"
echo "- Inventory Service: http://localhost:3004/health"
echo "- Notifications Service: http://localhost:3005/health"
echo ""
echo "Databases:"
echo "- Users DB: localhost:5432"
echo "- Orders DB: localhost:5433"
echo "- Shipments DB: localhost:5434"
echo "- Inventory DB: localhost:5435"
echo "- Notifications DB: localhost:5436"
echo ""
echo "To stop all services: docker-compose down"
echo "To view logs: docker-compose logs -f <service_name>"
echo ""
