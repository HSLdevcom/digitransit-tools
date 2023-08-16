#!/bin/bash

#run hsl production dataload immediately like this: ./dl.sh hsl-prod
#run pelias production dataload like this: ./dl.sh prod pelias-data-container
LOADER=${2:-'otp-data'}
SERVICE=$LOADER-builder-$1
TARGET='roles/aks-apply/files/dev/'$SERVICE'-dev.yml'
HOUR=$(date +"%H")
MIN=$(date +"%M")
MIN=$((MIN + 2))
if [$MIN -gt 59]
then
    MIN=1
    HOUR=$((HOUR + 1))
fi
if [$HOUR -gt 23]
then
    HOUR=0
fi

echo launching dataload at "$HOUR:$MIN"
GO='schedule: "'"$MIN $HOUR * * *"'"'
sed -i -e "s/schedule.*/$GO/" $TARGET
ansible-playbook play_apply_manifests.yml -e @env_vars/dev.yml -e service=$SERVICE
sleep 5000
git checkout $TARGET
ansible-playbook play_apply_manifests.yml -e @env_vars/dev.yml -e service=$SERVICE
