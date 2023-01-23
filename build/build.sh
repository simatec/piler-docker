#!/bin/bash

# Path Settings
buildPth=`pwd`

cd $buildPth

# chmod start.sh
chmod a+x start.sh

# build config load
. ./build.conf

# set Piler Version
#sed -i 's/PILER_VERSION=.*/PILER_VERSION="'$PILER_VERSION'"/g' ../piler.conf

# set Maria-DB Version
#sed -i 's/MARIA_DB_VERSION=.*/MARIA_DB_VERSION="'$MARIA_DB_VERSION'"/g' ../piler.conf


# Package Download
rm -f $buildPth/*.deb

curl -OL https://bitbucket.org/jsuto/piler/downloads/$PILER_PACKAGE

set -o errexit
set -o pipefail
set -o nounset

IMAGE_NAME="simatec/piler:$PILER_VERSION"

if [ ! -f $buildPth/$PILER_PACKAGE ]; then 
    echo "ERROR: missing package name" 1>&2; exit 1; 
fi

docker build --build-arg PACKAGE="$PILER_PACKAGE" -t "$IMAGE_NAME" .
exit 0
