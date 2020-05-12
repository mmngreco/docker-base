#!/bin/bash
IMAGE_NAME="com:latest"
IMAGE_NAME="etsgit1.ets.es:5005/com/docker-base"
SSH_PRIVATE_KEY="$(cat ~/.ssh/id_rsa)"
SSH_PUBLIC_KEY="$(cat ~/.ssh/id_rsa.pub)"
CONFIG_INI="$(cat /ETS/configs/config.ini)"
# extra dependencies
APT_LIST=""

echo IMAGE_NAME: $IMAGE_NAME

docker build \
    --build-arg SSH_PRIVATE_KEY="$SSH_PRIVATE_KEY" \
    --build-arg SSH_PUBLIC_KEY="$SSH_PUBLIC_KEY" \
    --build-arg CONFIG_INI="$CONFIG_INI" \
    --build-arg APT_LIST="$APT_LIST" \
    -t $IMAGE_NAME \
    .
