#!/usr/bin/bash

MSYS_NO_PATHCONV=1
az login --user "${email}" --password "${password}"

# specify CREATOR
NAME="lghg-$RANDOM"
AZURE_RESOURCE_GROUP="${NAME}-group"

#  westus2 can be changed to any available location (`az account list-locations`)
az group create --name "${AZURE_RESOURCE_GROUP}" -l westus2

az network vnet create \
    --resource-group "${AZURE_RESOURCE_GROUP}" \
    --name "${NAME}-cluster-net" \
    --address-prefixes 192.168.30.0/24 \
    --subnet-name "${NAME}-node-subnet" \
    --subnet-prefix 192.168.30.0/24

# Store the ID of the created subnet
NODE_SUBNET_ID=$(az network vnet subnet show \
    --resource-group "${AZURE_RESOURCE_GROUP}" \
    --vnet-name "${NAME}-cluster-net" \
    --name "${NAME}-node-subnet" \
    --query id \
    -o tsv)

az aks create \
    --resource-group "${AZURE_RESOURCE_GROUP}" \
    --name "${NAME}" \
    --network-plugin none \
    --pod-cidr "10.10.0.0/16" \
    --service-cidr "10.11.0.0/16" \
    --dns-service-ip "10.11.0.10" \
    --vnet-subnet-id "${NODE_SUBNET_ID}" \
    -s standard_d4ds_v4 -c 1

az aks get-credentials \
    --resource-group "${AZURE_RESOURCE_GROUP}" \
    --name "${NAME}"

cilium install \
    --version 1.15.5 \
    --set azure.resourceGroup="${AZURE_RESOURCE_GROUP}" \
    --set cluster.id=1 \
    --set ipam.operator.clusterPoolIPv4PodCIDRList='{10.10.0.0/16}'

cilium hubble enable --ui

cilium clustermesh enable --context $NAME --enable-kvstoremesh
cilium clustermesh status --context $NAME --wait

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