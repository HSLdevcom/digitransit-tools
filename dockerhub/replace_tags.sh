#!/bin/bash

# this works for removing opentripplanner-data-container
# and hsl-timetable-container images
ORG=${ORG:-hsldevcom}
FULL_IMAGE_PATH=$ORG/$IMAGE
startdate=$START
enddate=$END
minimalimage=hsldevcom/minimal-image
docker pull $minimalimage
d=
n=0
until [ "$d" = "$enddate" ]
do  
    ((n++))
    d=$(date -d "$startdate + $n days" +%Y-%m-%d)
    imageforday=$FULL_IMAGE_PATH:$d-$TAG
    echo $imageforday
    docker tag $minimalimage $imageforday
    docker push $imageforday
done
