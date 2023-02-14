#!/bin/bash

TARGET="DEBUG"
ARCH="X64"

if [ "$1" != "" ]; then
  TARGET=$1
  shift
fi

if [ "$1" != "" ]; then
  ARCH=$1
  shift
fi

echo "Rebuilding..."
ARCHS=(${ARCH})
TARGETS=(${TARGET})
pushd .
source ./build_duet.tool --skip-tests || exit 1
popd 1>/dev/null

echo "Done."
