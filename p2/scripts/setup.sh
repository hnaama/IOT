#!/bin/bash
set -e

echo "[setup] Installing required packages..."
apt-get update -qq
apt-get install -y -qq curl wget apt-transport-https ca-certificates gnupg
echo "[setup] Packages installed."

echo "[setup] Starting K3s installation..."

# Detect the private network interface (eth1 or enp0s8)
IFACE=$(ip -o -4 addr show | awk '$4 ~ /^192\.168\.56\./ {print $2}' | head -1)
if [ -z "$IFACE" ]; then
  echo "[setup] ERROR: Could not detect private network interface"
  exit 1
fi
echo "[setup] Detected private network interface: $IFACE"

# Install K3s in server mode bound to the private network IP
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server \
  --bind-address=192.168.56.110 \
  --advertise-address=192.168.56.110 \
  --node-ip=192.168.56.110 \
  --flannel-iface=$IFACE \
  --disable=metrics-server" sh -

echo "[setup] Waiting for K3s to be ready..."
sleep 10
until kubectl get nodes 2>/dev/null | grep -q "Ready"; do
  echo "[setup] Still waiting..."
  sleep 3
done
echo "[setup] K3s is ready!"

# Make kubectl usable without sudo for vagrant user
mkdir -p /home/vagrant/.kube
cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
chown vagrant:vagrant /home/vagrant/.kube/config
echo "export KUBECONFIG=/home/vagrant/.kube/config" >> /home/vagrant/.bashrc
echo "alias k=kubectl" >> /home/vagrant/.bashrc

# Apply all manifests
echo "[setup] Applying manifests..."
kubectl apply -f /vagrant/confs/

# Wait for all pods to be running
echo "[setup] Waiting for pods to be ready..."
sleep 10
kubectl wait --for=condition=ready pod --all --timeout=120s 2>/dev/null || true

echo "[setup] Done! Run: kubectl get all"
echo "[setup]            kubectl get ingress"
