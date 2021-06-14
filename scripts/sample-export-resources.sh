#!/bin/bash
# Sample script to export Purview's resources with the migration helper script.

# Common constants for I/O
declare -r SCRIPT_DIR=$(cd $(dirname $0); pwd)
declare -r HELPER_SCRIPT="${SCRIPT_DIR}/purview-migration-helper.sh"
source "${HELPER_SCRIPT}"

# [Optional] Uncomment to load script for environment variables for Purview CLI (Note the script is not managed by Git because contains sensitive information such as secret)
# declare -r ENV_VAL_SCRIPT="${SCRIPT_DIR}/.env.sh"
# source "${ENV_VAL_SCRIPT}"

# Define payload base directory with PURVIEW_NAME in environment variable
declare -r PAYLOAD_BASE_DIR="${SCRIPT_DIR}/payloads/${PURVIEW_NAME}"

# Export references for Azure Key Vaults
export_resources "pv scan readKeyVaults" "${PAYLOAD_BASE_DIR}/keyvaults"

# Export credentials
export_resources "pv credential read" "${PAYLOAD_BASE_DIR}/credentials"

# Export data sources
export_resources "pv scan readDatasources" "${PAYLOAD_BASE_DIR}/datasources"

# Export scans of each data source
datasource_names=($(pv scan readDatasources | jq -r '.value[].name'))
for datasource_name in ${datasource_names[@]}; do
  export_resources "pv scan readScans --dataSourceName=${datasource_name}" "${PAYLOAD_BASE_DIR}/scans/${datasource_name}"
done