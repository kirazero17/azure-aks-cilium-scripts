#!/usr/bin/bash

MSYS_NO_PATHCONV=1

# specify CREATOR
NAME="${CLUSTER2}"
AZURE_RESOURCE_GROUP="${NAME}-group"

#  westus2 can be changed to any available location (`az account list-locations`)
az group create --name "${AZURE_RESOURCE_GROUP}" -l centralindia

az network vnet create \
    --resource-group "${AZURE_RESOURCE_GROUP}" \
    --name "${NAME}-cluster-net" \
    --address-prefixes 192.168.20.0/24 \
    --subnet-name "${NAME}-node-subnet" \
    --subnet-prefix 192.168.20.0/24

# Store the ID of the created subnet
NODE_SUBNET_ID=$(az network vnet subnet show \
    --resource-group "${AZURE_RESOURCE_GROUP}" \
    --vnet-name "${NAME}-cluster-net" \
    --name "${NAME}-node-subnet" \
    --query id \
    -o tsv)

az aks create 
    --resource-group "${AZURE_RESOURCE_GROUP}" \
    --name "${NAME}" \
    --network-plugin none \
    --pod-cidr "10.20.0.0/16" \
    --service-cidr "10.21.0.0/16" \
    --dns-service-ip "10.21.0.10" \
    --vnet-subnet-id "${NODE_SUBNET_ID}" \
    -s standard_d2as_v4 -c 1

az aks get-credentials \
    --resource-group "${AZURE_RESOURCE_GROUP}" \
    --name "${NAME}

cilium install \
    --version 1.15.5 \
    --set azure.resourceGroup="${AZURE_RESOURCE_GROUP}" \
    --set cluster.id=2 \
    --set ipam.operator.clusterPoolIPv4PodCIDRList='{10.20.0.0/16}'
