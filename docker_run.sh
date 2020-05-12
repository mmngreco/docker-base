#!/bin/bash
IMAGE_NAME="etsgit1.ets.es:5005/com/docker-base"
UUID="$(uuidgen)"
CONTAINER_NAME="base-${UUID:0:7}"

# ENV variables
SSH_PRIVATE_KEY="$(cat ~/.ssh/id_rsa)"
SSH_PUBLIC_KEY="$(cat ~/.ssh/id_rsa.pub)"
CONFIG_INI="$(cat /ETS/configs/config.ini)"
APT_LIST=""

echo CONTAINER_NAME: $CONTAINER_NAME
docker run \
    --env SSH_PUBLIC_KEY="$SSH_PUBLIC_KEY" \
    --env SSH_PRIVATE_KEY="$SSH_PRIVATE_KEY" \
    --env CONFIG_INI="$CONFIG_INI" \
    --name $CONTAINER_NAME \
    --volume $(pwd):/ETS/git/$(basename $PWD) \
    -it $IMAGE_NAME
