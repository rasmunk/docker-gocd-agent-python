PACKAGE_NAME=docker-gocd-agent-python
PACKAGE_NAME_FORMATTED=$(subst -,_,$(PACKAGE_NAME))
OWNER=ucphhpc
IMAGE=$(PACKAGE_NAME)
# Enable that the builder should use buildkit
# https://docs.docker.com/develop/develop-images/build_enhancements/
DOCKER_BUILDKIT=1
# NOTE: dynamic lookup with docker as default and fallback to podman
DOCKER=$(shell which docker || which podman)
ALL_IMAGES:=docker-gocd-agent-python 
TAG=edge
INIT_ARGS=
BUILD_ARGS=

.PHONY: all init dockerbuild dockerclean dockerpush clean dist distclean maintainer-clean
.PHONY: install uninstall installtest test

all: venv install-dep init dockerbuild

init: venv
ifeq ($(shell test -e defaults.env && echo yes), yes)
ifneq ($(shell test -e .env && echo yes), yes)
		ln -s defaults.env .env
endif
endif
	. $(VENV)/activate; python3 init-build.py ${INIT_ARGS}

build: init
	docker build -t ${OWNER}/${IMAGE}:${TAG} -f ./${PACKAGE_NAME}/Dockerfile.${TAG} ${BUILD_ARGS} ${PACKAGE_NAME}

build-all: $(foreach i,${ALL_IMAGES},build/$(i))

dockerclean:
	${DOCKER} rmi -f ${OWNER}/${IMAGE}:${TAG}

dockerpush:
	${DOCKER} push ${OWNER}/${IMAGE}:${TAG}

clean: dockerclean distclean
	rm -fr .env
	rm -fr .pytest_cache
	rm -fr tests/__pycache__

dist:
### PLACEHOLDER ###

distclean:
### PLACEHOLDER ###

maintainer-clean: distclean
	@echo 'This command is intended for maintainers to use; it'
	@echo 'deletes files that may need special tools to rebuild.'

install-dep:
	$(VENV)/pip install -r requirements.txt

uninstall-dep:
	$(VENV)/pip uninstall -y -r requirements.txt

install-dev:
	$(VENV)/pip install -r requirements-dev.txt

uninstall-dev:
	$(VENV)/pip uninstall -y -r requirements-dev.txt

install: install-dep

uninstall:
### PLACEHOLDER ###

uninstalltest:
### PLACEHOLDER ###

installtest:
### PLACEHOLDER ###

test:
### PLACEHOLDER ###

include Makefile.venv