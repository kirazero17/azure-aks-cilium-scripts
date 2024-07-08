#!/bin/bash

KUBECONFIG=~/.kube/cluster1:~/.kube/cluster2

kubectl config use kind-cluster1
kubectl apply -f yaml/metallb_c1.yaml

kubectl config use kind-cluster2
kubectl apply -f yaml/metallb_c2.yaml