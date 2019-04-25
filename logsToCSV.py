import numpy as np
import pandas as pd
import os

logs = open('logs/pinglogs.txt', 'r').read().splitlines()
cluster_details = open('logs/clusterDetails.txt', 'r').read().splitlines()

inputs = []
response_times = []
diskSize = []
diskType = []
machineType = []
nodeCount = []
zone = ""

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

data = np.asarray([inputs, response_times, [diskSize for _ in range(len(inputs))],
 [diskType for _ in range(len(inputs))],  [machineType for _ in range(len(inputs))],
  [nodeCount for _ in range(len(inputs))],  [zone for _ in range(len(inputs))]])

data = {"Inputs": inputs,
        "ResponseTimes": response_times,
        "DiskSize": diskSize*len(inputs),
        "DiskType": diskType*len(inputs),
        "MachineType": machineType*len(inputs),
        "NodeCount": nodeCount*len(inputs),
        "Zone": [zone for _ in range(len(inputs))]}

df = pd.DataFrame(data)

if (os.path.isfile('./data.csv')):
        df = pd.concat([df, pd.read_csv('./data.csv')])
df.to_csv('./data.csv', index=False)