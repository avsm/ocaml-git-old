OCAMLMAKEFILE=../OCamlMakefile

GIT_TEST ?= $(shell pwd)/..
export GIT_TEST

.PHONY: run
run: dnc
	echo $(GIT_TEST)
	./$(RESULT) -verbose

RESULT= run_test
SOURCES= test.ml
ANNOTATE=yes

# to test with built version
INCDIRS=../lib
LIBS=git
PACKS=unix lwt lwt.unix oUnit pcre

# to test with installed version
# comment out previous and use this
# PACKS=git oUnit

-include $(OCAMLMAKEFILE)
