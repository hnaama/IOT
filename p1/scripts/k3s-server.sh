curl -sfL https://get.k3s.io/ | K3S_TOKEN="1234" INSTALL_K3S_EXEC="--node-ip=192.168.56.110 --bind-address=192.168.56.110 --advertise-address=192.168.56.110  --tls-san 192.168.56.110" sh -
chmod 777 /etc/rancher/k3s/k3s.yaml

# In your provisioning script
mkdir -p /home/vagrant/.kube
cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
chown vagrant:vagrant /home/vagrant/.kube/config

# Also export for the current shell session
export KUBECONFIG=/home/vagrant/.kube/config