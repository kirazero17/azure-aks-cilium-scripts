#!/usr/bin/bash

MSYS_NO_PATHCONV=1
az login --user "${email}" --password "${password}"

# specify CREATOR
NAME="lghg-$RANDOM"
AZURE_RESOURCE_GROUP="${NAME}-group"

#  westus2 can be changed to any available location (`az account list-locations`)
az group create --name "${AZURE_RESOURCE_GROUP}" -l centralindia

az network vnet create \
    --resource-group "${AZURE_RESOURCE_GROUP}" \
    --name "${NAME}-cluster-net" \
    --address-prefixes 192.168.10.0/24 \
    --subnet-name "${NAME}-node-subnet" \
    --subnet-prefix 192.168.10.0/24

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
    --network-plugin azure \
	--network-plugin-mode overlay \
    --pod-cidr "10.10.0.0/16" \
    --service-cidr "10.11.0.0/16" \
    --dns-service-ip "10.11.0.10" \
    --vnet-subnet-id "${NODE_SUBNET_ID}" \
    -s standard_d2as_v4 -c 1

az aks get-credentials \
    --resource-group "${AZURE_RESOURCE_GROUP}" \
    --name "${NAME}"

kubectl create namespace micro-onos
helm repo add cord https://charts.opencord.org
helm repo add atomix https://charts.atomix.io
helm repo add onosproject https://charts.onosproject.org
helm repo update
helm install -n kube-system atomix atomix/atomix
helm install -n kube-system onos-operator onosproject/onos-operator
helm -n micro-onos install onos-umbrella ../../Helm/onos-helm-charts/onos-umbrella
