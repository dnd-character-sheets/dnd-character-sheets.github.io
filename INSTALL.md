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
to build or generate.  It locates `lib/lua/` — the small pure-Lua
modules it ships with — from how it was invoked (`argv[0]`), as long
as the path used to run it contains a `bin/` component:
`./bin/charsheet`, an absolute path, or a bare `charsheet` found via
`$PATH` all work.  And it asks `luarocks` directly, at startup, where
`lyaml` is — wherever *your* `luarocks` put it, a per-user tree under
`$HOME/.luarocks`, a system tree under `/usr/local`, or somewhere else
again, `charsheet` finds it itself.

So `./configure` doesn't need to write anything.  It just checks, once
from the top of the checkout, that this machine actually has what
`charsheet` is about to go looking for:

```sh
./configure
```

It tries Lua 5.1 and 5.2, confirms `lyaml` loads for at least one of
them, and checks for `pdflatex`, `xelatex`, and whatever TeX packages
`templates/*.tex` and `templates/*.sty` actually `\usepackage` or
`\RequirePackage` — then finishes with a real end-to-end run of
`charsheet`.  It prints what it's checking as it goes, and tells you
what to install if something's missing.  Re-run it whenever you
reinstall Lua or Lua packages on this machine, or after a template
starts using a new package; nothing here goes stale the way a
written-out config file or list would.

A few other things depend on where *you* keep the checkout, rather
than on the machine, so `configure` leaves them to you:

```sh
export PATH="$(pwd)/bin:$PATH"
export CHARSHEETS="$(pwd)/templates"
export TEXINPUTS=".:$(pwd)/templates//:"
```

 - `PATH` lets you type `charsheet`, `gmsheet`, `gmspells` from any
   directory.
 - `CHARSHEETS` is where `charsheet` looks for its templates; without
   it, `charsheet` falls back to
   `$HOME/etc/dnd/resources/character-sheets/templates`, which is only
   right if you happen to have cloned there.  `-templates DIR`
   overrides it for one invocation instead.
 - `TEXINPUTS` is how `pdflatex`/`xelatex` find `charsheet.sty`.

(Put these three lines in your shell's rc file, or in a small
`charsheets-env.sh` you `source` before use, so you don't retype them
every session.)

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

If `charsheet` complains about a missing Lua module, run `./configure`
to see what it's missing; if `pdflatex`/`xelatex` can't find
`charsheet.sty`, double check `TEXINPUTS`.

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
