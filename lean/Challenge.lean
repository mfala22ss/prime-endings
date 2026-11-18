import Mathlib

theorem prime_ending (p : ℕ) (hp : p.Prime) (h5 : 5 < p) :
    p % 10 = 1 ∨ p % 10 = 3 ∨ p % 10 = 7 ∨ p % 10 = 9 := sorry

theorem prime_mod30 (p : ℕ) (hp : p.Prime) (h5 : 5 < p) :
    p % 30 = 1 ∨ p % 30 = 7 ∨ p % 30 = 11 ∨ p % 30 = 13 ∨
      p % 30 = 17 ∨ p % 30 = 19 ∨ p % 30 = 23 ∨ p % 30 = 29 := sorry

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

theorem infinitely_many_ending (d : ℕ) (hd : d = 1 ∨ d = 3 ∨ d = 7 ∨ d = 9) (n : ℕ) :
    ∃ p > n, p.Prime ∧ p % 10 = d := sorry

def Survives (n : ℕ) : Prop :=
  5 < n ∧ (n % 10 = 1 ∨ n % 10 = 3 ∨ n % 10 = 7 ∨ n % 10 = 9) ∧
    ∀ p < n + 1, p * p ≤ n → p ∣ n → ¬ p.Prime

instance (n : ℕ) : Decidable (Survives n) := by unfold Survives; infer_instance

theorem survives_iff (n : ℕ) : Survives n ↔ n.Prime ∧ 5 < n := sorry

def primesSpec (x : ℕ) : List ℕ :=
  (List.range (x + 1)).filter fun n => decide (n = 2 ∨ n = 3 ∨ n = 5 ∨ Survives n)

theorem mem_primesSpec {x n : ℕ} : n ∈ primesSpec x ↔ n.Prime ∧ n ≤ x := sorry

theorem survivor_count (x : ℕ) (hx : 5 ≤ x) :
    ((Finset.range (x + 1)).filter Survives).card + 3 = Nat.primeCounting x := sorry

theorem prime_count_100 : Nat.primeCounting 100 = 25 := sorry

theorem prime_count_1000 : Nat.primeCounting 1000 = 168 := sorry

theorem prime_count_10000 : Nat.primeCounting 10000 = 1229 := sorry

theorem sqrt_rule (x n : ℕ) (hn : 1 < n) (hx : n ≤ x)
    (h : ∀ p, p.Prime → p * p ≤ x → ¬ p ∣ n) : n.Prime := sorry

theorem square_not_prime (p : ℕ) (hp : p.Prime) : ¬ (p * p).Prime := sorry

theorem square_needs_p (p q : ℕ) (hp : p.Prime) (hq : q.Prime) (h : q ∣ p * p) : q = p := sorry

theorem three_seven_enough (n : ℕ) (h5 : 5 < n) (hn : n ≤ 120)
    (hend : n % 10 = 1 ∨ n % 10 = 3 ∨ n % 10 = 7 ∨ n % 10 = 9)
    (h3 : ¬ 3 ∣ n) (h7 : ¬ 7 ∣ n ∨ n = 7) : n.Prime := sorry

theorem three_seven_fails_at_121 :
    121 % 10 = 1 ∧ ¬ 3 ∣ 121 ∧ ¬ 7 ∣ 121 ∧ ¬ Nat.Prime 121 := sorry

theorem mul_coprime_ten {p k : ℕ} (hp : Nat.Coprime p 10) :
    Nat.Coprime (p * k) 10 ↔ Nat.Coprime k 10 := sorry

theorem multiplier_range {a b p k : ℕ} (hp : 0 < p) :
    (max p ((a + p - 1) / p) ≤ k ∧ k ≤ b / p) ↔ (p ≤ k ∧ a ≤ p * k ∧ p * k ≤ b) := sorry

def CrossedOut (a b n : ℕ) : Prop :=
  ∃ p k, p.Prime ∧ 3 ≤ p ∧ p ≠ 5 ∧ p * p ≤ b ∧ Nat.Coprime k 10 ∧
    max p ((a + p - 1) / p) ≤ k ∧ k ≤ b / p ∧ p * k = n

theorem window_sieve (a b n : ℕ) :
    (a ≤ n ∧ n ≤ b ∧ 5 < n ∧ Nat.Coprime n 10 ∧ ¬ CrossedOut a b n) ↔
      (n.Prime ∧ max a 6 ≤ n ∧ n ≤ b) := sorry

theorem known_primes_reach (Y n : ℕ) (hn : 1 < n) (hY : n < (Y + 1) * (Y + 1))
    (h : ∀ p, p.Prime → p ≤ Y → ¬ p ∣ n) : n.Prime := sorry

theorem known_primes_not_enough (Y : ℕ) :
    ∃ n, 1 < n ∧ ¬ n.Prime ∧ ∀ p, p.Prime → p ≤ Y → ¬ p ∣ n := sorry

theorem bootstrap (Y n : ℕ) (hn : n ≤ Y * Y) :
    n.Prime ↔ (1 < n ∧ ∀ p, p.Prime → p ≤ Y → p ∣ n → p = n) := sorry
