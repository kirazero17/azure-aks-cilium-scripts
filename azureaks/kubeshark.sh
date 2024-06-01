#!/usr/bin/bash

shark_install() {
    ‍helm --kube-context $1 upgrade -i kubeshark kubeshark/kubeshark
}

shark_install $CLUSTER1
shark_install $CLUSTER2

# kubectl --kube-context $CLUSTER1 port-forward service/kubeshark-front 8899:80
# kubectl --kube-context $CLUSTER2 port-forward service/kubeshark-front 8899:80