#!/usr/bin/bash

MSYS_NO_PATHCONV=1

# email="your-email@example.com"
# password="yourpassword"

CREATOR="lghg"
CLUSTER1="${CREATOR}-$RANDOM"
CLUSTER2="${CREATOR}-$RANDOM"
#  westus2 (West US 2) can be changed to any available location (`az account list-locations`)
REGION="westus2"

createresource() {
    NAME=$1
    AZURE_RESOURCE_GROUP="$1-group"
    
    echo -e  "---------------------------"
    echo -e  ""
    echo -e  "--- Creating resources for AKS Cluster $1 ---"
    echo -e  ""

    echo -e  "Creating resource group for cluster ${NAME}..."
    az group create --name "${AZURE_RESOURCE_GROUP}" -l $2

    echo -e  "Creating VNet for cluster ${NAME}..."
    az network vnet create \
        --resource-group "${AZURE_RESOURCE_GROUP}" \
        --name "${NAME}-cluster-net" \
        --address-prefixes "192.168.$((10*$3)).0/24" \
        --subnet-name "${NAME}-node-subnet" \
        --subnet-prefix "192.168.$((10*$3)).0/24"

    # Store the ID of the created subnet
    NODE_SUBNET_ID=$(az network vnet subnet show \
        --resource-group "${AZURE_RESOURCE_GROUP}" \
        --vnet-name "${NAME}-cluster-net" \
        --name "${NAME}-node-subnet" \
        --query id \
        -o tsv)

    echo -e  "Creating cluster ${NAME}..."
    az aks create \
        --resource-group "${AZURE_RESOURCE_GROUP}" \
        --name "${NAME}" \
        --network-plugin none \
        --pod-cidr "10.$((10*$3)).0.0/16" \
        --service-cidr "10.$((10*$3+1)).0.0/16" \
        --dns-service-ip "10.$((10*$3+1)).0.10" \
        --vnet-subnet-id "${NODE_SUBNET_ID}" \
        -s standard_d2as_v4 -c 1

    echo -e  "Get credential from cluster ${NAME}..."
    az aks get-credentials \
        --resource-group "${AZURE_RESOURCE_GROUP}" \
        --name "${NAME}"

    echo -e  "Installing cilium for cluster ${NAME}..."
    cilium install \
        --version 1.15.5 \
        --set etcd.enabled=true \
        --set identityAllocationMode=kvstore \
        --set azure.resourceGroup="${AZURE_RESOURCE_GROUP}" \
        --set cluster.id=$3 \
        --set ipam.operator.clusterPoolIPv4PodCIDRList="{10.$((10*$3)).0.0/16}"

    cilium status --context $1 --wait
}

vnetpeer() {
    
    echo -e  "---------------------------"
    echo -e  ""
    echo -e  "--- Peering networks for clusters $1 and $2 ---"
    echo -e  ""

    echo -e  "Creating peering"

    VNET_ID=$(az network vnet show \
        --resource-group "$2-group" \
        --name "$2-cluster-net" \
        --query id -o tsv)

    az network vnet peering create \
        -g "$1-group" \
        --name "peering-$1-to-$2" \
        --vnet-name "$1-cluster-net" \
        --remote-vnet "${VNET_ID}" \
        --allow-vnet-access

    VNET_ID=$(az network vnet show \
        --resource-group "$1-group" \
        --name "$1-cluster-net" \
        --query id -o tsv)

    az network vnet peering create \
        -g "$2-group" \
        --name "peering-$2-to-$1" \
        --vnet-name "$2-cluster-net" \
        --remote-vnet "${VNET_ID}" \
        --allow-vnet-access
}

clusterconnect() {
    echo -e  "---------------------------"
    echo -e  ""
    echo -e  "Clustermesh connection between $1 and $2 is being initiated..."
    echo -e  ""

    cilium clustermesh enable --context $1 --enable-kvstoremesh
    cilium clustermesh enable --context $2 --enable-kvstoremesh

    echo -e  "Waiting for clustermesh on cluster $1"
    cilium clustermesh status --context $1 --wait
    echo -e  "Waiting for clustermesh on cluster $2"
    cilium clustermesh status --context $2 --wait
    cilium clustermesh connect --context $1 --destination-context $2
    echo -e  "Waiting for clustermesh connection"
    cilium clustermesh status --context $1 --wait
}

main() {
    createresource $CLUSTER1 $REGION 1
    createresource $CLUSTER2 $REGION 2
    vnetpeer $CLUSTER1 $CLUSTER2
    clusterconnect $CLUSTER1 $CLUSTER2
    return 0
}

az login
main

echo -e '#!/bin/bash' > ./envvar.sh
echo -e '' >> ./envvar.sh
echo -e '# source this file instead of running it' >> ./envvar.sh
echo "export CLUSTER1=\"${CLUSTER1}\"" >> ./envvar.sh
echo "export CLUSTER2=\"${CLUSTER2}\"" >> ./envvar.sh
