## This project

A D&D character-sheet generator system that converts YAML character
data into professional LaTeX-typeset character sheets.  YAML may come from a web form.
Critical parts:

  - bin/charsheet and its aliases render YAML into various useful forms
  - templates/ has LaTeX style `charsheet.sty` and sheet-layout templates like `silverpine.tex`
  - www/character-form.html has the web form, plus JavaScript to upload and download YAML
  - `QUICKSTART.yaml`: documentation that uses examples of valid YAML files to help human creators get started. 

  - `YAML.md` is the reference
  - `www/character-form.html`: A web form, plus JavaScript, that provides a means of creating a character sheet by filling in the form, without knowing the YAML.  This form includes a button that forwards YAML to a web service that is backed by the `charsheet` script.  **Important:** The form must send the YAML data raw, and the form just trust the server's response, complete with headers.  It must never try to capture or massage the server's response.  Let the browser take care of it.

## Example files

Example YAML files may be found here in `yaml/*.yaml` as well as in `/home/nr/etc/dnd/my-adventures/*.yaml`.

## LaTeX Style System

The `charsheet.sty` package provides:

### Visual Elements
- TikZ-based decorative boxes with rounded corners
- Color-coded sections (stats, proficiencies, attacks, magic, etc.)
- Custom shapes for coins, hit point boxes, etc.

### Layout Components
- Responsive column layouts
- Automatic text wrapping and spacing

## File Naming Conventions

- Character YAML files: `character-name.yaml`
- Generated LaTeX: `character-name.tex`
- Template files: `template-name.tex` (e.g., silverpine.tex)
- Generated PDFs follow input name with .pdf extension

## Dependencies

- **lua5.1** - Script runtime
- **lyaml** - YAML parsing library
- **pdflatex** - LaTeX compilation (from TeX Live)
- **Required LaTeX packages**: tikz, times, xcolor, colortbl, tabularx, booktabs, calc, etc.

## HTML and CSS

Never use `nth-child` in CSS.  At need, invent a new class and label the child.

### Web form version markers

**IMPORTANT**: Every time `character-form.html` changes, its internal "Version"
string needs to be updated.  Our convention is to name each version
after a vegetable or other food category.  The next version gets a new
vegetable with its initial letter advancing by one letter of the
alphabet.  For example: eggplant could be followed by fennel which
could be followed by garlic.  If Claude can't think of an appropriate
food it is OK to skip a difficult letter like X or Z.

### Web form requirements

An empty sheet or a sheet with no magic should just show the header "Magic (click to open)."  Clicking on it should open.
  
Spells should be segregated by level, each level in its own section.
A section is headed either "Cantrips" or "Level N spells (k slots)", where the N is fixed for each level but the k can be filled in by the user in a small textbox.

Initially, no empty magic sections should be shown.  And at the end of the last section there should be a box "open level N+1 spells," where "N+1" is as appropriate.  When opened, this section will be empty, and should be succeeded by a button to open level N+2 spells, and so on up through spell level 9.  There are no spells of level 10 or beyond.
  

## Troubleshooting

### PDF Generation "Failed to fetch" Error
If the character form's "Generate PDF" button gives a "Failed to fetch" error, remind the user that this commonly happens when accessing the form via a `file://` URL instead of through a web server. The PDF generation requires HTTP/HTTPS to make fetch requests to the server endpoint. The form must be served through a web server (like Apache) for the PDF generation to work properly.
