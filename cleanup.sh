#!/bin/bash

echo "Cleaning up all Kubernetes resources..."
echo ""

echo "Deleting deployments..."
kubectl delete deployment --all

echo "Deleting statefulsets..."
kubectl delete statefulset --all

echo "Deleting services..."
kubectl delete service --all

echo "Deleting persistent volume claims..."
kubectl delete pvc --all

echo "Deleting secrets..."
kubectl delete secret --all

echo "Deleting configmaps..."
kubectl delete configmap --all

echo ""
echo "Cleanup completed!"
echo ""
echo "Remaining resources:"
kubectl get all
