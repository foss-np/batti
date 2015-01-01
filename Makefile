SOURCES = $(wildcard *.sh)
SUPPORT = "README.md AUTHORS LICENSE .version"
PKG_NAME = "batti"

default:
	./main.sh
	echo "This was the DEMO, use make install"

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
	cp ${SOURCES} /opt/${PKG_NAME}/
	cp ${SUPPORT} /opt/${PKG_NAME}/
	ln -s /opt/${PKG_NAME}/main.sh /usr/local/bin/${PKG_NAME}

installcheck:
	@echo "# Not implemented"
	@echo ${SOURCES}

clean:
	@echo "# Not implemented"
	@echo "erase what has been buit (opposite of make all)"

dist:
	@echo "# Not implemented"
	@echo "create PACKAGE-VERSION.tar.gz"

distclean:
	@echo "# Not implemented"
	@echo "erase what ever done by make all, then clean what ever done by ./configure"

distcheck:
	@echo "# Not implemented"
	@echo "do sanity check"

check:
	@echo "# Not implemented"
	@echo "run the test suite if any"
