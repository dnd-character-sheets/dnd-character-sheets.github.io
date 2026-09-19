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
    ```
    apt install luarocks
    ```
 - A Lua binding for YAML parsing:
   ```
   luarocks install lyaml
   ```
 - The TeX Live distribution from 2024.  Later distributions may work,
   but new TeX Live distributions often introduce incompatibilities.

   A full or nearly-full TeXLive install covers the packages the
   templates need.  If you're using a minimal one, `./configure`
   (below) reads `templates/*.tex` and `templates/*.sty` itself and
   tells you if any of the packages they ask for are missing, rather
   than you having to track the list by hand.

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
