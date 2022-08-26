#!/bin/bash

#compute average time of responses of a proxy log for desired api path
#an example: ./avgresponse.sh digitransit-proxy-6d856c4548-d8f8m  geocoding/v1/search

kubectl logs $1 | grep $2 | grep -oE '[^ ]+$' > log.txt
SUM=$(paste -sd+ log.txt | bc)
COUNT=$(cat log.txt | wc -l)
rm log.txt
echo "$SUM/$COUNT" | bc -l
