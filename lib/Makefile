OCAMLMAKEFILE=../OCamlMakefile

SOURCES=git_types.mli git_types.ml cmd.mli cmd.ml actor.mli \
	actor.ml commit.mli commit.ml repo.mli repo.ml
RESULT=git
PACKS=unix lwt lwt.unix pcre
LIB_PACK_NAME=git
DOC_DIR=../doc
ANNOTATE=yes

.PHONY: all
all: dcl dncl
	@ :

.PHONY: install uninstall
install:
	ocamlfind install git META git.a git.cma git.cmxa *.cmi

uninstall:
	ocamlfind remove git

include $(OCAMLMAKEFILE)
