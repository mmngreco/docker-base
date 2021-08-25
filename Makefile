.PHONY: all build run push clean

# How to enable experimental mode (squash)
# https://github.com/docker/cli/blob/master/experimental/README.md#use-docker-experimental

# build
TAG = 0.3.0
IMAGE_BASE = "python:3.6"
IMAGE_NAME = mmngreco:${TAG}
APT_LIST = $(shell cat apt.list)

# run
DIR = ${PWD}
BASENAME = -$(shell basename ${DIR})
UUID = -$(shell uuidgen)
CONTAINER_NAME = $(shell echo mmngreco${BASENAME}${UUID:0:7})


all: build run push

build:
		docker build \
			--build-arg IMAGE_BASE="${IMAGE_BASE}" \
			--build-arg APT_LIST="${APT_LIST}" \
			--tag "${IMAGE_NAME}" \
			--squash \
			.

run:
		docker run \
			--user $(shell id -u):$(shell id -g) \
			--volume "$(shell pwd):/home/docker/$(shell basename ${DIR})" \
			--volume "${DOTFILES}:/root/.dotfiles" \
			--volume "${HOME}/.ssh:/root/.ssh/" \
			--workdir "/home/docker/$(shell basename ${DIR})" \
			--name ${CONTAINER_NAME} \
			--interactive \
			--tty \
			${IMAGE_NAME}

push:
		docker push ${IMAGE_NAME}

clean:
		docker system prune --all -f

fix:
		# see https://serverfault.com/a/642984/573706
		# apt-get install bridge-utils
		pkill docker
		iptables -t nat -F
		ifconfig docker0 down
		brctl delbr docker0
		service docker restart
