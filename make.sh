#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")"

# build images
docker build --tag mamachanko/make-anything-init-container init-container
docker build --tag mamachanko/make-anything-container container

# push images
docker push mamachanko/make-anything-init-container
docker push mamachanko/make-anything-container

# resolve images
# build package
mkdir -p build/package
cp -R package build
ytt \
  --file build/package |
  kbld \
    --file - \
    --imgpkg-lock-output build/package/.imgpkg/images.yml

# push package
imgpkg push \
  --file build/package \
  --bundle mamachanko/make-anything-package

# build package repository
mkdir -p build/package-repository
cp -R package-repository build
ytt \
  --file build/package-repository |
  kbld \
    --file - \
    --imgpkg-lock-output build/package-repository/.imgpkg/images.yml

# push package repository
imgpkg push \
  --file build/package-repository \
  --bundle mamachanko/make-anything-package-repository
