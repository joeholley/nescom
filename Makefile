include Makefile.sets

# Building for Windows:
#HOST=i686-w64-mingw32-
#LDFLAGS +=
#CPPFLAGS += -I.
#LD=$(HOST)g++ -static
#CXXFLAS += -m32 -march=i386

# Building for native:
HOST=
LDFLAGS += -pthread 
LD=$(HOST)g++

CXX=$(HOST)g++
CC=$(HOST)gcc
CPP=$(HOST)gcc

DEPDIRS =

OPTIM=-O3 -std=c++0x

CPPFLAGS += -I.

VERSION=1.1.7

ARCHFILES=COPYING Makefile.sets progdesc.php \
          assemble.cc assemble.hh \
          tristate \
          hash.hh \
          expr.cc expr.hh \
          insdata.cc insdata.hh \
          parse.cc parse.hh \
          object.cc object.hh \
          precompile.cc precompile.hh \
          warning.cc warning.hh \
          dataarea.cc dataarea.hh \
          main.cc \
          \
          disasm.cc clever.cc \
          link.cc \
          \
          o65.cc o65.hh relocdata.hh \
          o65linker.cc o65linker.hh \
          refer.cc refer.hh msginsert.hh \
          space.cc space.hh \
          romaddr.cc romaddr.hh \
          binpacker.hh binpacker.tcc \
          logfiles.hh \
          rangeset.hh rangeset.tcc range.hh range.tcc \
          miscfun.hh miscfun.tcc \
          \
          clever/kage.ini \
          clever/cv2u.ini \
          clever/cv.ini \
          clever/solokey.ini \
          clever/lunarball.ini

PREFIX=/usr/local
BINDIR=$(PREFIX)/bin

ARCHNAME=nescom-$(VERSION)
ARCHDIR=archives/

PROGS=nescom disasm clever-disasm neslink

INSTALLPROGS=nescom neslink nescom-disasm
INSTALL=install

all: $(PROGS)

nescom: \
		assemble.o insdata.o object.o \
		expr.o parse.o precompile.o \
		dataarea.o \
		main.o warning.o \
		romaddr.o
	$(LD) $(CXXFLAGS) -g -o $@ $^ $(LDFLAGS)


neslink: \
		link.o o65.o o65linker.o space.o refer.o romaddr.o \
		object.o dataarea.o \
		warning.o 
	$(LD) $(CXXFLAGS) -g -o $@ $^ $(LDFLAGS)

nescom-disasm: disasm
	ln -f $^ $@

disasm: disasm.o romaddr.o o65.o
	$(LD) $(CXXFLAGS) -g -o $@ $^

clever-disasm: clever.o
	$(LD) $(CXXFLAGS) -g -o $@ $^

clean: FORCE
	rm -f *.o $(PROGS)
distclean: clean
	rm -f *~ .depend
realclean: distclean


# Build a windows archive
fullzip: \
		nescom disasm \
		README.html \
		README.TXT
	@rm -rf $(ARCHNAME)
	- mkdir $(ARCHNAME){,/doc}
	for s in $^;do ln "$$s" $(ARCHNAME)/"$$s"; done
	for dir in . doc ; do (\
	 cd $(ARCHNAME)/$$dir; \
	 /bin/ls|while read s;do echo "$$s"|grep -qF . || test -d "$$s" || mv -v "$$s" "$$s".exe;done; \
	                           ); done
	$(HOST)strip $(ARCHNAME)/*.exe $(ARCHNAME)/*/*.exe
	- upx --overlay=strip -9 $(ARCHNAME)/*.exe $(ARCHNAME)/*/*.exe
	zip -r9 $(ARCHNAME)-win32.zip $(ARCHNAME)
	rm -rf $(ARCHNAME)
	mv -f $(ARCHNAME)-win32.zip archives/
	- ln -f archives/$(ARCHNAME)-win32.zip /WWW/src/arch/

#../assemble: FORCE
#	$(MAKE) -C ../.. utils/assemble
#
#%.o: %.cc FORCE
#	$(MAKE) -C ../.. utils/asm/$@

include depfun.mak

.PHONY: all clean distclean realclean

FORCE: ;
