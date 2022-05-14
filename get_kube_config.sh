#!/bin/bash

terraform output kubeconfig | tr -d '"' | base64 -d > lke-cluster-config.yaml

export KUBECONFIG=lke-cluster-config.yaml

kubectl config get-contexts

kubectl get nodes