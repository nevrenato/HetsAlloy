# $Id: Makefile 6074 2006-03-20 16:33:04Z 2maeder $

.PHONY: check

check: h2h hacapa
	./runcheck.sh ../../Haskell/h2h

output: h2h hacapa
	./runcheck.sh ../../Haskell/h2h set

%: 
	(cd ../..; $(MAKE) $@)

