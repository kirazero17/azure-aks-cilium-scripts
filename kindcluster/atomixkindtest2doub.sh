#!/bin/bash

# cluster 1
kind create cluster --config ./yaml/testcluster.yaml --name cluster1
kind get kubeconfig > ~/.kube/cluster1 --name cluster1
KUBECONFIG=~/.kube/cluster1

# helm repo add cord https://charts.opencord.org
# helm repo add atomix https://charts.atomix.io
# helm repo add onosproject https://charts.onosproject.org
# helm repo update

kind load docker-image quay.io/cilium/cilium:v1.15.6 --name cluster1

helm upgrade -i cilium cilium/cilium --version 1.15.6 \
    --namespace kube-system \
    --set nodeinit.enabled=true \
    --set image.pullPolicy=IfNotPresent \
    --set ipam.mode=kubernetes \
    --set cluster.name="cluster1" \
    --set cluster.id=1 \
    --set k8sServiceHost=cluster1-control-plane \
    --set k8sServicePort=6443 \
    --set externalIPs.enabled=true \
    --set nodePort.enabled=true \
    --set hostPort.enabled=true \
    --set clustermesh.enableEndpointSliceSynchronization=true \
    --values - <<EOF
    kubeProxyReplacement: strict
    hostServices:
        enabled: false
    image:
        pullPolicy: IfNotPresent
    enableIPv4Masquerade: true
    hubble:
        enabled: true
        relay:
            enabled: true
        ui:
            enabled: true
            ingress:
                enabled: true
                annotations:
                    kubernetes.io/ingress.class: nginx
EOF

helm upgrade --install --namespace metallb-system \
    --create-namespace --repo https://metallb.github.io/metallb metallb metallb
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"

kubectl apply -f yaml/metallb_c1.yaml

helm upgrade --install --namespace ingress-nginx --create-namespace --repo https://kubernetes.github.io/ingress-nginx ingress-nginx ingress-nginx --values - <<EOF
defaultBackend:
  enabled: true
EOF


# cluster 2
kind create cluster --config ./yaml/testcluster2.yaml --name cluster2
kind get kubeconfig > ~/.kube/cluster2 --name cluster2
KUBECONFIG=~/.kube/cluster1:~/.kube/cluster2

kind load docker-image quay.io/cilium/cilium:v1.15.6 --name cluster2

helm upgrade -i cilium cilium/cilium --version 1.15.6 \
    --namespace kube-system \
    --set nodeinit.enabled=true \
    --set image.pullPolicy=IfNotPresent \
    --set ipam.mode=kubernetes \
    --set kubeProxyReplacement=strict \
    --set cluster.name="cluster2" \
    --set cluster.id=2 \
    --set k8sServiceHost=cluster2-control-plane \
    --set k8sServicePort=6443 \
    --set externalIPs.enabled=true \
    --set nodePort.enabled=true \
    --set hostPort.enabled=true \
    --set clustermesh.enableEndpointSliceSynchronization=true \
    --values - <<EOF
    kubeProxyReplacement: strict
    hostServices:
        enabled: false
    image:
        pullPolicy: IfNotPresent
    enableIPv4Masquerade: true
    hubble:
        enabled: true
        relay:
            enabled: true
        ui:
            enabled: true
            ingress:
                enabled: true
                annotations:
                    kubernetes.io/ingress.class: nginx
EOF

helm upgrade --install --namespace metallb-system \
    --create-namespace --repo https://metallb.github.io/metallb metallb metallb
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"

kubectl apply -f yaml/metallb_c2.yaml

helm upgrade --install --namespace ingress-nginx --create-namespace --repo https://kubernetes.github.io/ingress-nginx ingress-nginx ingress-nginx --values - <<EOF
defaultBackend:
  enabled: true
EOF