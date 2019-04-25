# Set variables
baselinelogtime=10
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
tracetime=10
testcluster=testcluster


gcloud container clusters get-credentials $testcluster --zone $testzone --project $testproject 
# Get baseline logs (CPU and Memory load)
kubectl top nodes > baseline.txt

echo "Collecting baseline top logs"

end=$((SECONDS+$baselinelogtime))
while [ $SECONDS -lt $end ]; do
    kubectl top nodes >> baseline.txt
done

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

gcloud container clusters get-credentials $testcluster --zone $testzone --project $testproject
# While job trace ongoing get logs of CPU and memory load
echo "Collecting top logs while ping trace finishes"

end=$((SECONDS+$tracetime))
while [ $SECONDS -lt $end ]; do
    kubectl top nodes >> tracetop.txt
done

# Collect job trace from pinging container
gcloud container clusters get-credentials $pingcluster --zone $pingzone --project $pingproject 
echo "Waiting for DONE in ping logs"
while [[ $(kubectl logs -l name=${pinglabel} --tail 1) != *"DONE"* ]]; do
    sleep 1;
done
kubectl logs -l name=$pinglabel > pinglogs.txt

# Destroy container and pinging container
kubectl delete -f $pingcontainer
gcloud container clusters get-credentials $testcluster --zone $testzone --project $testproject
kubectl delete -f $testcontainer
kubectl delete svc $testservicename

# Analyse logs to choose next test cluster, or stop if stopping condition met
# python3 logAnalysis.py

# Print analysis and suggested cluster configuration