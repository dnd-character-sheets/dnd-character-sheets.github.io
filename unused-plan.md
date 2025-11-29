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
- threatadj → ignore
- threatval → THREAT value

## Fields for derived/calculated values (ignore - handled elsewhere)

- dpr → will not appear in source files.  ignore.
- mthresh → Minion threshold (derived)
- mtrig → Minion trigger (derived)
- mtype → Minion type (derived)
- separationPoint → Layout hint (not data)

## Fields for presentation/UI (ignore - not core data)

- bonuses → Presentation detail
- customSpeed → Redundant with speedDesc
- doubleColumns → Layout flag
- hpCut → Layout/calculation threshold
- isLegendary → Can derive from presence of LEGENDARY ACTIONS
- legendariesDescription → Standard text, not unique data
- otherArmorDesc → Presentation detail
- paragon → Presentation flag
- shieldBonus → Already factored into AC
- specialdamage → Presentation detail

## Fields that are field labels/names (ignore - metadata)



- blind → Seems to be for blindsight range (but we use "blindsight" field)


## Other

- speedDesc → human-readable speed info. translate to SPEED
- properties → check, error if it is not an empty list

- Translate numeric JSON speed properties into a yaml table SPEEDS,
keyed by WALK, BURROW, CLIMB, FLY, SWIM.  Take those properties out of top level.

