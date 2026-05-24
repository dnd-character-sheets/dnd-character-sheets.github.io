---
title: LaTeX Macros Used in Character-Sheet YAML
---

# LaTeX macros found in character-sheet YAML

This file lists every LaTeX macro that appears in `yaml/*.yaml` and
`~/etc/dnd/my-adventures/*.yaml`, plus close siblings from
`templates/charsheet.sty`.

## Size-changing macros

`\scriptsize`, `\footnotesize`, `\small`, `\normalsize` — standard
LaTeX font-size declarations.  Each switches the current text to the
named relative size and stays in effect until the end of the
enclosing group.  Listed in increasing order of size:
`\scriptsize` < `\footnotesize` < `\small` < `\normalsize`.

## Other standard LaTeX macros

- `\color` — set the current text color (from `xcolor`).
- `\emph` — emphasize text (italic by default).
- `\ensuremath` — render the argument in math mode regardless of the surrounding mode.
- `\frac` — typeset a fraction with numerator and denominator (`amsmath`).
- `\ge` — math symbol `>=`.
- `\hskip` — insert a horizontal skip of the given length (TeX primitive).
- `\lceil` — math symbol `[` (left ceiling).
- `\le` — math symbol `<=`.
- `\par` — end the current paragraph.
- `\quad` — insert one em of horizontal space.
- `\rceil` — math symbol `]` (right ceiling).
- `\rlap` — typeset its argument with zero width, overlapping to the right.
- `\smallskip` — insert a small vertical skip.
- `\text` — typeset its argument in text mode inside a math expression (`amsmath`).
- `\textbf` — set its argument in boldface.
- `\textminus` — text-mode minus sign (`textcomp`).
- `\textsc` — set its argument in small caps.
- `\times` — math symbol `x` (multiplication).

## Calculation macros (defined in `templates/charsheet.sty`)

Macros that compute or look up D&D combat and casting numbers.

- `\psam` — total signed spell-attack bonus printed as `+N`, computed from proficiency bonus plus `SPELLCASTING ABILITY MODIFIER`.
- `\satk` — value of `SPELL ATTACK MODIFIER` preceded by a non-breaking space; empty if undefined.
- `\spellattack` — value of `SPELL ATTACK MODIFIER` with no leading space (sibling of `\satk`).
- `\spelldc` — render `DC ~<n>` from the `SPELL DC` field.
- `\statdc` — render `DC ~<n>` computed as `8 + proficiency bonus + stat modifier` for the named ability.

## Other custom macros (defined in `templates/charsheet.sty`)

Each macro below is either used directly in a YAML file or is a close
sibling of one that is.

- `\ditto` — typewriter-style ditto mark (`"`); used in tabular cells such as the `RANGE` column of an attack.
- `\fourslots` — four spell-slot circles drawn tightly together (sibling of `\slots`).
- `\profskip` — vertical separator between groups of proficiencies; expands to `\medskip`.
- `\slots` — render `N` connected circles representing spell slots (or hit dice) for argument `N`.
- `\slotsliteral` — like `\slots` but takes an optional first argument that sets the spacing between circles (sibling of `\slots`).
- `\stackslots` — like `\slots`, but stacks rows of 3 or 4 circles when too many fit in a single row (sibling of `\slots`).
- `\weaponname` — wrapper around a weapon name; a no-op by default, but styles may redefine it.
