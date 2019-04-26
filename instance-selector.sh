#!/bin/bash

# Set variables
toplogtime=10
testcontainer=exampleserver.yaml
pingcontainer=exampleping.yaml
pinglabel=curl-test
testsetupscript=exampletestsetup.sh
testservicename=hello-web
testport=80
pingcluster=pingcluster
pingzone=europe-west1-b
testzone=europe-west1-b
pingproject=scenic-rampart-237010
testproject=$pingproject
tracetime=20

mkdir logs

# For each set of test clusters / while optimal test cluster not found
while read p; do

    oldMachineType=$machineType

    diskSize=$(echo "$p" | awk '{split($0, a, ","); print a[1]}')
    diskType=$(echo "$p" | awk '{split($0, a, ","); print a[2]}')
    machineType=$(echo "$p" | awk '{split($0, a, ","); print a[3]}')
    numNodes=$(echo "$p" | awk '{split($0, a, ","); print a[4]}')
    zone=$(echo "$p" | awk '{split($0, a, ","); print a[5]}')

    # Make test cluster
        # Variables: Zone, Number of nodes, Machine type

    if [[ $oldMachineType == $machineType ]]; then
        gcloud container clusters resize testcluster --node-pool default-pool --size ${numNodes} -q
    else
        gcloud container clusters delete testcluster -q
        gcloud config set compute/zone ${zone}
        gcloud container clusters create testcluster --machine-type ${machineType} --disk-size ${diskSize} --num-nodes ${numNodes} --disk-type ${diskType}
    fi
    gcloud container clusters get-credentials testcluster

    bash collectclusteranalysis.sh

done <input.csv
    # Analyse logs to choose next test cluster, or stop if stopping condition met

# Print analysis and suggested cluster configuration