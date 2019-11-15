#!/bin/bash

if [ -v NLS_API_TOKEN ]; then
    echo "NLS_API_TOKEN env variable found."
else
    echo "NLS_API_TOKEN env variable is not set. Exiting."
    exit 1
fi

if [ -v TEST ] && [ $TEST = true ]; then
    echo "Env variable TEST has value true. Running test run."
    bash download_and_optimize_dem_data.sh
    exit 0
fi

if [ -v AREA_CODE ] && [ -v CLIPPER ]; then
    echo "Env variable AREA_CODE=${AREA_CODE} found. Env variable CLIPPER=${CLIPPER} found."
    bash download_and_optimize_dem_data.sh $AREA_CODE $CLIPPER
    exit 0
elif [ -v AREA_CODE ] && [ ! -v CLIPPER ]; then
    echo "Env variable AREA_CODE=${AREA_CODE} found. No Env variable CLIPPER found. Downloading and optimizing tiles without clipping to area extent."
    bash download_and_optimize_dem_data.sh $AREA_CODE
    exit 0
fi
