#!/usr/bin/env bash
set -euo pipefail

export CHARSHEET_CMD=/h/nr/www/charsheet/charsheet
export CHARSHEETS=/h/nr/www/charsheet/
export TEXINPUTS=.:/h/nr/www/charsheet/:
export PATH="/usr/local/bin:/home/nr/bin:/usr/sup/bin:/usr/local/texlive/2025/bin/x86_64-linux:$PATH"
export LUA_PATH="/h/nr/src/lua/?.lua;/h/nr/src/lua/?/init.lua;/h/nr/lib/lua/5.1/?.lua;/usr/unsup/nr/lib/lua5.1/?.lua;/usr/unsup/nr/lib/lua5.1/?/init.lua;/h/nr/.luarocks/share/lua/5.1/?/init.lua;/h/nr/.luarocks/share/lua/5.1/?.lua;;"
export LUA_CPATH="/h/nr/machine/amd64-linux/lib/?.so;/h/nr/machine/amd64-linux/lib/lua5.1/?.so;/usr/unsup/nr/lib/lua5.1/?.so;/h/nr/.luarocks/lib/lua/5.1/?.so;;"

DEBUG="PATH=$PATH
LUA_PATH=$LUA_PATH
LUA_CPATH=$LUA_CPATH
which lua.51: $(type lua5.1)"

lua="$(which lua5.1)"

if [[ ! -x "$lua" ]]; then
  DEBUG="$DEBUG
/usr/sup/bin/lua5.1 is NOT executable"
fi

