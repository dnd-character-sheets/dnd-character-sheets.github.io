---
title: YAML Reference for D&D Character Sheets
---

# Introduction

This document specifies what you can put in a YAML character sheet.
Most of the document is taken up with an alphabetical list of all the keys, 
but this reference also
provides some details about what you can put in your text,
and it mentions some keys that are special.

As you perused the guide, you will see examples both with and without quotation marks.
YAML's rules for quotation are actually fairly involved, but for the character sheets, 
most quotation marks are optional.

Finally, I have not yet documented exactly how few keys you can get away with.
I have tried to require as few as possible.
You might be able to get a character sheet with as little as `CLASS` and `LEVEL`.

# What you can write: Beyond plain text

YAML handles plain text well and does not hit you with a ton of
bureaucracy (special quote marks and so on).
But sometimes you want more than plain text.
And I provide a hook:
the back end exploits the full power of the LaTeX typesetting
system.
LaTeX can be intimidating, but it is very powerful,
and it provides not only traditional typesetting but also 
graphic-design tools.
(Much of the graphic design has been done using the [TikZ
package](https://tikz.dev).)

You can benefit from LaTeX without being an expert.
You just need to know that
the text that you write is interpreted by LaTeX,
and that LaTeX treats the `\`,
`{`, and `}` characters specially.
(If you *are* an expert, you will also want to know that LaTeX's other
special characters are escaped by the back end.)

The `\` character marks a
LaTeX macro, and you will sometimes want to use macros in your text:

  - To get text to fit on a single page, you may have to change font size.  Specify a size using macros `\large`, `\normalsize`, `\small`, `\footnotesize`, `\scriptsize`, and `\tiny`.

  - You can write `\textbf{`**bold text**`}`, `\emph{`_emphasis_`}`, and `\textsc{`<span style="font-size: 80%;">SMALL CAPS</span>`}`.
  
  - You can write math between `\(` ... `\)` macros, which support symbols like `\ge` (≥), `\le` (≤), and `\times` (×).  Also `+`, `<`, `>`, `=`, and so on.

To help you write numbers like spell
attack modifiers or spell DCs, which may change as your character evolves,
I have defined a handful of custom macros
In any text field you can write any of the following:

- `\psam` is "plus spell attack modifier" rendered as "+N."
- `\satk` is "spell attack modifier," preceded by a hard space.
- `\spellattack` is the spell attack modifier *without* the hard space.
- `\statdc{XXX}` calculates a DC from a stat modifier, as in `\statdc{CON}`.
- `\spelldc` calculates a DC using the spellcasting modifier for the class, from the `SPELL DC` field.



# Special YAML keys

## Keys for changing font size

Some key names
can have " FONT" appended to control the font used when rendering the named section in the character sheet. The value should be a LaTeX font command, as in these examples:

- `MAGIC FONT: \small`
- `EQUIPMENT FONT: \footnotesize`
- `FEATURES FONT: \footnotesize`

The sections that support `FONT` keys are
`ATTACKS`,
`FEATURES`,
`MAGIC`,
`EQUIPMENT`,
and
`PROFICIENCIES`

If a font-size specification seems not to be having any effect,
there is a bug in my code.
Open a Github issue.

## Keys with calculated values

The following keys are automatically calculated rendering engine.
Unless you want to override the calculated values, do not include them
in a YAML file:

- Saving-throw modifiers `STR SAVING`, `DEX SAVING`, `CON SAVING`, `INT SAVING`, `WIS SAVING`, and `CHA SAVING` are calculated automatically based on the `CLASS`.  (The class determines the character's saving-throw proficiencies.)
- `SPELL ATTACK MODIFIER` and `SPELLCASTING ABILITY MODIFIER` are calculated automatically for spellcasters.
- `PROFICIENCY BONUS` is calculated automatically based on LEVEL.

Other calculated keys may be included, but when they are absent, the rendering engine calculates them:

- `PASSIVE PERCEPTION` (the rendering engine attempts to account for Expertise)
- `SPELL DC`

# Alphabetical list of keys

Each key is described briefly; most are followed by examples.
Unless otherwise specified, a key expects to be associated with text.

#### `ALIGNMENT`

A string.

- `"ALIGNMENT": "Chaotic Good"`
- `"ALIGNMENT": ""`
- `ALIGNMENT: Lawful Good`



#### `AGE`

Could be a number or just a string describing a life stage.
The age is displayed in parentheses after the character's name.

- `AGE: "young adult"`
- `AGE: "late middle age"`
- `AGE: "elderly"`
- `AGE: 35 [young]`




#### `ARMOR CLASS`

A number, which is  displayed prominently in a shield-shaped box.

- `"ARMOR CLASS": 13`
- `"ARMOR CLASS": 18`
- `ARMOR CLASS: 14` (unquoted form)



#### `ATTACKS`

A list of attack possibilities, each of which is described by a table with these fields:

- `NAME`: Names the weapon or the attack, as in `Dagger`
- `ATTACK`: Attack bonus, as in `+5`
- `DAMAGE`: Damage dice or formula, as in `2d4+2`
- `TYPE`: Damage type, as in `Piercing`
- `RANGE`: optional string, as in `80/320 ft`
- `AMMO TYPE`: Describes ammunition, as in `bolts` or `sling bullets`
- `AMMO COUNT`: An optional number giving the amount of ammunition available
- `NOTES`: Optional additional notes

If `AMMO COUNT` is given, `AMMO TYPE` must also be given.

**Examples**:
```yaml
ATTACKS:
  - NAME: Shortsword
    ATTACK: "+4"
    DAMAGE: "1d6+2"
    TYPE: piercing
    RANGE: "5 ft."
    # No ammo fields for melee weapons

  - NAME: Light Crossbow
    ATTACK: "+4"
    DAMAGE: "1d8+2"
    TYPE: piercing
    RANGE: "80/320 ft."
    AMMO TYPE: "bolts"
    AMMO COUNT: 20
    NOTES: "Loading property"

  - NAME: Dagger (thrown)
    ATTACK: "+4"
    DAMAGE: "1d4+2"
    TYPE: piercing
    RANGE: "20/60 ft."
    AMMO COUNT: 3
    AMMO TYPE: daggers

  - NAME: Sling
    ATTACK: "+4"
    DAMAGE: "1d4+2"
    TYPE: bludgeoning
    RANGE: "30/120 ft."
    AMMO TYPE: "bullets"
    # Count omitted when not tracked
```



#### `BACKGROUND`

A string that is displayed in the character-information section.

- `"BACKGROUND": "Scholar"`
- `"BACKGROUND": "Hermit"`
- `BACKGROUND: Acolyte`
- `BACKGROUND: Town Watch`



#### `CHA`

The Charisma ability score, a number, as in `CHA: 15`.


#### `CHA SAVING` (calculated by the system)

If the character `CLASS` indicates saving-throw proficiency in
Charisma,
the rendering engine defines `CHA SAVING` to be `true`.
Otherwise `CHA SAVING` is left undefined.


#### `COLOR`

A Boolean; if true, the rendering engine uses colored backgrounds in
those templates that support color.
(The colored backgrounds are primarily a teaching tool.)
Defaults to `true`.

- `COLOR: true`
- `COLOR: false`



#### `CHARACTER NAME`

The character's name, which is displayed prominently.

- `"CHARACTER NAME": "Miriel"`
- `CHARACTER NAME: Arana Alewind`



#### `CLASS`

The character's class.
It is used to determine saving-throw proficiencies, and it is displayed.

- `CLASS: "Cleric"`
- `CLASS: "Fighter"`
- `CLASS: Rogue`




#### `CON`

The Constitution ability score, a number, as in `CON: 15`.


#### `CON SAVING` (calculated by the system)

If the character `CLASS` indicates saving-throw proficiency in
Constitution,
the rendering engine defines `CON SAVING` to be `true`.
Otherwise `CON SAVING` is left undefined.


#### `CP`

Number of copper pieces in the character's inventory.
May also be left blank.

- `CP: 10`
- `CP: ""`

#### `CURRENT HIT POINTS`

Not actually used.  It changes too frequently.


#### `DESCRIPTION`

A physical description of the character.

  - ```yaml
    DESCRIPTION: "Tall with dark hair and piercing blue eyes"`
    ```

  - ```yaml
    DESCRIPTION: >-
      Bleached blonde pulled to one side; piercing eyes. Leather armor,
      rapier, shortbow, black cloak. Very young.`
    ```



#### `DEX`

The Dexterity ability score, a number, as in `DEX: 15`.


#### `DEX SAVING` (calculated by the system)

If the character `CLASS` indicates saving-throw proficiency in
Dexterity,
the rendering engine defines `DEX SAVING` to be `true`.
Otherwise `DEX SAVING` is left undefined.


#### `CP`

Number of electrum pieces in the character's inventory.
May also be left blank.

*Warning:* The templates I made don't show electrum pieces.

- `EP: ""`



#### `EQUIPMENT`

(Multicolumn?)

May be a simple list of items, or a list of categories with items in
each category.
The categories are useful if the party is using the [Alexandrian
system of encumbrance by
stones](https://thealexandrian.net/wordpress/46824/roleplaying-games/5e-encumbrance-by-stone)
to track encumbrance.

The categories are as follows:

- `HEAVY WEAPONS`
- `NORMAL WEAPONS`
- `LIGHT WEAPONS`
- `SHIELDS`
- `HEAVY ARMOR`
- `MEDIUM ARMOR`
- `LIGHT ARMOR`
- `HEAVY ITEMS` (items in this category may include a weight in the Alexandrian stone
  system, as in `- "Meteor iron (4 stones)"`
- `SLOTTED ITEMS` (items the consume a slot in the Alexandrian stone system)
- `SMALL ITEMS` (items that don't count against encumbrance)
- `STORED ITEMS` (items the character owns or controls but does not
  keep on their person.)

The simple list style looks like this:

```yaml
EQUIPMENT:
  - "Leather Armor"
  - "Shortsword"
  - "Light Crossbow"
  - "Backpack"
  - "Bedroll"
```

The categorized style looks like this:

```yaml
EQUIPMENT:
  NORMAL WEAPONS:
    - "Longsword"
    - "Shortbow"
  LIGHT ARMOR:
    - "Leather Armor"
  SLOTTED ITEMS:
    - "Arrows (20)"
    - "Rations (10 days)"
  FREE ITEMS:
    - "Clothes"
  HEAVY ITEMS:
    - "Anvil (8 stones)"
```

It is also possible to code the structured equipment list
using a list of strings.  This interpretation is used when rendering a
structured equipment list on the web form.
Each line can optionally start with a category name followed by a colon, then the item name:

 - `"Longsword"` (no category, will be auto-categorized)
 - `"NORMAL WEAPONS: Longsword"` (explicitly categorized)
 - `"light armor: Leather Armor"` (categories can be singular or plural)

You can mix both styles in the same equipment list (see the
[Quick-Start Guide](QUICKSTART.md). Category names are
case-insensitive and can be singular or plural (e.g., "light armor" or
"light armors"). The rendering engine maps these forms to the standard category names.

For experts: the list-of-strings format, with one string per line,
is defined by this EBNF grammar:

    <equipment> ::= { [<category>:] <item> NL
                    | <category>: NL {- <item> NL}
                    }
    <category>  ::= light armor | medium armor | ...
                 |  <category>s


#### `EQUIPMENT COLS`

The number of columns used to display equipment in the equipment
section.

- `EQUIPMENT COLS: 2`
- `EQUIPMENT COLS: 3`

Depending on the template, the default value may be one column or two.


#### `EXPERIENCE POINTS`

For display, usually suggesting what's needed to reach the next level.

- `"EXPERIENCE POINTS": "0/300"`
- `"EXPERIENCE POINTS": ""`



#### `FEATURES`

A list of class features, racial traits, and so on.
Each feature is a structured key-value table, which *must* have at
least two keys:

- `name`: The name of the feature, formatted to take up very little space
- `description`: A description that is modeled on the description in
  the rulebook but is typically condensed to take up less space on the
  character sheet. The `description` field should contain just enough
  information to use the feature at the table.

The `description` is the default description, but the feature may also
include an `abbrev` description, which is as short as possible, or a
`long` description, which may contain more verbiage.

In addition, each feature may be labeled with any or all of the following properties:

- `bonus`: Made `true` if the feature involves a bonus action
- `reaction`: Made `true` if the feature involves a reaction
- `attack`: Made `true` if using the feature involves an attack roll
- `save`: Made `true` if using the feature requires an enemy to make a saving throw
- `enemy`: Made `true` if using the feature involves targeting an enemy
- `duration`: A string describing how long the effect of the feature lasts

If a feature has the `attack`, `save`, or `enemy` property, that
feature will be displayed using an "attack color."  (Provided the
template supports colors.)
The other properties are used by the `gmsheet` and `gmspells` scripts
in this repository, which create summaries for the Game Master to
refer to at the table. 

A very similar format is also used in
the `MAGIC` list.

```yaml
FEATURES:
  - name: Cunning Action
    description: Dash, Disengage, or Hide as a bonus action.
    abbrev: Bonus Dash, Disengage, or Hide
    bonus: true

  - name: Sneak Attack
    description: Add 1d6 damage to finesse or ranged weapon.  Needs Advantage,
      or straight roll w/target threatened.  1/turn.
    abbrev: >-
      +1d6 dmg finesse, ranged. Need Adv or target threatened (no Dis). 1/turn.
    attack: true

  - name: "Fey Ancestry"
    description: "You have advantage to save against charms and you can't be magically put to sleep."

  - name: "Bardic Inspiration 2/day"
    description: "Grant an ally within 60 ft. +1d6 inspiration they can use on any one check within 10 minutes."
```



#### `GM NOTES`

These private notes for the game master may be used by the `gmsheet`
script.

- `GM NOTES: Favored enemy: undead.  Favored terrain: forest.`
- `GM NOTES: The dagger is cursed, but player doesn't know it yet.`



#### `GP`

Number of gold pieces in the character's inventory.
May also be left blank.

- `GP: 10`
- `GP: ""`


#### `HIT DICE`

A string showing the type of the character's hit dice.

- `"HIT DICE": "d8"`
- `"HIT DICE": "d12"`
- `HIT DICE: d6`
- `HIT DICE: d10`



#### `INITIATIVE`

The character's initiative modifier.

- `"INITIATIVE": "+2"`
- `"INITIATIVE": "-1"`
- `INITIATIVE: '+3'`



#### `INT`

The Intelligence ability score, a number, as in `INT: 15`.


#### `INT SAVING` (calculated by the system)

If the character `CLASS` indicates saving-throw proficiency in
Intelligence,
the rendering engine defines `INT SAVING` to be `true`.
Otherwise `INT SAVING` is left undefined.

#### `LAYOUT`

An optional key recommending a layout template.
The system currently supports three templates:

- `silverpine`: Silverpine Watch style (one narrow column, one wide)
- `3col`: Three narrow columns
- `tropical`: A tropical theme with mostly three columns and no colors.


#### `LEVEL`

A number giving the character's level.
The number is used to calculate the character's proficiency bonus.


#### `MAGIC`

A list of spells, separated by level markers.
A level marker is a table with a `level` key and possibly a `slots` key.
The `slots` key is forbidden for level 0 spells (cantrips) and mandatory for spells of level 1 and up.

A spell is a structured key-value table, which *must* have at
least two keys:

- `name`: The name of the spell, formatted to take up very little space
- `description`: A description that is modeled on the description in
  the rulebook but is typically condensed to take up less space on the
  character sheet. The `description` field should contain just enough
  information to cast the spell at the table.

The `description` is the default description, but the spell may also
include an `abbrev` description, which is as short as possible, or a
`long` description, which may contain more verbiage.

In addition, each spell may be labeled with any or all of the following properties:

- `ritual`: Made `true` if the spell can be cast as a ritual
- `concentration`: Made `true` if the spell requires concentration
- `components`: A string containing one or more of the letters VSM
- `material`: A description of material components
- `bonus`: Made `true` if the spell is cast as a bonus action
- `reaction`: Made `true` if the spell may be cast as a reaction
- `attack`: Made `true` if using the spell involves an attack roll
- `save`: Made `true` if using the spell requires an enemy to make a saving throw
- `enemy`: Made `true` if using the spell involves targeting an enemy
- `duration`: A string describing how long the effect of the spell lasts

If a spell has the `attack`, `save`, or `enemy` property, that
spell will be displayed using an "attack color."  (Provided the
template supports colors.)
The other properties are used by the `gmsheet` and `gmspells` scripts
in this repository, which create summaries for the Game Master to
refer to at the table. 

A very similar format is also used in
the `FEATURES` list.

```yaml
MAGIC:
  - level: 0
  - name: "Fire Bolt"
    description: "Make a ranged spell attack (+5) to deal 1d10 fire damage"

  - level: 1
    slots: 2

  - name: "Magic Missile"
    description: "Create 3 darts that each deal 1d4+1 force damage"

  - name: Cure Wounds
    components: VS
    description: A touched creature regains 1d8\psam HP.

  - name: Thorn Whip
    components: VSM
    material: the stem of a plant with thorns
    description: >-
        A vine-like whip lashes at a creature within 30 ft.  Melee spell attack\satk,
        1d6 piercing damage.  When hitting Large or smaller,
        pull up to 10 feet toward yourself.
    attack: true
    abbrev: >-
      Melee spell attack 30 ft, 1d6 pierce.  Pull \(\le\)Large 10 ft.

  - name: Shield
    description: >-
      Reaction; +5 AC until start of next turn, including triggering attack.
      No damage from \emph{magic missile}.
    reaction: true
    duration: 1 round
```


#### `MAGIC SEPARATE`

If `true` or similar value, the rendering engine puts the magic section on its own page.
Otherwise the magic section goes with the other sections.
(This feature is not yet implemented.)

- `MAGIC SEPARATE: true` (magic on separate page)
- `MAGIC SEPARATE: 1` (magic on separate page)
- `MAGIC SEPARATE: false` (magic inline, default behavior)
- `MAGIC SEPARATE: 0` (magic inline, default behavior)

#### `MAX HP`

The character's maximum hit points, which is displayed prominently in a box.

- `"MAX HP": 11`
- `"MAX HP": 32`
- `MAX HP: 28`
- `MAX HP: 15`



#### `MOTIVATION`

An optional, short string displayed in italic text near the character's name.

- `MOTIVATION: "Kylane wants to harness her newfound power"`
- `MOTIVATION: "Miriel is trying to prove herself"`
- `MOTIVATION: "Find family"`

#### `PASSIVE PERCEPTION` (calculated by the system)

May be displayed with the character's other information, and is also used on the GM's sheet.
`PASSIVE PERCEPTION` is worth including explicitly, just in case something goes wrong with the calculation.


#### `PLAYER NAME`

Name of the person playing the character.

- `"PLAYER NAME": "Dave"`
- `PLAYER NAME: Gary`
- `"PLAYER NAME": ""` (for templates)



#### `PP`

Number of platinum pieces in the character's inventory.
May also be left blank.

- `PP: 10`
- `PP: ""`


#### `PREGENERATED`

A Boolean field that marks pregenerated characters.
Some templates will label such characters.



#### `PROFICIENCIES`

A list of the character's skill, tool, language, and other proficiencies.
A completely blank list element is interpreted as a separator between
groups of related proficiencies. 
(Only the first two groups are shown on the GM's summary sheet.)
The separator can also be written as `proficiencies_skip: true`.

```yaml
PROFICIENCIES:
  - "Acrobatics"
  - "Arcana"
  - 
  - Dwarvish
  - "Language (Common)"
  - "Languages: Elvish"  # alternate format
  - 
  - "Simple Weapons"
  - "All Armor"
```

#### `PROFICIENCY BONUS`

The character's proficiency bonus, which is displayed near the proficiencies.
This value can be calculated by the system.

- `"PROFICIENCY BONUS": "+2"`
- `"PROFICIENCY BONUS": "+3"`
- `PROFICIENCY BONUS: +2`



#### `RACE`

Character's race and (optionally) subrace.

- `"RACE": "Elf (High)"`
- `"RACE": "Human (Sunderland)"`
- `RACE: Human`
- `RACE: Wood Elf`



#### `SENSES`

Special senses that may be displayed on the character sheet.

- `"SENSES": "Darkvision 60 ft."`
- `"SENSES": ""`
- `SENSES: Blindsight 25 ft.`


#### `SHEET ORIGIN`

Metadata indicating where the character sheet came from.

- `"SHEET ORIGIN": "Wizard by NoxAeternus"`
- `"SHEET ORIGIN": "Character Builder Web Form"`
- `"SHEET ORIGIN": "Manual YAML Creation"`
- `"SHEET ORIGIN": "D&D Beyond Import"`



#### `SORCERY POINTS`

The total number of sorcery points available to the character.
May be displayed using circles that can be marked.

- `SORCERY POINTS: 3`



#### `SPECIALTY`

The character's class specialty (subclass, domain, archetype, etc.).

- `SPECIALTY: "Life Domain"` (for clerics)
- `SPECIALTY: "Champion"` (for fighters)
- `SPECIALTY: "Draconic Bloodline"` (for sorcerers)
- `SPECIALTY: ""` (empty/not specified)
- `SPECIALTY: Champion`



#### `SP`

Number of silver pieces in the character's inventory.
May be left blank.

- `SP: 10`
- `SP: ""`



#### `SPEED`

Character's normal movement speed.
(The system does not yet track specialized speeds like climbing, swimming, and so on.)

- `"SPEED": "30 ft."`
- `"SPEED": "25"`
- `SPEED: '35'`
- `SPEED: 30 ft`



#### `SPELL ATTACK MODIFIER` (calculated by the system)

This modifier is calculated using the character's proficiency bonus
and spellcasting ability modifier.

#### `SPELL DC`

A number that is normally calculated by the system, but can also be
written explicitly.
If it is written explicitly the system will validate it.

- `SPELL DC: 13`

#### `SPELLCASTING ABILITY MODIFIER` (calculated by the system)

A modifier that is  calculated from the appropriate ability score (`CHA` for Bard/Sorcerer/Warlock, `WIS` for Cleric/Druid/Ranger, `INT` for Wizard).



#### `SPELLS KNOWN`

A number that may be used for spell tracking.
May appear only on the GM's sheet.

- `SPELLS KNOWN: 5`



#### `STR`

The Strength ability score, a number, as in `STR: 15`.


#### `STR SAVING` (calculated by the system)

If the character `CLASS` indicates saving-throw proficiency in
Strength,
the rendering engine defines `STR SAVING` to be `true`.
Otherwise `STR SAVING` is left undefined.

**Usage**: Strength ability score
**Type**: Number
**Template Usage**: Displayed in stats column with calculated modifier
**Examples**:
- `STR: 17`
- `STR: 8`
- `STR: 9`
- `STR: 16`



#### `TRAITS`

A list of tables each containing a `name` and `description` key.
May be used for the character's personality traits, ideals, bonds, and
flaws.
Not used by any of the current templates.

#### `VALIDATION ERRORS` (generated by the rendering engine)

A list of strings.

If the rendering engine detects a badly formatted value or a value
that is inconsistent with a calculated value, it adds an error message
to the list.
Some templates render this list as an additional error page.



#### `WIS`

The Wisdom ability score, a number, as in `WIS: 15`.


#### `WIS SAVING` (calculated by the system)

If the character `CLASS` indicates saving-throw proficiency in
Wisdom,
the rendering engine defines `WIS SAVING` to be `true`.
Otherwise `WIS SAVING` is left undefined.
