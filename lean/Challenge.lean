import Mathlib

theorem prime_ending (p : ℕ) (hp : p.Prime) (h5 : 5 < p) :
    p % 10 = 1 ∨ p % 10 = 3 ∨ p % 10 = 7 ∨ p % 10 = 9 := sorry

theorem removed_not_prime (n : ℕ) (h5 : 5 < n)
    (hd : n % 10 = 0 ∨ n % 10 = 2 ∨ n % 10 = 4 ∨ n % 10 = 5 ∨ n % 10 = 6 ∨ n % 10 = 8) :
    ¬ n.Prime := sorry

theorem smallest_factor_le_sqrt (n : ℕ) (hn : 0 < n) (hc : ¬ n.Prime) :
    n.minFac ^ 2 ≤ n := sorry

theorem candidate_prime_above (n : ℕ) :
    ∃ p, p.Prime ∧ n < p ∧ (p % 10 = 1 ∨ p % 10 = 3 ∨ p % 10 = 7 ∨ p % 10 = 9) := sorry

theorem density_factor : (1 : ℚ) / (4 / 10) = 5 / 2 := sorry

theorem prime_97 : Nat.Prime 97 := sorry

theorem not_prime_91 : ¬ Nat.Prime 91 := sorry
