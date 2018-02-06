#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 2 ]] ; then
    echo 'Usage: create-env env aws-profile'
    exit 1
fi

export ENVIRONMENT=$1
export AWS_PROFILE=$2

export TF_IN_AUTOMATION=true

for MODULE in app-shared-infra app-backend-infra app-frontend-infra; do

    echo "#-----------------------------------------------------"
    echo "#  Creating infrastructure module $MODULE             "
    echo "#-----------------------------------------------------"

    cd $MODULE
    terraform init
    terraform workspace new $ENVIRONMENT || true
    terraform apply -auto-approve
    cd ..

    echo "#-----------------------------------------------------"
    echo "#  Infrastructure module $MODULE created              "
    echo "#-----------------------------------------------------"
done