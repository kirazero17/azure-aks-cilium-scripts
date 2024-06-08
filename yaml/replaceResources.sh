#!/usr/bin/bash

for file in ./services/cluster1/**/rolebinding.yaml
do
    echo -e "creating ${file}"
    kubectl -n micro-onos-1 replace -f ${file}
done

for file in ./services/cluster2/**/rolebinding.yaml
do
    echo -e "creating ${file}"
    kubectl -n micro-onos-2 replace -f ${file}
done

for file in ./services/cluster1/**/storageprofile.yaml
do
    echo -e "replacing ${file}"
    kubectl -n micro-onos-1 replace -f ${file}
done

for file in ./services/cluster2/**/storageprofile.yaml
do
    echo -e "replacing ${file}"
    kubectl -n micro-onos-2 replace -f ${file}
done