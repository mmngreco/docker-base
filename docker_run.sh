#!/bin/bash
. ./variables.sh
MODE=$1
UUID="$(uuidgen)"
CONTAINER_NAME="base-${UUID:0:7}"

docker run \
    --env SSH_PUBLIC_KEY="$SSH_PUBLIC_KEY" \
    --env SSH_PRIVATE_KEY="$SSH_PRIVATE_KEY" \
    --env CONFIG_INI="$CONFIG_INI" \
    --name $CONTAINER_NAME \
    --volume $(pwd):/ETS/git/$(basename $PWD) \
    --interactive \
    --tty \
    $IMAGE_NAME
