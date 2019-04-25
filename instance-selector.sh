# Set variables
baselinelogtime=10
testcontainer=exampleserver.yaml
pingcontainer=pingcontainer.yaml
testsetupscript=exampletestsetup.sh
testservicename=hello-web
testport=80
pingcluster=pingcluster
pingzone=europe-west1-b
testzone=europe-west1-b
pingproject=scenic-rampart-237010
testproject=$pingproject
tracetime=10

# For each set of test clusters / while optimal test cluster not found

    # Make test cluster
        # Variables: Zone, Number of nodes, Machine type

    # Get baseline logs (CPU and Memory load)
    kubectl top nodes > baseline.txt
    end=$((SECONDS+$baselinelogtime))
    while [$SECONDS -lt $end]; do
        kubectl top nodes >> baseline.txt
    done

    # Deploy container
    kubectl apply -f $testcontainer
    bash $testsetupscript

    # Get ip address of container service being tested
    # Have to wait for ip address to be available:
    while true; do
        if ($(kubectl describe svc $testservicename | grep "LoadBalancer Ingress") -ne 0); then
            testip=$(kubectl describe svc $testservicename | grep "LoadBalancer Ingress" | awk '{print substr($0, 27)}')
            break
        fi
    done
    # Port can be input manually, as it's hard to extract. Defaults to 80

    # Deploy job trace on pinging container
    # NEED TO GIVE IT IP ADDRESS OF TEST CONTAINER?
    gcloud container clusters get-credentials $pingcluster --zone $pingzone --project $pingproject 
    kubectl apply -f $pingcontainer

    gcloud container clusters get-credentials $testcluster --zone $testzone --project $testproject
    # While job trace ongoing get logs of CPU and memory load
    kubectl top nodes > tracetop.txt
    end=$((SECONDS+$tracetime))
    while [$SECONDS -lt $end]; do
        kubectl top nodes >> tracetop.txt
    done

    # Collect job trace from pinging container
    gcloud container clusters get-credentials $pingcluster --zone $pingzone --project $pingproject 
    kubectl logs -l name=$pinglabel > pinglogs.txt

    # Destroy container and pinging container
    kubectl delete -f $pingcontainer
    gcloud container clusters get-credentials $testcluster --zone $testzone --project $testproject
    kubectl delete -f $testcontainer

    # Destroy test cluster
    gcloud container clusters delete $testcluster

    # Analyse logs to choose next test cluster, or stop if stopping condition met
    python3 logAnalysis.py

# Print analysis and suggested cluster configuration