.PHONY: all build run push clean

# NOTE: How to enable experimental mode for --squash option
# https://github.com/docker/cli/blob/master/experimental/README.md#use-docker-experimental

IMAGE_BASE = "continuumio/miniconda3:4.10.3"
IMAGE_BASE = "ubuntu:20.04"
IMAGE_NAME = mmngreco

# build only
TAG = $(shell git describe --tags)
APT_LIST = $(shell cat ./apt.list)

# run only
DIR = $(PWD)
USERNAME = docker
# BASENAME = -$(shell basename ${DIR})
# UUID = -$(shell uuidgen)
# CONTAINER_NAME = $(shell echo mmngreco${BASENAME}${UUID:0:7})

all: build run push

build:
	docker build \
			--build-arg USERID=$(shell id -u):$(shell id -g) \
			--build-arg IMAGE_BASE="$(IMAGE_BASE)" \
			--build-arg APT_LIST="$(APT_LIST)" \
			--tag "mmngreco/dev:$(TAG)" \
			--tag "$(IMAGE_NAME):$(TAG)" \
			--tag "$(IMAGE_NAME)-$(shell echo $(IMAGE_BASE) | tr : _ | tr / -):$(TAG)" \
			--tag "$(IMAGE_NAME)-$(shell echo $(IMAGE_BASE) | tr : _ | tr / -):latest" \
			--squash \
			.

run:
	docker run \
			--user $(shell id -u):$(shell id -g) \
			--volume "$(DIR):/home/$(USERNAME)/$(shell basename ${DIR})" \
			--volume "$(DOTFILES):/home/$(USERNAME)/.dotfiles" \
			--volume "$(HOME)/.ssh:/home/$(USERNAME)/.ssh/" \
			--workdir "/home/$(USERNAME)/$(shell basename ${DIR})" \
			--interactive \
			--tty \
			$(IMAGE_NAME):$(TAG)

push:
	docker push "mmngreco/dev:$(TAG)"

clean:
	docker system prune --all -f

fix:
	# Fix network/connection problems
	# see https://serverfault.com/a/642984/573706
	# apt-get install bridge-utils
	pkill docker
	iptables -t nat -F
	ifconfig docker0 down
	brctl delbr docker0
	service docker restart
