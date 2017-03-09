PREFIX?= /usr/local
BINDIR?= ${PREFIX}/bin
MANDIR?= ${PREFIX}/share/man
INSTALL?= install
INSTALLDIR= ${INSTALL} -d
INSTALLBIN= ${INSTALL} -m 755
INSTALLMAN= ${INSTALL} -m 644

all: fasder.1

uninstall:
	rm -f ${DESTDIR}${BINDIR}/fasder
	rm -f ${DESTDIR}${MANDIR}/man1/fasder.1

install:
	${INSTALLDIR} ${DESTDIR}${BINDIR}
	${INSTALLBIN} fasder ${DESTDIR}${BINDIR}
	${INSTALLDIR} ${DESTDIR}${MANDIR}/man1
	${INSTALLMAN} fasder.1 ${DESTDIR}${MANDIR}/man1

man: fasder.1

fasder.1: fasder.1.md
	pandoc -s -w man fasder.1.md -o fasder.1

.PHONY: all install uninstall man

