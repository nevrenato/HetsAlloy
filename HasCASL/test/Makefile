# $Id: Makefile 3715 2005-01-25 15:17:41Z 2maeder $

.PHONY: check

check: hacapa
	./runcheck.sh ../hacapa

output: hacapa 
	./runcheck.sh ../hacapa set

%: 
	(cd ../..; $(MAKE) $@)
