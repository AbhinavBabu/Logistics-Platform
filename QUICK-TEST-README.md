# Quick Local Testing

This is the **fastest way** to test if your logistics platform works before deploying to Kubernetes.

## Prerequisites
- Docker and Docker Compose installed
- At least 4GB RAM available
- Ports 3000-3005 and 5432-5436 free

## Quick Test (5 minutes)

### Windows
```cmd
quick-test.bat
```

### Linux/Mac
```bash
chmod +x quick-test.sh
./quick-test.sh
```

## What it does:
1. **Starts all services** with Docker Compose
2. **Waits for initialization** (30 seconds)
3. **Tests health endpoints** for all 5 microservices
4. **Validates databases** are ready
5. **Tests API endpoints** (expects auth errors - normal!)
6. **Checks frontend** accessibility
7. **Shows service status** and access points

## Expected Results
- All services should show ✓ (healthy)
- Frontend accessible at http://localhost:3000
- APIs respond (with auth errors - this is expected)

## Manual Testing
After quick test completes:
1. Open http://localhost:3000 in browser
2. Register a new user
3. Login and test features
4. Check logs: `docker-compose logs -f [service-name]`

## Stop Testing
```bash
docker-compose down
```

## Next: Kubernetes Deployment
If local test passes, proceed to Kubernetes:
```bash
# Build and push images
./build-and-push.sh yourusername

# Deploy to cluster
./deploy.sh
```

## Troubleshooting
- **Port conflicts**: Change ports in docker-compose.yml
- **Memory issues**: Close other apps, restart Docker
- **Database errors**: Check logs with `docker-compose logs [db-name]`
- **Service failures**: Check logs with `docker-compose logs [service-name]`