ifeq ($(prefix),)
	prefix=/usr/local
endif
ifeq ($(datadir),)
	datadir=$(prefix)/share
endif
ifeq ($(shell which $(PC)),)
	PC=fpc
endif
ifeq ($(PFLAGS),)
	PFLAGS=-XX -Xg -Xs
endif
all:
	$(PC) $(PFLAGS) thundermaker.pas
install:
	if [ ! -d "$(DESTDIR)$(prefix)/bin" ]; then mkdir -p $(DESTDIR)$(prefix)/bin; fi
	install -m755 thundermaker $(DESTDIR)$(prefix)/bin
clean:
	rm thundermaker thundermaker.dbg thundermaker.o
