
###############################################################################
# Building our app
###############################################################################

CC = clang -Os # Change this to preferred compiler
XSC = xsc
XSL = xsl
OUT := $(shell pwd)/out
MODDABLE := $(shell pwd)/moddable
CFLAGS = \
	-I$(MODDABLE)/xs/includes \
	-I$(MODDABLE)/xs/sources \
	-I$(MODDABLE)/xs/platforms \
	-I$(OUT)/gen
MODULES = \
	$(OUT)/gen/main.xsb
LIBS = \
	$(OUT)/src/main.o \
	$(OUT)/gen/mc.xs.o \
	$(OUT)/xs/xsAll.o \
	$(OUT)/xs/xsAPI.o \
	$(OUT)/xs/xsArguments.o \
	$(OUT)/xs/xsArray.o \
	$(OUT)/xs/xsAtomics.o \
	$(OUT)/xs/xsBoolean.o \
	$(OUT)/xs/xsCode.o \
	$(OUT)/xs/xsCommon.o \
	$(OUT)/xs/xsDataView.o \
	$(OUT)/xs/xsDate.o \
	$(OUT)/xs/xsDebug.o \
	$(OUT)/xs/xsError.o \
	$(OUT)/xs/xsFunction.o \
	$(OUT)/xs/xsGenerator.o \
	$(OUT)/xs/xsGlobal.o \
	$(OUT)/xs/xsJSON.o \
	$(OUT)/xs/xsLexical.o \
	$(OUT)/xs/xsMapSet.o \
	$(OUT)/xs/xsMarshall.o \
	$(OUT)/xs/xsMath.o \
	$(OUT)/xs/xsMemory.o \
	$(OUT)/xs/xsModule.o \
	$(OUT)/xs/xsNumber.o \
	$(OUT)/xs/xsObject.o \
	$(OUT)/xs/xsPlatforms.o \
	$(OUT)/xs/xsProfile.o \
	$(OUT)/xs/xsPromise.o \
	$(OUT)/xs/xsProperty.o \
	$(OUT)/xs/xsProxy.o \
	$(OUT)/xs/xsRegExp.o \
	$(OUT)/xs/xsRun.o \
	$(OUT)/xs/xsScope.o \
	$(OUT)/xs/xsScript.o \
	$(OUT)/xs/xsSourceMap.o \
	$(OUT)/xs/xsString.o \
	$(OUT)/xs/xsSymbol.o \
	$(OUT)/xs/xsSyntaxical.o \
	$(OUT)/xs/xsTree.o \
	$(OUT)/xs/xsType.o \
	$(OUT)/xs/xsdtoa.o \
	$(OUT)/xs/xsmc.o \
	$(OUT)/xs/xsre.o

.PHONY: all run debug clean distclean

all: $(OUT)/mxs

run: $(OUT)/mxs
	$<

debug: $(OUT)/mxs
	gdb $<

clean:
	rm -rf $(OUT)

distclean: clean
	git submodule foreach git clean -xdf

$(OUT)/mxs: $(OUT) $(LIBS) 
	$(CC) $(LIBS) -lm -o $@ 

$(OUT):
	mkdir -p $(OUT)/gen $(OUT)/src $(OUT)/xs

$(OUT)/xs/%.o: $(MODDABLE)/xs/sources/%.c 
	$(CC) $(CFLAGS) -std=gnu99 -c $< -o $@

$(OUT)/src/%.o: src/%.c $(OUT)/gen/mc.xs.h
	$(CC) $(CFLAGS) -Wall -Werror -std=c99 -c $< -o $@

$(OUT)/gen/mc.xs.o: $(OUT)/gen/mc.xs.h 
	$(CC) $(CFLAGS) -Wall -Werror -std=c99 -c $(OUT)/gen/mc.xs.c -o $@

$(OUT)/gen/mc.xs.h: $(MODULES)
	$(XSL) $(MODULES) -o $(OUT)/gen -b $(OUT)/gen
	
$(OUT)/gen/%.xsb: src/%.js
	$(XSC) -c -d -e $< -o $(OUT)/gen

