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

   A full or nearly-full TeXLive install covers the
   packages the templates need; if you're using a minimal one, make
   sure these are available: `amsmath`, `array`, `booktabs`,
   `calc`, `colortbl`, `enumitem`, `environ`, `fontspec`, `geometry`,
   `ifmtarg`, `ifthen`, `iftex`, `multicol`, `pgfkeys`, `soul`,
   `suffix`, `tabularx`, `times`, `tikz`, `xcolor`, `xstring`.

Lua, `luarocks`, and TeXLive should all be easy to install with your
distribution's package manager.

## Check out the repository

```sh
git clone https://github.com/dnd-character-sheets/dnd-character-sheets.github.io.git charsheets
cd charsheets
```

## 3. Point Lua and TeX at this checkout

`charsheet` needs a handful of small Lua modules that live in
`lib/lua/`, and its templates live in `templates/`.  Neither is found
automatically — tell Lua and TeX where they are:

```sh
here=$(pwd)
export LUA_PATH="$here/lib/lua/?.lua;$here/lib/lua/?/init.lua;;"
export TEXINPUTS=".:$here/templates//:"
export CHARSHEETS="$here/templates"
export PATH="$here/bin:$PATH"
```

(The trailing `;;` in `LUA_PATH` and the leading `.:` in `TEXINPUTS`
keep Lua's and TeX's own default search paths in effect too.  Put
these lines in your shell's rc file, or in a small `charsheets-env.sh`
you `source` before use, so you don't retype them every session.)

`CHARSHEETS` is what tells `charsheet` where its templates are; if you
don't set it, `charsheet` falls back to
`$HOME/etc/dnd/resources/character-sheets/templates`, which is only
right if you happen to have cloned there.  You can also point one
invocation at a different templates directory with `-templates DIR`
instead of exporting `CHARSHEETS`.

## 4. Verify

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

If `charsheet` complains about a missing Lua module, double check
`LUA_PATH`; if `pdflatex`/`xelatex` can't find `charsheet.sty`, double
check `TEXINPUTS`.

## 5. What you *don't* need, unless you're rebuilding the project's own site

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
