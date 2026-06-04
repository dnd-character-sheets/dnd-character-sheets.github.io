MKSHELL=/bin/ksh

PUBLISH=/usr/local/charsheet
REMOTEHOST=homework
REMOTE=$REMOTEHOST-clone
REMOTEWEBPATH=/h/nr/www
CHARSHEET_DIR=/h/nr/www
REMOTECGINAME=render-charsheet.cgi

KINGS=fighter barbarian cleric paladin rogue monk wizard sorcerer
KINGYAMLS=${KINGS:%=yaml/king-%.yaml}
SILVERKINGYAMLS=${KINGS:%=yaml/silver-king-%.yaml}

TEMPLATES=silverpine 3col tropical
TEMPLATES_TEX=${TEMPLATES:%=templates/%.tex}
BGBASES=splash.png splash-nocolor.png merman.pdf
BGS=${BGBASES:%=templates/%}

CODE=bin/charsheet $TEMPLATES_TEX
CSS=https://www.cs.tufts.edu/cs/106/course.css

S=samples
QCHARS=`lib/yaml-from-md -keys QUICKSTART.md`
QYAMLS=${QCHARS:%=/tmp/%.yaml}

all:V: bundle zanogh.pdf miriel.pdf
samples:V: $S/samples.pdf demo
demo:V: $S/wizard.pdf
draft:V: /tmp/README.html /tmp/YAML.html /tmp/QUICKSTART.html
test:V: /tmp/QUICKSTART.yaml ${QCHARS:%=%.test} zanogh.pdf miriel.pdf fighter.pdf
	yamllint -d '{extends: default, rules: { document-start: disable, key-duplicates: disable } }' /tmp/QUICKSTART.yaml

&.test:VQ: /tmp/&-test.pdf /tmp/&.yaml
	yamllint -d '{extends: default, rules: { document-start: disable } }' /tmp/$stem.yaml
	charsheet -o /dev/null -s /tmp/$stem.yaml

$QYAMLS: QUICKSTART.md lib/yaml-from-md
	lib/yaml-from-md QUICKSTART.md > /tmp/QUICKSTART.yaml

&.pdf: /tmp/&.yaml
	charsheet -o $target $prereq

/tmp/&-test.pdf: /tmp/&.yaml
	charsheet -o $target $prereq

/tmp/&.html: &.md
	pandoc -c $CSS -f gfm -s -o $target $prereq

$S/wizard.pdf: $S/king-wizard.3.pdf $S/king-wizard.s.pdf
	pdftk $prereq cat output $target

LUAUTIL=flags inspect osutil tabutil
LUAFILES=${LUAUTIL:%=$HOME/src/lua/%.lua}

local-cgi:V: /usr/lib/cgi-bin/render.cgi
	sudo systemctl reload apache2

/usr/lib/cgi-bin/render.cgi: render.cgi
	sudo cp $prereq $target

docs/index.html:D: yaml/mario.yaml $KINGYAMLS $SILVERKINGYAMLS lib/insert-pregen-yamls www/character-form.html
	lib/insert-pregen-yamls -html www/character-form.html -o $target yaml/mario.yaml $KINGYAMLS $SILVERKINGYAMLS

bundle:V: docs/index.html docs/charsheet.css
	cp -auvL $BGS bin/charsheet templates/charsheet.sty $TEMPLATES_TEX $LUAFILES $PUBLISH
	cp -auvL docs/index.html $HOME/www/charsheet.html
	cp -auvL docs/charsheet.css $HOME/www/

publish:V: $REMOTE/index.html $REMOTE/render.cgi $REMOTE/charsheet.css
	rsync -avP $PUBLISH $REMOTEHOST:$CHARSHEET_DIR
	rsync -avP -L $REMOTE/index.html $REMOTE/render.cgi $REMOTE/charsheet.css $LUAFILES \
                      $REMOTEHOST:$REMOTEWEBPATH/charsheet/
	rsync -avP $REMOTE/render.cgi $REMOTEHOST:$REMOTEWEBPATH/cgi-bin/render-charsheet.cgi
	rsync -avP $REMOTE/render.cgi $REMOTEHOST:www/cgi-bin/$REMOTECGINAME

GITDOCS=index.html README.html YAML.html QUICKSTART.html
github:V: ${GITDOCS:%=docs/%}

docs/&.html: &.md
	pandoc -s -o $target -c charsheet.css $prereq

push:V: ${GITDOCS:%=docs/%}
	git commit -m 'updated web page' -- $prereq
	git push

$REMOTE/index.html: docs/index.html mkfile
	cat docs/index.html > $target

$REMOTE/render.cgi: www/halligan-prefix.sh www/render.cgi
	cat $prereq > $target
        chmod 755 $target 

$REMOTE/charsheet.css:	docs/charsheet.css
	/bin/cp $prereq $target

yaml/silver-king-%.yaml:D: yaml/king-%.yaml lib/un3ify
	lib/un3ify yaml/king-$stem.yaml > $target

###################

$S/king-%.s.pdf: yaml/silver-king-%.yaml bin/charsheet templates/caster.tex templates/charsheet.sty
	bin/charsheet -t silverpine -o $target yaml/silver-king-$stem.yaml

$S/%.3.pdf: yaml/%.yaml bin/charsheet templates/3col.tex templates/charsheet.sty
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

$S/mario.3.pdf: bin/charsheet yaml/mario.yaml $TEMPLATES_TEX templates/charsheet.sty
	bin/charsheet -t 3col -o $target yaml/mario.yaml

mario.pdf: bin/charsheet yaml/mario.yaml $TEMPLATES_TEX templates/charsheet.sty
	bin/charsheet -o $target yaml/mario.yaml

mario-preview.png: mario.pdf
	convert -density 50 $prereq $target
