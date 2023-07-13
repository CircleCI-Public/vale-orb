#!/bin/bash

redtext() {
  echo -e "\033[0;31m$1\033[0m"
}

base_dir="${CIRCLE_WORKING_DIRECTORY/\~/$HOME}"
config_path="$(eval echo "$ORB_STR_CLI_CONFIG")"
glob="$(circleci env subst "$ORB_STR_CLI_GLOB")"

if [[ ! -f "$config_path" ]]; then
  redtext "No configuration file found at $config_path"
  echo "To get started, you'll need a configuration file (.vale.ini)"
  echo "Create a config file, or modify the 'config' parameter for this job"
  echo "Example:"
  echo '
    - vale/lint:
        config: .github/vale.ini
  '
  exit 1
fi
set -x
vale sync
vale --glob="$glob" --config="$config_path" "$base_dir"
set +x
