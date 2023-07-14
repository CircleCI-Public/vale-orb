#!/bin/bash

redtext() {
  echo -e "\033[0;31m$1\033[0m"
}

VALE_EVAL_CLI_CONFIG="$(eval echo "$VALE_EVAL_CLI_CONFIG")"
VALE_STR_CLI_GLOB="$(circleci env subst "$VALE_STR_CLI_GLOB")"
VALE_EVAL_CLI_BASE_DIR="$(eval echo "$VALE_EVAL_CLI_BASE_DIR")"

if [[ ! -f "$VALE_EVAL_CLI_CONFIG" ]]; then
  redtext "No configuration file found at $VALE_EVAL_CLI_CONFIG"
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
vale --glob="$VALE_STR_CLI_GLOB" --config="$VALE_EVAL_CLI_CONFIG" "$VALE_EVAL_CLI_BASE_DIR"
set +x
