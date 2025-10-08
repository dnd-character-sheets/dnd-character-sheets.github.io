# Introduction

When I play D&D, I love the convenience of a paper character sheet.
Everything I need to know is right in front of me; there is no
mousing, clicking, tapping, or other fiddling with devices.
But when my character levels up or prepares new spells, 
updating a paper sheet is a nuisance, and so is copying out my character to a new sheet.
This project tries to provide the best of both worlds.

This project works with a "digital character sheet" that is plain text and is meant to be edited and maintained with a simple, ordinary text editor like Emacs, vim, or Notepad.  The text of the character sheet is a form of [YAML]() ([decent beginner tutorial](https://www.cloudbees.com/blog/yaml-tutorial-everything-you-need-get-started)), which I consider decently user-friendly while still being machine-readable.  A character sheet might start something like this:

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

The software can then produce [a PDF suitable for printing and using at the table](sample-rogue.pdf): ![not actually Mario's character sheet](sample-rogue.png).

The software runs on Linux---the Angry GM uses Linux now, you know---but for those who don't wish to fool around with installing it and getting it to work, I provide [a web service](https://dnd-character-sheets.github.io).

# Getting started, documentation

quickstart
yaml.ml

LaTeX

# Character-sheet layouts

# Where to get YAML

I have yamls.

ChatGPT can help.




