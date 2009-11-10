.PHONY: all clean test
all:
	@cd lib && $(MAKE) all

clean:
	@cd lib && $(MAKE) clean

test:
	$(MAKE) all
	./lib/git
