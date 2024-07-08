#!/bin/bash

kind create cluster --config ./yaml/testcluster.yaml
kind get kubeconfig > ~/.kube/kind
KUBECONFIG=~/.kube/kind

helm repo add cord https://charts.opencord.org
helm repo add atomix https://charts.atomix.io
helm repo add onosproject https://charts.onosproject.org
helm repo update

kind load docker-image quay.io/cilium/cilium:v1.15.6

helm install cilium cilium/cilium --version 1.15.6 \
    --namespace kube-system \
    --set image.pullPolicy=IfNotPresent \
    --set ipam.mode=kubernetes \
    --set cluster.name="kind" \
    --set cluster.id=1 \
    --set k8sServiceHost=kind-control-plane \
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
    routingMode: native
    ipv4NativeRoutingCIDR: 10.10.0.0/16
    enableIPv4Masquerade: true
    autoDirectNodeRoutes: true
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

kubectl create namespace micro-onos-data

helm upgrade -i -n kube-system atomix ../../../Helm/atomix-helm-charts/atomix-umbrella
helm upgrade -i -n micro-onos-data onos-raft ../../../Helm/onos-helm-charts/onos-raft