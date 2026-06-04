---
title: D&D Character Sheets using YAML
---

# Introduction

Paper character sheets are great.
A paper sheet puts
everything I need to know right in front of me; 
I don't have to mouse, click, tap, or fiddle with a device.
And I can scribble on it!
But when my character levels up or prepares new spells, 
a paper sheet is a pain to update.
So I created a digital format that is easy to read and update,
plus software that
produces well-designed paper sheets.
As an example, 
here's a fictitious character sheet in a format that I admire (click to embiggen):

<div align="center">
  <a href="mario.pdf">
    <img src="mario-preview.png"
         style="width:50%; height:auto;"
         alt="Not actually Mario's character sheet">
  </a>
</div>

This character sheet, designed by Alyssa, is readable and yet dense
with information.
Use my software, and
you can create character sheets just like it.
You don't need any kind of subscription;
just go to 
[`https://dnd-character-sheets.github.io`](https://dnd-character-sheets.github.io)
and start exploring.


# An open, archival digital character sheet

A web service is great,
but a web form disappears when the browser closes,
and your character needs to last as long as your campaign.
My web service can save your character in archival form;
it uses a plain-text format
called
[YAML](https://en.wikipedia.org/wiki/YAML).
YAML is
a common format that is reasonably user-friendly ([beginner
tutorial](https://www.cloudbees.com/blog/yaml-tutorial-everything-you-need-get-started)).
Your YAML character sheets can be created and edited entirely on the
web.


A YAML character sheet might start something like this:

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

You can download Mario's complete character sheet from [the web site](https://dnd-character-sheets.github.io).


# Using the web service

The web service has two parts: a site with a form that you can use to describe your character,
and a back end that renders your sheet as PDF.
Once you have a character in the form,
you can download it as a YAML file,
which you can keep as long as you want.
When you want to change your character sheet, or just generate new PDF,
go back to the site and upload your YAML.
You will find
all the important buttons ("upload", "download", and "generate PDF")
at the beginning of the web form.

To help you get started, I have provided some pregenerated characters to play with.

 1. Go to
    [`https://dnd-character-sheets.github.io`](https://dnd-character-sheets.github.io).
    From the first dropdown ("best at 2 columns"), choose a
    pregenerated character, perhaps Mario.  Then click "Load this
    character" on the right.
 
 2. Click the "Generate PDF" button.  After a few seconds, your browser should show the PDF in a new tab.
 
 3. Go back to the web form and look for
    a "Download `mario-greymist.yaml`" button.
    Click to save Mario's sheet on your machine.
    (By default, a YAML file that you download is named for the character, or if there is no character name, for the character's class.)

The web form works just fine,
but if you are an experienced computer user, 
you may prefer to edit your YAML character sheet on your own machine.
In this case 
you will use a text editor like Emacs, vim, or Notepad, and 
you will continue to use the web service to generate PDF:

  * Go to [the web site](https://dnd-character-sheets.github.io) and use the "Upload YAML file" button to load your character sheet into the web form.
 
  * Click "Generate PDF."

# Running the back end on your own machine (with bonus!)

If you have Linux and are comfortable with software,
you can try dispensing with the web service and generating PDF on your own machine.
The software you'll need is sketched in [`INSTALL.md`](INSTALL.md),
and my code is in [a Github repository](https://github.com/dnd-character-sheets/dnd-character-sheets.github.io).
If you want help, ask.

If you do install the software locally, you get a couple of other goodies.
In particular, you can create a [one-page summary of characters'
important abilities and stats, for a GM to use at the table](gmsheet.pdf):

<div align="center">
  <a href="gmsheet.pdf">
    <img src="gmsheet-preview.png"
         style="width:50%; height:auto;"
         alt="A summary I use at the table">
  </a>
</div>




# Working with YAML

## YAML for beginners

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
the software should preserve all your YAML data—even fields that don't appear on the form.
But the software may add a few fields, and it may change empty values
to `null`.
Finally, the software removes blank lines, because they are not visible
to a YAML parser.


## YAML keys for this project

YAML is just a format; to write anything meaningful, you must know
what keys to use.
My software recognizes over 60 keys, from `ARMOR CLASS` to `WIS`.
Each key is described in a project-specific [YAML reference](YAML.md),
but you are probably better off using the 
[Quick-Start Guide](QUICKSTART.md).
<!--And if something goes wrong, you can find the ultimate truth in the
`.sty` and `.tex` files in the [templates directory](templates).
-->

## Getting YAML from other digital character sheets

There are eight million ~~stories~~ digital character sheets in ~~the naked city~~ various corners of the Web.
If you are willing to use a large language model, the popular chatbots can extract pretty good YAML from a web page or PDF.
Show the bot an example YAML sheet or the [user documentation](YAML.md), then ask it to convert whatever format you have to the YAML format.


## More YAML to play with

To see more examples of YAML, including fragments that you might want
to incorporate into your own character sheets,
check out the [`yaml`](yaml) directory.
For example, if you want to roll up a ranger, you can include [`yaml/ranger-class.yaml`](yaml/ranger-class.yaml).
Or if your druid is about to specialize, try
[`yaml/circle-of-the-land-forest.yaml`](yaml/circle-of-the-land-forest.yaml).

The snippets in the [`yaml`](yaml) directory aren't comprehensive;
they are just fragments I put together for my own game.  If you find
them useful, we're both surprised and pleased.


# Limitations and caveats

## Limitations

My YAML doesn't support all of D&D 5e.

  - The character sheets are meant to be used at the table, and
    I want everything I need on one sheet of paper.  So my format doesn't
    support such properties as traits, bonds, ideals—they're not
    immediately useful during play, and I could not find room for them.
    If these are things that you want, sketch the layout you are looking for and open [a Github issue](https://github.com/dnd-character-sheets/dnd-character-sheets.github.io/issues).
  
  - Electrum pieces clutter the character sheet, and they tend to confuse players: unlike the other coins, they are not ten times as valuable as the next most valuable coin.  Electrum pieces do have a dedicated YAML key, but they do not display on any of the existing layouts.

## Character-sheet layouts

Although I have some training in information design,
I am not a graphic designer.
If you want another layout, please open [a Github issue](https://github.com/dnd-character-sheets/dnd-character-sheets.github.io/issues).

## AI

I used AI for help with code.
I do not love theft of intellectual property or the likelihood of AI putting creative artists out of work.
But the popular models are trained on my work—I have been putting code on the public internet for over 35 years—and given my contributions, I wish to reap some of the benefits.

I have not used AI blindly; except for parts of the JavaScript,
I have reviewed every line of AI-generated code, and I have rewritten most of it.

And AI doesn't write for me; this README is all mine.

# Acknowledgments

The pregenerated characters and the bones of the three-column template were supplied by
[NoxAeternus](https://ko-fi.com/noxaeturnus/).

The two-column template is taken from the module [_The Fall of Silverpine Watch_](https://theangrygm.com/the-fall-of-silverpine-watch/) by [The Angry GM](https://theangrygm.com/) (who uses Linux now, by the way).
The template was originally designed by Alyssa.

The tropical template was designed by French Rice Meɹman.
