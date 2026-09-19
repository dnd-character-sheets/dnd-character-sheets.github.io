---
title: Running character-sheet software on your own machine
---

These instructions let you run `charsheet`
on your own machine, turning a character's YAML into a PDF without
using the web form.
You can also run the `gmsheet` and `gmspells` scripts, which prepare
useful summaries for a Game Master to use at the table.

Creating your own Web service is also possible in principle, but there
are too many moving parts.  If you're feeling brave look at the
`publish` target in the `mkfile`.

## Dependencies

The character-sheet software requires the following dependencies:

  - Lua version 5.1 or 5.2.
  - `luarocks`, to install `lyaml`
  - The `lyaml` Lua binding for YAML parsing
  - The TeX Live distribution from 2024.  Later distributions may work,
    but new TeX Live distributions often introduce incompatibilities.

    A full or nearly-full TeXLive install covers the packages the
    templates need.
  - TeX Gyre fonts

Lua, `luarocks`, and TeXLive should all be easy to install with your
distribution's package manager.
On Debian/Ubuntu, the following should suffice:

```sh
sudo apt install lua5.1 luarocks \
    texlive-latex-base texlive-latex-recommended \
    texlive-latex-extra texlive-base texlive-pictures \
    texlive-plain-generic texlive-xetex \
    fonts-texgyre
luarocks install lyaml
```

## Check out the repository

```sh
git clone https://github.com/dnd-character-sheets/dnd-character-sheets.github.io.git charsheets
cd charsheets
```

## Check dependencies

The repo includes a `configure` script that checks for the necessary
dependencies.

```sh
./configure
```

This script checks for the dependencies above, including the LaTeX
packages actually used in the templates.  It prints what it's
checking, and if something is missing it tells you what to install.

No actual configuration is written; the main script uses `realpath` to
locate its installation directory, which contains everything else it
needs.

## Make commands visible

To run the `charsheet`, `gmsheet`, and
`gmspells`  scripts, you have one of two approaches:

  - Put the installation directory's `bin` on your `$PATH`, as in

    ```sh
    export PATH="$(pwd)/bin:$PATH"
    ```

  - Create symbolic links from a directory already on your `$PATH`,
    perhaps `~/bin`:

    ```sh
    ln -s "$(pwd)/bin/charsheet" ~/bin/charsheet
    ln -s "$(pwd)/bin/gmsheet"   ~/bin/gmsheet
    ln -s "$(pwd)/bin/gmspells"  ~/bin/gmspells
    ```

The scripts *cannot* successfully be *copied* to another location;
they rely on the `templates` and `lib` directories being siblings to
the `bin` directory.

## Verify

As a test, run

```sh
charsheet -o /tmp/mario.pdf yaml/mario.yaml
```

This command should produce a one-page PDF at `/tmp/mario.pdf` with no error
output.
(LaTeX will emit a tremendous amount of noise; ignore it.)

If `charsheet` complains about a missing Lua module or can't find
`charsheet.sty`, run `./configure` to see what it's missing.


## Creating game-master sheets

When invoked as `gmspells` or `gmsheet`, the main script produces
pages of summary information.  The arguments should include YAML files
for each of the characters in your party, as in these examples:

```sh
gmspells -o /tmp/spells.pdf yaml/king-barbarian.yaml yaml/king-cleric.yaml yaml/king-wizard.yaml yaml/king-rogue.yaml
gmsheet -o /tmp/sheet.pdf yaml/king-barbarian.yaml yaml/king-cleric.yaml yaml/king-wizard.yaml yaml/king-rogue.yaml
```

