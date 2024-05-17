#!/usr/bin/bash

cilium clustermesh enable --context $CLUSTER1 --enable-kvstoremesh
cilium clustermesh enable --context $CLUSTER2 --enable-kvstoremesh
cilium clustermesh status --context $CLUSTER1 --wait
cilium clustermesh status --context $CLUSTER2 --wait
cilium clustermesh connect --context $CLUSTER1 --destination-context $CLUSTER2
cilium clustermesh status --context $CLUSTER1 --wait