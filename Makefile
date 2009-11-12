.PHONY: all clean test doc
all:
	@cd lib && $(MAKE) all

clean:
	@cd lib && $(MAKE) clean
	@rm -rf doc/

doc:
	@cd lib && $(MAKE) doc

test: 
	@cd lib && $(MAKE)
	@cd lib_test && $(MAKE) run
