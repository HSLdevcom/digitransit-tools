#!/bin/bash

#compute average time of responses of a proxy log for desired api path
#an example: ./avgresponse.sh digitransit-proxy-6d856c4548-d8f8m  geocoding/v1/search

kubectl logs $1 > log.txt
tail -500 log.txt > logtail.txt
cat logtail.txt | grep $2 | grep -oE '[^ ]+$' > log2.txt
SUM=$(paste -sd+ log2.txt | bc)
COUNT=$(cat log2.txt | wc -l)
rm log.txt logtail.txt log2.txt
echo "$SUM/$COUNT" | bc -l
