#!/bin/bash

# set smart sudo
if [[ $EUID == 0 ]]; then export SUDO=""; else export SUDO="sudo"; fi
const releases = 'https://github.com/errata-ai/vale/releases/download';

if [[ $ORB_STR_CLI_VERSION == "latest" ]]; then
  ORB_STR_CLI_VERSION=$(curl -sSL https://api.github.com/repos/errata-ai/vale/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
  export ORB_STR_CLI_VERSION
fi

# sanitize version
ORB_STR_CLI_VERSION=${ORB_STR_CLI_VERSION//v}

curl -sSL "https://github.com/errata-ai/vale/releases/download/v${ORB_STR_CLI_VERSION}/vale_${ORB_STR_CLI_VERSION}_Linux_64-bit.tar.gz" -o vale.tar.gz
tar -xzf vale.tar.gz
$SUDO mv vale /usr/local/bin
rm vale.tar.gz

# validate installation
COMMAND_PATH=$(command -v vale)
if [[ -z "$COMMAND_PATH" ]]; then
  echo "vale installation failed"
  exit 1
else
  echo "vale installation successful"
  vale --version
  exit 0
fi
