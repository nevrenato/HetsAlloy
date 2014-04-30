# $Id: Makefile 2551 2004-05-06 12:26:39Z 2maeder $

.PHONY: check

check: capa 
	./runcheck.sh ../capa

output: capa 
	./runcheck.sh ../capa set

%: 
	(cd ../..; $(MAKE) $@)

