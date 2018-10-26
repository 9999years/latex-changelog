PACKAGE := changelog
DIST_FILES := ${PACKAGE}.sty ${PACKAGE}.tex ${PACKAGE}-doc.sty ${PACKAGE}.pdf \
	README.md LICENSE.md
TEXMF_ROOT := ${HOME}/texmf
INSTALL_DIR := $(TEXMF_ROOT)/tex/latex/${PACKAGE}
LATEXMK = latexmk -aux-directory=extra -pdf -r ./.latexmkrc

${PACKAGE}.pdf: ${PACKAGE}.tex
	$(LATEXMK) $?

${PACKAGE}: $(DIST_FILES)
	mkdir ${PACKAGE}
	cp -t ${PACKAGE} $?
	chmod -x,+r ${PACKAGE}/*

${PACKAGE}.tar.gz: ${PACKAGE}
	tar -czf $@ $?
	tar -tvf $@

dist: ${PACKAGE}.tar.gz

tidy:
	# all generated files but the pdf
	$(LATEXMK) -c
	rm -r extra
	# copied files
	rm -r ${PACKAGE}

clean:
	$(LATEXMK) -C
	make tidy
	rm ${PACKAGE}.tar.gz

install: ${PACKAGE}
	install -d ${INSTALL_DIR}
	install $(DIST_FILES) ${INSTALL_DIR}
