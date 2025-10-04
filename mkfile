MKSHELL=/bin/ksh
PUBLISH=/usr/local/charsheet
REMOTE=corylea
RHOST=corylea.com
REMOTE=dreamhost
RHOST=build-prove-compare.net
BPCHOME=/home/dh_q745m7
REMOTE=homework
RHOST=/h/nr/www
CHARSHEET_DIR=/h/nr/www
HALLIGANNAME=render-charsheet.cgi

KINGS=fighter barbarian cleric paladin rogue monk wizard sorcerer


all:V: bundle samples.pdf
samples: samples.pdf 3samples.pdf

LUAUTIL=flags inspect osutil tabutil
LUAFILES=${LUAUTIL:%=$HOME/src/lua/%.lua}

bundle:V:
	cp -auvL splash.png charsheet charsheet.sty silverpine.tex 3col.tex $LUAFILES $PUBLISH
	cp -auvL character-form.html $HOME/www/charsheet.html
	cp -auvL claude-character-form.html $HOME/www/claude.html
	cp -auvL hof-character-form.html $HOME/www/hof.html

publish:V: $REMOTE/index.html $REMOTE/render.cgi
	rsync -avP $PUBLISH $REMOTE:$CHARSHEET_DIR
	rsync -avP $REMOTE/index.html $REMOTE/render.cgi $REMOTE:$RHOST/charsheet/
	if [[ $REMOTE = homework ]]; then rsync -avP $REMOTE/render.cgi homework:www/cgi-bin/$HALLIGANNAME; fi

corylea/index.html: character-form.html
	cat $prereq > $target
corylea/render.cgi: corylea-prefix.sh /usr/lib/cgi-bin/render.cgi
	cat $prereq > $target
	chmod +x $target

dreamhost/index.html: character-form.html
	cat $prereq > $target
dreamhost/render.cgi: corylea-prefix.sh /usr/lib/cgi-bin/render.cgi
	sed "s@/home/corylea@$BPCHOME@g" $prereq > $target
	chmod +x $target

homework/index.html: character-form.html mkfile
	sed "s@/charsheet/render.cgi@/~nr/cgi-bin/$HALLIGANNAME@g" character-form.html > $target
homework/render.cgi: halligan-prefix.sh /usr/lib/cgi-bin/render.cgi
	cat $prereq > $target
        chmod 755 $target 


%.s.pdf: %.yaml charsheet caster.tex charsheet.sty
	charsheet -t silverpine -o $target $stem.yaml

%.3.pdf: %.yaml charsheet 3col.tex charsheet.sty
	charsheet -t 3col -o $target $stem.yaml

samples.pdf: ${KINGS:%=king-%.s.pdf} ${KINGS:%=king-%.3.pdf}
	set -A pdfs
	for k in $KINGS; do pdfs+=(king-$k.3.pdf king-$k.s.pdf); done
	pdftk "${pdfs[@]}" cat output $target

3samples.pdf: ${KINGS:%=king-%.3.pdf}
	pdftk $prereq cat output $target

3samples1.pdf: ${KINGS:%=king-%.3.pdf}
	./catpage1s $target $prereq 
3sampless.pdf: ${KINGS:%=king-%.s.pdf}
	./catpage1s $target $prereq 

