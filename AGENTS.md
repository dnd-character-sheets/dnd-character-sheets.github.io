## This project

A D&D character-sheet generator system that converts YAML character
data into professional LaTeX-typeset character sheets.  YAML may come from a web form.
Critical parts:

  - bin/charsheet and its aliases render YAML into .tex or .pdf
  - templates/ has LaTeX style `charsheet.sty` and sheet-layout templates like `silverpine.tex`
  - www/character-form.html has the web form, plus JavaScript to upload and download YAML.  The `Generate PDF` button sends YAML to a back end that runs `bin/charsheet`.
  - `js-testing/` has some infrastructure for testing the JavaScript.
  - `QUICKSTART.yaml`: documentation that uses examples of valid YAML files to help human creators get started. 
  - `YAML.md` is the reference

**Important:** The web form must send the YAML data raw, and the form must trust the server's response, complete with headers.  It must never try to capture or massage the server's response.  Let the browser take care of it.

Other parts:

  - README.md advertises the project and has many details

  - Many YAML examples in `yaml/*.yaml` and `yaml/*/*.yaml`. Also `/home/nr/etc/dnd/my-adventures/*.yaml`.

  - templates/ provides charsheet.sty and three .tex layouts (silverpine, 3col, tropical).

## HTML and CSS

### Web form 

**IMPORTANT**: Every time `character-form.html` changes, its internal "Version"
string needs to be updated.  Our convention is to name each version
after a vegetable or other food category.  The next version gets a new
vegetable with its initial letter advancing by one letter of the
alphabet.  For example: eggplant could be followed by fennel which
could be followed by garlic.  If  you can't think of an appropriate
food it is OK to skip a difficult letter like X or Z.

Requirements:

  - Empty MAGIC section has to be opened.
  - Spells are segregated by level

## Troubleshooting

### PDF Generation "Failed to fetch" Error

If the character form's "Generate PDF" button gives a "Failed to fetch" error, remind the user that this commonly happens when accessing the form via a `file://` URL instead of through a web server. The PDF generation requires HTTP/HTTPS to make fetch requests to the server endpoint. The form must be served through a web server (like Apache) for the PDF generation to work properly.
