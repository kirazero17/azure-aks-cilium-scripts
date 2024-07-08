#!/bin/bash

KUBECONFIG=~/.kube/cluster1:~/.kube/cluster2

kubectl config use kind-cluster1
helm uninstall -n micro-onos onos-umbrella

kubectl config use kind-cluster2
helm uninstall -n micro-onos onos-umbrella