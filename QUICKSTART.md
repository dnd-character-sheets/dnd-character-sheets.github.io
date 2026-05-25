---
title: 'Quick-Start Guide to YAML Character Sheets'
---

<article>

To create a D&D character sheet using YAML,
follow this guide.
The guide is organized around the colored sections of character sheets
generated in
two-column PDF.
The guide uses examples from [Zanogh the Barbarian](zanogh.pdf) and
[Miriel the Cleric](miriel.pdf).
Comprehensive, alphabetical documentation of the YAML is found in [`YAML.md`](YAML.md).

To build your character,
go through each section of the guide, copy the YAML, and
fill in just the basics.  You can add detail later.
You can also explore the many examples in the [`yaml` directory](yaml).
If you have installed the software on Linux, you can try

    charsheet -o mycharacter.pdf mycharacter.yaml

Or just upload your YAML to [the web
form](https://dnd-character-sheets.github.io) and try it there.


## Basic character identity (light green)

<div class="playername">

Your character's basic identity appears in the colored banner at the
top of the character sheet.

```yaml zanogh
CHARACTER NAME: Zanogh Greyfist
PLAYER NAME: Carolyn
AGE: young adult  # Optional: age category or life stage
DESCRIPTION: Tall half-orc with gray skin and fierce amber eyes  # optional
CLASS: Barbarian
LEVEL: 3
SPECIALTY: ""  # optional subclass, domain, archetype, etc.
RACE: Half-Orc
BACKGROUND: Hermit
ALIGNMENT: ""
EXPERIENCE POINTS: ""
MOTIVATION: Get in touch with her orcish side  # optional
```

Notes:

- `SPECIALTY` is optional—use it for subclass, domain, archetype, and so on (e.g., "Life Domain", "Champion").
- Empty fields are fine, but empty strings need to be written with double quotes. (Quoting strings is otherwise mostly optional.)

If you are using GM sheets, you can add a note to go on that sheet.
Here I've added a note about a new player who does not always remember how to roll an attack.
The note helps me keep things moving during combat.

```yaml
GM NOTES: Scimitar attack +5, 1d6+3 slashing.
```

</div>

## Ability scores (warm blue)

<div class="stats">

Your ability scores appear in the left column with blue background.
Fill in all six scores with the raw numbers.
(The system calculates modifiers for ability checks and saving throws.)

```yaml zanogh
STR: 17
DEX: 14
CON: 14
INT: 8
WIS: 12
CHA: 10
```

</div>

## Proficiencies (yellow)

<div class="proficiencies">

Proficiencies appear in the yellow column immediately to the right of
the blue ability scores.
The section starts with the proficiency bonus.
You can include it, or you can let the system calculate it.


```yaml zanogh
PROFICIENCY BONUS: +2
```

Writing the proficiencies themselves requires something new:
instead of a simple number or string, `PROFICIENCIES` are a list:

```yaml zanogh
PROFICIENCIES:
  - Animal Handling
  - Athletics
  - Perception
  - Intimidation
  - Survival
  -
  - Herbalism Kit
  -
  - Common
  - Orcish
  - Dwarvish
  - Light Armor
  - Medium Armor
  - Shield
  - Simple Weapons
  - Martial Weapons
```

The blank list elements provide a useful visual separator.
They also divide proficiencies into groups; only the first two or
three groups are shown on the GM's sheet.

</div>


## Senses and passive abilities (white)

Next to the proficiencies are a couple of white boxes, on a white background.
These boxes hold information that varies by character class and race.
For Zanogh the barbarian it is her darkvision and her passive Perception.


```yaml zanogh
SENSES: Darkvision 60 ft.
PASSIVE PERCEPTION: 13
```

Notes:

  - The space in `60 ft.` is actually a non-breaking space (`U+00A0`).  That looks better on the character sheet.



## Combat statistics (white on gray)

<div class="hpetc">

To the right of senses and spells,
below the green banner at the top of the sheet,
 is the information you will use in combat.
It appears in white boxes on a gray background.


```yaml zanogh
MAX HP: 32
INITIATIVE: +2
SPEED: 30 ft
ARMOR CLASS: 14
HIT DICE: d12  # should match the class
```


</div>

## Attacks (orange)

<div class="attacks">

Below the white boxes is an orange section that
shows
your character's weapon attacks.
The attacks are specified using our most complex YAML yet:

  - The `ATTACKS` field is a list.
  - Instead of a string as in the proficiencies, each list element is a table of key-value pairs.

Not all table fields are required for all attacks.
For example, the `AMMO TYPE` and `AMMO COUNT` fields are used only for
weapons that require ammunition.
(And if your table doesn't track ammunition, you can leave them out.)


### Attack Entries
```yaml zanogh
ATTACKS:

  - NAME: Greataxe
    ATTACK: +5
    DAMAGE: 1d12+3
    TYPE: slashing
    RANGE: 5 ft.

  - NAME: Hand Axe
    ATTACK: +5
    DAMAGE: 1d6+3
    TYPE: slashing
    RANGE: 5ft, 20/60 ft.
    AMMO COUNT: 2
    AMMO TYPE: axes

  - NAME: Light Crossbow
    ATTACK: +4
    DAMAGE: 1d8+2
    TYPE: piercing
    RANGE: 80/320 ft.
    AMMO TYPE: bolts
    AMMO COUNT: 20
```

Notes:

  - If `AMMO COUNT` is present, `AMMO TYPE` must also be present.
  - If a weapon can be used in melee and also thrown, `RANGE` should include multiple ranges.

</div>

## Magic (pale magenta)

<div class="magic">

If your character is a spellcaster, you will list spells in
a `MAGIC` section.
On the character sheet, this section appears right below the attacks.

Although the system will check, it's a good idea to specify your
spell DC explicitly.

```yaml miriel
SPELL DC: 13
```

Just like attacks, spells are specified by a list of tables.
Each spell has a `name` and a `description`.

Spells are segregated by level, and
each level is headed by a table that specifies the level and the number of
slots.
(Cantrips, at level 0, have unlimited slots, so `slots` is omitted.)

In addition to `name` and `description`,
spells may have other properties,
including
`duration`,
`concentration`,
`ritual`,
`bonus`,
`reaction`,
`attack`,
and
`save`,
among others.
The full list, with explanations, can be found in the [`MAGIC` section](YAML.md#magic)
of the [alphabetical reference](YAML.md#magic).


```yaml miriel
MAGIC:

  - level: 0  # Cantrips

  - name: Sacred Flame
    description: Target one creature; DEX save or 1d8 radiant damage.
    save: true  # target must make a saving throw

  - name: Spare the Dying
    description: One unconscious creature you touch is stabilized.

  - level: 1
    slots: 2

  - name: Bane
    concentration: true  # requires concentration
    save: true           # target must make a saving throw
    description: >-
        Up to three targets within 30 ft gain \textminus 1d4 to attacks and
        saves for 1 minute (CHA saving throw).
    duration: 1 min

  - name: Cure Wounds
    description: A touched creature regains 1d8+3 HP, +3 more [Life domain]

  - name: Bless
    description: >-
       Up to three allies within 30 ft gain +1d4 to
       attacks and saves for 1 minute [Life domain].
    concentration: true
    duration: 1 min

  - name: Guiding Bolt
    attack: true  # requires a spell attack roll
    description: >-
       Ranged spell attack \psam, 120 ft, 4d6 radiant damage;
       next attack against the target has advantage.
```

Notes:

  - In the description of Bane, `\textminus` is supposed to produce a good-looking minus sign, instead of the usual hyphen.
  - In the description of Guiding Bolt, `\psam` stands for "plus spell attack modifier," and it asks the system to calculate the modifier.

Spell lists can take up a lot of room.
At need, you can shrink the font as follows:
```yaml
MAGIC FONT: \small         # Render magic section in smaller font
MAGIC FONT: \footnotesize  # Even smaller
MAGIC FONT: \scriptsize    # Smaller yet
```

If spells won't fit even with a small font, move magic to its own page:
```yaml
MAGIC SEPARATE: true    # Magic section on separate page (not yet implemented)
```

A sorcerer will have not only spells but also sorcery points:

```yaml
SORCERY POINTS: 3
```

Sorcery points are shown in the white section along with senses and passive abilities.


</div>

## Features (warm pink)

<div class="features">

Class features, racial traits, and special abilities are found in the
right-hand column below `ATTACKS` (or `MAGIC`, if present)
The `FEATURES` section is structured like a simplified version of the `MAGIC` section: there are no levels or slots, and there are few properties.
Each feature has a `name` and a `description`, and maybe a property like `bonus` or `duration`.



```yaml zanogh
FEATURES:
  - name: Rage
    bonus: true
    duration: 1 min
    description: >-
      Start/stop as a bonus action. Lasts 1 minute or until you are
      unconscious or fail to attack or take damage for 1 turn. Can't
      concentrate. While raging: • Advantage on Str checks & saves. • Melee
      Str attacks deal +2 damage. • You take half damage from bludgeoning,
      piercing, and slashing damage. • At 3rd level, 3 times per long rest.

  - name: Unarmored Defense
    description: If you wear no armor, your AC is 10 + Dex + Con.

  - name: Savage Attacks
    description: >-
       When you score a critical hit with a melee attack,
       add one extra weapon damage die to the total.
```

</div>

## Equipment (light green)

<div class="equipment">

The equipment section appears at the bottom of the character sheet.

- Equipment section may display in multiple columns for non-casters


It includes the character's armor, weapons, and gear.
These things are listed under `EQUIPMENT`.

### Equipment List
```yaml zanogh
EQUIPMENT:
  - Scale Mail Armor
  - Shield (+2 AC)
  - Backpack
  - Bedroll
  - Mess Kit
  - Tinderbox
  - Torches (10)
  - Rations (10)
  - Waterskin
```

The equipment section also includes the contents of the character's purse.

```yaml zanogh
CP:     # Copper pieces
SP:     # Silver pieces
GP: 10  # Gold pieces
PP:     # Platinum pieces
```


</div>

## Complete Example: Basic Fighter

Here's a small example for a 1st-level Fighter;
the player has yet to choose some features and proficiencies:

```yaml fighter
CHARACTER NAME:
PLAYER NAME:
CLASS & LEVEL: Fighter 1
RACE: Human
BACKGROUND: Soldier
ALIGNMENT:
EXPERIENCE POINTS:

STR: 16
DEX: 13
CON: 14
INT: 10
WIS: 12
CHA: 8

PROFICIENCY BONUS: +2
MAX HP: 12
CURRENT HIT POINTS:
HIT DICE: d10
INITIATIVE: +1
SPEED: 30
ARMOR CLASS: 16
PASSIVE PERCEPTION: 11

PROFICIENCIES:
  - Athletics
  - Intimidation
  -
  - Common
  - All Armor
  - Shield
  - Simple Weapons
  - Martial Weapons

ATTACKS:
  - NAME: Longsword
    ATTACK: +5
    DAMAGE: 1d8+3
    TYPE: slashing
    RANGE: 5 ft.


FEATURES:
  - name: Fighting Style
    description: Choose a fighting style that grants combat benefits.

  - name: Second Wind
    description: Regain 1d10+1 hit points as a bonus action. Once per rest.

EQUIPMENT:
  - Chain Mail
  - Shield
  - Longsword
  - Backpack
  - Bedroll
  - Rations (10)

CP:
SP:
GP:
PP:
```


</article>

<!--
```yaml miriel
CHARACTER NAME: Miriel
PLAYER NAME: Michelle
CLASS & LEVEL: Cleric 3
RACE: Human
BACKGROUND: Acolyte
MOTIVATION: Miriel is trying to prove herself
STR: 9
DEX: 15
CON: 14
INT: 11
WIS: 16
CHA: 13
PROFICIENCY BONUS: '2'
MAX HP: 29
HIT DICE: d8
INITIATIVE: '+2'
SPEED: '30'
ARMOR CLASS: 18
PASSIVE PERCEPTION: 13
PROFICIENCIES:
  - Insight
  - Medicine
  - Persuasion
  - Religion
  - Nature
  - null
  - Common
  - Celestial
  - Abyssal
  - Infernal
  - All Armor
  - Shield
  - Simple Weapons
ATTACKS:
  - NAME: Frost brand scimitar
    ATTACK: '+2'
    DAMAGE: 1d6+2/1d6
    TYPE: slashing/cold
    RANGE: 5 ft.
    AMMO: '---'
  - NAME: Light Crossbow
    ATTACK: '+4'
    DAMAGE: 1d8+2
    TYPE: piercing
    RANGE: 80/320 ft.
    AMMO: ''
FEATURES:
  - name: Disciple of Life
    description: Healing spells restore an additional 2 HP + spell's level.
  - name: Channel Divinity
    description: >-
       Turn Undead; Preserve Life (HP = 5\(\times\)level).
       1 per rest until level 6.

EQUIPMENT:
  - Cleric's Vestments
  - Holy Symbol
  - Scale Mail Armor
  - Shield (+2 AC)
  - Backpack
  - Blanket
  - Candles (10)
  - Incense Sticks (2)
  - Censer
  - Tinderbox
  - Rations (10)
  - Waterskin
```
-->
