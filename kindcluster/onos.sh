#!/bin/bash

KUBECONFIG=~/.kube/cluster1:~/.kube/cluster2

kubectl config use kind-cluster1
kubectl create namespace micro-onos
helm upgrade -i -n kube-system atomix ../../../Helm/atomix-helm-charts/atomix-umbrella
helm upgrade -i -n kube-system onos-operator onosproject/onos-operator
# helm upgrade -i -n micro-onos-data onos-raft ../../../Helm/onos-helm-charts/onos-raft
helm upgrade -i -n micro-onos-east onos-umbrella ../../../Helm/onos-helm-charts/onos-umbrella

kubectl config use kind-cluster2
kubectl create namespace micro-onos
helm upgrade -i -n kube-system atomix ../../../Helm/atomix-helm-charts/atomix-umbrella
helm upgrade -i -n kube-system onos-operator onosproject/onos-operator
# helm upgrade -i -n micro-onos-data onos-raft ../../../Helm/onos-helm-charts/onos-raft
helm upgrade -i -n micro-onos-west onos-umbrella ../../../Helm/onos-helm-charts/onos-umbrella