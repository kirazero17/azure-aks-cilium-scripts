helm upgrade -i -n kube-system cilium cilium/cilium \
    --set cluster.id=1 \
    --set ipam.operator.clusterPoolIPv4PodCIDRList='{10.10.0.0/16}'

cilium hubble enable --ui

cilium clustermesh enable --enable-kvstoremesh
cilium clustermesh status --wait

kubectl create namespace micro-onos-1
kubectl create namespace micro-onos-2

helm upgrade -i -n kube-system atomix ../../../Helm/atomix-helm-charts/atomix-umbrella
helm upgrade -i -n kube-system onos-operator onosproject/onos-operator

helm upgrade -i -n micro-onos-1 onos-umbrella ../../../Helm/onos-helm-charts/onos-umbrella
helm upgrade -i -n micro-onos-2 onos-umbrella ../../../Helm/onos-helm-charts/onos-umbrella