#!/bin/bash

redtext() {
  echo -e "\033[0;31m$1\033[0m"
}

# $1: glob
# $2: config
# $3: base_dir or files
sync_and_run_vale() {
  set -x
  vale sync
  vale --glob="$1" --config="$2" "$3"
  set +x
}

VALE_EVAL_CLI_CONFIG="$(eval echo "$VALE_EVAL_CLI_CONFIG")"
VALE_STR_CLI_GLOB="$(circleci env subst "$VALE_STR_CLI_GLOB")"
VALE_STR_REFERENCE_BRANCH="$(circleci env subst "$VALE_STR_REFERENCE_BRANCH")"

VALE_EVAL_CLI_BASE_DIR="$(eval echo "$VALE_EVAL_CLI_BASE_DIR")"
VALE_EVAL_CLI_BASE_DIR="${VALE_EVAL_CLI_BASE_DIR/\~/$HOME}"

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

if [[ "$VALE_ENUM_STRATEGY" == "all" ]]; then
  sync_and_run_vale "$VALE_STR_CLI_GLOB" "$VALE_EVAL_CLI_CONFIG" "$VALE_EVAL_CLI_BASE_DIR"
elif [[ "$VALE_ENUM_STRATEGY" == "modified" ]]; then
  echo "Installing git..."
  command -v git &>/dev/null || { apk add git; }

  echo "Checking for modified files..."
  modified_files="$(git diff --name-only "$VALE_STR_REFERENCE_BRANCH")"
  files_space_delimited="$(echo "$modified_files" | tr '\n' ' ')"

  echo "Running vale on modified files..."
  sync_and_run_vale "$VALE_STR_CLI_GLOB" "$VALE_EVAL_CLI_CONFIG" "$files_space_delimited"
else
  echo "Invalid strategy: $VALE_ENUM_STRATEGY"
  exit 1
fi
