#!/usr/bin/env bash

# !! Tiller & cert-manager take time, be patient

# Fail whole script on any error
set -eu

# Debug info
currentContext="$(kubectl config current-context)"
echo "Strapping '$currentContext' cluster"

# Addons
## Nginx Ingress Controller [Typhoon specific?]
echo "Fetching latest Typhoon add-on version"
if [ ! -d "typhoon" ]; then
    git clone https://github.com/poseidon/typhoon.git
else
    cd typhoon
    git fetch --all
    git reset --hard origin/master
    cd -
fi
echo "Setting up Nginx Ingress Controller"
kubectl apply -R -f typhoon/addons/nginx-ingress/digital-ocean

## Tiller [Helm server]
echo "Setting up Helm"
kubectl apply -f tiller-rbac.yaml
### --wait flag should keep the command running until the Tiller pods are up
### This tends to be very slow
helm init --wait --service-account tiller

## NFS Share object
echo "Setting up personal NFS share"
kubectl apply -f nfs.yaml

## SSL certificate resource definitions & manager
echo "Setting up SSL certificate infrastructure"
### Create the custom resource definition (CRD) of the following:
### "Certificate", "Challange", "ClusterIssuer",  "Issuer", "Order"
kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.8/deploy/manifests/00-crds.yaml
kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.8/deploy/manifests/01-namespace.yaml

### Wait for CRDs to apply
sleep 2s

### Add Jetstack as a Helm repository
helm repo add jetstack https://charts.jetstack.io

### Install cert-manager w/ Helm 
helm install --wait --name cert-manager --namespace cert-manager jetstack/cert-manager --version v0.8.0 

### Workaround to allow anonymous requesters do SSL requests
kubectl apply -f ssl-permission-workaround.yaml

### Staging & production LetsEncrypt SSL cert issuers
kubectl apply -f ssl-issuers.yaml

## K8s Dashboard
kubectl apply -f dashboard-admin.yaml
kubectl apply -f dashboard-certificate.yaml
helm install --wait -f dashboard-cfg.yaml --name dashy-mc-dash --namespace kube-system stable/kubernetes-dashboard
