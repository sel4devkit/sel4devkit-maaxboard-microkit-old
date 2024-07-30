################################################################################
# Makefile
################################################################################

#===========================================================
# Check
#===========================================================
EXP_INFO := sel4devkit-maaxboard-microkit-docker-dev-env 1 *
CHK_PATH_FILE := /check.mk
ifeq ($(wildcard ${CHK_PATH_FILE}),)
    HALT := TRUE
else
    include ${CHK_PATH_FILE}
endif
ifdef HALT
    $(error Expected Environment Not Found: ${EXP_INFO})
endif

#===========================================================
# Layout
#===========================================================
DEP_PATH := dep
TMP_PATH := tmp
OUT_PATH := out

DEP_SL4_PATH := ${DEP_PATH}/sel4

#===========================================================
# Usage
#===========================================================
.PHONY: usage
usage: 
	@echo "usage: make <target> [COMPLETE=TRUE]"
	@echo ""
	@echo "<target> is one off:"
	@echo "all"
	@echo "clean"
	@echo "reset"

#===========================================================
# Target
#===========================================================

# Prefer relative. Only use where absolutely essential.
ROOT_PATH := $(shell dirname $(realpath $(firstword ${MAKEFILE_LIST})))

.PHONY: all
all: ${OUT_PATH}/microkit-sdk-1.2.6

${TMP_PATH}:
	mkdir ${TMP_PATH}

${OUT_PATH}:
	mkdir ${OUT_PATH}

${DEP_SL4_PATH}/out/sel4:
	make -C ${DEP_SL4_PATH} all

ifdef COMPLETE
# Cache with dependencies.
${OUT_PATH}/microkit-sdk-1.2.6: ${TMP_PATH}/microkit/release/microkit-sdk-1.2.6 | ${OUT_PATH}
	cp -r $< $@
else
# Cache without dependencies.
${OUT_PATH}/microkit-sdk-1.2.6:
	make all COMPLETE=TRUE
endif

${TMP_PATH}/microkit/release/microkit-sdk-1.2.6: ${DEP_SL4_PATH}/out/sel4 | ${TMP_PATH}
	# Acquire.
	git -C ${TMP_PATH} clone --branch "dev" "git@github.com:Ivan-Velickovic/microkit.git" microkit
	git -C ${TMP_PATH}/microkit reset --hard "7c679ea2df3603f81e4afdb36676bbaea0f265c8"
	# Adjust to use "0x50000000".
	sed --in-place --expression "s/loader_link_address=0x40480000/loader_link_address=0x50000000/g" ${TMP_PATH}/microkit/build_sdk.py
	# Adjust to use GCC 12.
	sed --in-place --expression "s/aarch64-none-elf/aarch64-linux-gnu/g" ${TMP_PATH}/microkit/build_sdk.py ${TMP_PATH}/microkit/example/maaxboard/hello/Makefile ${TMP_PATH}/microkit/monitor/Makefile ${TMP_PATH}/microkit/loader/Makefile ${TMP_PATH}/microkit/libmicrokit/Makefile
	sed --in-place --expression "s/ -g3 /     /g" ${TMP_PATH}/microkit/example/maaxboard/hello/Makefile ${TMP_PATH}/microkit/monitor/Makefile ${TMP_PATH}/microkit/loader/Makefile ${TMP_PATH}/microkit/libmicrokit/Makefile
	# Increase stack size.
	# Target: 1024*128=131072 bytes
	# 131072-1 = 131071 = 1FFFF trimmed as 1FFF0
	sed --in-place --expression "s/0xff0/0x1FFF0/g" ${TMP_PATH}/microkit/libmicrokit/src/aarch64/crt0.s
	sed --in-place --expression "s/_stack\[4096\]/_stack[131072]/g" ${TMP_PATH}/microkit/libmicrokit/src/main.c
	# Remove document build.
	sed --in-place --expression "s/^ *build_doc(root_dir)/# &/g" ${TMP_PATH}/microkit/build_sdk.py
	# Python.
	python -m venv ${TMP_PATH}/pyenv
	. ${TMP_PATH}/pyenv/bin/activate ; pip install --requirement ${TMP_PATH}/microkit/requirements.txt
	# Build.
	. ${TMP_PATH}/pyenv/bin/activate ; cd ${TMP_PATH}/microkit ; python build_sdk.py --sel4=${ROOT_PATH}/${DEP_SL4_PATH}/out/sel4 --filter-boards maaxboard
	
.PHONY: clean
clean:
	make -C ${DEP_SL4_PATH} clean
	rm -rf ${TMP_PATH}

.PHONY: reset
reset: clean
	rm -rf ${OUT_PATH}

################################################################################
# End of file
################################################################################
