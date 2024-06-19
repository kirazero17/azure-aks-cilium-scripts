#!/usr/bin/bash

kubectl config set-context $CLUSTER1
for file in ./services/single/**/rolebinding.yaml
do
    echo -e "creating ${file}"
    envsubst < ${file} | kubectl -n micro-onos-data create -f -
done

kubectl config set-context $CLUSTER2
for file in ./services/single/**/rolebinding.yaml
do
    echo -e "creating ${file}"
    envsubst < ${file} | kubectl -n micro-onos-data create -f -
done

# kubectl config set-context $CLUSTER1
# for file in ./services/single/**/storageprofile.yaml
# do
#     echo -e "replacing ${file}"
#     kubectl -n micro-onos-lghg-25390 replace -f ${file}
# done

# kubectl config set-context $CLUSTER2
# for file in ./services/single2/**/storageprofile.yaml
# do
#     echo -e "replacing ${file}"
#     kubectl -n micro-onos-lghg-22375 replace -f ${file}
# done