SOURCES = main.sh main.py
SUPPORT = README.org AUTHORS LICENSE .version
PKG_NAME = batti
FILE_CONFIG="${HOME}/.cache/batti.sch"

default:
	./main.sh
	@echo "This was the DEMO, use make install"

all:
	@echo "# Not implemented"
	@echo "build programs lib, doc."

unlink:
	rm -f /usr/local/bin/${PKG_NAME}

uninstall: unlink
	rm -rf /opt/${PKG_NAME}

link: unlink
	ln -s "$(PWD)/main.sh" /usr/local/bin/${PKG_NAME}

alias:
	@echo "add alias in to '.bashrc'"
	@echo "alias ${PKG_NAME}='$PWD/main.sh'"

install: unlink uninstall
	mkdir -p /opt/${PKG_NAME}
	install -m 755 ${SOURCES} -t /opt/${PKG_NAME}/
	cp ${SUPPORT} /opt/${PKG_NAME}/
	ln -s /opt/${PKG_NAME}/main.sh /usr/local/bin/${PKG_NAME}

installcheck:
	@echo "# Not implemented"
	@echo ${SOURCES}

clean: deb-clean droid-clean
	@echo "erase what has been buit (opposite of make all)"

dist:
	@echo "# Not implemented"
	@echo "create PACKAGE-VERSION.tar.gz"

droid:
	@echo "# Compacting for Android"
	mkdir droid
	sed 's|HOME/.cache|WD|' main.sh > droid/batti.sh
	chmod +x droid/batti.sh
	./main.sh -d > droid/batti.sch
	[ -e .version ] && cp .version droid/

droid-clean:
	rm -rf droid

distclean: clean droid-clean deb-clean
	@echo "# Not implemented"
	@echo "erase what ever done by make all, then clean what ever done by ./configure"

distcheck:
	@echo "# Not implemented"
	@echo "do sanity check"

check:
	@echo "# Not implemented"
	@echo "run the test suite if any"

deb: deb-clean
	@echo "creates debain package"
	mkdir -p deb/DEBIAN
	mkdir -p deb/usr/local/bin
	cp main.sh deb/usr/local/bin/batti
	cp info deb/DEBIAN/control
	dpkg-deb --build deb .

deb-clean:
	rm -rf deb
