#!/bin/bash
# Sample script to import Purview's resources with Purview CLI. Please try this script after exporting payloads with atnoher sample script.

# [Required] Specify payload base directory
declare -r PAYLOAD_BASE_DIR="${1}"
if [ ! -d "${PAYLOAD_BASE_DIR}" ]; then
  echo "Payload base directory does not exist."
  exit 1
fi

# [Optional] Uncomment to load script for environment variables for Purview CLI (Note the script is not managed by Git because contains sensitive information such as secret)
# declare -r SCRIPT_DIR=$(cd $(dirname $0); pwd)
# declare -r ENV_VAL_SCRIPT="${SCRIPT_DIR}/.env.sh"
# source "${ENV_VAL_SCRIPT}"

# Import references for Azure Key Vaults
for keyvault_payload_file in $(find "${PAYLOAD_BASE_DIR}/keyvaults" -type f -name '*.json'); do
  keyvault_name=$(basename "${keyvault_payload_file}" .json)
  pv scan putKeyVault --keyVaultName="${keyvault_name}" --payload-file="${keyvault_payload_file}"
done

# Import credentials
for credential_payload_file in $(find "${PAYLOAD_BASE_DIR}/credentials" -type f -name '*.json'); do
  credential_name=$(basename "${credential_payload_file}" .json)
  pv credential put --credentialName="${credential_name}" --payload-file="${credential_payload_file}"
done

# Import data sources
# [Note] If you're using collections for datasources, you should create it in advance
for datasource_payload_file in $(find "${PAYLOAD_BASE_DIR}/datasources" -type f -name '*.json'); do
  datasource_name=$(basename "${datasource_payload_file}" .json)
  pv scan putDataSource --dataSourceName="${datasource_name}" --payload-file="${datasource_payload_file}"
done

# Import scans of each data source
# [Note] If you're using Self-Hosted Integration Runtime, you should create and make it online in advance
for scan_payload_file in $(find "${PAYLOAD_BASE_DIR}/scans" -type f -name '*.json'); do
  datasource_name=$(basename $(dirname "${scan_payload_file}"))
  scan_name=$(basename "${scan_payload_file}" .json)
  pv scan putScan --dataSourceName="${datasource_name}" --scanName="${scan_name}" --payload-file="${scan_payload_file}"

  # [Optional] Uncomment to run scan
  # pv scan runScan --dataSourceName="${datasource_name}" --scanName="${scan_name}"
done