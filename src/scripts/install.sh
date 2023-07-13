#!/bin/bash

ORB_STR_CLI_VERSION=$(circleci env subst "$ORB_STR_CLI_VERSION")


# set smart sudo
if [[ $EUID == 0 ]]; then export SUDO=""; else export SUDO="sudo"; fi

if [[ -z "$ORB_STR_CLI_VERSION" ]]; then
  echo "No version specified, using latest..."
  export ORB_STR_CLI_VERSION="latest"
fi

if [[ $ORB_STR_CLI_VERSION == "latest" ]]; then
  ORB_STR_CLI_VERSION=$(curl -sSL https://api.github.com/repos/errata-ai/vale/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
  export ORB_STR_CLI_VERSION
fi

# sanitize version
ORB_STR_CLI_VERSION=${ORB_STR_CLI_VERSION//v}

# consts
GZIPPED_OUTPUT="vale.tar.gz"

# install vale

echo "Installing vale version ${ORB_STR_CLI_VERSION}..."
curl -sSL "https://github.com/errata-ai/vale/releases/download/v${ORB_STR_CLI_VERSION}/vale_${ORB_STR_CLI_VERSION}_Linux_64-bit.tar.gz" -o "${GZIPPED_OUTPUT}"
# Check if the downloaded file is empty
if [ ! -s "${GZIPPED_OUTPUT}" ]; then
    echo "Downloaded file is empty"
    rm "${GZIPPED_OUTPUT}"
    exit 1
fi

tar -xzf "${GZIPPED_OUTPUT}"
$SUDO mv vale /usr/local/bin
rm "${GZIPPED_OUTPUT}"

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
