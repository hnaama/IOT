while ! curl -sk https://192.168.56.110:6443/ping > /dev/null; do
  echo "Server not ready, retrying in 5s..."
  sleep 5
done
curl -sfL https://get.k3s.io | K3S_URL=https://192.168.56.110:6443 K3S_TOKEN="1234" INSTALL_K3S_EXEC="--node-ip=192.168.56.111" sh -
