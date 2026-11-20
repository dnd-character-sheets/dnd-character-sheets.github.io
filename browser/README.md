# Typesetting character sheets in the browser

The character form (`www/character-form.html`, deployed as
`docs/index.html`) makes PDFs with no server: `bin/charsheet` and TeX
run in the browser, compiled to WebAssembly, in a Web Worker whose
files the form finds in `typesetter/` beside it.
The PDFs are identical to those that `bin/charsheet` makes with TeX
Live 2025.

## How a sheet is typeset

```
form (generatePDF in character-form.html)
  │  YAML text, from createYAMLContent()
  ▼
Web Worker (typeset-worker.js)
  1. Lua 5.1 + lyaml (lua.wasm) runs charsheet.lua -wasm   YAML → sheet.tex
  2. engine choice, as in bin/charsheet: any byte ≥ 0x80 → XeTeX, else pdfTeX
  3. BusyTeX (busytex.wasm):  pdftex                       sheet.tex → sheet.pdf
                          or  xetex -no-pdf, xdvipdfmx     sheet.tex → .xdv → .pdf
  │  PDF Blob, or a text Blob holding the console output of charsheet and TeX
  ▼
new tab, opened during the click so that pop-up blockers allow it; a PDF
shows at typesetter/pdf/NAME.pdf, which the service worker pdf-server.js
serves from the browser's cache with the headers a server would send,
so that the browser shows it and saves it as NAME.pdf
```

Each run gets a fresh Wasm instance, so it starts from a clean address
space, and the instance's in-memory file system (Emscripten's MEMFS)
receives the files it needs:

| Path | Contents |
|---|---|
| `/charsheet/bin/charsheet` | `charsheet.lua`: `bin/charsheet` with its Lua modules, lyaml's included |
| `/charsheet/templates/` | layouts, `charsheet.sty`, `charsheet-packages.sty`, `articlesize.sty`, images |
| `/texmf/` | the TeX Live files that sheets read, `texmf.cnf`, a small `pdftex.map`, `fonts.conf` |
| `/formats/` | the format for the chosen engine |
| `/work/` | `sheet.yaml`, `sheet.tex`, and outputs |

## What loads when

The page starts the worker as it loads, and the worker fetches, in
parallel, everything but the pdfTeX format and the extra fonts:

| File | Compressed | Loaded |
|---|---|---|
| `busytex.wasm` | 1.9 MB | at page load |
| `charsheet-xetex.fmt` | 3.6 MB | at page load |
| `core.tar` | 2.7 MB | at page load |
| `lua.wasm`, `lua.js`, `busytex.js`, `charsheet.lua` | 0.2 MB | at page load |
| `charsheet-pdftex.fmt` | 3.4 MB | when an ASCII sheet first needs it |
| `extras.tar` | 3.6 MB | when TeX fails without it; the run is then retried |

Every file is served gzipped, so it downloads compressed from any
server, and the worker gunzips it unless the server has.  The served
names include a hash of the contents, as listed in `manifest.json`,
which the worker rechecks with the server whenever it starts: browsers
may cache files indefinitely, engines and formats from different builds
never meet, and returning visitors download only files that changed.
The worker compiles Wasm as it downloads, whatever Content-Type the
server sends.  Once loaded, files serve every later
sheet.  A sheet then takes about 0.2 to 1.3 s, median 0.7 s, in Chrome
and Firefox.

## Pieces

**Templates.**  The layouts share a preamble, `charsheet-packages.sty`,
which loads packages only and so can live in a format.  Each layout
loads it, marks `\endofdump`, and sets its type size with `\articlesize`
from `articlesize.sty`, which reproduces the article class's size
option after the class.  `DOCUMENT FONT` rewrites that `\articlesize`
argument.  booktabs (which measures in em as it loads) and fontspec
(which loads OpenType fonts as it loads) are loaded by `charsheet.sty`.

**Formats.**  `build-formats` builds, for each engine, a LaTeX kernel
format with English hyphenation only (`texmf/.../language.dat`) and on
top of it a `mylatexformat` format from `charsheet-format.tex`, which
holds a layout's preamble up to `\endofdump`.  A format must be built by
the engine build that loads it.

**TeX files.**  `texlive-files` runs the native pipeline under strace
and lists the TeX Live files read while building formats
(`texlive/formats.files`), while typesetting the baseline sheets
(`texlive/sheets.files`), and the rest of the font families those
sheets use (`texlive/extras.files`).  `baseline/markup.yaml` exercises
the markup that sheets may use, so that its fonts are traced.
`build-texmf` assembles a tree from the lists.

**Engines.**  `build-busytex` builds BusyTeX (TeX Live 2023) with only
pdfTeX, XeTeX, xdvipdfmx, and kpsewhich, and with only the ICU data in
`icu-data.keep`.  `build-lua` builds Lua 5.1.5 with libyaml and lyaml's
C module and amalgamates `charsheet.lua`.  `charsheet -wasm` runs no
other programs and writes TeX only.

**Typesetter files.**  `build-typesetter` fills `browser/build/typesetter`
with the worker, the compressed engines, formats, and TeX files under
hashed names, `manifest.json`, `web/pdf-server.js`, and
`web/selftest.html`.

## Building

`mk typesetter` runs these steps as needed; `mk bundle` installs the
form and `typesetter/` in `~/www` to try them locally.

```
browser/build-busytex                      # first time about 30 minutes
browser/build-lua
browser/build-texmf browser/texlive/*.files
BUSYTEX=$PWD/browser/build/engines/busytex-slim TEXMFTREE=$PWD/browser/build/texmf \
  PDFTEX=$PWD/browser/wasm-bin/pdftex XETEX=$PWD/browser/wasm-bin/xetex \
  browser/build-formats -d browser/build/fmt-busytex
browser/build-typesetter -d browser/build/typesetter
```

`browser/wasm-bin` holds links to `busytex` named for the programs it
runs.  When the templates or TeX Live change, regenerate
`browser/texlive/*.files` with `mk texlive-lists`.

Build needs: emscripten, gcc, cmake, gperf, perl, python3, git, wget,
pigz, strace, native TeX Live, Lua 5.1 and 5.2 with lyaml, `amalg`, and
Node 20.  The page needs WebAssembly, Web Workers, and
`DecompressionStream` (Chrome 80, Firefox 113, Safari 16.4).

## Testing

| Script | Checks |
|---|---|
| `record-baseline` | typesets `baseline/cases` natively, optionally with formats, and times it |
| `compare-pdfs` | PDFs alike: same bytes (ignoring `/ID`), else same pixels |
| `busytex`, `wasm-charsheet` | run the Wasm builds under Node as native commands, so the scripts above can drive them |
| `browser-test` | typesets YAML files in headless Chrome or Firefox (`web/selftest.html`) and times first, warm, and reloaded runs |

`baseline/timings.tsv` times native TeX Live; `baseline/browser-timings.tsv`
times Chrome and Firefox with files from a local web server, and
`baseline/live-timings.tsv` with files from dnd-character-sheets.github.io.

All baseline sheets, the markup sheets, and private sheets kept out of
the repository render identically to native TeX Live in Node, Chrome,
and Firefox.

## Limitations

- The engines are TeX Live 2023; the TeX files are TeX Live 2025.
- With the reduced ICU data, `\XeTeXlinebreaklocale` breaks CJK and
  Southeast Asian text by rule rather than by dictionary, and
  `\XeTeXinputencoding` knows only UTF-8, UTF-16, and Mac Roman.
- A sheet whose fonts are in neither `core.tar` nor `extras.tar` fails.
- The first sheet waits for about 8.4 MB to download.
- Assets are cached only by the browser's HTTP cache; offline use and
  cache invalidation across versions are not yet provided.
