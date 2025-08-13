---
title: 'Quick-Start Guide to YAML Character Sheets'
header-includes: |
  <style>
  .playername { background-color: #e8f5d0; }
  .stats { background-color: #e6f2ff; }
  .hpetc { background-color: #e6e6e6; }
  .proficiencies { background-color: #fffae6; }
  .attacks { background-color: #ffe6cc; }
  .magic { background-color: #ffe6e6; }
  .features { background-color: #f0e6f7; }
  .equipment { background-color: #e8f5d0; }
  div.playername, div.stats, div.hpetc, div.proficiencies, div.attacks, div.magic, div.features, div.equipment {
    padding: 1em;
    margin: 0.5em 0;
    border-radius: 4px;
  }
  body {
    font-family: tahoma, verdana, arial, sans-serif;
    font-size: 11pt;
    max-width: 52em;
    margin-left: 1em;
  }
  a {
    color: #35A;
    text-decoration: none;
  }
  a:hover {
    text-decoration: underline;
  }
  </style>
---

<article>

This guide walks you through creating a D&D character sheet using YAML, following the visual order and colored sections of the generated character sheet. Use examples from `zanogh.pdf` (Barbarian) and `miriel.pdf` (Cleric) as reference.

## Character Info Section

<div class="playername">

This banner section at the top contains the core character identity information.

### Character Name and Identity
Start with your character's basic identity:

```yaml
"CHARACTER NAME": "Zanogh Greyfist"
"PLAYER NAME": "Amelia"
"CLASS & LEVEL": "Barbarian 3"
"RACE": "Half-Orc"
"BACKGROUND": "Hermit"
"ALIGNMENT": ""
"EXPERIENCE POINTS": ""
```

**Key Notes:**
- `"CHARACTER NAME"` appears prominently in large italic text
- `"CLASS & LEVEL"` should include subclass if applicable (e.g., "Cleric (Life Domain) 3")
- All keys with spaces must be quoted
- Leave `"ALIGNMENT"` and `"EXPERIENCE POINTS"` empty if not yet determined

### Character Motivation
Optionally add a personal motivation that appears in italics:

```yaml
MOTIVATION: "Zanogh wants to get in touch with her orcish side"
```

</div>

## Stats Section

<div class="stats">

The ability scores appear in the left column with blue background. These are the foundation of your character.

### The Six Ability Scores
```yaml
STR: 17
DEX: 14  
CON: 14
INT: 8
WIS: 12
CHA: 10
```

### Proficiency Bonus
```yaml
"PROFICIENCY BONUS": "+2"
```

**Key Notes:**
- Ability scores are just the raw numbers (8-20 typically)
- The system automatically calculates modifiers and saving throw proficiencies
- Proficiency bonus should include the + sign
- Based on your class, saving throw proficiencies are auto-generated

</div>

## Combat Stats Section

<div class="hpetc">

This section contains hit points, initiative, speed, and armor class.

### Hit Points and Combat Info
```yaml
"MAX HP": 32
"CURRENT HIT POINTS": ""
"HIT DICE": "d12"
"INITIATIVE": "+2"
"SPEED": "30"
"ARMOR CLASS": 14
```

**Key Notes:**
- `"CURRENT HIT POINTS"` is typically left empty for filling during play
- `"HIT DICE"` should match your class (d6, d8, d10, d12)
- Initiative should include the + or - sign
- Speed can include "ft." but it's not required

### Senses and Spell Information
Additional combat-relevant info may appear in this area:

```yaml
"SENSES": "Darkvision 60 ft."
"PASSIVE PERCEPTION": 13
SPELL DC: 13  # For spellcasters only
```

</div>

## Proficiencies Section

<div class="proficiencies">

Lists all your character's proficiencies, organized by type.

### Skills, Languages, and Equipment Proficiencies
```yaml
PROFICIENCIES:
  - "Animal Handling"
  - "Athletics" 
  - "Perception"
  - "Intimidation"
  - "Survival"
  -   # Blank entry creates visual separator
  - "Herbalism Kit"
  - proficiencies_skip: true  # Alternative separator syntax
  - "Common"
  - "Orcish"
  - "Dwarvish"
  - "Light Armor"
  - "Medium Armor"
  - "Shield"
  - "Simple Weapons"
  - "Martial Weapons"
```

**Key Notes:**
- Use `-` (blank list entry) or `proficiencies_skip: true` to create visual separators between sections
- Languages can be formatted as just the name (e.g., "Common") 
- Armor and weapon proficiencies follow D&D categorizations

</div>

## Attacks Section

<div class="attacks">

Your character's weapon attacks and combat options.

### Attack Entries
```yaml
ATTACKS:
  - NAME: "Greataxe"
    ATTACK: "+5"
    DAMAGE: "1d12+3"
    TYPE: "slashing"
    RANGE: "5 ft."
    AMMO: "—"
  - NAME: "Hand Axe (x2)"
    ATTACK: "+5" 
    DAMAGE: "1d6+3"
    TYPE: "slashing"
    RANGE: "5ft, 20/60 ft."
    AMMO: "—"
```

**Key Notes:**
- Each attack needs all six fields: NAME, ATTACK, DAMAGE, TYPE, RANGE, AMMO
- Attack bonus should include + or - sign
- Use "—" for AMMO when not applicable
- RANGE can include multiple ranges for thrown weapons

</div>

## Magic Section

<div class="magic">

Spells and magical abilities. This section only appears for spellcasters.

### Spell Structure
```yaml
MAGIC:
  - level: 0  # Cantrips
  - name: "Sacred Flame"
    description: "Target one creature; DEX save or 1d8 radiant damage."
  - name: "Spare the Dying"
    description: "One unconscious creature you touch is stabilized."
  - level: 1  # 1st level spells
  - name: "Cure Wounds"
    description: "A touched creature regains 1d8+3 HP, +3 more (DoL)."
  - name: "Bless [C]"
    description: "Up to three allies within 30 ft gain +1d4 to attacks and saves for 1 minute [Life domain]."
```

### Advanced Spell Slot Tracking
For classes with spell slots:
```yaml
MAGIC:
  - level: {number: 1, slots: 4}  # 1st level with 4 slots
  - name: "Magic Missile"
    description: "Create 3 darts that each deal 1d4+1 force damage"
  - level: {number: 2, slots: 2}  # 2nd level with 2 slots
```

**Key Notes:**
- Use `level: 0` for cantrips
- Spell descriptions can include formatting markers like [C] for concentration, [B] for bonus action
- For non-casters, use `MAGIC: []` (empty list)

### Font Control for Magic
For dense spell lists, control font size:
```yaml
MAGIC FONT: \small
```

</div>

## Features Section

<div class="features">

Class features, racial traits, and special abilities.

### Feature Structure
```yaml
FEATURES:
  - name: "Rage"
    description: "Start/stop as a bonus action. Lasts 1 minute or until you are unconscious or fail to attack or take damage for 1 turn. Can't concentrate. While raging: • Advantage on Str checks & saves. • Melee Str attacks deal +2 damage. • You take half damage from bludgeoning, piercing, and slashing damage. • At 3rd level, 3 times per long rest."
  - name: "Unarmored Defense"  
    description: "If you wear no armor, your AC = 10 + Dex + Con."
  - name: "Savage Attacks"
    description: "When you score a critical hit with a melee attack, add one extra weapon damage die to the total."
```

**Key Notes:**
- Each feature needs a `name` and `description`
- Descriptions can be quite long and include formatting
- Include both class and racial features

</div>

## Equipment Section

<div class="equipment">

Character's gear, items, and currency.

### Equipment List
```yaml
EQUIPMENT:
  - "Scale Mail Armor"
  - "Shield (+2 AC)"
  - "Backpack"
  - "Bedroll" 
  - "Mess Kit"
  - "Tinderbox"
  - "Torches (10)"
  - "Rations (10)"
  - "Waterskin"
```

### Currency
```yaml
CP: ""  # Copper pieces
SP: ""  # Silver pieces  
EP: ""  # Electrum pieces
GP: ""  # Gold pieces
PP: ""  # Platinum pieces
```

**Key Notes:**
- Equipment is a simple list of strings
- Include important details like "+2 AC" for shields
- Currency can be numbers or empty strings
- Equipment section may display in multiple columns for non-casters

</div>

## Class-Specific Keys

Some keys are specific to certain classes or character types:

### Clerics
```yaml
DOMAIN SPELLS: 2  # Number of domain spells
SPELLS KNOWN: 5   # Total spells known
```

### Sorcerers  
```yaml
SORCERY POINTS: 3  # Sorcery points available
```

### Pregenerated Characters
```yaml
PREGENERATED: true  # Marks template characters
```

## Complete Example: Basic Fighter

Here's a minimal example for a 1st-level Fighter:

```yaml
"CHARACTER NAME": ""
"PLAYER NAME": ""
"CLASS & LEVEL": "Fighter 1"
"RACE": "Human"
"BACKGROUND": "Soldier"
"ALIGNMENT": ""
"EXPERIENCE POINTS": ""

STR: 16
DEX: 13
CON: 14
INT: 10
WIS: 12
CHA: 8

"PROFICIENCY BONUS": "+2"
"MAX HP": 12
"CURRENT HIT POINTS": ""
"HIT DICE": "d10"
"INITIATIVE": "+1"
"SPEED": "30"
"ARMOR CLASS": 16
"PASSIVE PERCEPTION": 11

PROFICIENCIES:
  - "Athletics"
  - "Intimidation"
  -   # Separator
  - "Common"
  - "All Armor"
  - "Shield"
  - "Simple Weapons"
  - "Martial Weapons"

ATTACKS:
  - NAME: "Longsword"
    ATTACK: "+5"
    DAMAGE: "1d8+3"
    TYPE: "slashing"
    RANGE: "5 ft."
    AMMO: "—"

MAGIC: []

FEATURES:
  - name: "Fighting Style"
    description: "Choose a fighting style that grants combat benefits."
  - name: "Second Wind"
    description: "Regain 1d10+1 hit points as a bonus action. Once per rest."

EQUIPMENT:
  - "Chain Mail"
  - "Shield"
  - "Longsword"
  - "Backpack"
  - "Bedroll"
  - "Rations (10)"

CP: ""
SP: ""
EP: ""
GP: ""
PP: ""
```

## Tips for Success

1. **Start Simple**: Begin with basic required fields, then add details
2. **Check Examples**: Reference `zanogh.yaml` and `miriel.yaml` for complex characters
3. **Mind the Quotes**: Keys with spaces need quotes, values usually don't
4. **Test Early**: Generate a PDF frequently to see how your YAML renders
5. **Use Separators**: Add `-` (blank entry) to organize proficiencies visually
6. **Empty vs Missing**: Use empty strings `""` for fields you want to fill in later

## Next Steps

Once you have a basic character sheet working:

1. Generate a PDF: `./charsheet -o mycharacter.pdf mycharacter.yaml`
2. Refine the details based on the visual output
3. Add class-specific features and spells
4. Customize font sizes if needed
5. Create additional characters using the same structure

The character sheet system is flexible—start with the essentials and build up your character's complexity over time.

</article>