#!/bin/bash

REGION="eu-west-1"

if [[ $# -ne 1 ]]; then
    echo "Please enter only 1 argument. Example: switchEKSCluster.sh <cluster-name>"
    exit 1
fi

aws eks update-kubeconfig --name $1 --region $REGION
