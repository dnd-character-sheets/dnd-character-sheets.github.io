---
title: D&D Character Sheets using YAML
---

# Introduction

When I play D&D, I love the convenience of a paper character sheet.
Everything I need to know is right in front of me; there is no
mousing, clicking, tapping, or other fiddling with devices.
But when my character levels up or prepares new spells, 
updating a paper sheet is a nuisance, and so is copying out my character to a new sheet.
This project tries to provide the best of both worlds.

The project defines a plain-text format for digital character sheets.
The sheets are meant to be edited and maintained with a simple, ordinary text editor like Emacs, vim, or Notepad.
Each character sheet is written using [YAML](https://en.wikipedia.org/wiki/YAML) ([beginner tutorial](https://www.cloudbees.com/blog/yaml-tutorial-everything-you-need-get-started)), which I consider reasonably user-friendly while still being machine-readable.  
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

The software can then produce [a PDF suitable for printing and using at the table](mario.pdf).\
Preview:

<a href="mario.pdf">
<img src="mario-preview.png" height=300 alt="Not actually Mario's character sheet">
</a>

The software runs on Linux—the Angry GM uses Linux now, you know—but for those who don't wish to fool around with installing it and getting it to work, I provide [a web service](https://dnd-character-sheets.github.io).
If you are curious, the web service is the best way to explore.

# Using the web service

The web service starts with a form that describes your character.
On a web form, you fill in the text fields and most of the numbers
(the service does calculate a few values, like modifiers and proficiency
bonus).

The web form actually starts with bureaucracy: load a character, save
a character, choose the format for the PDF, and so on.
To get started, try something like this:

 1. Go to <https://dnd-character-sheets.github.io> and choose a pregenerated character from one of the dropdowns.  Then click "Load this character."
 
 2. Fill in a couple of missing fields, edit what's there, and otherwise tinker with the form.
 
 3. Click the "Generate PDF" button to see what your character sheet will look like.
 
 4. Click the "Download _name_`.yaml`" button to save your work.

The web form is intended primarily for demo purposes.
<!-- —and not merely because I am a crap web designer. -->
In the long term, you will
ideally use the service something like this:

 5. Edit your YAML character sheet on the comfort of your own machine.

 6. Go to the web service and use the "Load YAML file" button to load your character sheet into the web form.
 
 7. Get PDF by clicking "Generate PDF."

# Working with YAML

## Yaml for beginners

By far the best way to get started with YAML is to download one of the pregenerated characters from <https://dnd-character-sheets.github.io>.
The downloaded file contains key-value pairs in the form

```
KEY: value
```

Top-level keys are uppercase by convention, and a value is usually a string, a number, or a list.
Most lists look like Markdown lists, in which each item is a string marked with a leading dash.
But for more complex data, like attacks, features, and magic, each item in the list is itself a list of named properties.  For example, a feature has a `name` and a `description`.
An attack has `DAMAGE`, a `TYPE`, possibly a `RANGE`, and other properties.

You can try editing the file and then uploading the result to the web form.
And if you edit on the web, you can download the result.
This kind of 
round trip through web form is meant to preserve all the information in the YAML file, even if not all of it appears on the form.
But the round trip may add a few fields, and empty space following a dash may render as `null`.
Finally, blank lines are not visible to the YAML parser, so they are lost.

## YAML for this project

A character sheet may have over 60 properties, each of which has its own YAML key.
The set of valid keys is ultimately determined by low-level key-declaration code in 
<templates/charsheet.sty>.
And their meaning is determined by their usage in the various `.tex` template files.
But I do provide an AI-generated [alphabetical list of keys](YAML.md) and their usage.

## What you can write in text values

The character sheets are created using the LaTeX typesetting system; the graphic design is done using LaTeX's [TikZ package](https://tikz.dev).
Every text field is interpreted by LaTeX, and therefore the `\`, `{`, and `}` characters have special significance.
(For LaTeX experts, the other special characters are escaped by the rendering engine.)

The `\` character starts a use of a
LaTeX macro, and you will sometimes want to use standard macros in your text:

  - To get text to fit you may have to use smaller fonts.  From large to small, font size can be changed by macros `\large`, `\normalsize`, `\small`, `\footnotesize`, `\scriptsize`, and `\tiny`.

  - You can set `\textbf{bold text}` and `\emph{emphasize (italics) text}`.
  
  - You can write math between `\(` ... `\)` macros, and use symbols like `\ge` (≥), `\le` (≤), and `\times` (×).  Also `+`, `<`, `>`, `=`, and so on.

A few custom macros are useful for calculating things like spell
attack modifier or spell DC, which may change as your character evolves:

- `\psam` is "plus spell attack modifier" rendered as "+N."
- `\satk` is "spell attack modifier," preceded by a hard space.
- `\spellattack` is the spell attack modifier *without* the hard space.
- `\statdc{XXX}` calculates a DC from a stat modifier, as in `\statdc{CON}`.
- `\spelldc` calculates a DC using the spellcasting modifier for the class, from the `SPELL DC` field.

## Getting YAML from other digital character sheets

There are eight million ~~stories~~ digital character sheets in the ~~naked city~~ various corners of the Web.
Trying to create software to convert from one to the other is a mug's game.  But if you are willing to use a large language model, the popular chatbots can extract pretty good YAML from a web page or PDF.
Show the bot an example YAML sheet or the [user documentation](YAML.md) and then ask it to convert whatever format you have to the YAML format.


## Prewritten YAML you can use with your own characters

I have yamls.




# Deliberate omissions

The layouts and YAML forms do not support all of the options available in D&D 5e (2014).

  - Traits, bonds, ideals, and so on are aspects of a D&D character that are best developed during play, not decided beforehand at character-creation time.  Accordingly, they are not found on the character sheet.
  
  - Electrum pieces clutter the character sheet and tend to confuse players because unlike the other coins, they are not ten times as valuable as the next most valuable coin.  Copper, silver, gold, and platinum provide plenty of variety to work with.

# Character-sheet layouts

Although I have some training in information design,
I am not a graphic designer.
If you want to recommend support for another layout, please open an issue.

# Notes on sources

AI used.  Link to Nox, Silverpine W, Alyssa sheets

Thanks to "Alyssa" for the two-column character-sheet layout (`silverpine`) that is used in _The Fall of Silverpine Watch_.
Thanks to NoxAeternus for the three-column (`3col`) style.
Thanks to French Rice Merman for the `tropical` style.






