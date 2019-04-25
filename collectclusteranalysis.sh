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
testcluster=testcluster

mkdir logs

gcloud container clusters get-credentials $testcluster --zone $testzone --project $testproject 

# Get cluster details
gcloud container clusters describe $testcluster | grep "zone: \|initialNodeCount:\|machineType:\|diskSize\|diskType\|nodePools:" > logs/clusterDetails.txt

# Deploy container
kubectl apply -f $testcontainer
bash $testsetupscript

# Get ip address of container service being tested
# Have to wait for ip address to be available:
echo "Waiting for external IP"

while true; do
    if [ $(kubectl describe svc $testservicename | grep "LoadBalancer Ingress" | wc -l) -ne 0 ]; then
        testip=$(kubectl describe svc $testservicename | grep "LoadBalancer Ingress" | awk '{print substr($0, 27)}')
        break
    fi
done
# Port can be input manually, as it's hard to extract. Defaults to 80

# Deploy job trace on pinging container
gcloud container clusters get-credentials $pingcluster --zone $pingzone --project $pingproject 
   
# Make config map for pinging
kubectl delete configmap ping-config
kubectl create configmap ping-config --from-literal=PINGTIME=${tracetime} --from-literal=IPTARGET=${testip} --from-literal=PORTTARGET=${testport}
kubectl apply -f $pingcontainer

# Collect job trace from pinging container
# gcloud container clusters get-credentials $pingcluster --zone $pingzone --project $pingproject 
echo "Waiting for DONE in all ping logs"

while true; do
    PODS=$(kubectl get pods | grep ${pinglabel} | awk '{print $1}')
    breaking="Yes"
    for POD in ${PODS}; do
      if  [[ $(kubectl logs ${POD} --tail 1) != *"DONE"* ]]
      then
        breaking="No"
      fi
    done
    if [[ $breaking == "Yes" ]]
    then
      break
    fi
  done

kubectl logs -l name=$pinglabel > logs/pinglogs.txt

# Destroy container and pinging container
kubectl delete -f $pingcontainer
gcloud container clusters get-credentials $testcluster --zone $testzone --project $testproject
kubectl delete -f $testcontainer
kubectl delete svc $testservicename

# Add to csv
python3 logsToCSV.py
rm logs/clusterDetails.txt
rm logs/pinglogs.txt

# Print analysis and suggested cluster configuration