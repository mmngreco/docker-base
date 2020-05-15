.PHONY: all build run push clean

all: build run push

build:
	bash docker_build.sh

run:
	bash docker_run.sh

push:
	bash docker_push.sh

clean:
	docker system prune --all -f
