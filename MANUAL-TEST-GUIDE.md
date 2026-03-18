# Manual Testing Without Docker

Since Docker isn't installed locally, here's how to test your logistics platform manually:

## Option 1: Test Individual Services (Fastest)

### 1. Test a Single Service Locally
```bash
# Go to any service directory
cd services/users-service

# Install dependencies
npm install

# Start the service
npm start
```

### 2. Test the API
```bash
# In another terminal, test the health endpoint
curl http://localhost:3001/health
```

### 3. Test Database Connection
```bash
# Check if service can connect to database
curl http://localhost:3001/users
# Should return auth error (expected)
```

## Option 2: Install Docker Desktop (Recommended)

### Quick Docker Install:
1. Download from: https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe
2. Run as Administrator
3. Restart PowerShell
4. Run: `.\quick-test.bat`

## Option 3: Test on Your Kubernetes Cluster

If you have kubectl configured for your cluster:

### 1. Install kubectl
```powershell
# Download kubectl
curl -LO "https://dl.k8s.io/release/v1.28.0/bin/windows/amd64/kubectl.exe"

# Add to PATH or move to a directory in PATH
```

### 2. Quick Cluster Test
```bash
# Check cluster connection
kubectl cluster-info

# Test with a simple pod
kubectl run test-pod --image=nginx --port=80
kubectl get pods
kubectl delete pod test-pod
```

### 3. Deploy Your Platform
```bash
# Use the deployment scripts
.\build-and-push.bat your-dockerhub-username
.\deploy.bat
```

## What to Look For:

✅ **Service starts without errors**
✅ **Health endpoint returns status**
✅ **Database connection works**
✅ **API endpoints respond** (even with auth errors)

## If Services Start Successfully:

Your code is working! The platform will deploy fine to Kubernetes.

## Quick Validation Checklist:

- [ ] Can install Node.js dependencies
- [ ] Services start on correct ports
- [ ] Health endpoints respond
- [ ] Database schemas are valid
- [ ] Frontend builds successfully

Would you like me to help you test one service manually, or would you prefer to install Docker first?