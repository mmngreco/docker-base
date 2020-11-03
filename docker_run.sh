#!/bin/bash
CDIR=$(cd "$(dirname "$0")"; pwd -P)
. $CDIR/variables.sh

UUID="$(uuidgen)"
CONTAINER_NAME="base-${UUID:0:7}"
DIR=$PWD

docker run \
    --env SSH_PUBLIC_KEY="$SSH_PUBLIC_KEY" \
    --env SSH_PRIVATE_KEY="$SSH_PRIVATE_KEY" \
    --env CONFIG_INI="$CONFIG_INI" \
    --name $CONTAINER_NAME \
    --volume $(pwd):/ETS/git/$(basename $DIR) \
    --interactive \
    --tty \
    $IMAGE_NAME
