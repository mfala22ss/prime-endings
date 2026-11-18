# Verification record: the site's challenge, the results, and the printed axioms

Everything needed to check the Lean work in one place.

## 1. The challenge (the site's own, not ours)

Comparator Live, https://comparator.live.lean-lang.org, built-in challenge **"There Are Infinitely Many Primes"**, run on "Latest Mathlib with Lean v4.36.0". The statement, as shown on the site ([copy](InfinitelyManyPrimes_challenge.lean)):

```lean
def IsPrime (n : Nat) := 1 < n ∧ ∀ k, 1 < k → k < n → ¬ k ∣ n

theorem InfinitudeOfPrimes : ∀ n, ∃ p > n, IsPrime p := by
  sorry
```

Because the statement is the site's, not ours, nobody has to trust that we wrote the challenge correctly.

## 2. The results

| Run | Date | Solution file checked | Theorems in file | Result |
|---|---|---|---:|---|
| 8 | 18 Nov 2026 | [`run8_SolutionProofsOnly_24_theorems.lean`](../runs/run8_SolutionProofsOnly_24_theorems.lean) | 24 | **Success** ([screenshot](../../docs/img/comparator-run8-24-theorems.png)) |
| 9 | 18 Nov 2026 | [`run9_SolutionProofsOnly_27_theorems.lean`](../runs/run9_SolutionProofsOnly_27_theorems.lean) | 27 | **Success** ([screenshot](../../docs/img/comparator-run9-27-theorems.png)) |
| 10 | 18 Nov 2026 | [`run10_SolutionProofsOnly_30_theorems.lean`](../runs/run10_SolutionProofsOnly_30_theorems.lean) | 30 | **Success** (screenshot not saved as a file) |
| next | pending | [`SolutionProofsOnly.lean`](../SolutionProofsOnly.lean) | 38 | not yet run |

Earlier runs (1 to 7, 15 to 17 November 2026) are in the [WALKTHROUGH run log](../../WALKTHROUGH.md#run-log).

Comparator's message on success: *"Comparator verified that the solution proves the claims described in the challenge's theorem (`InfinitudeOfPrimes`), and the challenge is recognized."*

**What a success proves.** It certifies `InfinitudeOfPrimes` by name, against the site's statement, using only Lean's standard axioms. It also shows that the whole solution file compiled with no errors. It does **not** by itself rule out a `sorry` or an extra `axiom` in the other theorems, because those compile with only a warning. That is what section 3 checks.

## 3. The printed axioms, for every theorem

Produced by [`../check_axioms.sh`](../check_axioms.sh), which checks the file for `sorry` and `axiom` declarations and runs Lean's `#print axioms` on every theorem ([saved output](../../results/lean_axioms.txt)). The only axioms allowed are Lean's standard three: `propext`, `Quot.sound`, `Classical.choice`. A `sorryAx` would mean an unfinished proof; `Lean.ofReduceBool` would mean the `native_decide` shortcut. Neither appears.

```
Output of lean/check_axioms.sh, 18 November 2026 (Lean 4.34, Mathlib 818f61d)

sorry occurrences: 0
axiom declarations: 0
'prime_ending' depends on axioms: [propext, Quot.sound]
'prime_mod30' depends on axioms: [propext, Quot.sound]
'removed_not_prime' depends on axioms: [propext, Quot.sound]
'smallest_factor_le_sqrt' depends on axioms: [propext, Classical.choice, Quot.sound]
'candidate_prime_above' depends on axioms: [propext, Classical.choice, Quot.sound]
'infinitely_many_ending' depends on axioms: [propext, Classical.choice, Quot.sound]
'survives_iff' depends on axioms: [propext, Classical.choice, Quot.sound]
'mem_primesSpec' depends on axioms: [propext, Classical.choice, Quot.sound]
'survivor_count' depends on axioms: [propext, Classical.choice, Quot.sound]
'survivesBelow_iff' depends on axioms: [propext, Classical.choice, Quot.sound]
'filter_survivesBelow' depends on axioms: [propext, Classical.choice, Quot.sound]
'prime_count_100' depends on axioms: [propext, Classical.choice, Quot.sound]
'prime_count_1000' depends on axioms: [propext, Classical.choice, Quot.sound]
'prime_count_10000' depends on axioms: [propext, Classical.choice, Quot.sound]
'sqrt_rule' depends on axioms: [propext, Classical.choice, Quot.sound]
'square_not_prime' depends on axioms: [propext, Classical.choice, Quot.sound]
'square_needs_p' depends on axioms: [propext, Classical.choice, Quot.sound]
'three_seven_enough' depends on axioms: [propext, Classical.choice, Quot.sound]
'three_seven_fails_at_121' depends on axioms: [propext]
'left37_100' does not depend on any axioms
'left37_120' does not depend on any axioms
'left37_121' does not depend on any axioms
'mul_coprime_ten' depends on axioms: [propext, Quot.sound]
'multiplier_range' depends on axioms: [propext, Classical.choice, Quot.sound]
'window_sieve' depends on axioms: [propext, Classical.choice, Quot.sound]
'known_primes_reach' depends on axioms: [propext, Classical.choice, Quot.sound]
'bootstrap' depends on axioms: [propext, Classical.choice, Quot.sound]
'known_primes_not_enough' depends on axioms: [propext, Classical.choice, Quot.sound]
'InfinitudeOfPrimes' depends on axioms: [propext, Classical.choice, Quot.sound]
'density_factor' depends on axioms: [propext, Classical.choice, Quot.sound]
'prime_97' depends on axioms: [propext, Classical.choice, Quot.sound]
'not_prime_91' depends on axioms: [propext]
'candidateCount_100' does not depend on any axioms
'candidateCount_1e10' depends on axioms: [propext]
'candidateCount_1000' does not depend on any axioms
'candidateCount_10000' does not depend on any axioms
'record_digits' depends on axioms: [propext]
'first_exponent_100M' depends on axioms: [propext]
```

To reproduce: install Lean and Mathlib, then run `lean/check_axioms.sh` (set `MATHLIB` to your Mathlib folder).
