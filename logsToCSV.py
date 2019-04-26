import numpy as np
import pandas as pd
import os

logs = open('logs/pinglogs.txt', 'r').read().splitlines()
cluster_details = open('logs/clusterDetails.txt', 'r').read().splitlines()

# Due to time constraints just put this in a dictionary, specific
# to europe-west1-b shouldn't be hard to get this from the 
# user input file instead though
prices = {"f1-micro": 0.0086,
          "g1-small": 0.0285,
          "n1-standard-1": 0.0523,
          "n1-standard-2": 0.1046,
          "n1-standard-8": 0.4184,
          "n1-standard-16": 0.8368,
          "n1-standard-32": 1.6736,
          "n1-standard-64": 3.3472,
          "n1-standard-96": 5.0280,
          "n1-highcpu-2": 0.078,
          "n1-highcpu-8": 0.312}


inputs = []
response_times = []
diskSize = []
diskType = []
machineType = []
nodeCount = []
zone = ""
prices = []

for line in logs:
    if line != "DONE":
        split_line = line.split("\t")
        inputs.append(int(split_line[1].split('/')[1]))
        response_times.append(float(split_line[3]))

for line_index in range(len(cluster_details)):
    if cluster_details[line_index] == "nodePools:":
        diskSize.append(int(cluster_details[line_index+1].split(": ")[1]))
        diskType.append(cluster_details[line_index+2].split(": ")[1])
        machineType.append(cluster_details[line_index+3].split(": ")[1])
        nodeCount.append(int(cluster_details[line_index+4].split(": ")[1]))
    elif cluster_details[line_index].split(": ")[0] == "zone":
        zone=cluster_details[line_index].split(": ")[1]

data = {"Inputs": inputs,
        "ResponseTimes": response_times,
        "DiskSize": diskSize*len(inputs),
        "DiskType": diskType*len(inputs),
        "MachineType": machineType*len(inputs),
        "NodeCount": nodeCount*len(inputs),
        "Zone": [zone for _ in range(len(inputs))],
        "PriceHourlyPerNode": prices[machneType]*len(inputs)}

df = pd.DataFrame(data)

if (os.path.isfile('./data.csv')):
        df = pd.concat([df, pd.read_csv('./data.csv')])
df.to_csv('./data.csv', index=False)