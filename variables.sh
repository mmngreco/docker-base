TAG="0.1.0-py35-pip18-debian"
IMAGE_NAME="etsgit1.ets.es:5005/com/docker-base:$TAG"
SSH_PRIVATE_KEY="$(cat ~/.ssh/id_rsa)"
SSH_PUBLIC_KEY="$(cat ~/.ssh/id_rsa.pub)"
CONFIG_INI="$(cat /ETS/configs/config.ini)"
PY_VER="3.5.8"
APT_LIST=""

