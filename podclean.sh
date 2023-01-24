#!/bin/bash

#kill failed and OOMKilled pods
#especially useful for cleaning failed dataloader pods in dev
kubectl get pods | grep Error | cut -d " " -f1 | xargs -L1 kubectl delete pod
kubectl get pods | grep OOMKilled | cut -d " " -f1 | xargs -L1 kubectl delete pod
