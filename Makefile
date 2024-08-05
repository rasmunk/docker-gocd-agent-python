PACKAGE_NAME=gocd-agent-python
PACKAGE_NAME_FORMATTED=$(subst -,_,$(PACKAGE_NAME))
OWNER=ucphhpc
IMAGE=$(PACKAGE_NAME)
# Enable that the builder should use buildkit
# https://docs.docker.com/develop/develop-images/build_enhancements/
DOCKER_BUILDKIT=1
# NOTE: dynamic lookup with docker as default and fallback to podman
DOCKER=$(shell which docker || which podman)
ALL_IMAGES:=gocd-agent-python
TAG=edge
INIT_ARGS=
BUILD_ARGS=

.PHONY: all
all: venv install-dep init build

.PHONY: init
init: venv
ifeq ($(shell test -e defaults.env && echo yes), yes)
ifneq ($(shell test -e .env && echo yes), yes)
		ln -s defaults.env .env
endif
endif
	. ${VENV}/activate; python3 init-build.py ${INIT_ARGS}

.PHONY: build
build: init
	docker build -t ${OWNER}/${IMAGE}:${TAG} -f ./${PACKAGE_NAME}/Dockerfile.${TAG} ${BUILD_ARGS} ${PACKAGE_NAME}

.PHONY: build-all
build-all: $(foreach i,${ALL_IMAGES},build/$(i))

.PHONY: dockerclean
dockerclean:
	${DOCKER} rmi -f ${OWNER}/${IMAGE}:${TAG}

.PHONY: dockerpush
dockerpush:
	${DOCKER} push ${OWNER}/${IMAGE}:${TAG}

.PHONY: clean
clean: dockerclean distclean
	rm -fr .env
	rm -fr .pytest_cache
	rm -fr tests/__pycache__

.PHONY: dist
dist:
### PLACEHOLDER ###

.PHONY: distclean
distclean:
### PLACEHOLDER ###

.PHONY: maintainer-clean
maintainer-clean: distclean
	@echo 'This command is intended for maintainers to use; it'
	@echo 'deletes files that may need special tools to rebuild.'

.PHONY: install-dep
install-dep: venv
	${VENV}/pip install -r requirements.txt

.PHONY: uninstall-dep
uninstall-dep: venv
	${VENV}/pip uninstall -y -r requirements.txt

.PHONY: install-dev
install-dev: venv
	${VENV}/pip install -r requirements-dev.txt

.PHONY: uninstall-dev
uninstall-dev: venv
	${VENV}/pip uninstall -y -r requirements-dev.txt

.PHONY: install
install: install-dep

.PHONY: uninstall
uninstall:
### PLACEHOLDER ###

.PHONY: installtest
uninstalltest:
### PLACEHOLDER ###

.PHONY: installtest
installtest:
### PLACEHOLDER ###

.PHONY: test
test:
### PLACEHOLDER ###

include Makefile.venv