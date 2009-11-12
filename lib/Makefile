OCAMLMAKEFILE=../OCamlMakefile

SOURCES=git_types.mli git_types.ml cmd.mli cmd.ml actor.mli actor.ml commit.mli commit.ml repo.mli repo.ml test.ml 
RESULT=git
PACKS=unix lwt lwt.unix pcre
LIB_PACK_NAME=git
DOC_DIR=../doc
ANNOTATE=yes

.PHONY: all
all: dnc
	@ :

include $(OCAMLMAKEFILE)
