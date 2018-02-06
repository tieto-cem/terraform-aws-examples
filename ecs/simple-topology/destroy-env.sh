#!/usr/bin/env bash

set -uo pipefail

if [[ $# -ne 2 ]] ; then
    echo 'Usage: destroy-env env aws-profile'
    exit 1
fi

ENVIRONMENT=$1

export AWS_PROFILE=$2
export TF_IN_AUTOMATION=true

for MODULE in app-frontend-infra app-backend-infra app-shared-infra; do

    cd $MODULE

    echo "Checking if workspace $MODULE exist"
    terraform workspace 'select' $ENVIRONMENT

    if [[ $? -eq 0 ]]; then
        echo "Destroying module $MODULE"
        terraform destroy -force
        echo "Switching to default workspace"
        terraform workspace 'select' default
        echo "Deleting workspace $ENVIRONMENT"
        terraform workspace delete $ENVIRONMENT
    else
        echo "Workspace doens't exist, skipping module $MODULE"
    fi
    cd ..
done
