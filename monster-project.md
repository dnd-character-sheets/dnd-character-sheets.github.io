Our next project is to develop a similar YAML infrastructure for dealing with monsters.

Monsters have the same properties as player characters, except not the following:

  PLAYER NAME, CHARACTER NAME, LEVEL, STONES, RACE, CLASS, BACKGROUND, MOTIVATION, MAGIC, FEATURES, EQUIPMENT, CP, GP, PP, SP, ATTACKS, PROFICIENCES
  
Monsters have or may have the following additional properties:

DPR: damage per round (number)
ATTACK BONUS: bonus of best attack
DC: save DC of best attack or best spell

NAME: monster's name
TIER: one of these: legendary veteran apprentice heroic champion adventurer journeyman
ORGANIZATION one of these: party solo gang group mob pair
SIZE: standard DND size
HABITATS: list of strings
MONSTER TYPE: string
BURROW, CLIMB, FLY, SWIM: number or string (a speed)
SKILLS: list of (string, number) pairs
VULNERABILITIES, RESISTANCES, IMMUNITIES: list of strings
SENSES: list of (string, number or string) pairs
LANGUAGES: list of strings
CR: number (challenge rating)
THREAT: number (total threat by F*CR)
XP: number of XP gained if killed


TRAITS: a list of { name, description }.  Like features for characters.  
MULTIATTACK: like TRAITS
LEGENDARY ACTIONS: like TRAITS
LAIR ACTIONS: like TRAITS
VILLAIN ACTIONS: like TRAITS
REACTIONS: like TRAITS
ATTACKS: like TRAITS, but also includes an ATTACK BONUS field.

THREATS: table keyed by AC, MAX HP, DPR, ATTACK BONUS, DC
         each value is 'average', 'good', or 'poor'
         defaults to average

