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

    # Make test cluster
        # Variables: Zone, Number of nodes, Machine type
    testcluster=testcluster

    bash collectclusteranalysis.sh

    # Analyse logs to choose next test cluster, or stop if stopping condition met

# Print analysis and suggested cluster configuration