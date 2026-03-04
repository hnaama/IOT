#!/bin/bash

# Setup for IoT Part 3
echo "Starting setup..."

# Install kubectl if it's not installed
if ! command -v kubectl &> /dev/null; then
    echo "kubectl could not be found, installing..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
fi

# Install k3d
# I already have it but just in case
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Create the cluster
# need to delete it first if it exists or it fails
k3d cluster delete iot-cluster
k3d cluster create iot-cluster --api-port 6550 -p "8080:80@loadbalancer" -p "8888:8888@loadbalancer" --wait

# Namespaces
kubectl create namespace argocd
kubectl create namespace dev

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml --server-side

# Wait for stuff to start
echo "Waiting for pods..."
sleep 60 

# Apply the app config
# Make sure you are in the right folder for this to work
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
kubectl apply -f "$SCRIPT_DIR/../confs/argocd/application.yaml" -n argocd

echo "Done."
echo "Port forward: kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "Get password: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"