local M, __doc, thismodule, _ENV = require 'module52'.new()

__doc.__overview = [[
This module provides D&D 5e equipment data organized for efficient lookup and filtering.

STRUCTURE:
- Individual items defined as local variables with detailed properties
- Items organized into categorical tables (M.weapons, M.armor, etc.)  
- Weight categories: light (≤3 lb), normal (4-8 lb), heavy (≥9 lb)
- All weights in decimal pounds, prices as strings with currency

ALL ITEM FIELDS:
COMMON FIELDS (all items):
- name: string - Display name of the item
- category: string - Primary category (e.g., "Simple Melee Weapons", "Light Armor")  
- price: string - Cost with currency (e.g., "15 gp", "2 sp")
- weight: number|nil - Weight in pounds (decimal), omitted if no weight

WEAPON-SPECIFIC FIELDS:
- damage_dice: string - Damage dice (e.g., "1d8", "2d6")
- damage_type: string - Type of damage ("bludgeoning", "piercing", "slashing")
- ammunition: string|nil - Range for ammunition weapons (e.g., "80/320")
- finesse: true|nil - Can use Dex instead of Str for attack/damage
- heavy: true|nil - Small/Tiny creatures have disadvantage
- light: true|nil - Suitable for two-weapon fighting
- loading: true|nil - Can only fire one shot per action/bonus/reaction
- reach: true|nil - Adds 5 feet to reach
- special: true|nil - Has special rules (see weapon description)
- thrown: string|nil - Range when thrown (e.g., "20/60")
- two_handed: true|nil - Requires two hands to use
- versatile: string|nil - Damage when used two-handed (e.g., "1d10")

ARMOR-SPECIFIC FIELDS:
- ac_formula: string - AC calculation (e.g., "16", "11 + Dex modifier")
- ac_bonus: number|nil - AC bonus for shields
- strength_requirement: number|nil - Minimum Str needed to wear
- stealth_disadvantage: true|nil - Disadvantage on Stealth checks

TOOL-SPECIFIC FIELDS:
- subcategory: string - Tool subcategory ("artisan", "musical", "kit", "professional")

NOTES:
- Boolean properties use true|nil pattern (not true|false)  
- Weight omitted for weightless items (sling, candles, etc.)
- Services and Trade Goods tables from equipment.md were omitted
]]

-- Simple Melee Weapons
local club = {
  name = "Club", category = "Simple Melee Weapons", price = "1 sp", weight = 2,
  damage_dice = "1d4", damage_type = "bludgeoning", light = true
}

local dagger = {
  name = "Dagger", category = "Simple Melee Weapons", price = "2 gp", weight = 1,
  damage_dice = "1d4", damage_type = "piercing", finesse = true, light = true, thrown = "20/60"
}

local greatclub = {
  name = "Greatclub", category = "Simple Melee Weapons", price = "2 sp", weight = 10,
  damage_dice = "1d8", damage_type = "bludgeoning", two_handed = true
}

local handaxe = {
  name = "Handaxe", category = "Simple Melee Weapons", price = "5 gp", weight = 2,
  damage_dice = "1d6", damage_type = "slashing", light = true, thrown = "20/60"
}

local javelin = {
  name = "Javelin", category = "Simple Melee Weapons", price = "5 sp", weight = 2,
  damage_dice = "1d6", damage_type = "piercing", thrown = "30/120"
}

local light_hammer = {
  name = "Light hammer", category = "Simple Melee Weapons", price = "2 gp", weight = 2,
  damage_dice = "1d4", damage_type = "bludgeoning", light = true, thrown = "20/60"
}

local mace = {
  name = "Mace", category = "Simple Melee Weapons", price = "5 gp", weight = 4,
  damage_dice = "1d6", damage_type = "bludgeoning"
}

local quarterstaff = {
  name = "Quarterstaff", category = "Simple Melee Weapons", price = "2 sp", weight = 4,
  damage_dice = "1d6", damage_type = "bludgeoning", versatile = "1d8"
}

local sickle = {
  name = "Sickle", category = "Simple Melee Weapons", price = "1 gp", weight = 2,
  damage_dice = "1d4", damage_type = "slashing", light = true
}

local spear = {
  name = "Spear", category = "Simple Melee Weapons", price = "1 gp", weight = 3,
  damage_dice = "1d6", damage_type = "piercing", thrown = "20/60", versatile = "1d8"
}

-- Simple Ranged Weapons
local crossbow_light = {
  name = "Crossbow, light", category = "Simple Ranged Weapons", price = "25 gp", weight = 5,
  damage_dice = "1d8", damage_type = "piercing", ammunition = "80/320", loading = true, two_handed = true
}

local dart = {
  name = "Dart", category = "Simple Ranged Weapons", price = "5 cp", weight = 0.25,
  damage_dice = "1d4", damage_type = "piercing", finesse = true, thrown = "20/60"
}

local shortbow = {
  name = "Shortbow", category = "Simple Ranged Weapons", price = "25 gp", weight = 2,
  damage_dice = "1d6", damage_type = "piercing", ammunition = "80/320", two_handed = true
}

local sling = {
  name = "Sling", category = "Simple Ranged Weapons", price = "1 sp",
  damage_dice = "1d4", damage_type = "bludgeoning", ammunition = "30/120"
}

-- Martial Melee Weapons
local battleaxe = {
  name = "Battleaxe", category = "Martial Melee Weapons", price = "10 gp", weight = 4,
  damage_dice = "1d8", damage_type = "slashing", versatile = "1d10"
}

local longsword = {
  name = "Longsword", category = "Martial Melee Weapons", price = "15 gp", weight = 3,
  damage_dice = "1d8", damage_type = "slashing", versatile = "1d10"
}

local scimitar = {
  name = "Scimitar", category = "Martial Melee Weapons", price = "25 gp", weight = 3,
  damage_dice = "1d6", damage_type = "slashing", finesse = true, light = true
}

local shortsword = {
  name = "Shortsword", category = "Martial Melee Weapons", price = "10 gp", weight = 2,
  damage_dice = "1d6", damage_type = "piercing", finesse = true, light = true
}

local rapier = {
  name = "Rapier", category = "Martial Melee Weapons", price = "25 gp", weight = 2,
  damage_dice = "1d8", damage_type = "piercing", finesse = true
}

-- Heavy weapons
local greatsword = {
  name = "Greatsword", category = "Martial Melee Weapons", price = "50 gp", weight = 6,
  damage_dice = "2d6", damage_type = "slashing", heavy = true, two_handed = true
}

local greataxe = {
  name = "Greataxe", category = "Martial Melee Weapons", price = "30 gp", weight = 7,
  damage_dice = "1d12", damage_type = "slashing", heavy = true, two_handed = true
}

local maul = {
  name = "Maul", category = "Martial Melee Weapons", price = "10 gp", weight = 10,
  damage_dice = "2d6", damage_type = "bludgeoning", heavy = true, two_handed = true
}

local pike = {
  name = "Pike", category = "Martial Melee Weapons", price = "5 gp", weight = 18,
  damage_dice = "1d10", damage_type = "piercing", heavy = true, reach = true, two_handed = true
}

local flail = {
  name = "Flail", category = "Martial Melee Weapons", price = "10 gp", weight = 2,
  damage_dice = "1d8", damage_type = "bludgeoning"
}

local glaive = {
  name = "Glaive", category = "Martial Melee Weapons", price = "20 gp", weight = 6,
  damage_dice = "1d10", damage_type = "slashing", heavy = true, reach = true, two_handed = true
}

local halberd = {
  name = "Halberd", category = "Martial Melee Weapons", price = "20 gp", weight = 6,
  damage_dice = "1d10", damage_type = "slashing", heavy = true, reach = true, two_handed = true
}

local lance = {
  name = "Lance", category = "Martial Melee Weapons", price = "10 gp", weight = 6,
  damage_dice = "1d12", damage_type = "piercing", reach = true, special = true
}

local morningstar = {
  name = "Morningstar", category = "Martial Melee Weapons", price = "15 gp", weight = 4,
  damage_dice = "1d8", damage_type = "piercing"
}

local trident = {
  name = "Trident", category = "Martial Melee Weapons", price = "5 gp", weight = 4,
  damage_dice = "1d6", damage_type = "piercing", thrown = "20/60", versatile = "1d8"
}

local war_pick = {
  name = "War pick", category = "Martial Melee Weapons", price = "5 gp", weight = 2,
  damage_dice = "1d8", damage_type = "piercing"
}

local warhammer = {
  name = "Warhammer", category = "Martial Melee Weapons", price = "15 gp", weight = 2,
  damage_dice = "1d8", damage_type = "bludgeoning", versatile = "1d10"
}

local whip = {
  name = "Whip", category = "Martial Melee Weapons", price = "2 gp", weight = 3,
  damage_dice = "1d4", damage_type = "slashing", finesse = true, reach = true
}

-- Martial Ranged Weapons
local blowgun = {
  name = "Blowgun", category = "Martial Ranged Weapons", price = "10 gp", weight = 1,
  damage_dice = "1", damage_type = "piercing", ammunition = "25/100", loading = true
}

local crossbow_hand = {
  name = "Crossbow, hand", category = "Martial Ranged Weapons", price = "75 gp", weight = 3,
  damage_dice = "1d6", damage_type = "piercing", ammunition = "30/120", light = true, loading = true
}

local crossbow_heavy = {
  name = "Crossbow, heavy", category = "Martial Ranged Weapons", price = "50 gp", weight = 18,
  damage_dice = "1d10", damage_type = "piercing", ammunition = "100/400", heavy = true, loading = true, two_handed = true
}

local longbow = {
  name = "Longbow", category = "Martial Ranged Weapons", price = "50 gp", weight = 2,
  damage_dice = "1d8", damage_type = "piercing", ammunition = "150/600", heavy = true, two_handed = true
}

local net = {
  name = "Net", category = "Martial Ranged Weapons", price = "1 gp", weight = 3,
  thrown = "5/15", special = true
}

-- Light Armor
local padded = {
  name = "Padded", category = "Light Armor", price = "5 gp", weight = 8,
  ac_formula = "11 + Dex modifier", stealth_disadvantage = true
}

local leather = {
  name = "Leather", category = "Light Armor", price = "10 gp", weight = 10,
  ac_formula = "11 + Dex modifier"
}

local studded_leather = {
  name = "Studded leather", category = "Light Armor", price = "45 gp", weight = 13,
  ac_formula = "12 + Dex modifier"
}

-- Medium Armor
local hide = {
  name = "Hide", category = "Medium Armor", price = "10 gp", weight = 12,
  ac_formula = "12 + Dex modifier (max 2)"
}

local chain_shirt = {
  name = "Chain shirt", category = "Medium Armor", price = "50 gp", weight = 20,
  ac_formula = "13 + Dex modifier (max 2)"
}

local scale_mail = {
  name = "Scale mail", category = "Medium Armor", price = "50 gp", weight = 45,
  ac_formula = "14 + Dex modifier (max 2)", stealth_disadvantage = true
}

local breastplate = {
  name = "Breastplate", category = "Medium Armor", price = "400 gp", weight = 20,
  ac_formula = "14 + Dex modifier (max 2)"
}

local half_plate = {
  name = "Half plate", category = "Medium Armor", price = "750 gp", weight = 40,
  ac_formula = "15 + Dex modifier (max 2)", stealth_disadvantage = true
}

-- Heavy Armor  
local ring_mail = {
  name = "Ring mail", category = "Heavy Armor", price = "30 gp", weight = 40,
  ac_formula = "14", stealth_disadvantage = true
}

local chain_mail = {
  name = "Chain mail", category = "Heavy Armor", price = "75 gp", weight = 55,
  ac_formula = "16", strength_requirement = 13, stealth_disadvantage = true
}

local splint = {
  name = "Splint", category = "Heavy Armor", price = "200 gp", weight = 60,
  ac_formula = "17", strength_requirement = 15, stealth_disadvantage = true
}

local plate = {
  name = "Plate", category = "Heavy Armor", price = "1,500 gp", weight = 65,
  ac_formula = "18", strength_requirement = 15, stealth_disadvantage = true
}

-- Shield
local shield = {
  name = "Shield", category = "Shield", price = "10 gp", weight = 6,
  ac_bonus = 2
}

-- Sample Adventuring Gear
local backpack = {
  name = "Backpack", category = "Adventuring Gear", price = "2 gp", weight = 5
}

local bedroll = {
  name = "Bedroll", category = "Adventuring Gear", price = "1 gp", weight = 7
}

local rope_hempen = {
  name = "Rope, hempen (50 feet)", category = "Adventuring Gear", price = "1 gp", weight = 10
}

local thieves_tools = {
  name = "Thieves' tools", category = "Tools", subcategory = "professional", price = "25 gp", weight = 1
}

local smiths_tools = {
  name = "Smith's tools", category = "Tools", subcategory = "artisan", price = "20 gp", weight = 8
}

-- More Ammunition
local arrows = {
  name = "Arrows (20)", category = "Ammunition", price = "1 gp", weight = 1
}

local crossbow_bolts = {
  name = "Crossbow bolts (20)", category = "Ammunition", price = "1 gp", weight = 1.5
}

local blowgun_needles = {
  name = "Blowgun needles (50)", category = "Ammunition", price = "1 gp", weight = 1
}

local sling_bullets = {
  name = "Sling bullets (20)", category = "Ammunition", price = "4 cp", weight = 1.5
}

-- Spellcasting Focus Items
local crystal = {
  name = "Crystal", category = "Spellcasting Focus", subcategory = "arcane", price = "10 gp", weight = 1
}

local orb = {
  name = "Orb", category = "Spellcasting Focus", subcategory = "arcane", price = "20 gp", weight = 3
}

local rod = {
  name = "Rod", category = "Spellcasting Focus", subcategory = "arcane", price = "10 gp", weight = 2
}

local staff = {
  name = "Staff", category = "Spellcasting Focus", subcategory = "arcane", price = "5 gp", weight = 4
}

local wand = {
  name = "Wand", category = "Spellcasting Focus", subcategory = "arcane", price = "10 gp", weight = 1
}

local sprig_of_mistletoe = {
  name = "Sprig of mistletoe", category = "Spellcasting Focus", subcategory = "druidic", price = "1 gp"
}

local totem = {
  name = "Totem", category = "Spellcasting Focus", subcategory = "druidic", price = "1 gp"
}

local wooden_staff = {
  name = "Wooden staff", category = "Spellcasting Focus", subcategory = "druidic", price = "5 gp", weight = 4
}

local yew_wand = {
  name = "Yew wand", category = "Spellcasting Focus", subcategory = "druidic", price = "10 gp", weight = 1
}

local amulet = {
  name = "Amulet", category = "Spellcasting Focus", subcategory = "holy", price = "5 gp", weight = 1
}

local emblem = {
  name = "Emblem", category = "Spellcasting Focus", subcategory = "holy", price = "5 gp"
}

local reliquary = {
  name = "Reliquary", category = "Spellcasting Focus", subcategory = "holy", price = "5 gp", weight = 2
}

-- More Adventuring Gear
local abacus = {
  name = "Abacus", category = "Adventuring Gear", price = "2 gp", weight = 2
}

local acid_vial = {
  name = "Acid (vial)", category = "Adventuring Gear", price = "25 gp", weight = 1
}

local alchemists_fire = {
  name = "Alchemist's fire (flask)", category = "Adventuring Gear", price = "50 gp", weight = 1
}

local antitoxin = {
  name = "Antitoxin (vial)", category = "Adventuring Gear", price = "50 gp"
}

local ball_bearings = {
  name = "Ball bearings (bag of 1,000)", category = "Adventuring Gear", price = "1 gp", weight = 2
}

local barrel = {
  name = "Barrel", category = "Adventuring Gear", price = "2 gp", weight = 70
}

local basket = {
  name = "Basket", category = "Adventuring Gear", price = "4 sp", weight = 2
}

local bell = {
  name = "Bell", category = "Adventuring Gear", price = "1 gp"
}

local blanket = {
  name = "Blanket", category = "Adventuring Gear", price = "5 sp", weight = 3
}

local block_and_tackle = {
  name = "Block and tackle", category = "Adventuring Gear", price = "1 gp", weight = 5
}

local book = {
  name = "Book", category = "Adventuring Gear", price = "25 gp", weight = 5
}

local bottle_glass = {
  name = "Bottle, glass", category = "Adventuring Gear", price = "2 gp", weight = 2
}

local bucket = {
  name = "Bucket", category = "Adventuring Gear", price = "5 cp", weight = 2
}

local caltrops = {
  name = "Caltrops (bag of 20)", category = "Adventuring Gear", price = "1 gp", weight = 2
}

local candle = {
  name = "Candle", category = "Adventuring Gear", price = "1 cp"
}

local case_crossbow_bolt = {
  name = "Case, crossbow bolt", category = "Adventuring Gear", price = "1 gp", weight = 1
}

local case_map_or_scroll = {
  name = "Case, map or scroll", category = "Adventuring Gear", price = "1 gp", weight = 1
}

local chain_10_feet = {
  name = "Chain (10 feet)", category = "Adventuring Gear", price = "5 gp", weight = 10
}

local chalk = {
  name = "Chalk (1 piece)", category = "Adventuring Gear", price = "1 cp"
}

local chest = {
  name = "Chest", category = "Adventuring Gear", price = "5 gp", weight = 25
}

local climbers_kit = {
  name = "Climber's kit", category = "Adventuring Gear", price = "25 gp", weight = 12
}

local clothes_common = {
  name = "Clothes, common", category = "Adventuring Gear", price = "5 sp", weight = 3
}

local clothes_costume = {
  name = "Clothes, costume", category = "Adventuring Gear", price = "5 gp", weight = 4
}

local clothes_fine = {
  name = "Clothes, fine", category = "Adventuring Gear", price = "15 gp", weight = 6
}

local clothes_travelers = {
  name = "Clothes, traveler's", category = "Adventuring Gear", price = "2 gp", weight = 4
}

local component_pouch = {
  name = "Component pouch", category = "Adventuring Gear", price = "25 gp", weight = 2
}

local crowbar = {
  name = "Crowbar", category = "Adventuring Gear", price = "2 gp", weight = 5
}

local fishing_tackle = {
  name = "Fishing tackle", category = "Adventuring Gear", price = "1 gp", weight = 4
}

local flask_or_tankard = {
  name = "Flask or tankard", category = "Adventuring Gear", price = "2 cp", weight = 1
}

local grappling_hook = {
  name = "Grappling hook", category = "Adventuring Gear", price = "2 gp", weight = 4
}

local hammer = {
  name = "Hammer", category = "Adventuring Gear", price = "1 gp", weight = 3
}

local hammer_sledge = {
  name = "Hammer, sledge", category = "Adventuring Gear", price = "2 gp", weight = 10
}

local healers_kit = {
  name = "Healer's kit", category = "Adventuring Gear", price = "5 gp", weight = 3
}

local holy_water = {
  name = "Holy water (flask)", category = "Adventuring Gear", price = "25 gp", weight = 1
}

local hourglass = {
  name = "Hourglass", category = "Adventuring Gear", price = "25 gp", weight = 1
}

local hunting_trap = {
  name = "Hunting trap", category = "Adventuring Gear", price = "5 gp", weight = 25
}

local ink = {
  name = "Ink (1 ounce bottle)", category = "Adventuring Gear", price = "10 gp"
}

local ink_pen = {
  name = "Ink pen", category = "Adventuring Gear", price = "2 cp"
}

local jug_or_pitcher = {
  name = "Jug or pitcher", category = "Adventuring Gear", price = "2 cp", weight = 4
}

local ladder_10_foot = {
  name = "Ladder (10 foot)", category = "Adventuring Gear", price = "1 sp", weight = 25
}

local lamp = {
  name = "Lamp", category = "Adventuring Gear", price = "5 sp", weight = 1
}

local lantern_bullseye = {
  name = "Lantern, bullseye", category = "Adventuring Gear", price = "10 gp", weight = 2
}

local lantern_hooded = {
  name = "Lantern, hooded", category = "Adventuring Gear", price = "5 gp", weight = 2
}

local lock = {
  name = "Lock", category = "Adventuring Gear", price = "10 gp", weight = 1
}

local magnifying_glass = {
  name = "Magnifying glass", category = "Adventuring Gear", price = "100 gp"
}

local manacles = {
  name = "Manacles", category = "Adventuring Gear", price = "2 gp", weight = 6
}

local mess_kit = {
  name = "Mess kit", category = "Adventuring Gear", price = "2 sp", weight = 1
}

local mirror_steel = {
  name = "Mirror, steel", category = "Adventuring Gear", price = "5 gp", weight = 0.5
}

local oil_flask = {
  name = "Oil (flask)", category = "Adventuring Gear", price = "1 sp", weight = 1
}

local paper = {
  name = "Paper (one sheet)", category = "Adventuring Gear", price = "2 sp"
}

local parchment = {
  name = "Parchment (one sheet)", category = "Adventuring Gear", price = "1 sp"
}

local perfume = {
  name = "Perfume (vial)", category = "Adventuring Gear", price = "5 gp"
}

local pick_miners = {
  name = "Pick, miner's", category = "Adventuring Gear", price = "2 gp", weight = 10
}

local piton = {
  name = "Piton", category = "Adventuring Gear", price = "5 cp", weight = 0.25
}

local poison_basic = {
  name = "Poison, basic (vial)", category = "Adventuring Gear", price = "100 gp"
}

local pole_10_foot = {
  name = "Pole (10-foot)", category = "Adventuring Gear", price = "5 cp", weight = 7
}

local pot_iron = {
  name = "Pot, iron", category = "Adventuring Gear", price = "2 gp", weight = 10
}

local potion_of_healing = {
  name = "Potion of healing", category = "Adventuring Gear", price = "50 gp", weight = 0.5
}

local pouch = {
  name = "Pouch", category = "Adventuring Gear", price = "5 sp", weight = 1
}

local quiver = {
  name = "Quiver", category = "Adventuring Gear", price = "1 gp", weight = 1
}

local ram_portable = {
  name = "Ram, portable", category = "Adventuring Gear", price = "4 gp", weight = 35
}

local rations = {
  name = "Rations (1 day)", category = "Adventuring Gear", price = "5 sp", weight = 2
}

local robes = {
  name = "Robes", category = "Adventuring Gear", price = "1 gp", weight = 4
}

local rope_silk = {
  name = "Rope, silk (50 feet)", category = "Adventuring Gear", price = "10 gp", weight = 5
}

local sack = {
  name = "Sack", category = "Adventuring Gear", price = "1 cp", weight = 0.5
}

local scale_merchants = {
  name = "Scale, merchant's", category = "Adventuring Gear", price = "5 gp", weight = 3
}

local sealing_wax = {
  name = "Sealing wax", category = "Adventuring Gear", price = "5 sp"
}

local shovel = {
  name = "Shovel", category = "Adventuring Gear", price = "2 gp", weight = 5
}

local signal_whistle = {
  name = "Signal whistle", category = "Adventuring Gear", price = "5 cp"
}

local signet_ring = {
  name = "Signet ring", category = "Adventuring Gear", price = "5 gp"
}

local soap = {
  name = "Soap", category = "Adventuring Gear", price = "2 cp"
}

local spellbook = {
  name = "Spellbook", category = "Adventuring Gear", price = "50 gp", weight = 3
}

local spikes_iron = {
  name = "Spikes, iron (10)", category = "Adventuring Gear", price = "1 gp", weight = 5
}

local spyglass = {
  name = "Spyglass", category = "Adventuring Gear", price = "1,000 gp", weight = 1
}

local tent_two_person = {
  name = "Tent, two-person", category = "Adventuring Gear", price = "2 gp", weight = 20
}

local tinderbox = {
  name = "Tinderbox", category = "Adventuring Gear", price = "5 sp", weight = 1
}

local torch = {
  name = "Torch", category = "Adventuring Gear", price = "1 cp", weight = 1
}

local vial = {
  name = "Vial", category = "Adventuring Gear", price = "1 gp"
}

local waterskin = {
  name = "Waterskin", category = "Adventuring Gear", price = "2 sp", weight = 5
}

local whetstone = {
  name = "Whetstone", category = "Adventuring Gear", price = "1 cp", weight = 1
}

-- More Artisan Tools
local brewers_supplies = {
  name = "Brewer's supplies", category = "Tools", subcategory = "artisan", price = "20 gp", weight = 9
}

local calligraphers_supplies = {
  name = "Calligrapher's supplies", category = "Tools", subcategory = "artisan", price = "10 gp", weight = 5
}

local carpenters_tools = {
  name = "Carpenter's tools", category = "Tools", subcategory = "artisan", price = "8 gp", weight = 6
}

local cartographers_tools = {
  name = "Cartographer's tools", category = "Tools", subcategory = "artisan", price = "15 gp", weight = 6
}

local cobblers_tools = {
  name = "Cobbler's tools", category = "Tools", subcategory = "artisan", price = "5 gp", weight = 5
}

local cooks_utensils = {
  name = "Cook's utensils", category = "Tools", subcategory = "artisan", price = "1 gp", weight = 8
}

local glassblowers_tools = {
  name = "Glassblower's tools", category = "Tools", subcategory = "artisan", price = "30 gp", weight = 5
}

local jewelers_tools = {
  name = "Jeweler's tools", category = "Tools", subcategory = "artisan", price = "25 gp", weight = 2
}

local leatherworkers_tools = {
  name = "Leatherworker's tools", category = "Tools", subcategory = "artisan", price = "5 gp", weight = 5
}

local masons_tools = {
  name = "Mason's tools", category = "Tools", subcategory = "artisan", price = "10 gp", weight = 8
}

local painters_supplies = {
  name = "Painter's supplies", category = "Tools", subcategory = "artisan", price = "10 gp", weight = 5
}

local potters_tools = {
  name = "Potter's tools", category = "Tools", subcategory = "artisan", price = "10 gp", weight = 3
}

local tinkers_tools = {
  name = "Tinker's tools", category = "Tools", subcategory = "artisan", price = "50 gp", weight = 10
}

local weavers_tools = {
  name = "Weaver's tools", category = "Tools", subcategory = "artisan", price = "1 gp", weight = 5
}

local woodcarvers_tools = {
  name = "Woodcarver's tools", category = "Tools", subcategory = "artisan", price = "1 gp", weight = 5
}

-- Professional Tools
local forgery_kit = {
  name = "Forgery kit", category = "Tools", subcategory = "professional", price = "15 gp", weight = 5
}

local herbalism_kit = {
  name = "Herbalism kit", category = "Tools", subcategory = "kit", price = "5 gp", weight = 3
}

local navigators_tools = {
  name = "Navigator's tools", category = "Tools", subcategory = "professional", price = "25 gp", weight = 2
}

local poisoners_kit = {
  name = "Poisoner's kit", category = "Tools", subcategory = "kit", price = "50 gp", weight = 2
}

-- Gaming Sets
local dice_set = {
  name = "Dice set", category = "Tools", subcategory = "gaming", price = "1 sp"
}

local dragonchess_set = {
  name = "Dragonchess set", category = "Tools", subcategory = "gaming", price = "1 gp", weight = 0.5
}

local playing_card_set = {
  name = "Playing card set", category = "Tools", subcategory = "gaming", price = "5 sp"
}

local three_dragon_ante_set = {
  name = "Three-Dragon Ante set", category = "Tools", subcategory = "gaming", price = "1 gp"
}

-- Musical Instruments  
local bagpipes = {
  name = "Bagpipes", category = "Tools", subcategory = "musical", price = "30 gp", weight = 6
}

local drum = {
  name = "Drum", category = "Tools", subcategory = "musical", price = "6 gp", weight = 3
}

local dulcimer = {
  name = "Dulcimer", category = "Tools", subcategory = "musical", price = "25 gp", weight = 10
}

local flute = {
  name = "Flute", category = "Tools", subcategory = "musical", price = "2 gp", weight = 1
}

local lyre = {
  name = "Lyre", category = "Tools", subcategory = "musical", price = "30 gp", weight = 2
}

local horn = {
  name = "Horn", category = "Tools", subcategory = "musical", price = "3 gp", weight = 2
}

local pan_flute = {
  name = "Pan flute", category = "Tools", subcategory = "musical", price = "12 gp", weight = 2
}

local shawm = {
  name = "Shawm", category = "Tools", subcategory = "musical", price = "2 gp", weight = 1
}

local viol = {
  name = "Viol", category = "Tools", subcategory = "musical", price = "30 gp", weight = 1
}

local lute = {
  name = "Lute", category = "Tools", subcategory = "musical", price = "35 gp", weight = 2
}

local disguise_kit = {
  name = "Disguise kit", category = "Tools", subcategory = "kit", price = "25 gp", weight = 3
}

-- Organizational Tables
M.weapons = {
  -- By weight category (light ≤3 lb, normal 4-8 lb, heavy ≥9 lb)
  light = {dagger, dart, club, handaxe, javelin, light_hammer, sickle, shortbow, shortsword, rapier, scimitar, 
           flail, war_pick, warhammer, whip, blowgun, crossbow_hand, longbow},
  normal = {spear, quarterstaff, mace, crossbow_light, battleaxe, longsword, morningstar, trident, net,
            glaive, halberd, lance, greatsword},
  heavy = {greatclub, greataxe, maul, pike, crossbow_heavy},
  
  -- By complexity
  simple = {club, dagger, greatclub, handaxe, javelin, light_hammer, mace, quarterstaff, sickle, spear, 
            crossbow_light, dart, shortbow, sling},
  martial = {battleaxe, longsword, scimitar, shortsword, rapier, greatsword, greataxe, maul, pike, flail, 
             glaive, halberd, lance, morningstar, trident, war_pick, warhammer, whip, blowgun, crossbow_hand, 
             crossbow_heavy, longbow, net},
  
  -- By use
  melee = {club, dagger, greatclub, handaxe, javelin, light_hammer, mace, quarterstaff, sickle, spear, 
           battleaxe, longsword, scimitar, shortsword, rapier, greatsword, greataxe, maul, pike, flail, 
           glaive, halberd, lance, morningstar, trident, war_pick, warhammer, whip},
  ranged = {crossbow_light, dart, shortbow, sling, blowgun, crossbow_hand, crossbow_heavy, longbow, net}
}

M.armor = {
  light = {padded, leather, studded_leather},
  medium = {hide, chain_shirt, scale_mail, breastplate, half_plate},
  heavy = {ring_mail, chain_mail, splint, plate},
  shields = {shield}
}

M.shields = {shield}

M.ammunition = {arrows, crossbow_bolts, blowgun_needles, sling_bullets}

M.spellcasting_focus = {
  arcane = {crystal, orb, rod, staff, wand},
  druidic = {sprig_of_mistletoe, totem, wooden_staff, yew_wand},
  holy = {amulet, emblem, reliquary}
}

M.adventuring_gear = {
  abacus, acid_vial, alchemists_fire, antitoxin, backpack, ball_bearings, barrel, basket, bedroll, bell,
  blanket, block_and_tackle, book, bottle_glass, bucket, caltrops, candle, case_crossbow_bolt,
  case_map_or_scroll, chain_10_feet, chalk, chest, climbers_kit, clothes_common, clothes_costume,
  clothes_fine, clothes_travelers, component_pouch, crowbar, fishing_tackle, flask_or_tankard,
  grappling_hook, hammer, hammer_sledge, healers_kit, holy_water, hourglass, hunting_trap, ink,
  ink_pen, jug_or_pitcher, ladder_10_foot, lamp, lantern_bullseye, lantern_hooded, lock,
  magnifying_glass, manacles, mess_kit, mirror_steel, oil_flask, paper, parchment, perfume,
  pick_miners, piton, poison_basic, pole_10_foot, pot_iron, potion_of_healing, pouch, quiver,
  ram_portable, rations, robes, rope_hempen, rope_silk, sack, scale_merchants, sealing_wax,
  shovel, signal_whistle, signet_ring, soap, spellbook, spikes_iron, spyglass, tent_two_person,
  tinderbox, torch, vial, waterskin, whetstone
}

M.tools = {
  artisan = {alchemists_supplies, brewers_supplies, calligraphers_supplies, carpenters_tools, 
            cartographers_tools, cobblers_tools, cooks_utensils, glassblowers_tools, jewelers_tools, 
            leatherworkers_tools, masons_tools, painters_supplies, potters_tools, smiths_tools, 
            tinkers_tools, weavers_tools, woodcarvers_tools},
  professional = {thieves_tools, forgery_kit, navigators_tools},
  kit = {disguise_kit, herbalism_kit, poisoners_kit},
  musical = {bagpipes, drum, dulcimer, flute, horn, lute, lyre, pan_flute, shawm, viol},
  gaming = {dice_set, dragonchess_set, playing_card_set, three_dragon_ante_set}
}

-- Sample trinkets list (subset from the full 100)
M.trinkets = {
  "A mummified goblin hand",
  "A piece of crystal that faintly glows in the moonlight", 
  "A gold coin minted in an unknown land",
  "A diary written in a language you don't know",
  "A brass ring that never tarnishes"
}

__doc.weapons = [[Nested table organizing all weapons with multiple lookup categories:
- light/normal/heavy: by weight (≤3 lb / 4-8 lb / ≥9 lb)  
- simple/martial: by complexity requirement
- melee/ranged: by usage type
Same weapon may appear in multiple categories (e.g., dagger in light, simple, and melee)]]

__doc.armor = [[Nested table organizing armor by weight categories:
- light: padded, leather, studded leather
- medium: hide, chain shirt, scale mail, breastplate, half plate  
- heavy: ring mail, chain mail, splint, plate
- shields: shield (also available as M.shields)]]

__doc.shields = "List of all shields (redundant with M.armor.shields)"

__doc.ammunition = "List of ammunition items including arrows, crossbow bolts, blowgun needles, and sling bullets"

__doc.spellcasting_focus = [[Nested table organizing spellcasting focus items by type:
- arcane: crystal, orb, rod, staff, wand
- druidic: sprig of mistletoe, totem, wooden staff, yew wand  
- holy: amulet, emblem, reliquary]]

__doc.adventuring_gear = [[Comprehensive list of adventuring equipment including containers, tools, supplies, and utilities.
Items range from basic gear (rope, torch, backpack) to specialized equipment (spyglass, alchemist's fire)]]

__doc.tools = [[Nested table organizing tools by subcategory:
- artisan: crafting tools (alchemist's supplies, smith's tools, etc.)
- professional: specialized tools (thieves' tools, navigator's tools, forgery kit)
- kit: general purpose kits (disguise kit, herbalism kit, poisoner's kit)
- musical: instruments (lute, drum, flute, bagpipes, etc.)
- gaming: gaming sets (dice, dragonchess, playing cards, etc.)]]

__doc.trinkets = "List of mysterious trinket descriptions (sample from full set of 100 in equipment.md)"

-- Note: Services and Trade Goods tables from equipment.md were omitted as requested

return thismodule()