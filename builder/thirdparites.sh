#!/bin/bash
set -e

export CMAKE_VERSION=4.4.3
export NODE_VERSION=26.8.2
export GO_VERSION=1.26.8

mkdir -p lib
cd lib
wget "https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-x86_64.sh"
wget "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz"
wget "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"

shasum -a 256 -c - <<EOF
6decbd2f268e48ed405c5b40563b0334c903209e61fe4ecad460b00c60b27e79  cmake-${CMAKE_VERSION}-linux-x86_64.sh
40e1d3225c1c9ae9a2671c98ecb9857e4d5555026394f348645676798840d5c5  node-v${NODE_VERSION}-linux-x64.tar.xz
d0f743b33e8d8945e6b1f432edd15785c70507121d6e2a723b21285eddf8b57b  go${GO_VERSION}.linux-amd64.tar.gz
EOF
