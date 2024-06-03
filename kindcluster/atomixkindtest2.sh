#!/bin/bash

kind create cluster
kind get kubeconfig > ~/.kube/kind
KUBECONFIG=~/.kube/kind

helm repo add cord https://charts.opencord.org
helm repo add atomix https://charts.atomix.io
helm repo add onosproject https://charts.onosproject.org
helm repo update

# MSYS_NO_PATHCONV=1

cilium install \
    --version 1.15.5 \
    --set cluster.id=1 \
    --set hubble.enabled=true \
    --set hubble.relay.enabled=true \
    --set hubble.ui.enabled=true

kubectl create namespace micro-onos-1
kubectl create namespace micro-onos-2

helm upgrade -i cilium cilium/cilium
helm upgrade -i -n kube-system atomix ../../../Helm/atomix-helm-charts/atomix-umbrella
helm upgrade -i -n kube-system onos-operator onosproject/onos-operator

helm upgrade -i -n micro-onos-1 onos-umbrella ../../../Helm/onos-helm-charts/onos-umbrella
helm upgrade -i -n micro-onos-2 onos-umbrella ../../../Helm/onos-helm-charts/onos-umbrella

# --set etcd.enabled=true \
# --set identityAllocationMode=kvstore \
# --set "etcd.endpoints[0]=http://atomix-controller:443" \