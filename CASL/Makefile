# $Id: Makefile 11107 2008-11-27 16:37:44Z till $

kif:
	ghc --make -Wall -i..:../ghc fromKif.hs -o fromKif

call:
	./ghc-call

%: 
	(cd test; $(MAKE) $@)
