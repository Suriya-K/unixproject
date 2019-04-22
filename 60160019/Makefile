# 60160019 Suriya Kenma Group 1
# Simple Makefile for hello project
.SUFFIXES:
DESTDIR=
PROFIX=/usr/local
GROFF=groff
INSTALL=install
GZIP=gzip
STD=-std=c++11
CXX=g++
OPT=-O3 -march=x86-64 -mtune=generic -pipe
CXXflags=-Wall -Wextra -pedantic $(STD) $(OPT)
override CPPFLAGS+=-D_XOPEN_SOURCE=700
LDFLAGS=-s
LIBS=-lm

all:	hello hello.1.pdf hello.1.ps
	
hello:	hello.o emitter.o
	$(CXX) $(LDFLAGS) $^ -o $@ $(LIBS)

hello.o:	hello.cpp emitter.hpp
	$(CXX) $(CXXflags) $(CPPFLAGS) -c $< -o $@

emitter.o:	emitter.cpp emitter.hpp
	$(CXX) $(CXXflags) $(CPPFLAGS) -c $< -o $@

install:	all
	$(INSTALL) -m 755 -d $(DESTDIR)$(PREFIX)/bin
	$(INSTALL) -m 755 -d $(DESTDIR)$(PREFIX)/man/man1
	$(INSTALL) -m 755 -d $(DESTDIR)$(PREFIX)/doc
	$(INSTALL) -m 555 hello $(DESTDIR)$(PREFIX)/bin/
	$(GZIP) -9c hello.1 >hello.1.gz
	$(INSTALL) -m 444 hello.1.gz $(DESTDIR)$(PREFIX)/man/man1/
	$(INSTALL) -m 444 hello.1.pdf $(DESTDIR)$(PREFIX)/doc/
	$(INSTALL) -m 444 hello.1.ps $(DESTDIR)$(PREFIX)/doc/

hello.1.pdf:	hello.1
	$(GROFF) -man -Tpdf -P-pa4 $< >$@

hello.1.ps:	hello.1
	$(GROFF) -man -Tps -P-pa4 $< >$@

clean:	
	$(RM) hello.o emitter.o core

distclean:	clean
	$(RM) hello hello.1.pdf hello.1.ps hello.1.gz

.PHONY:	all install clean distclean
