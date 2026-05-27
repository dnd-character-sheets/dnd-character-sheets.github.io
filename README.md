---
title: D&D Character Sheets using YAML
---

# Introduction

Paper character sheets are great.
A paper sheet puts
everything I need to know right in front of me; 
I don't have to mouse, click, tap, or fiddle with any device.
But when my character levels up or prepares new spells, 
a paper sheet is a pain to update.
So I created software that
produces well-designed paper sheets from 
a digital format.
The format is readable and easy to update,
and you can use the software without any kind of subscription or even a
cloud service.

A character sheet is written using
[YAML](https://en.wikipedia.org/wiki/YAML) ([beginner
tutorial](https://www.cloudbees.com/blog/yaml-tutorial-everything-you-need-get-started)).
YAML is
a common,
machine-readable, plain-text format,
and it is reasonably user-friendly.
YAML character sheets are meant to be edited and maintained with a simple,
ordinary text editor like Emacs, vim, or Notepad.

A character sheet might start something like this:

```
CHARACTER NAME: Mario Greymist
CLASS: Rogue
LEVEL: 20
PLAYER NAME: Steve
RACE: Dragaeran 
ALIGNMENT: Chaotic good

STR: 10
DEX: 20
CON: 14
INT: 12
WIS: 15
CHA: 16

PROFICIENCIES:
  - Perception
  - Sleight of Hand
  - 
  - Daggers
# ... and so on
```

From a sheet in this format, my software can produce [a PDF suitable for
printing and using at the table](mario.pdf);
here's a thumbnail:

<a href="mario.pdf">
<img src="mario-preview.png" height=300 alt="Not actually Mario's character sheet">
</a>

The software runs on Linux—the Angry GM uses Linux now, you know—but
if you don't care to install it, it is
available as [a web service](https://dnd-character-sheets.github.io).
Just go explore.

(Bonus:
If you do get the software to run on Linux, it can also create a [one-page summary of characters' important abilities and stats, for use by a GM at the table](gmsheet.pdf).)

# Using the web service

The web service offers a form that you can use to describe your character.
The form can be rendered as PDF at the click of a button;
you choose a layout from a small menu.
But a web form disappears when the browser closes,
and your character needs to last as long as your campaign.
Once you download your character sheet as a YAML file,
it lasts as long as you want to keep it.
To support YAML,
the web form begins with "load" and "download" buttons,
which move YAML between the web form and your machine.
Once you have loaded your YAML, just hit the big "Generate PDF" button.

To help you get started, I have provided some pregenerated characters to play with.

 1. Go to
    [`https://dnd-character-sheets.github.io`](https://dnd-character-sheets.github.io).
    From the first dropdown ("best at 2 columns"), choose a
    pregenerated character, perhaps Mario Greymist.  Then click "Load this
    character" on the right.
 
 2. Click the "Generate PDF" button.  After an interval, your browser should show the PDF in a new tab.
 
 3. Go back to the web form and look for
    a "Download `mario-greymist.yaml`" button.
    Click to save Mario's sheet on your machine.
    (By default, a YAML file that you download is named for the character, or if there is no character name, for the character's class.)

The web form is mostly for demo purposes.
In the long term, you will
likely edit your YAML character sheet on your own machine, 
using the text editor of your choice.
You will still use the web service to generate PDF:

 4. Go to [the web service](https://dnd-character-sheets.github.io) and use the "Load YAML file" button to load your character sheet into the web form.
 
 5. Click "Generate PDF."

# Working with YAML

## Yaml for beginners

To get started with YAML, you can
work through my [Quick-Start Guide](QUICKSTART.md), 
or you can download one of the pregenerated characters from [`https://dnd-character-sheets.github.io`](https://dnd-character-sheets.github.io).

Every YAML character sheet contains key-value pairs in the form

```
KEY: value
```

Character-sheet keys are uppercase by convention, and a value is
usually a string, a number, or a list. 
Lists look like Markdown lists, in which each item is a string marked
with a leading dash.
Most items are strings, but an item that describes an attack,
a feature, or a magic spell is itself a list of named properties.  For example, a feature has a `name` and a `description`.
An attack has `DAMAGE`, a `TYPE`, possibly a `RANGE`, and other properties.

You can edit a character sheet both on your machine and on the
web form.
If you upload your YAML to the web form, edit on the form, and
download the result,
the process should preserve all your YAML data—even fields that don't appear on the form.
But the process may add a few fields, and it may change empty values
to `null`.
Finally, the process removes blank lines, because they are not visible
to a YAML parser.


## YAML keys for this project

YAML is just a format; to write anything meaningful, you must know
what keys to use.
My software recognizes over 60 keys, from `ARMOR CLASS` to `WIS`.
Most of the keys are described in an [alphabetical
reference](YAML.md),
but you are probably better off using the 
[Quick-Start Guide](QUICKSTART.md).
And if something goes wrong, you can find the ultimate truth in the
`.sty` and `.tex` files in the [templates directory](templates).

## What you can write in text

The character sheets are rendered into PDF using the LaTeX typesetting
system; their graphic design is programmed using LaTeX's [TikZ
package](https://tikz.dev).
The text that you write is interpreted by LaTeX, which treats the `\`,
`{`, and `}` characters specially.
(If you already know LaTeX, you will need to know that LaTeX's other
special characters are escaped by the rendering engine.)

The `\` character marks a
LaTeX macro, and you will sometimes want to use macros in your text:

  - To get text to fit on a single page, you may have change font size.  Specify a size using macros `\large`, `\normalsize`, `\small`, `\footnotesize`, `\scriptsize`, and `\tiny`.

  - You can write `\textbf{`**bold text**`}`, `\emph{`_emphasis_`}`, and `\textsc{`<span style="font-size: 80%;">SMALL CAPS</span>`}`.
  
  - You can write math between `\(` ... `\)` macros, which support symbols like `\ge` (≥), `\le` (≤), and `\times` (×).  Also `+`, `<`, `>`, `=`, and so on.

To help you write numbers like spell
attack modifiers or spell DCs, which may change as your character evolves,
I have defined a handful of custom macros:

- `\psam` is "plus spell attack modifier" rendered as "+N."
- `\satk` is "spell attack modifier," preceded by a hard space.
- `\spellattack` is the spell attack modifier *without* the hard space.
- `\statdc{XXX}` calculates a DC from a stat modifier, as in `\statdc{CON}`.
- `\spelldc` calculates a DC using the spellcasting modifier for the class, from the `SPELL DC` field.

## Getting YAML from other digital character sheets

There are eight million ~~stories~~ digital character sheets in ~~the naked city~~ various corners of the Web.
If you are willing to use a large language model, the popular chatbots can extract pretty good YAML from a web page or PDF.
Show the bot an example YAML sheet or the [user documentation](YAML.md), then ask it to convert whatever format you have to the YAML format.


## There's more YAML to play with

To see more examples of YAML, including useful fragments,
check out the [`yaml`](yaml) directory.
For example, if you want to roll up a ranger, you can include [`yaml/ranger-class.yaml`](yaml/ranger-class.yaml).
Or if your druid is about to specialize, try
[`yaml/circle-of-the-land-forest.yaml`](yaml/circle-of-the-land-forest.yaml).

The snippets in the [`yaml`](yaml) directory don't claim to be comprehensive; they are just fragments I put together for my own game.  If you find them useful, we're surprised and pleased.



# Limitations and caveats

## Limitations

My YAML don't support all of D&D 5e.

  - Traits, bonds, ideals, and so on are aspects of a D&D character that are best developed during play, not decided beforehand at character-creation time.  Accordingly, they are not found on the character sheet.

    If these are things that you want, sketch the layout you are looking for and open [a Github issue](https://github.com/dnd-character-sheets/dnd-character-sheets.github.io/issues).
  
  - Electrum pieces clutter the character sheet, and they tend to confuse players: unlike the other coins, they are not ten times as valuable as the next most valuable coin.  Electrum pieces do have a dedicated YAML key, but they do not display on any of the existing layouts.

## Character-sheet layouts

Although I have some training in information design,
I am not a graphic designer.
If you want to recommend another layout, please open [a Github issue](https://github.com/dnd-character-sheets/dnd-character-sheets.github.io/issues).

## Offline use

If you have Linux and are comfortable with software,
you can dry dispensing with the web service and generating PDF on your own machine.
The code is in [a Github repository](https://github.com/dnd-character-sheets/dnd-character-sheets.github.io), and I will provide help on request.

## AI

I used AI for help.
I do not love theft of intellectual property or the likelihood of AI putting creative artists out of work.
But the popular models are trained on my work—I have been putting code on the public internet for over 35 years—and given my contributions, I wish to reap some of the benefits.

I have not used AI blindly; except for parts of the JavaScript,
I have reviewed every line of AI-generated code, and I have rewritten most of it.

# Acknowledgments

The pregenerated characters and the bones of the three-column template were supplied by
[NoxAeternus](https://ko-fi.com/noxaeturnus/).

The two-column template is taken from the module [_The Fall of Silverpine Watch_](https://theangrygm.com/the-fall-of-silverpine-watch/) by [The Angry GM](https://theangrygm.com/).
The template was originally designed by Alyssa.

The tropical template was designed by French Rice Meɹman.
