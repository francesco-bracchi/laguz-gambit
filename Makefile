GSC		=	gsc
GSI		=	gsi
COPY		=	cp -r
INSTALL		= 	cp
CATENATE	= 	cat
REMOVE		= 	rm -r
MAKEDIR		= 	mkdir
CC		=	gcc -shared 

LIBNAME		= 	laguz
SRCDIR		= 	src
LIBDIR		= 	lib
EXAMPLEDIR	=	examples

INSTALLDIR	= 	$(shell ${GSI} -e "(display (path-expand \"~~/${LIBNAME}\"))")
SOURCES		=	$(shell ls ${SRCDIR}/*[a-zA-Z0-9].scm)
CFILES		= 	$(SOURCES:.scm=.c)
OBJECT_FILES	=	$(SOURCES:.scm=.o)
INCLUDES	= 	$(shell ls ${SRCDIR}/*\#.scm)

LINKFILE	=	$(SRCDIR)/$(LIBNAME).o1
CLINKFILE	=	$(LINKFILE:.o1=.o1.c)
OBJECT_LINKFILE =	$(LINKFILE:.o1=.o1.o)

TESTDIR		= 	test
TESTFILES	= 	$(shell ls ${TESTDIR}/*[a-zA-Z0-9].scm)

all: libdir

clean: 
	-$(REMOVE) $(SRCDIR)/*~
	-$(REMOVE) $(CFILES)
	-$(REMOVE) $(OBJECT_FILES)
	-$(REMOVE) $(CLINKFILE)
	-$(REMOVE) $(OBJECT_LINKFILE)
	-$(REMOVE) $(LINKFILE)
	-$(REMOVE) $(LIBDIR)
	-$(REMOVE) $(EXAMPLEDIR)/*.o1

clean-linkfile:
	-$(REMOVE) $(CLINKFILE)
	-$(REMOVE) $(LINKFILE)

libdir: $(LINKFILE) $(LIBDIR)
	$(COPY) $(LINKFILE) $(LIBDIR)
	$(COPY) $(INCLUDES) $(LIBDIR)

$(LINKFILE): $(OBJECT_LINKFILE) $(OBJECT_FILES)
	$(CC) $(OBJECT_FILES) $(OBJECT_LINKFILE) -o $(LINKFILE)

$(CLINKFILE):
	$(GSC) -link -flat -o $(CLINKFILE) $(SOURCES)

$(OBJECT_LINKFILE): $(CLINKFILE)
	$(GSC) -cc-options "-D___DYNAMIC" -obj -o $(OBJECT_LINKFILE) $(CLINKFILE)

%.o: %.c 
	$(GSC) -cc-options "-D___DYNAMIC" -obj -o $@ $<

%.c : %.scm
	$(GSC) -c -o $@ $<

%.o1 : %.scm
	$(GSC) -:~~$(LIBNAME)=$(LIBDIR) -o $@ $<

$(LIBDIR):
	-$(MAKEDIR) $(LIBDIR)

$(INSTALLDIR): 
	-$(MAKEDIR) $(INSTALLDIR)

install: libdir $(INSTALLDIR) 
	@echo "installing in:"
	@echo $(INSTALLDIR)
	$(INSTALL) -r $(LIBDIR)/* $(INSTALLDIR)

example: libdir $(EXAMPLEDIR)/laguz-test.o1
	@echo "testing laguz"
	@echo
	$(GSI) -:~~$(LIBNAME)=$(LIBDIR),m128000 $(LIBDIR)/$(LIBNAME) $(EXAMPLEDIR)/laguz-test

repl: libdir
	@echo "REPL with laguz"
	@echo
	$(GSI) -:~~$(LIBNAME)=$(SRCDIR) $(LIBDIR)/laguz -
