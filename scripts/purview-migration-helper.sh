#!/bin/bash
# Helper script for migration resources under Azure Purview account. This script requires purviewcli & jq.

# Prints usage of this script
function usage() {
cat <<EOF
Usage:
  export_resources "Purview CLI command and parameters" "Directory path to export payload"
EOF
return 0
}

# Exports specified resources with Purview CLI
function export_resources() {
  local -r purviewcli_req="${1}"
  local -r payload_dir="${2}"

  local -r purviewcli_res=$(eval "${purviewcli_req}")
  local -r num_of_array_elements=$(echo "${purviewcli_res}" | jq '.value | length')

  echo "Purview CLI's response:"
  echo ${purviewcli_res} | jq
  if [ ${num_of_array_elements} -eq 0 ]; then
    echo "The number of array elements is 0, skip the following process."
    return 0
  fi

  mkdir -p "${payload_dir}"

  for ((i = 0; i < ${num_of_array_elements}; i++)); do
    local payload_file_name=$(echo ${purviewcli_res} | jq -r --argjson i $i '.value[$i].name')
    local payload_file="${payload_dir}/${payload_file_name}.json"
    local payload_json=$(echo ${purviewcli_res} | jq -r --argjson i $i '.value[$i]')
    echo "${payload_json}" > "${payload_file}" && echo "Created: ${payload_file}"
  done

  return 0
}