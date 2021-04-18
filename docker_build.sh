#!/bin/bash
. ./variables.sh
echo IMAGE_NAME: $IMAGE_NAME

docker build \
    --build-arg SSH_PRIVATE_KEY="$SSH_PRIVATE_KEY" \
    --build-arg SSH_PUBLIC_KEY="$SSH_PUBLIC_KEY" \
    --build-arg CONFIG_INI="$CONFIG_INI" \
    --build-arg APT_LIST="$APT_LIST" \
    --build-arg PY_VER="$PY_VER" \
    --tag "$IMAGE_NAME" \
    --squash \
    .
