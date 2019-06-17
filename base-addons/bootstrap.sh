#!/usr/bin/env bash

# Debug info
currentContext="$(kubectl config current-context)"
echo "Strapping '$currentContext' cluster"

# Addons
## Nginx Ingress Controller [Typhoon specific?]
git clone https://github.com/poseidon/typhoon.git
kubectl apply -R -f typhoon/addons/nginx-ingress/digital-ocean

## Tiller [Helm server]
kubectl apply -f https://raw.githubusercontent.com/eclipse/che/master/deploy/kubernetes/helm/che/tiller-rbac.yaml
helm init --service-account tiller

## NFS Share
kubectl apply -f nfs.yaml
