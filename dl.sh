#!/bin/bash

#run hsl production dataload immediately like this: ./dl.sh hsl-prod
SERVICE='otp-data-builder-'$1
TARGET='roles/aks-apply/files/dev/'$SERVICE'-dev.yml'
HOUR=$(date -u +"%H")
MIN=$(date -u +"%M")
MIN=$((MIN + 5))
echo launching dataload at "$HOUR:$MIN"
GO='schedule: "'"$MIN $HOUR * * *"'"'
sed -i -e "s/schedule.*/$GO/" $TARGET
ansible-playbook play_apply_manifests.yml -e @env_vars/dev.yml -e service=$SERVICE
sleep 5000
git checkout $TARGET
ansible-playbook play_apply_manifests.yml -e @env_vars/dev.yml -e service=$SERVICE
