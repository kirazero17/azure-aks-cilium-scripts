#!/usr/bin/bash

export VNET_ID=$(az network vnet show \
    --resource-group "${CLUSTER2}-group" \
    --name "${CLUSTER2}-cluster-net" \
    --query id -o tsv)

az network vnet peering create \
    -g "${CLUSTER1}-group" \
    --name "peering-${CLUSTER1}-to-${CLUSTER2}" \
    --vnet-name "${CLUSTER1}-cluster-net" \
    --remote-vnet "${VNET_ID}" \
    --allow-vnet-access

export VNET_ID=$(az network vnet show \
    --resource-group "${CLUSTER1}-group" \
    --name "${CLUSTER1}-cluster-net" \
    --query id -o tsv)

az network vnet peering create \
    -g "${CLUSTER2}-group" \
    --name "peering-${CLUSTER2}-to-${CLUSTER1}" \
    --vnet-name "${CLUSTER2}-cluster-net" \
    --remote-vnet "${VNET_ID}" \
    --allow-vnet-access
