-- Comparator Live built-in challenge "There Are Infinitely Many Primes"
-- (https://comparator.live.lean-lang.org, "Latest Mathlib with Lean v4.36.0").
-- Statement copied as shown on the site on 18 November 2026; the site's own file is authoritative.

def IsPrime (n : Nat) := 1 < n ∧ ∀ k, 1 < k → k < n → ¬ k ∣ n

theorem InfinitudeOfPrimes : ∀ n, ∃ p > n, IsPrime p := by
  sorry
