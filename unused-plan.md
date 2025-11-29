# Plan for handling currently unaccessed JSON fields

## Fields to convert to YAML

### Threat levels (stat names)
These map to THREATS table in YAML: poor=-1, average=0, good=+1

- armorName → THREATS["AC"]
- atkName → THREATS["ATTACK BONUS"]
- dprName → THREATS["DPR"]
- hpName → THREATS["MAX HP"]
- stName → THREATS["DC"]

### Condition immunities
- conditions → IMMUNITIES (list of condition names)

### Flying hover capability
- hover → HOVER: true to the SPEEDS  table described below

### Hit dice
- hitDice → HIT DICE field (format as 'd%d', e.g., d8, d10)

### Saving throw proficiencies
- sthrows → SAVE PROFICIENCIES (list of ability names from sthrows[].name)

### Telepathy
- telepathy → Add "Telepathy" to ABILITIES if telepathy > 0

## Fields that are adjustments (need research/clarification)

- acadj → AC ADJUSTMENT (convert only)
- hpadj → HP ADJUSTMENT (convert only)
- threatadj → assert it is 0
- threatval → THREAT value

## Fields for derived/calculated values (ignore - handled elsewhere)

- dpr → will not appear in source files.  ignore.
- separationPoint → Layout hint (not data)

## Fields for presentation/UI (ignore - not core data)

- customSpeed → Redundant with speedDesc
- doubleColumns → Layout flag
- isLegendary → Can derive from presence of LEGENDARY ACTIONS
- legendariesDescription → Standard text, not unique data.  ignore.
- paragon → fancy pants stuff for special monsters. ignore.
- shieldBonus → Already factored into AC.  ignore.
- specialdamage → Presentation detail

## Fields that are field labels/names (ignore - metadata)





## Other

- speedDesc → human-readable speed info. translate to SPEED
- properties → check, error if it is not an empty list

- Translate numeric JSON speed properties into a yaml table SPEEDS,
keyed by WALK, BURROW, CLIMB, FLY, SWIM.  Take those properties out of top level.


add  MORALE table with these keys:

  THRESHOLD: number between 0 and 1, fraction of HP when morale check is triggered
  TRIGGER: string, describes what the THRESHOLD is meant to represent
  TYPE: string, describes behavior when morale check is failed
  DC: difficulty of the morale check
  
These come from the following json fields
- mthresh
- mtrig
- mtype
- mdc



- bonuses → translate to BONUS ACTIONS list when nonempty
- otherArmorDesc → ARMOR (string description)
- blind -> BLIND (boolean, the monster does not have vision)

- hpCut → a number.  assert that it is 1.

- customSpeed: assert it is `false`
- specialDamage: assert it is the empty object
