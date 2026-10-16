#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

# Path Settings
buildPth="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$buildPth"

# build config load
. ./build.conf

# The Piler package is downloaded and verified inside the Dockerfile.
# Same image name as used in config/piler-default.yml and config/piler-ssl.yml
IMAGE_NAME="${IMAGE_NAME:-piler-docker/piler:$PILER_VERSION}"

docker buildx build --load -t "$IMAGE_NAME" .
exit 0
