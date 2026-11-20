MKSHELL=/bin/ksh

REMOTEHOST=homework
REMOTEWEBPATH=/h/nr/www

KINGS=fighter barbarian cleric paladin rogue monk wizard sorcerer
KINGYAMLS=${KINGS:%=yaml/king-%.yaml}
SILVERKINGYAMLS=${KINGS:%=yaml/silver-king-%.yaml}

TEMPLATES=silverpine 3col tropical
TEMPLATES_TEX=${TEMPLATES:%=templates/%.tex}
STYBASES=charsheet charsheet-packages articlesize
STYS=${STYBASES:%=templates/%.sty}
BGBASES=splash.png splash-nocolor.png merman.pdf
BGS=${BGBASES:%=templates/%}

CSS=https://www.cs.tufts.edu/cs/106/course.css

S=samples
QCHARS=`lib/yaml-from-md -keys QUICKSTART.md`
QYAMLS=${QCHARS:%=/tmp/%.yaml}
PREVIEWS=mario gmsheet


all:V: bin/exported-charsheet typesetter samples githubdocs ${PREVIEWS:%=%-preview.png}
samples:V: $S/samples.pdf demo
demo:V: $S/wizard.pdf
draft:V: /tmp/README.html /tmp/YAML.html /tmp/QUICKSTART.html ${PREVIEWS:%=/tmp/%-preview.png}
qstest:V: /tmp/QUICKSTART.yaml ${QCHARS:%=%.test} ${QCHARS:%=/tmp/%-test.pdf}
	yamllint -d '{extends: default, rules: { document-start: disable, key-duplicates: disable } }' /tmp/QUICKSTART.yaml

export:V: bin/exported-charsheet

LUADEPENDS=`lib/lua-depends -x lyaml bin/charsheet`
LUADEPENDSSRC=`lua-searchpath $LUADEPENDS`


bin/exported-charsheet:D: bin/charsheet $LUADEPENDSSRC
	amalg -o bin/exported-charsheet -s bin/charsheet $(lib/lua-depends -x lyaml bin/charsheet)
	chmod +x bin/exported-charsheet

# export-check only catches drift in modules it already knows to
# compare; sandbox-check catches a new `require` that was never added
# to the export at all, by running charsheet against lib/lua alone.
sandbox-check:V:
	lib/check-exported-lua


# Steps run one at a time, in the shell script below, rather than as mk
# prerequisites: formcrash runs many pdflatex jobs back to back, and a
# concurrent pdflatex job from another target corrupts its results.
test:V:
	mk qstest
	testing/formcrash
	testing/formcrash testing/crashers/*.yaml

&.test:VQ: /tmp/&-test.pdf /tmp/&.yaml
	yamllint -d '{extends: default, rules: { document-start: disable } }' /tmp/$stem.yaml
	charsheet -o /dev/null -s /tmp/$stem.yaml

$QYAMLS /tmp/QUICKSTART.yaml: QUICKSTART.md lib/yaml-from-md
	lib/yaml-from-md QUICKSTART.md > /tmp/QUICKSTART.yaml

/tmp/&-test.pdf: /tmp/&.yaml
	charsheet -o $target $prereq

/tmp/&.html: &.md
	pandoc -c $CSS -f gfm -s -o $target $prereq

$S/wizard.pdf: $S/king-wizard.3.pdf $S/king-wizard.s.pdf
	pdftk $prereq cat output $target

docs/index.html:D: yaml/mario.yaml $KINGYAMLS $SILVERKINGYAMLS lib/insert-pregen-yamls www/character-form.html
	lib/insert-pregen-yamls -html www/character-form.html -o $target yaml/mario.yaml $KINGYAMLS $SILVERKINGYAMLS

bundle:V: docs/index.html docs/charsheet.css typesetter
	cp -auvL docs/index.html $HOME/www/charsheet.html
	cp -auvL docs/charsheet.css $HOME/www/
	rsync -a --delete $TYPESETTER/ $HOME/www/typesetter/

publish:V: docs/index.html docs/charsheet.css typesetter
	rsync -avP docs/index.html docs/charsheet.css $REMOTEHOST:$REMOTEWEBPATH/charsheet/
	rsync -avP --delete $TYPESETTER/ $REMOTEHOST:$REMOTEWEBPATH/charsheet/typesetter/

# The typesetter that the form loads from typesetter/ beside it: charsheet
# and TeX compiled to WebAssembly (browser/README.md).  The first build of
# BusyTeX takes about half an hour.
B=browser/build
TYPESETTER=$B/typesetter
BUSYTEX=$B/engines/busytex-slim
TEXLISTS=browser/texlive/formats.files browser/texlive/sheets.files browser/texlive/extras.files

typesetter:V: $TYPESETTER/typeset-worker.js

$TYPESETTER/typeset-worker.js:D: browser/build-typesetter browser/web/typeset-worker.js browser/web/selftest.html \
        $BUSYTEX/busytex.wasm $B/lua/charsheet.lua $B/fmt-busytex/charsheet-xetex.fmt \
        $B/texmf/web2c/texmf.cnf $STYS $TEMPLATES_TEX $BGS
	browser/build-typesetter -d $TYPESETTER

$BUSYTEX/busytex.wasm: browser/build-busytex browser/icu-data.keep
	browser/build-busytex -d $BUSYTEX

$B/lua/charsheet.lua:D: browser/build-lua bin/charsheet $LUADEPENDSSRC
	browser/build-lua -d $B/lua

$B/texmf/web2c/texmf.cnf:D: browser/build-texmf $TEXLISTS
	browser/build-texmf -d $B/texmf $TEXLISTS

$B/fmt-busytex/charsheet-xetex.fmt:D: browser/build-formats browser/charsheet-format.tex $STYS $TEMPLATES_TEX \
        $BUSYTEX/busytex.wasm $B/texmf/web2c/texmf.cnf
	BUSYTEX=$PWD/$BUSYTEX TEXMFTREE=$PWD/$B/texmf PDFTEX=$PWD/browser/wasm-bin/pdftex \
	  XETEX=$PWD/browser/wasm-bin/xetex browser/build-formats -d $B/fmt-busytex

# after the templates or TeX Live change
texlive-lists:V:
	for s in formats sheets extras; do browser/texlive-files -o browser/texlive/$s.files $s; done

GITDOCS=index.html README.html YAML.html QUICKSTART.html CHANGELOG.html INSTALL.html \
        mario.pdf mario-preview.png gmsheet.pdf gmsheet-preview.png

githubdocs:V: ${GITDOCS:%=docs/%}

docs/&.html:D: &.md
	set -o pipefail
	pandoc -s -t html -c charsheet.css $prereq |
        sed -E -e 's/(QUICKSTART|README|YAML|INSTALL)\.md/\1.html/g' |
	cat > $target

docs/&.pdf:D: &.pdf
	cp $prereq $target

docs/&.png:D: &.png
	cp $prereq $target

push:V: test typesetter ${GITDOCS:%=docs/%}
	git commit -m 'updated web page' -- ${GITDOCS:%=docs/%}
	git push

yaml/silver-king-%.yaml:D: yaml/king-%.yaml lib/un3ify
	lib/un3ify yaml/king-$stem.yaml > $target

###################

$S/king-%.s.pdf: yaml/silver-king-%.yaml bin/charsheet templates/caster.tex $STYS
	bin/charsheet -t silverpine -o $target yaml/silver-king-$stem.yaml

$S/%.3.pdf: yaml/%.yaml bin/charsheet templates/3col.tex $STYS
	bin/charsheet -t 3col -o $target yaml/$stem.yaml

$S/samples.pdf: mario.pdf $S/mario.3.pdf ${KINGS:%=$S/king-%.s.pdf} ${KINGS:%=$S/king-%.3.pdf}
	set -A pdfs
	for k in $KINGS; do pdfs+=($S/king-$k.3.pdf $S/king-$k.s.pdf); done
	pdfs+=(mario.pdf $S/mario.3.pdf)
	pdftk "${pdfs[@]}" cat output $target

$S/samples1.pdf: ${KINGS:%=$S/king-%.s.pdf} ${KINGS:%=$S/king-%.3.pdf}
	set -A pdfs
	for k in $KINGS; do pdfs+=(king-$k.3.pdf king-$k.s.pdf); done
	lib/catpage1s $target "${pdfs[@]}"

$S/3samples.pdf: ${KINGS:%=$S/king-%.3.pdf}
	pdftk $prereq cat output $target

$S/3samples1.pdf: ${KINGS:%=$S/king-%.3.pdf}
	lib/catpage1s $target $prereq 

$S/ssamples1.pdf: ${KINGS:%=$S/king-%.s.pdf}
	lib/catpage1s $target $prereq 

$S/ssamples.pdf: ${KINGS:%=$S/king-%.s.pdf}
	pdftk $prereq cat output $target

$S/mario.3.pdf: bin/charsheet yaml/mario.yaml $TEMPLATES_TEX $STYS
	bin/charsheet -t 3col -o $target yaml/mario.yaml

mario.pdf: bin/charsheet yaml/mario.yaml $TEMPLATES_TEX $STYS
	bin/charsheet -o $target yaml/mario.yaml

&-preview.png: &.pdf
	convert -density 50 $prereq $target

/tmp/&-preview.png: &-preview.png
	cp $prereq $target
