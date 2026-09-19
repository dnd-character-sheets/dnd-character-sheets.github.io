---
title: Running character-sheet software on your own machine
---

# Running character-sheet software locally

These instructions let you run `charsheet`
on your own machine, turning a character's YAML into a PDF without
using the web form.
You can also run the `gmsheet` and `gmspells` scripts, which prepare
useful summaries for a Game Master to use at the table.

## Dependencies

 - Lua version 5.1 or 5.2.
   On Debian/Ubuntu,
   ```
   apt install lua5.1
   ```
 - `luarocks`, to install one Lua package:

    ````
    apt install luarocks
    ````
 - A Lua binding for YAML parsing:
   ```
   luarocks install lyaml
   ```
 - The TeX Live distribution from 2024.  Later distributions may work,
   but new TeX Live distributions often introduce incompatibilities.
   A full or nearly-full TeXLive install covers the packages the
   templates need.

Lua, `luarocks`, and TeXLive should all be easy to install with your
distribution's package manager.

## Check out the repository

```sh
git clone https://github.com/dnd-character-sheets/dnd-character-sheets.github.io.git charsheets
cd charsheets
```

## Configure

`charsheet` finds its own dependencies at run time, so there's nothing
to build or generate.  It locates both `lib/lua/` — the small pure-Lua
modules it ships with — and `templates/` from how it was invoked
(`argv[0]`), as long as the path used to run it contains a `bin/`
component: `./bin/charsheet`, an absolute path, or a bare `charsheet`
found via `$PATH` all work.  It asks `luarocks` directly, at startup,
where `lyaml` is — wherever *your* `luarocks` put it, a per-user tree
under `$HOME/.luarocks`, a system tree under `/usr/local`, or
somewhere else again, `charsheet` finds it itself.  And it sets
`$TEXINPUTS` for `pdflatex`/`xelatex` itself, from that same
self-located `templates/`, before running them.

So `./configure` doesn't need to write anything into `charsheet`
itself.  It just checks, once from the top of the checkout, that this
machine actually has what `charsheet` is about to go looking for:

```sh
./configure
```

It tries Lua 5.1 and 5.2, confirms `lyaml` loads for at least one of
them, and checks for `pdflatex`, `xelatex`, and whatever TeX packages
`templates/*.tex` and `templates/*.sty` actually `\usepackage` or
`\RequirePackage` — then finishes with a real end-to-end run of
`charsheet`, rendering an actual PDF with nothing but `$PATH` set, to
confirm the self-location and `$TEXINPUTS` really do work without any
further setup.  It prints what it's checking as it goes, and tells you
what to install if something's missing.  Re-run it whenever you
reinstall Lua or Lua packages on this machine, or after a template
starts using a new package; nothing here goes stale the way a
written-out config file or list would.

`configure` also (re)generates `bin/dndsheets`, a small dispatcher
that `exec`s whichever of `bin/charsheet`, `bin/gmsheet`, or
`bin/gmspells` it was invoked as, from this checkout, wherever that
checkout lives.  That gives you two ways to make `charsheet`,
`gmsheet`, and `gmspells` typeable from anywhere, without needing
`$CHARSHEETS` or `$TEXINPUTS` at all:

```sh
export PATH="$(pwd)/bin:$PATH"
```

or, if you'd rather not put the whole checkout on `$PATH`, symlink the
one dispatcher under each name from a directory that's already there
(`~/bin`, say):

```sh
ln -s "$(pwd)/bin/dndsheets" ~/bin/charsheet
ln -s "$(pwd)/bin/dndsheets" ~/bin/gmsheet
ln -s "$(pwd)/bin/dndsheets" ~/bin/gmspells
```

Either way, this only needs doing once (or again if you move the
checkout and re-run `./configure`, which rewrites `bin/dndsheets`'
notion of where it lives) — put the `export` line in your shell's rc
file if you go that route, so you don't retype it every session.  If
you ever do need to point at a different templates directory than the
one in this checkout — a customized fork, say — `$CHARSHEETS` or
`-templates DIR` still override the default.

## Verify

```sh
charsheet -o /tmp/mario.pdf yaml/mario.yaml
```

This should produce a one-page PDF at `/tmp/mario.pdf` with no error
output.  (LaTeX `Overfull \hbox` warnings on stderr are cosmetic and
expected; anything under `! LaTeX Error` or a nonzero exit means
something above wasn't set up correctly.)

`gmsheet` and `gmspells` are the same program as `charsheet` — they
are symlinks to it, and it looks at how it was invoked (`argv[0]`) to
decide which output to produce — so once `charsheet` works, so do
they:

```sh
gmsheet -o /tmp/mario-gm.pdf yaml/mario.yaml
gmspells -o /tmp/mario-spells.pdf yaml/mario.yaml
```

If `charsheet` complains about a missing Lua module or can't find
`charsheet.sty`, run `./configure` to see what it's missing.

## What you *don't* need, unless you're rebuilding the project's own site

Everything above is all `charsheet`, `gmsheet`, and `gmspells` need to
run. A separate set of tools — `mk` (plan9/9base `mk`, not GNU make),
`ksh`, `pandoc`, `pdftk`, `yamllint`, and ImageMagick's `convert` — is
used only by `mkfile`, to regenerate this repository's own samples,
docs, and test corpus. You don't need any of them just to turn your
own YAML into a PDF.

## Uploading YAML instead

If you'd rather not install anything, the web form at
[`https://dnd-character-sheets.github.io`](https://dnd-character-sheets.github.io)
runs `charsheet` for you — see the [`README`](README.md).

## Installing the web service on your own server (optional)

Everything above runs `charsheet` from a shell.  This section is for
hosting your *own* copy of the web form and its backend — the thing
`https://dnd-character-sheets.github.io` does — on a server you
control.  It needs everything above, working, on that server, plus a
web server that can run CGI scripts (these instructions assume
Apache).

### 1. Deploy the backend, `www/render.cgi`

Copy or symlink it into your web server's `cgi-bin`.  On Debian/Ubuntu
with `apache2` and `mod_cgi`/`mod_cgid` enabled, that's typically
`/usr/lib/cgi-bin/`:

```sh
sudo cp www/render.cgi /usr/lib/cgi-bin/
```

`render.cgi` runs `charsheet` (bare, found via the web server's own
`$PATH`) by default.  A CGI environment's `$PATH` is usually much
narrower than your login shell's, so unless `charsheet` is genuinely
on it, set `$CHARSHEET_CMD` to an absolute path — `bin/charsheet` from
this checkout, or a `bin/dndsheets` symlink (see Configure, above)
works too:

```sh
export CHARSHEET_CMD=/path/to/charsheets/bin/charsheet
```

How you set that for the CGI process depends on your server; Apache's
`SetEnv` directive, or a one-line wrapper script placed where
`render.cgi` is (see the prefix-script pattern below), both work.

Two more environment variables `render.cgi` reads, both optional:

 - `MAX_YAML_BYTES` (default 2 MiB) — rejects larger request bodies
   before doing anything with them.
 - `RENDER_TIMEOUT_SECS` (default 30) — kills a `charsheet` run that's
   still going after this long, and everything it spawned (it runs as
   the leader of its own process group for exactly this reason).

### 2. Serve the form

The simplest setup serves `www/character-form.html` from the *same*
origin as `render.cgi` (e.g. both under the same Apache vhost) — in
that case there's nothing else to configure: same-origin requests
aren't subject to CORS at all, and you can skip straight to step 3.

If you'd rather use the version with pregenerated characters already
loaded into it, `mk docs/index.html` builds that from
`www/character-form.html`; either file works as the form.

### 3. Point the form at your backend

`www/character-form.html`'s `generatePDF()` function has one hardcoded
URL, in its `fetch(...)` call — change it to wherever you put
`render.cgi`:

```js
const response = await fetch('https://your-server.example/cgi-bin/render.cgi', {
```

**If you edit `character-form.html`, bump its `Version:` string** —
this project's convention, from `AGENTS.md`: each version is named
after a vegetable (or other food) one initial letter further into the
alphabet than the last (eggplant → fennel → garlic, ...).

### 4. Cross-origin access (only if the form isn't same-origin with `render.cgi`)

`render.cgi`'s own `Access-Control-Allow-Origin` handling is a no-op
by default (`*`, meaning "no Origin header to react to" — i.e. not a
browser request at all) and it doesn't answer the CORS *preflight*
`OPTIONS` request browsers send before a cross-origin
`Content-Type: text/yaml` POST (which isn't a CORS-"simple" request,
so the preflight isn't optional). Serving the form from a different
origin than the backend therefore needs something to answer that
`OPTIONS` request and compute a real origin allowlist.

`www/halligan-prefix.sh` is the author's own version of that, meant to
be concatenated in front of `render.cgi` at deploy time (see the
`$REMOTE/render.cgi` target in `mkfile`) — it's a worked example to
adapt, not something to use verbatim: its `allowed_origin()` allowlist
and every path it exports (`$CHARSHEET_CMD`, `$LUA_PATH`, ...) are
specific to the author's own machine, and the `$LUA_PATH`/`$CHARSHEETS`/
`$TEXINPUTS` exports it sets are no longer needed at all now that
`charsheet` locates those itself (see Configure, above) — a prefix
script for a fresh deployment only needs an `allowed_origin()` matching
your own domain(s), the `OPTIONS` handling around it, and
`$CHARSHEET_CMD`.

### A privacy note

`render.cgi` keeps the most recently submitted sheet at
`/tmp/last-charsheet.yaml` (and, on a failed render, the raw
stderr/stdout too) for local debugging — written safely against
symlink attacks, but still every submitter's character sheet, in the
clear, on your server. Decide whether that's acceptable for your
deployment before you put it in front of real users; the `README`'s
privacy expectations for the author's own instance won't automatically
apply to yours.
