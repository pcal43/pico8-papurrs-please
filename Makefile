VERSION=0.0.1

CARTNAME=lost-cats
ROOT_DIR=.
BUILD_DIR=${ROOT_DIR}/build
PICO8_HOME=${ROOT_DIR}/pico8-home
PICO8_CARTS=${PICO8_HOME}/carts
PICO8_BIN=pico8
RELEASE_ARTIFACT=${BUILD_DIR}/${CARTNAME}-${VERSION}.p8.png

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
PICO8_INSTALL="/Applications/PICO-8.app/Contents/MacOS"
PICO8_BIN="${PICO8_INSTALL}/pico8"
endif


.PHONY: run
run:
	"${PICO8_BIN}" -home "${PICO8_HOME}"  -root_path  "${PICO8_CARTS}" -run "${PICO8_HOME}/carts/${CARTNAME}.p8"

clean:
	rm -rf ./build

version:
	echo "VERSION = \"${VERSION}\"" > ${PICO8_HOME}/carts/${CARTNAME}/version.lua

release: clean version
	mkdir -p ./build
	"${PICO8_BIN}" -home "${PICO8_HOME}"  -root_path  "${PICO8_CARTS}" -run "${PICO8_HOME}/carts/${CARTNAME}.p8" -export "${RELEASE_ARTIFACT}"

run-release: release
	${PICO8_BIN} -run ${RELEASE_ARTIFACT}

