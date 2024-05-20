#!/bin/bash
set -e

apt update && apt install -y jq

LATEST_RELEASE=$(curl -s -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/meshtastic/firmware/releases/latest | jq -r '.')
echo "LATEST_RELEASE: $LATEST_RELEASE"

BINARY_PACKGE_ASSET=$(echo $LATEST_RELEASE | jq -r '.assets[] | select(.content_type == "application/vnd.debian.binary-package")')
echo "BINARY_PACKGE_ASSET: $BINARY_PACKGE_ASSET"

ASSET_NAME=$(echo $BINARY_PACKGE_ASSET | jq -r '.name')
echo "ASSET_NAME $ASSET_NAME"

ASSET_URL=$(echo $BINARY_PACKGE_ASSET | jq -r '.browser_download_url')
echo "ASSET_URL $ASSET_URL"
FILE_NAME=meshtasticd_arm64.deb

curl -L -o $FILE_NAME $ASSET_URL
apt install -y -f libyaml-cpp0.7
apt install -y -f libulfius2.7
apt install -y -f ./$FILE_NAME

apt clean
