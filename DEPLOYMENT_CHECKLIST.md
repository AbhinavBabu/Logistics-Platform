# Deployment Checklist

## Pre-Deployment

- [ ] Verify Docker is installed and running
- [ ] Verify kubectl is installed and configured
- [ ] Verify access to Kubernetes cluster (`kubectl cluster-info`)
- [ ] Create DockerHub account (if not already done)
- [ ] Number of nodes in cluster: _____
- [ ] Available disk space: _____ GB
- [ ] Kubernetes version: _____

## Image Building & Pushing

- [ ] Login to Docker: `docker login`
- [ ] Update Docker username in all scripts
- [ ] Build frontend image
- [ ] Build users-service image
- [ ] Build orders-service image
- [ ] Build shipments-service image
- [ ] Build inventory-service image
- [ ] Build notifications-service image
- [ ] Verify all images pushed to DockerHub
- [ ] Test image pulls from Kubernetes cluster

## Kubernetes Preparation

- [ ] Create namespace (optional): `kubectl create namespace logistics`
- [ ] Update all deployment YAML files with correct image names
- [ ] Verify YAML syntax: `kubectl apply --dry-run=client -f <file>`
- [ ] Check cluster resource availability
- [ ] Verify persistent volume availability

## Deployment Execution

### Phase 1: Configuration
- [ ] Apply secrets: `kubectl apply -f kubernetes/services/secrets.yaml`
- [ ] Apply configmaps: `kubectl apply -f kubernetes/services/configmaps.yaml`
- [ ] Verify secrets created: `kubectl get secrets`
- [ ] Verify configmaps created: `kubectl get configmaps`

### Phase 2: Databases
- [ ] Deploy users-db statefulset
- [ ] Deploy orders-db statefulset
- [ ] Deploy shipments-db statefulset
- [ ] Deploy inventory-db statefulset
- [ ] Deploy notifications-db statefulset
- [ ] Deploy all database services
- [ ] Wait for all database pods to be running (5-10 minutes)
- [ ] Verify database connections: `kubectl logs <db-pod>`

### Phase 3: Microservices
- [ ] Deploy all microservice deployments
- [ ] Deploy all microservice services
- [ ] Verify all pods are running: `kubectl get pods`
- [ ] Check logs for errors: `kubectl logs <service-pod>`
- [ ] Verify health endpoints: `kubectl port-forward pod/<name> 3001:3001`

### Phase 4: Frontend
- [ ] Deploy frontend deployment
- [ ] Deploy frontend service
- [ ] Verify frontend pod is running
- [ ] Check frontend logs for errors

## Post-Deployment Verification

- [ ] All pods running: `kubectl get pods -o wide`
- [ ] All services created: `kubectl get services`
- [ ] All statefulsets ready: `kubectl get statefulsets`
- [ ] All persistent volumes bound: `kubectl get pvc`
- [ ] No pending pods: `kubectl get pods --field-selector=status.phase=Pending`
- [ ] No crash looping pods: `kubectl get pods --all-namespaces --field-selector=status.phase=CrashLoopBackOff`

## Application Testing

- [ ] Get frontend external IP: `kubectl get service frontend`
- [ ] Access frontend in browser
- [ ] Verify frontend loads without errors
- [ ] Check browser console for errors
- [ ] Verify API connectivity from frontend
- [ ] Test authentication flow
- [ ] Create test user
- [ ] View users list
- [ ] Create test order
- [ ] Create test shipment
- [ ] View inventory
- [ ] Check notifications

## Load Testing (Optional)

- [ ] Deploy load testing pod
- [ ] Run performance tests
- [ ] Monitor resource usage during load
- [ ] Check for bottlenecks
- [ ] Verify auto-recovery after load

## Documentation

- [ ] Document cluster configuration
- [ ] Document resource allocation
- [ ] Document any custom changes made
- [ ] Record configuration for future reference
- [ ] Document any issues encountered and solutions

## Monitoring Setup (Optional)

- [ ] Setup Prometheus (optional)
- [ ] Setup Grafana (optional)
- [ ] Configure alerting (optional)
- [ ] Test alerting rules

## Backup & Recovery

- [ ] Export Kubernetes manifests: `kubectl get all -o yaml > backup.yaml`
- [ ] Backup database credentials
- [ ] Document recovery procedures
- [ ] Test recovery procedure
- [ ] Document backup location

## Presentation Preparation

- [ ] Prepare demo script
- [ ] Test all demo flows
- [ ] Prepare architecture diagrams
- [ ] Prepare performance metrics
- [ ] Document key features
- [ ] Prepare troubleshooting guide
- [ ] Take screenshots for documentation
- [ ] Record demo video (optional)

## Post-Presentation Cleanup

- [ ] Run cleanup script if decommissioning: `./cleanup.sh`
- [ ] Delete persistent volumes: `kubectl delete pvc --all`
- [ ] Clean up namespace (if created separate): `kubectl delete namespace logistics`
- [ ] Clean up local Docker images: `docker image prune`
- [ ] Archive logs and metrics

## Troubleshooting Reference

### Pod won't start
- Check logs: `kubectl logs <pod-name>`
- Check events: `kubectl describe pod <pod-name>`
- Check image availability: `docker image ls`
- Verify pull secrets if using private registry

### Service unreachable
- Check service: `kubectl get svc <service-name>`
- Check pod endpoints: `kubectl get endpoints <service-name>`
- Test connectivity: `kubectl exec -it <pod> -- sh`
- Check network policies

### Database connection issues
- Verify database pod is running
- Check database logs
- Verify connection string in env vars
- Test manual connection to database

### Memory/CPU issues
- Check current usage: `kubectl top pods`
- Check resource requests/limits
- Scale down other services
- Increase node capacity
