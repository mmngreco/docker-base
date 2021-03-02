PY_VER="3.6.13"
TAG="0.2.1-allpython-debian"
IMAGE_NAME="etsgit1.ets.es:5005/com/docker-base:$TAG"
SSH_PRIVATE_KEY="$(cat ~/.ssh/id_rsa)"
SSH_PUBLIC_KEY="$(cat ~/.ssh/id_rsa.pub)"
CONFIG_INI="$(cat /ETS/configs/config.ini)"
APT_LIST=""

