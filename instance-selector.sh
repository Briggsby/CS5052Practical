# Set variables

# Make ping cluster

# For each set of test clusters / while optimal test cluster not found

    # Make test cluster

    # Get baseline logs (CPU and Memory load)

    # Deploy container

    # Deploy job trace on pinging container

    # While job trace ongoing
    
        # Get logs of CPU and memory load

    # Collect job trace from pinging container

    # Destroy container and pinging container

    # Destroy test cluster

    # Analyse logs to choose next test cluster, or stop if stopping condition met

# Print analysis and suggested cluster configuration