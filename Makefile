all: build deploy
	@echo "Start build and deployment process"

build:
	./build.sh

deploy:
	./deploy.sh

.PHONY: build deploy all
