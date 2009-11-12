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
INCDIRS=../lib
LIBS=git
PACKS=unix lwt lwt.unix ounit pcre

-include $(OCAMLMAKEFILE)
