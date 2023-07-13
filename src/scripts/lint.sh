#!/bin/bash

redtext() {
  echo -e "\033[0;31m$1\033[0m"
}

if [[ ! -f "$ORB_STR_CLI_CONFIG" ]]; then
  redtext "No configuration file found at $ORB_STR_CLI_CONFIG"
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
vale --glob "$ORB_STR_CLI_GLOB" --config "$ORB_STR_CLI_CONFIG"
set +x
