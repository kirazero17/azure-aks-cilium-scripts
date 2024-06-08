#!/usr/bin/bash

kubectl -n micro-onos-1 delete StorageProfile onos-topo
kubectl -n micro-onos-2 delete StorageProfile onos-topo
kubectl -n micro-onos-1 delete RaftStore onos-topo-consensus
kubectl -n micro-onos-2 delete RaftStore onos-topo-consensus
kubectl -n micro-onos-1 delete RaftCluster onos-umbrella-consensus
kubectl -n micro-onos-2 delete RaftCluster onos-umbrella-consensus