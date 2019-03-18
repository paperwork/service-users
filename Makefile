# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                                                            ║
# ║                      \  |       |          _|_) |                          ║
# ║                     |\/ |  _` | |  /  _ \ |   | |  _ \                     ║
# ║                     |   | (   |   <   __/ __| | |  __/                     ║
# ║                    _|  _|\__,_|_|\_\\___|_|  _|_|\___|                     ║
# ║                                                                            ║
# ║           * github.com/paperwork * twitter.com/paperworkcloud *            ║
# ║                                                                            ║
# ╚════════════════════════════════════════════════════════════════════════════╝
.PHONY: help init deploy undeploy status

APP_NAME ?= `grep 'app:' mix.exs | sed -e 's/\[//g' -e 's/ //g' -e 's/app://' -e 's/[:,]//g'` ##@Variables The service name
APP_VSN ?= `grep 'version:' mix.exs | cut -d '"' -f2` ##@Variables The service version
BUILD ?= `git rev-parse --short HEAD` ##@Variables The build hash

FN_HELP = \
	%help; while(<>){push@{$$help{$$2//'options'}},[$$1,$$3] \
		if/^(\w+)\s*(?:).*\#\#(?:@(\w+))?\s(.*)$$/}; \
	print"$$_:\n", map"  $$_->[0]".(" "x(20-length($$_->[0])))."$$_->[1]\n",\
	@{$$help{$$_}},"\n" for keys %help; \

help: ##@Miscellaneous Show this help
	@echo "Usage: make [target] <var> ...\n"
	@echo "$(APP_NAME):$(APP_VSN)-$(BUILD)"
	@perl -e '$(FN_HELP)' $(MAKEFILE_LIST)

build: ##@Build Build service
	docker build --build-arg APP_NAME=$(APP_NAME) \
		--build-arg APP_VSN=$(APP_VSN) \
		-t $(APP_NAME):$(APP_VSN)-$(BUILD) \
		-t $(APP_NAME):latest .

run: ##@Run Run service locally
	docker run --env-file config/docker.env \
		--rm -it $(APP_NAME):latest
