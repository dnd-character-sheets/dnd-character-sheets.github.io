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

all:V: bundle samples
samples:V: $S/samples.pdf demo
demo:V: $S/wizard.pdf
draft:V: /tmp/README.html /tmp/YAML.html


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

docs/index.html:D: $KINGYAMLS $SILVERKINGYAMLS bin/insert-pregen-yamls www/character-form.html
	bin/insert-pregen-yamls -html www/character-form.html -o $target $KINGYAMLS $SILVERKINGYAMLS yaml/mario.yaml

bundle:V: docs/index.html docs/charsheet.css
	cp -auvL $BGS bin/charsheet templates/charsheet.sty $TEMPLATES_TEX $LUAFILES $PUBLISH
	cp -auvL docs/index.html $HOME/www/charsheet.html
	cp -auvL docs/charsheet.css $HOME/www/

publish:V: $REMOTE/index.html $REMOTE/render.cgi $REMOTE/charsheet.css
	rsync -avP $PUBLISH $REMOTEHOST:$CHARSHEET_DIR
	rsync -avP $REMOTE/index.html $REMOTE/render.cgi $REMOTE/charsheet.css $REMOTEHOST:$REMOTEWEBPATH/charsheet/
	rsync -avP $REMOTE/render.cgi $REMOTEHOST:$REMOTEWEBPATH/cgi-bin/render-charsheet.cgi
	rsync -avP $REMOTE/render.cgi homework:www/cgi-bin/$REMOTECGINAME

GITDOCS=index.html README.html YAML.html QUICKSTART.html
github:V: ${GITDOCS:%=docs/%}

docs/&.html: &.md
	pandoc -s -o $target -c charsheet.css $prereq

push:V: ${GITDOCS:%=docs/%}
	git commit -m 'updated web page' -- $prereq
	git push

$REMOTE/index.html: docs/index.html mkfile
	cat docs/index.html > $target

$REMOTE/render.cgi: halligan-prefix.sh render.cgi
	cat $prereq > $target
        chmod 755 $target 

$REMOTE/charsheet.css:	docs/charsheet.css
	/bin/cp $prereq $target

yaml/silver-king-%.yaml:D: yaml/king-%.yaml un3ify
	un3ify yaml/king-$stem.yaml > $target

yaml/king-%.s.pdf: yaml/silver-king-%.yaml charsheet caster.tex charsheet.sty
	charsheet -t silverpine -o $target yaml/silver-king-$stem.yaml

%.3.pdf: %.yaml charsheet 3col.tex charsheet.sty
	charsheet -t 3col -o $target $stem.yaml

samples.pdf: ${KINGS:%=king-%.s.pdf} ${KINGS:%=king-%.3.pdf}
	set -A pdfs
	for k in $KINGS; do pdfs+=(king-$k.3.pdf king-$k.s.pdf); done
	pdftk "${pdfs[@]}" cat output $target

samples1.pdf: ${KINGS:%=king-%.s.pdf} ${KINGS:%=king-%.3.pdf}
	set -A pdfs
	for k in $KINGS; do pdfs+=(king-$k.3.pdf king-$k.s.pdf); done
	./catpage1s $target "${pdfs[@]}"

3samples.pdf: ${KINGS:%=king-%.3.pdf}
	pdftk $prereq cat output $target

3samples1.pdf: ${KINGS:%=king-%.3.pdf}
	./catpage1s $target $prereq 

ssamples1.pdf: ${KINGS:%=king-%.s.pdf}
	./catpage1s $target $prereq 

ssamples.pdf: ${KINGS:%=king-%.s.pdf}
	pdftk $prereq cat output $target


mario.pdf: bin/charsheet $TEMPLATES_TEX
	bin/charsheet -o $target mario.yaml

mario-preview.png: mario.pdf
	convert -density 50 $prereq $target
