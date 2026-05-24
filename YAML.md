---
title: YAML Key Reference (D&D Character Sheets)
---

# Introduction

The bulk of this document is an alphabetical reference of all the keys that can define fields in a YAML character sheet.
But a few fields deserve special commentary.

Also, it is not documented which fields are required—but by design it is as few as possible.
You might be able to get a character sheet with as little as `CLASS` and `LEVEL`.

Finally, you will see examples with and without quotation marks.
Most quotation marks are optional.

## Keys for specifying class, level, and specialty

The recommended way to specify class, level, and specialty is with
separate keys `CLASS`, `LEVEL`, and `SPECIALTY`.
However, it is possible to define a single key 
`CLASS & LEVEL`, which may also include a specialty, as in
```yaml
"CLASS & LEVEL": "Cleric (Life Domain) 3"
```
This option is not recommended, but it may be useful when using AI to convert an existing character sheet to YAML format.
When both approaches are used in the same file, the individual keys take precedence over `CLASS & LEVEL`.

## Keys for changing font size

Any key name can have " FONT" appended to control the font used when rendering that section in the character sheet. The value should be a LaTeX font command, as in these examples:

- `MAGIC FONT: \small`
- `EQUIPMENT FONT: \footnotesize`
- `FEATURES FONT: \footnotesize`

If a font-size specification seems not to be having any effect, either
the key in question does not refer to a section of the character
sheet, or there is a bug in my code.
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


# Alphabetical Reference

Each key is described briefly; most are followed by examples.
Unless otherwise specified, a key expects to be associated with a string value.

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

#### `CLASS & LEVEL` (use discouraged)

A string showing the character's class, level, and possibly
background.
It is meant primarily for use in scraping YAML off of other character sheets.

- `"CLASS & LEVEL": "Bard 1"`
- `"CLASS & LEVEL": "Cleric (Life Domain) 3"`
- `"CLASS & LEVEL": Sorcerer 3`

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
**Usage**: Character's experience points
**Type**: String
**Template Usage**: Displayed in character info section
**Examples**:
- `"EXPERIENCE POINTS": "0/300"`
- `"EXPERIENCE POINTS": ""`



#### `FEATURES`
**Usage**: Character's class features, racial traits, etc.
**Type**: List of structured objects
**Template Usage**: Displayed in features section
**Structure**: Each feature contains:
- `name`: String (feature name)
- `description`: String (feature description)
In addition, each feature may be labeled with any or all of the following keys:
- `bonus`: true (the feature involves a bonus action)
- `reaction`: true (the feature involves a reaction)
- `attack`: true (the feature involves an attack roll)
- `save`: true (the feature requires an enemy's to make a saving throw)
- `enemy`: true (the feature targets an enemy)
- `duration`: String (when the feature causes an effect that lasts for more than one action action)



**Examples**:
```yaml
FEATURES:
  - name: "Fey Ancestry"
    description: "You have advantage to save against charms and you can't be magically put to sleep."
  - name: "Bardic Inspiration 2/day"  
    description: "Grant an ally within 60 ft. +1d6 inspiration they can use on any one check within 10 minutes."
```



#### `GM NOTES`
**Usage**: Private notes for the game master
**Type**: String (can be multi-line)
**Template Usage**: Not rendered in PDF or web form (GM only)
**Examples**:
- `GM NOTES: "Player tends to be cautious in combat"`
- `GM NOTES: "Has strong connection to the local thieves' guild"`
- `GM NOTES: "Secretly searching for their missing sister"`



#### `CP`

Number of copper pieces in the character's inventory.
May also be left blank.

- `CP: 10`
- `CP: ""`

#### `GP`
**Usage**: Gold pieces
**Type**: String or Number
**Template Usage**: Displayed in coin section
**Examples**:
- `GP: 10`
- `GP: ""`
- `GP: 150`



#### `HIT DICE`
**Usage**: Character's hit die type
**Type**: String
**Template Usage**: Displayed in hit dice section
**Examples**:
- `"HIT DICE": "d8"`
- `"HIT DICE": "d12"`
- `HIT DICE: d6`
- `HIT DICE: d10`



#### `INITIATIVE`
**Usage**: Character's initiative modifier
**Type**: String (with sign)
**Template Usage**: Displayed in initiative box
**Examples**:
- `"INITIATIVE": "+2"`
- `"INITIATIVE": "-1"`
- `INITIATIVE: '+3'`



#### `CON`

The Constitution ability score, a number, as in `CON: 15`.


#### `CON SAVING` (calculated by the system)

If the character `CLASS` indicates saving-throw proficiency in
Constitution,
the rendering engine defines `CON SAVING` to be `true`.
Otherwise `CON SAVING` is left undefined.
#### `INT`
**Usage**: Intelligence ability score
**Type**: Number
**Template Usage**: Displayed in stats column with calculated modifier
**Examples**:
- `INT: 15`
- `INT: 8`
- `INT: 13`



#### `INT SAVING` (CALCULATED)
**Usage**: Intelligence saving throw proficiency indicator
**Type**: Boolean
**Template Usage**: Shows proficiency marker on Intelligence save
**Calculated By**: `extend()` function based on class
**Note**: Automatically set to `true` for classes with Intelligence save proficiency (Druid, Rogue, Wizard). Do not include in YAML files.



#### `LAYOUT`
**Usage**: Defines the character sheet layout style
**Type**: String
**Template Usage**: Controls which template layout is used for PDF generation
**Valid Options**:
- `silverpine` - Silverpine Watch style (one narrow column, one wide)
- `3col` - Three narrow columns
**Default**: If omitted, uses default layout (handled by charsheet script)
**Examples**:
- `LAYOUT: silverpine`
- `LAYOUT: 3col`



#### `LEVEL` (USER/CALCULATED)
**Usage**: Character's level
**Type**: Number
**Template Usage**: Used for spell slot calculations and other level-dependent features
**Examples**:
- `LEVEL: 1`
- `LEVEL: 3`
- `LEVEL: 20`

**Note**: Can be provided directly by user or auto-extracted from "CLASS & LEVEL" by `extend()` function



#### `MAGIC`
**Usage**: Character's spells and magical abilities
**Type**: List of mixed objects or empty list
**Template Usage**: Displayed in magic section when present
**Structure**: Can contain:
- Level indicators: A single table entry with `level` (required) and `slots` (required for level ≥ 1, omitted for cantrips)
  - For cantrips: `level: 0`
  - For spell levels: `level: 1` with `slots: 2` (or appropriate slot count)
- Spell entries with `name` and `description`
In addition, each spell may be labeled with any or all of the following keys:
- `bonus`: true (the spell may be cast as a bonus action)
- `reaction`: true (the spell may be cast as a reaction)
- `attack`: true (casting the spell requires an attack roll)
- `save`: stat (casting the spell requires an enemy to make a saving throw)
- `enemy`: true (the spell targets an enemy [implied by `attack` or `save`])
- `ritual`: true (the spell may be cast as a ritual)
- `duration`: String (how long the spell lasts, if more than one action)
- `concentration`: true (the spell requires concentration)

**Examples**:
```yaml
MAGIC:
  - level: 0
  - name: "Fire Bolt"
    description: "Make a ranged spell attack (+5) to deal 1d10 fire damage"
  - level: 1
    slots: 2
  - name: "Magic Missile"
    description: "Create 3 darts that each deal 1d4+1 force damage"
```

**Non-caster example**:
```yaml
MAGIC: []
```



#### `MAGIC FONT`
**Usage**: Controls font size for the magic section rendering
**Type**: String (LaTeX font command)
**Template Usage**: When specified, changes the font size of the entire magic section
**Examples**:
- `MAGIC FONT: \small` (renders magic section in small font)
- `MAGIC FONT: \normalsize` (renders magic section in normal font, explicit)
- `MAGIC FONT: \tiny` (renders magic section in tiny font)

**Note**: If not specified, magic section renders at normal size. The value should include LaTeX font size commands.



#### `MAGIC SEPARATE`
**Usage**: Controls whether magic section appears on a separate page
**Type**: Boolean
**Template Usage**: When true (using \ifDNDfalse semantics), renders magic section on its own page
**Examples**:
- `MAGIC SEPARATE: true` (magic on separate page)
- `MAGIC SEPARATE: 1` (magic on separate page)
- `MAGIC SEPARATE: false` (magic inline, default behavior)
- `MAGIC SEPARATE: 0` (magic inline, default behavior)

**Note**: Follows \ifDNDfalse semantics: undefined, empty, "0", or "false" are considered false. Any other value is true.



#### `MAX HP`
**Usage**: Character's maximum hit points
**Type**: Number
**Template Usage**: Displayed prominently in max HP box
**Examples**:
- `"MAX HP": 11`
- `"MAX HP": 32`
- `MAX HP: 28`
- `MAX HP: 15`



#### `MOTIVATION`
**Usage**: Character's personal motivation
**Type**: String
**Template Usage**: Displayed in italic text near character info
**Examples**:
- `MOTIVATION: "Kylane wants to harness her newfound power"`
- `MOTIVATION: "Miriel is trying to prove herself"`
- `MOTIVATION: "Motivation: find family"`



#### `PASSIVE PERCEPTION` (USER/CALCULATED)
**Usage**: Character's passive Perception score
**Type**: Number
**Template Usage**: May be displayed in senses area or separate box
**Calculated By**: `extend()` function calculates as 10 + WIS modifier + proficiency bonus (if character doesn't have Expertise in Perception)
**Examples**:
- `"PASSIVE PERCEPTION": 13`
- `"PASSIVE PERCEPTION": 9`
- `PASSIVE PERCEPTION: 15`

**Note**: If not provided, the script will calculate this automatically. If provided, the script will validate the value against the calculated result.



#### `PLAYER NAME`
**Usage**: Name of the player (not character)
**Type**: String
**Template Usage**: Displayed in character info section
**Examples**:
- `"PLAYER NAME": "Katie"`
- `"PLAYER NAME": ""` (for templates)
- `PLAYER NAME: Katie`
- `PLAYER NAME: Web Test User`



#### `CP`

Number of copper pieces in the character's inventory.
May also be left blank.

- `CP: 10`
- `CP: ""`

#### `PP`
**Usage**: Platinum pieces
**Type**: String
**Template Usage**: Displayed in coin section
**Examples**:
- `PP: ""`

**Note**: Always empty in current character files



#### `PREGENERATED`
**Usage**: Marks template/pregenerated characters
**Type**: Boolean
**Template Usage**: Controls display of template-specific elements
**Examples**:
- `PREGENERATED: true`



#### `PROFICIENCIES`
**Usage**: Character's skill, tool, language, and other proficiencies
**Type**: List of strings with special entries
**Template Usage**: Displayed in proficiencies section
**Special Entries**:
- `proficiencies_skip: true` - Creates visual separator in proficiencies section

**Examples**:
```yaml
PROFICIENCIES:
  - "Acrobatics"
  - "Arcana"
  - "Language (Common)"
  - "Languages: Elvish"  # alternate format
  - proficiencies_skip: true
  - "Simple Weapons"
  - "All Armor"
```

**Note**: Language format varies between files



#### `PROFICIENCY BONUS`
**Usage**: Character's proficiency bonus
**Type**: String (with + sign)
**Template Usage**: Displayed in circular proficiency bonus box
**Examples**:
- `"PROFICIENCY BONUS": "+2"`
- `"PROFICIENCY BONUS": "+3"`
- `PROFICIENCY BONUS: +2`



#### `RACE`
**Usage**: Character's race and subrace
**Type**: String
**Template Usage**: Displayed in character info section
**Examples**:
- `"RACE": "Elf (High)"`
- `"RACE": "Human (Sunderland)"`
- `RACE: Human`
- `RACE: Wood Elf`



#### `SENSES`
**Usage**: Character's special senses
**Type**: String
**Template Usage**: May be displayed in senses box if present
**Examples**:
- `"SENSES": "Darkvision 60 ft."`
- `"SENSES": ""`
- `SENSES: Darkvision 60 ft.`



#### `SHEET ORIGIN`
**Usage**: Metadata indicating where the character sheet originated from
**Type**: String
**Template Usage**: Informational metadata, may be used for tracking or attribution
**Examples**:
- `"SHEET ORIGIN": "Character Builder Web Form"`
- `"SHEET ORIGIN": "Manual YAML Creation"`
- `"SHEET ORIGIN": "D&D Beyond Import"`



#### `SORCERY POINTS`
**Usage**: Sorcerer's sorcery points
**Type**: Number
**Template Usage**: Displayed as slots if character has this feature
**Examples**:
- `SORCERY POINTS: 3`



#### `SPECIALTY`
**Usage**: Character's class specialty (subclass, domain, archetype, etc.)
**Type**: String
**Template Usage**: When present, displayed in "CLASS & LEVEL" field in parentheses between class and level
**Examples**:
- `SPECIALTY: "Life Domain"` (for clerics)
- `SPECIALTY: "Champion"` (for fighters)
- `SPECIALTY: "Draconic Bloodline"` (for sorcerers)
- `SPECIALTY: ""` (empty/not specified)
- `SPECIALTY: Champion`

**Compatibility**:
- If both `SPECIALTY` and specialty in `"CLASS & LEVEL"` parentheses exist, `SPECIALTY` field takes precedence
- The system can extract specialty from existing `"CLASS & LEVEL"` format like "Cleric (Life Domain) 3"



#### `CP`

Number of copper pieces in the character's inventory.
May also be left blank.

- `CP: 10`
- `CP: ""`

#### `SP`
**Usage**: Silver pieces
**Type**: String or Number
**Template Usage**: Displayed in coin section
**Examples**:
- `SP: 5`
- `SP: ""`
- `SP: 10`



#### `SPEED`
**Usage**: Character's movement speed
**Type**: String
**Template Usage**: Displayed in speed box
**Examples**:
- `"SPEED": "30 ft."`
- `"SPEED": "25"`
- `SPEED: '35'`
- `SPEED: 30 ft`



#### `SPELL ATTACK MODIFIER` (CALCULATED)
**Usage**: Character's spell attack modifier
**Type**: String
**Template Usage**: Used for spell attack calculations
**Calculated By**: `extend()` function calculates as proficiency bonus + spellcasting ability modifier (for characters with MAGIC)
**Examples**:
- `SPELL ATTACK MODIFIER: "+5"`

**Note**: Do not include in YAML files. Automatically calculated based on class, level, and spellcasting ability score.



#### `SPELL DC` (USER/CALCULATED)
**Usage**: Character's spell save DC
**Type**: Number
**Template Usage**: May be displayed in upper info area
**Calculated By**: `extend()` function calculates as 8 + proficiency bonus + spellcasting ability modifier (for characters with MAGIC)
**Examples**:
- `SPELL DC: 13`

**Note**: If not provided, the script will calculate this automatically for spellcasters. If provided, the script will validate the value against the calculated result.



#### `SPELLCASTING ABILITY MODIFIER` (CALCULATED)
**Usage**: Character's spellcasting ability modifier
**Type**: Number
**Template Usage**: Used for spellcasting calculations
**Calculated By**: `extend()` function calculates from the spellcasting ability score (for characters with MAGIC)
**Examples**:
- `SPELLCASTING ABILITY MODIFIER: 3`

**Note**: Do not include in YAML files. Automatically calculated from the appropriate ability score (CHA for Bard/Sorcerer/Warlock, WIS for Cleric/Druid/Ranger, INT for Wizard).



#### `SPELLS KNOWN`
**Usage**: Number of spells known (certain classes)
**Type**: Number
**Template Usage**: May be used for spell tracking
**Examples**:
- `SPELLS KNOWN: 5`



#### `STR`
**Usage**: Strength ability score
**Type**: Number
**Template Usage**: Displayed in stats column with calculated modifier
**Examples**:
- `STR: 17`
- `STR: 8`
- `STR: 9`
- `STR: 16`



#### `STR SAVING` (CALCULATED)
**Usage**: Strength saving throw proficiency indicator
**Type**: Boolean
**Template Usage**: Shows proficiency marker on Strength save
**Calculated By**: `extend()` function based on class
**Note**: Automatically set to `true` for classes with Strength save proficiency (Barbarian, Fighter, Monk, Paladin, Ranger). Do not include in YAML files.



#### `TRAITS`
**Usage**: Character personality traits, ideals, bonds, flaws
**Type**: List of structured objects
**Template Usage**: *Not used by any known template at present*
**Structure**: Each trait contains:
- `name`: String (trait type: "Trait", "Ideal", "Bond", "Flaw")
- `description`: String (trait description)

**Examples**:
```yaml
TRAITS:
  - name: "Trait"
    description: "Listens to all sides of argument."
  - name: "Ideal"
    description: "Logic above all else."
```



#### `VALIDATION ERRORS` (generated by the rendering engine)

A list of strings.

If the rendering engine detects a badly formatted value or a value
that is inconsistent with a calculated value, it adds an error message
to the list.



#### `CON`

The Constitution ability score, a number, as in `CON: 15`.


#### `CON SAVING` (calculated by the system)

If the character `CLASS` indicates saving-throw proficiency in
Constitution,
the rendering engine defines `CON SAVING` to be `true`.
Otherwise `CON SAVING` is left undefined.

#### `WIS`
**Usage**: Wisdom ability score
**Type**: Number
**Template Usage**: Displayed in stats column with calculated modifier
**Examples**:
- `WIS: 16`
- `WIS: 12`
- `WIS: 11`



#### `WIS SAVING` (CALCULATED)
**Usage**: Wisdom saving throw proficiency indicator
**Type**: Boolean
**Template Usage**: Shows proficiency marker on Wisdom save
**Calculated By**: `extend()` function based on class
**Note**: Automatically set to `true` for classes with Wisdom save proficiency (Cleric, Druid, Monk, Paladin, Warlock, Wizard). Do not include in YAML files.

