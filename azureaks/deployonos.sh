#!/usr/bin/bash

onos_install() {
    kubectl config use-context $1
    kubectl create namespace micro-onos-$1 --context=$1
    kubectl create namespace micro-onos-data --context=$1 
    helm --kube-context $1 upgrade -i -n kube-system atomix ../../../Helm/atomix-helm-charts/atomix-umbrella 
    helm --kube-context $1 upgrade -i -n kube-system onos-operator onosproject/onos-operator
    helm --kube-context $1 upgrade -i -n micro-onos-data onos-raft-data ../../../Helm/onos-helm-charts/onos-raft
    helm --kube-context $1 upgrade -i -n micro-onos-$1 onos-umbrella ../../../Helm/onos-helm-charts/onos-umbrella \
        --set global.atomix.store.consensus.namespace="micro-onos-data" \
        --set global.atomix.store.consensus.name="onos-raft-data"
    echo ""
    echo ""
}

helm repo update
onos_install $CLUSTER1;
onos_install $CLUSTER2