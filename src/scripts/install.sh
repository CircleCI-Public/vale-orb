#!/bin/bash

VALE_STR_CLI_VERSION="$(circleci env subst "$VALE_STR_CLI_VERSION")"

# set smart sudo
if [[ $EUID -eq 0 ]]; then export SUDO=""; else export SUDO="sudo"; fi

if [[ -z "$VALE_STR_CLI_VERSION" ]]; then
  echo "No version specified, using latest..."
  export VALE_STR_CLI_VERSION="latest"
fi

if [[ $VALE_STR_CLI_VERSION == "latest" ]]; then
  VALE_STR_CLI_VERSION=$(curl -sSL https://api.github.com/repos/errata-ai/vale/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
  export VALE_STR_CLI_VERSION
fi

# sanitize version
VALE_STR_CLI_VERSION=${VALE_STR_CLI_VERSION//v/}

# Define current platform
if [[ "$(uname -s)" == "Darwin" && "$(uname -m)" == "x86_64" ]]; then
  if [[ "$(uname -m)" == "arm64" ]]; then
    export SYS_ENV_PLATFORM=macos_arm
  else
    export SYS_ENV_PLATFORM=macos
  fi
elif [[ "$(uname -s)" == "Linux" && "$(uname -m)" == "x86_64" ]]; then
  export SYS_ENV_PLATFORM=linux_x86
elif [[ "$(uname -s)" == "Linux" && "$(uname -m)" == "aarch64" ]]; then
  export SYS_ENV_PLATFORM=linux_arm
else
  echo "This platform appears to be unsupported."
  uname -a
  exit 1
fi

# consts
GZIPPED_OUTPUT="vale.tar.gz"

# Get binary url
if ! command -v gh >/dev/null 2>&1; then
  echo "Installing Vale version ${VALE_STR_CLI_VERSION}..."
  case $SYS_ENV_PLATFORM in
  linux_x86)
    BINARY_URL="https://github.com/errata-ai/vale/releases/download/v${VALE_STR_CLI_VERSION}/vale_${VALE_STR_CLI_VERSION}_Linux_64-bit.tar.gz"
    ;;
  linux_arm)
    BINARY_URL="https://github.com/errata-ai/vale/releases/download/v${VALE_STR_CLI_VERSION}/vale_${VALE_STR_CLI_VERSION}_Linux_arm64.tar.gz"
    ;;
  macos)
    BINARY_URL="https://github.com/errata-ai/vale/releases/download/v${VALE_STR_CLI_VERSION}/vale_${VALE_STR_CLI_VERSION}_macOS_64-bit.tar.gz"
    ;;
  macos_arm)
    BINARY_URL="https://github.com/errata-ai/vale/releases/download/v${VALE_STR_CLI_VERSION}/vale_${VALE_STR_CLI_VERSION}_macOS_arm64.tar.gz"
    ;;
  *)
    echo "This orb does not currently support your platform. If you believe it should, please consider opening an issue on the GitHub repository:"
    echo "https://github.com/CircleCI-Public/vale-orb"
    exit 1
    ;;
  esac
fi
# install vale
curl -sSL "$BINARY_URL" -o "${GZIPPED_OUTPUT}"
if [ ! -s "${GZIPPED_OUTPUT}" ]; then
  echo "Downloaded file is empty"
  rm "${GZIPPED_OUTPUT}"
  exit 1
fi

tar -xzf "${GZIPPED_OUTPUT}"
$SUDO mv vale /usr/local/bin
rm "${GZIPPED_OUTPUT}"

# validate installation
if [[ -z "$(command -v vale)" ]]; then
  echo "vale installation failed"
  exit 1
else
  echo "vale installation successful"
  vale --version
  exit 0
fi
