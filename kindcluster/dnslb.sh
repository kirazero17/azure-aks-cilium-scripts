#!/bin/bash

kubectl --context kind-cluster1 apply -f dns/dns-lb.yaml
kubectl --context kind-cluster2 apply -f dns/dns-lb.yaml