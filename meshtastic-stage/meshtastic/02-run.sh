#!/bin/bash
set -e

apt update && apt install -y curl jq

VERSION=${1:-prerelease}

if [ "$VERSION" == "latest" ]; then
    echo "Fetching latest release"
elif [ "$VERSION" == "prerelease" ]; then
    echo "Fetching latest prerelease"
else
    echo "Fetching release $VERSION"
fi

RELEASES=$(curl -s -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/meshtastic/firmware/releases)

if [ -z "$RELEASES" ]; then
    echo "Failed to fetch releases"
    exit 1
fi

if [ "$VERSION" == "latest" ]; then
    RELEASE=$(curl -s -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/meshtastic/firmware/releases/latest)
elif [ "$VERSION" == "prerelease" ]; then
    RELEASE=$(echo $RELEASES | jq -r '.[0] | select(.prerelease == true and .draft == false) | .')
else
    RELEASE=$(echo $RELEASES | jq -r '.[0] | select(.tag_name == "'$VERSION'")')
fi

if [ -z "$RELEASE" ]; then
    echo "Failed to fetch release"
    exit 1
else
    echo "RELEASE: $RELEASE"
fi

BINARY_PACKGE_ASSET=$(echo $RELEASE | jq -r '.assets[] | select(.content_type == "application/vnd.debian.binary-package")')
echo "BINARY_PACKGE_ASSET: $BINARY_PACKGE_ASSET"

ASSET_NAME=$(echo $BINARY_PACKGE_ASSET | jq -r '.name')
echo "ASSET_NAME $ASSET_NAME"

ASSET_URL=$(echo $BINARY_PACKGE_ASSET | jq -r '.browser_download_url')
echo "ASSET_URL $ASSET_URL"
FILE_NAME=meshtasticd_arm64.deb

curl -L -o $FILE_NAME $ASSET_URL

# list versions of libyaml-cpp-dev
apt-cache madison libyaml-cpp-dev

# list versions of libulfius-dev
apt-cache madison libulfius-dev

apt install -y -f libyaml-cpp-dev || true
apt install -y -f libulfius-dev || true
apt --fix-broken install -y || true

# apt install -y -f ./$FILE_NAME
dpkg -i $FILE_NAME --force-depends

apt clean
