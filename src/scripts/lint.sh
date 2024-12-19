#!/bin/sh

redtext() {
  echo -e "\033[0;31m$1\033[0m"
}

# $1: glob
# $2: config
# $3: files
sync_and_run_vale() {
  set -x
  vale sync
  # shellcheck disable=SC2086
  vale --glob="$1" --config="$2" $3  # No quotes around $3
  set +x
}

VALE_EVAL_CLI_CONFIG="$(eval echo "$VALE_EVAL_CLI_CONFIG")"
VALE_STR_CLI_GLOB="$(circleci env subst "$VALE_STR_CLI_GLOB")"
VALE_STR_REFERENCE_BRANCH="$(circleci env subst "$VALE_STR_REFERENCE_BRANCH")"

VALE_EVAL_CLI_BASE_DIR="$(eval echo "$VALE_EVAL_CLI_BASE_DIR")"
VALE_EVAL_CLI_BASE_DIR="${VALE_EVAL_CLI_BASE_DIR/\~/$HOME}"

if [ ! -f "$VALE_EVAL_CLI_CONFIG" ]; then
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

if [ "$VALE_ENUM_STRATEGY" = "all" ]; then
  sync_and_run_vale "$VALE_STR_CLI_GLOB" "$VALE_EVAL_CLI_CONFIG" "$VALE_EVAL_CLI_BASE_DIR"
elif [ "$VALE_ENUM_STRATEGY" = "modified" ]; then
  echo "Installing git..."
  command -v git > /dev/null 2>&1 || { apk add git; }

  echo "Checking for modified files..."
  set -x
  REGEX="^$VALE_EVAL_CLI_BASE_DIR/"
  FILES=()
  while read -r file; do
      if [[ "$file" =~ $REGEX || "$VALE_EVAL_CLI_BASE_DIR" = "." || "$VALE_EVAL_CLI_BASE_DIR" = "$PWD" ]]; then
          FILES+=("$file")
      fi
  done <<EOF
  $(git diff --name-only --diff-filter=d "$VALE_STR_REFERENCE_BRANCH")
EOF
  
  echo "${FILES[@]}"
  # modified_files="$(git diff --name-only --diff-filter=d "$VALE_STR_REFERENCE_BRANCH")"
  # echo "$modified_files"

  # modified_files_space_separated=$(echo "$modified_files" | tr '\n' ' ')
  echo "Running vale on modified files..."
  sync_and_run_vale "$VALE_STR_CLI_GLOB" "$VALE_EVAL_CLI_CONFIG" "${FILES[@]}"
else
  echo "Invalid strategy: $VALE_ENUM_STRATEGY"
  exit 1
fi
