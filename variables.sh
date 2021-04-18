PY_VER="3.6.13"
TAG="0.2.0-allpython-debian"
IMAGE_NAME="docker-base:$TAG"
SSH_PRIVATE_KEY="$(cat ~/.ssh/id_rsa)"
SSH_PUBLIC_KEY="$(cat ~/.ssh/id_rsa.pub)"
APT_LIST="$(cat apt.list)"

