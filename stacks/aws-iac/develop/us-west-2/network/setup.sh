#!/usr/bin/env bash

set -euo pipefail

# Export TF_VARs based on path:
# /workspaces/aws-labs-with-terraform/stacks/<project>/<env>/<region>/<stack>

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
stack_dir="$(dirname -- "$script_dir")"
region_dir="$(dirname -- "$stack_dir")"
env_dir="$(dirname -- "$region_dir")"
project_dir="$(dirname -- "$env_dir")"

region="$(basename -- "$region_dir")"
env="$(basename -- "$env_dir")"
project="$(basename -- "$project_dir")"

export TF_VAR_region="$region"
export TF_VAR_env="$env"
export TF_VAR_project="$project"

echo "Exported TF_VAR_region=$TF_VAR_region"
echo "Exported TF_VAR_env=$TF_VAR_env"
echo "Exported TF_VAR_project=$TF_VAR_project"
