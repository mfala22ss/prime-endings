#!/bin/sh
# Check every theorem in lean/SolutionProofsOnly.lean, not only the one Comparator names.
# 1. The file contains no `sorry` and declares no new `axiom`.
# 2. `#print axioms` for each theorem: only propext, Quot.sound, Classical.choice may appear
#    (no sorryAx, no Lean.ofReduceBool from native_decide).
# Needs a Mathlib checkout; set MATHLIB to its path (default ~/mathlib4).
set -e
cd "$(dirname "$0")"
MATHLIB=${MATHLIB:-$HOME/mathlib4}
F=SolutionProofsOnly.lean
echo "sorry occurrences: $(grep -cw sorry $F || true)"
echo "axiom declarations: $(grep -cE '^[[:space:]]*axiom ' $F || true)"
T=$(mktemp -d)/AxiomCheck.lean
cp $F "$T"
grep -oE '^theorem [A-Za-z_0-9]+' $F | awk '{print "#print axioms "$2}' >> "$T"
(cd "$MATHLIB" && lake env lean "$T") 2>&1 | grep -E "depends on|does not depend"
