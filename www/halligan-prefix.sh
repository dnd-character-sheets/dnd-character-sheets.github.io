#!/usr/bin/env bash
set -euo pipefail

# Origin allowlist. Computed once, here, and used for BOTH the OPTIONS
# preflight below and the real POST response render.cgi sends further
# down (this file is concatenated in front of it -- see mkfile). Echoes
# "*" for a non-browser request (no Origin header at all), the exact
# origin when it's on the allowlist, or the empty string when it's set but not
# allowed -- the empty case matters and is not the same as "*": it means
# "omit the Access-Control-Allow-Origin header", i.e. deny.
allowed_origin() {
  local origin="${HTTP_ORIGIN:-}"
  if [[ -z "$origin" ]]; then
    echo '*'
    return
  fi
  case "$origin" in
    https://www.cs.tufts.edu|https://www.cs.tufts.edu/*|\
    https://dnd-character-sheets.github.io|\
    https://nr.chickenkiller.com*|http://nr.chickenkiller.com*\
    )
      echo "$origin"
      ;;
  esac
}

ORIGIN="$(allowed_origin)"

if [[ "$REQUEST_METHOD" = OPTIONS ]]; then

  echo -e "Status: 200 OK\r"
  if [[ -n "$ORIGIN" ]]; then
    echo -e "Access-Control-Allow-Origin: $ORIGIN\r"
  fi
  echo -e "Access-Control-Allow-Headers: Content-Type\r"
  echo -e "Content-Type: text/plain\r"
#  echo -e "X-Request-Origin: ${HTTP_ORIGIN:-(unset)}\r"
  echo -e "\r"

  exit 0

fi


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
DROPDIR=/h/nr/www/charsheet/drop

lua="$(which lua5.1)"

if [[ ! -x "$lua" ]]; then
  DEBUG="$DEBUG
/usr/sup/bin/lua5.1 is NOT executable"
fi

