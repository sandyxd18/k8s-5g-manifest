#!/bin/bash

echo "=== Kubernetes Installation Script ==="

echo "[+] Install Istio"
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.26.2 TARGET_ARCH=x86_64 sh -
export PATH="$PATH:$(pwd)/istio-1.26.2/bin"
echo 'export PATH="$PATH:$(pwd)/istio-1.26.2/bin"' >> ~/.bashrc
source ~/.bashrc
istioctl x precheck
istioctl install --set profile=demo -y

echo "[+] Install Helm"
sudo apt-get install apt-transport-https wget --yes
wget https://get.helm.sh/helm-v3.17.3-linux-amd64.tar.gz
tar -zxvf helm-v3.17.3-linux-amd64.tar.gz

sudo mv linux-amd64/helm /usr/local/bin/helm

echo "[+] Install Flannel CNI"
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
kubectl wait pods -n kube-flannel  -l app=flannel --for condition=Ready --timeout=120s

echo "[+] Install Multus CNI"
git -C build/multus-cni pull || git clone https://github.com/k8snetworkplumbingwg/multus-cni.git build/multus-cni
cd build/multus-cni
cat ./deployments/multus-daemonset.yml | kubectl apply -f -
cd ~

echo "[+] Deploy OpenEBS"
helm repo add openebs https://openebs.github.io/charts
helm repo update
helm upgrade --install openebs --namespace openebs openebs/openebs --create-namespace
kubectl patch storageclass openebs-hostpath -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

echo "[+] Install OVS"
sudo apt-get update
sudo apt-get install -y openvswitch-switch

sudo ovs-vsctl --may-exist add-br n3br
sudo ovs-vsctl --may-exist add-br n4br

kubectl apply -f https://github.com/kubevirt/cluster-network-addons-operator/releases/download/v0.96.0/namespace.yaml
kubectl apply -f https://github.com/kubevirt/cluster-network-addons-operator/releases/download/v0.96.0/network-addons-config.crd.yaml
kubectl apply -f https://github.com/kubevirt/cluster-network-addons-operator/releases/download/v0.96.0/operator.yaml

kubectl apply -f https://raw.githubusercontent.com/sandyxd18/k8s-5g-manifest/refs/heads/main/networking/network-addons-config.yaml

