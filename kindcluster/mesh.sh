#!/bin/bash

KUBECONFIG=~/.kube/cluster1:~/.kube/cluster2

# cluster mesh

# kubectl --context kind-cluster1 get secret -n kube-system cilium-ca -o yaml | \
#     kubectl --context kind-cluster2 replace -f - <<EOF

cilium clustermesh enable --context kind-cluster1 --service-type LoadBalancer
cilium clustermesh enable --context kind-cluster2 --service-type LoadBalancer

echo -e  "Waiting for clustermesh on cluster1"
cilium clustermesh status --context kind-cluster1 --wait
echo -e  "Waiting for clustermesh on cluster2"
cilium clustermesh status --context kind-cluster2 --wait
cilium clustermesh connect --context kind-cluster1 --destination-context kind-cluster2
echo -e  "Waiting for clustermesh connection"
cilium clustermesh status --context kind-cluster1 --wait