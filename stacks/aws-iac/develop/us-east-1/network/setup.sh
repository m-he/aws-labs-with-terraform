#!/usr/bin/env bash

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
component_dir="$(dirname -- "$script_dir")"
region_dir="$(dirname -- "$component_dir")"
env_dir="$(dirname -- "$region_dir")"

component="$(basename -- "$script_dir")"
region="$(basename -- "$component_dir")"
env="$(basename -- "$region_dir")"
project="$(basename -- "$env_dir")"

export TF_VAR_component="$component"
export TF_VAR_region="$region"
export TF_VAR_env="$env"
export TF_VAR_project="$project"

echo "Exported TF_VAR_component=$TF_VAR_component"
echo "Exported TF_VAR_region=$TF_VAR_region"
echo "Exported TF_VAR_env=$TF_VAR_env"
echo "Exported TF_VAR_project=$TF_VAR_project"
