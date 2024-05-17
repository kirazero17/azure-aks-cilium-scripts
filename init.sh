#!/usr/bin/bash

# email="your-email@example.com"
# password="yourpassword"
az login --user "${email}" --password "${password}"
export CREATOR=lghg
export CLUSTER1="${CREATOR}-10001"
export CLUSTER2="${CREATOR}-10002"
bash $(pwd)/cluster1.sh
bash $(pwd)/cluster2.sh
bash $(pwd)/peering.sh
bash $(pwd)/clustermesh.sh
