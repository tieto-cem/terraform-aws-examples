#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 ]] ; then
    echo 'Usage: create-backend aws-profile'
    exit 1
fi

export AWS_PROFILE=$1
export TF_IN_AUTOMATION=true

#----------------------------------------------------------------------------------------------------------------------
# Create
# - Terraform backend
# - Terraform backend configuration file for each infrastructure module (shared, backend, frontend)
# - shared state reference configuration file for frontend and backend modules
# - copy configuration files under module folders
#-------------------------------------------------------------

cd terraform-backend-infra

terraform init
terraform apply -auto-approve

# Copy module specific state configuration file to corresponding module folder

cd configurations

cp frontend-state.tf  ../../app-frontend-infra
cp backend-state.tf   ../../app-backend-infra
cp shared-state.tf    ../../app-shared-infra

# Copy parent state reference configuration file to child modules

cp shared-state-ref.tf ../../app-backend-infra
cp shared-state-ref.tf ../../app-frontend-infra
