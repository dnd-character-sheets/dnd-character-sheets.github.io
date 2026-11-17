# Task: Move character-sheet PDF generation into the browser

The application in www/character-form.html currently generates LaTeX in JavaScript, sends it to a server, and receives a PDF. Replace server-side compilation with client-side WebAssembly, preserving existing behavior.

Work incrementally. Work on a new git branch called `browser-only`.  Use `git worktree` to do the work in a distinct working directory.  Do not modify the production workflow. 

## Steps

1. **Inspect the existing implementation.** Identify how LaTeX is generated, which packages, classes, fonts, and auxiliary files are required.  Consider all {caster,3col,tropical}.tex and charsheet.sty in the templates directory.  Also observe how bin/charsheet decides to invoke `pdflatex` or `xelatex`.

2. **Establish a baseline.** Save representative generated `.tex` files, including one requiring XeLaTeX.  Use YAML files from ~/etc/dnd/my-adventures.  Record compilation times and retain PDFs for comparison.

3. Identify a common preamble that can be shared among {caster,3col,tropical}.tex.
   This preamble should load packages only; it should not define any macros or tikz styles.  Refactor these three files to use the common preamble.

4. **Build custom formats.** Experiment with [`mylatexformat`](https://ctan.org/pkg/mylatexformat) to preload the document class, TikZ, and other fixed dependencies. Build separate pdfTeX and XeTeX formats. Verify that they compile the baseline documents correctly.

5. **Identify runtime dependencies.** Use TeX's `-recorder` option and `.fls` files to identify resources still needed after loading the formats. These resources will certainly include templates/*.png.  Construct the smallest practical resource bundle.

6. **Evaluate Wasm engines.** Start with BusyTeX and SwiftLaTeX. Determine whether each supports custom format files, both pdfTeX and XeTeX, and the required fonts and packages. Check licensing compatibility.

7. **Extend the charsheet script.**  Extend `bin/charsheet` with a `-from-lua` option whereby the character sheet is represented not in YAML but as a Lua table that can be loaded with Lua `loadstring`.  Define a standalone `yaml-to-lua` script that uses `lyaml` to turn YAML into a Lua table, then externalize the table using the `filetable` module.  Connect the two together and confirm that `charsheet` can convert YAML via this path with no regressions.

8. **Port the charsheet script to WASM**.  Using the Lua sources in ~/net/lua-5.1.5, compile Lua to WASM.  Using the amalgamated `bin/exported-charsheet`, create a web page based on character-form.html, except that instead of invoking a server to produce PDF, the page simply produces the `.tex` needed to render the character sheet.

9. **Build a standalone browser prototype.** When the TeX run succeeds, return a PDF Blob. On failure, return a text blob containing the console output from TeX.  Demonstrate the prototype by compiling a representative generated `.tex` file entirely in a Web Worker, using the custom format and bundled resources. No server-side compilation is permitted.

10. **Measure and validate.** Compare output against the baseline, including layout, fonts, TikZ graphics, and page breaks. Measure initial download size, cold compilation time, and warm compilation time. Test offline operation after assets have been cached.

11. **Integrate with the application.** Replace the server request with browser-side compilation. Preserve the existing ASCII/non-ASCII engine selection unless measurements justify using XeTeX unconditionally. Provide useful compilation errors and PDF download/preview behavior.

12. **Prepare deployment.** Bundle and cache Wasm engines, formats, fonts, and resources for GitHub Pages. Ensure that version changes invalidate incompatible cached formats.

## Constraints

- Preserve existing character-sheet appearance and functionality.
- Prefer a small, fixed TeX distribution over a general-purpose TeX Live installation.
- Generate format files using the exact engine build that will load them.
- Keep document-specific state out of precompiled formats.
- Do not require a backend or external compilation service.
- Avoid unrelated refactoring.

## Deliverables

- Working browser-only PDF compilation.
- Reproducible scripts for building custom formats and resource bundles.
- Compilation and download-size benchmarks.
- Brief documentation of architecture, dependencies, limitations, and deployment.
- A clear report of any blockers before making major architectural changes.
