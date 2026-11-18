import Mathlib

/-!
# Primes in the residue classes 1, 3, 7, 9 (mod 10)

Main results:
* `prime_ending`: every prime `p > 5` satisfies `p % 10 ∈ {1, 3, 7, 9}`.
* `prime_mod30`: every prime `p > 5` is coprime to 30 (the mod-30 wheel loses no prime).
* `removed_not_prime`: no `n > 5` with `n % 10 ∈ {0, 2, 4, 5, 6, 8}` is prime.
* `smallest_factor_le_sqrt`: a composite `n` has `minFac n ^ 2 ≤ n`, so sieving by primes up to
  `√x` suffices.
* `survives_iff`, `mem_primesSpec`: the sieve rule on the 40% keeps exactly the primes above 5,
  and the reference sieve `primesSpec x` lists exactly the primes up to `x`.
* `survivor_count`: for every `x ≥ 5`, the survivors of the sieve on the 40% plus 2, 3, 5 number
  exactly `π(x)`; `prime_count_100`, `prime_count_1000`: Lean's kernel runs the method and obtains
  `π(100) = 25` and `π(1000) = 168`.
* `infinitely_many_ending`: infinitely many primes end in each of 1, 3, 7 and 9 (Dirichlet).
* `sqrt_rule`, `square_not_prime`, `square_needs_p`: sieving by the primes up to `√x` is enough,
  and each prime is needed from its square on.
* `three_seven_enough`, `three_seven_fails_at_121`: on the 40%, 3 and 7 alone leave exactly the
  primes up to 120, and first fail at 121 = 11 × 11.
* `mul_coprime_ten`, `multiplier_range`, `window_sieve`: the sieve on any window `[a, b]`,
  started at `max p ⌈a/p⌉` for each sieving prime, keeps exactly the primes in `[max a 6, b]`.
* `known_primes_reach`, `bootstrap`, `known_primes_not_enough`: the primes up to `Y` decide every
  number up to `Y²`, so the sieve finds each prime before it needs it; but no fixed, finite list
  of primes is enough forever.
* `prime_alive`, `next_pickup_prime`, `stop_rule`: the sieve as a pick-up loop. The smallest number
  still standing above the last prime picked up is always the next prime (only 5 is skipped), no
  prime is ever removed, and once `p * p > x` everything still standing up to `x` is prime.

Computation: `report a b g` lists the primes in `[a, b]` together with summary statistics.
Windows with `√b ≤ 2·10⁶` are sieved exactly. Larger windows are pre-sieved by all primes up to
`2·10⁶` and the survivors are tested with Miller-Rabin on the first 20 prime bases; this is
deterministic for `n < ψ₁₃ = 3,317,044,064,679,887,385,961,981` (Sorenson and Webster,
Math. Comp. 2017) and probabilistic above it.
-/

/-! ## Theorems -/

theorem prime_ending (p : ℕ) (hp : p.Prime) (h5 : 5 < p) :
    p % 10 = 1 ∨ p % 10 = 3 ∨ p % 10 = 7 ∨ p % 10 = 9 := by
  have h2 : ¬ 2 ∣ p := by
    intro hd
    rcases hp.eq_one_or_self_of_dvd 2 hd with h | h <;> omega
  have h5' : ¬ 5 ∣ p := by
    intro hd
    rcases hp.eq_one_or_self_of_dvd 5 hd with h | h <;> omega
  omega

/-- The mod-30 wheel loses no prime: every prime above 5 is coprime to 30. -/
theorem prime_mod30 (p : ℕ) (hp : p.Prime) (h5 : 5 < p) :
    p % 30 = 1 ∨ p % 30 = 7 ∨ p % 30 = 11 ∨ p % 30 = 13 ∨
      p % 30 = 17 ∨ p % 30 = 19 ∨ p % 30 = 23 ∨ p % 30 = 29 := by
  have h2 : ¬ 2 ∣ p := by
    intro hd
    rcases hp.eq_one_or_self_of_dvd 2 hd with h | h <;> omega
  have h3 : ¬ 3 ∣ p := by
    intro hd
    rcases hp.eq_one_or_self_of_dvd 3 hd with h | h <;> omega
  have h5' : ¬ 5 ∣ p := by
    intro hd
    rcases hp.eq_one_or_self_of_dvd 5 hd with h | h <;> omega
  -- `omega` alone cannot combine the three facts mod 30, so split on the remainder.
  have e2 : p % 30 % 2 = p % 2 := Nat.mod_mod_of_dvd p (by decide)
  have e3 : p % 30 % 3 = p % 3 := Nat.mod_mod_of_dvd p (by decide)
  have e5 : p % 30 % 5 = p % 5 := Nat.mod_mod_of_dvd p (by decide)
  have hlt : p % 30 < 30 := Nat.mod_lt p (by decide)
  generalize p % 30 = r at e2 e3 e5 hlt ⊢
  match r, hlt with
  | 0, _ | 1, _ | 2, _ | 3, _ | 4, _ | 5, _ | 6, _ | 7, _ | 8, _ | 9, _
  | 10, _ | 11, _ | 12, _ | 13, _ | 14, _ | 15, _ | 16, _ | 17, _ | 18, _ | 19, _
  | 20, _ | 21, _ | 22, _ | 23, _ | 24, _ | 25, _ | 26, _ | 27, _ | 28, _ | 29, _ => omega
  | _ + 30, _ => omega

theorem removed_not_prime (n : ℕ) (h5 : 5 < n)
    (hd : n % 10 = 0 ∨ n % 10 = 2 ∨ n % 10 = 4 ∨ n % 10 = 5 ∨ n % 10 = 6 ∨ n % 10 = 8) :
    ¬ n.Prime := by
  intro hp
  have := prime_ending n hp h5
  omega

theorem smallest_factor_le_sqrt (n : ℕ) (hn : 0 < n) (hc : ¬ n.Prime) :
    n.minFac ^ 2 ≤ n :=
  Nat.minFac_sq_le_self hn hc

/-- For every `n` there is a prime `p > n` ending in 1, 3, 7 or 9: the least prime factor of
    `10 · (n + 5)! + 1` exceeds `n + 5` and so, by `prime_ending`, lies in the candidate set. -/
theorem candidate_prime_above (n : ℕ) :
    ∃ p, p.Prime ∧ n < p ∧ (p % 10 = 1 ∨ p % 10 = 3 ∨ p % 10 = 7 ∨ p % 10 = 9) := by
  have hpos := Nat.factorial_pos (n + 5)
  have hN1 : 10 * (n + 5).factorial + 1 ≠ 1 := by omega
  have hp : (10 * (n + 5).factorial + 1).minFac.Prime := Nat.minFac_prime hN1
  have hdvd := Nat.minFac_dvd (10 * (n + 5).factorial + 1)
  have hgt : n + 5 < (10 * (n + 5).factorial + 1).minFac := by
    by_contra h
    have hle : (10 * (n + 5).factorial + 1).minFac ≤ n + 5 := by omega
    have h1 := Nat.dvd_factorial hp.pos hle
    have h2 : (10 * (n + 5).factorial + 1).minFac ∣ 10 * (n + 5).factorial :=
      Dvd.dvd.mul_left h1 10
    have h3 := (Nat.dvd_add_right h2).mp hdvd
    exact hp.one_lt.ne' (Nat.dvd_one.mp h3)
  exact ⟨_, hp, by omega, prime_ending _ hp (by omega)⟩

/-- Dirichlet's theorem for the four endings: for each `d ∈ {1, 3, 7, 9}` there are infinitely
    many primes ending in `d`. -/
theorem infinitely_many_ending (d : ℕ) (hd : d = 1 ∨ d = 3 ∨ d = 7 ∨ d = 9) (n : ℕ) :
    ∃ p > n, p.Prime ∧ p % 10 = d := by
  have hcop : d.Coprime 10 := by rcases hd with rfl | rfl | rfl | rfl <;> decide
  obtain ⟨p, hpn, hp, hmod⟩ := Nat.forall_exists_prime_gt_and_modEq n (q := 10) (by norm_num) hcop
  have hd10 : d % 10 = d := by rcases hd with rfl | rfl | rfl | rfl <;> rfl
  unfold Nat.ModEq at hmod
  exact ⟨p, hpn, hp, by omega⟩

/-! ## Sieve correctness -/

/-- The survival rule of the sieve on the 40%: `n` is a candidate and no prime `p` with
    `p * p ≤ n` divides it. Crossing out the odd multiples of each prime `p` from `p * p`
    removes exactly the candidates with such a divisor. -/
def Survives (n : ℕ) : Prop :=
  5 < n ∧ (n % 10 = 1 ∨ n % 10 = 3 ∨ n % 10 = 7 ∨ n % 10 = 9) ∧
    ∀ p < n + 1, p * p ≤ n → p ∣ n → ¬ p.Prime

instance (n : ℕ) : Decidable (Survives n) := by unfold Survives; infer_instance

/-- A number survives the sieve on the 40% exactly when it is a prime above 5. -/
theorem survives_iff (n : ℕ) : Survives n ↔ n.Prime ∧ 5 < n := by
  constructor
  · rintro ⟨h5, -, hno⟩
    refine ⟨?_, h5⟩
    by_contra hnp
    have hsq : n.minFac ^ 2 ≤ n := Nat.minFac_sq_le_self (by omega) hnp
    have hle : n.minFac ≤ n := Nat.minFac_le (by omega)
    exact hno n.minFac (by omega) (by nlinarith [hsq]) (Nat.minFac_dvd n)
      (Nat.minFac_prime (by omega))
  · rintro ⟨hp, h5⟩
    refine ⟨h5, prime_ending n hp h5, fun q _ hqq hdvd hq => ?_⟩
    rcases hp.eq_one_or_self_of_dvd q hdvd with h | h
    · have := hq.one_lt
      omega
    · rw [h] at hqq
      have := hp.one_lt
      nlinarith

/-- Reference sieve: the numbers up to `x` that survive, plus 2, 3 and 5. -/
def primesSpec (x : ℕ) : List ℕ :=
  (List.range (x + 1)).filter fun n => decide (n = 2 ∨ n = 3 ∨ n = 5 ∨ Survives n)

/-- Sieve correctness: the reference sieve returns exactly the primes up to `x`. -/
theorem mem_primesSpec {x n : ℕ} : n ∈ primesSpec x ↔ n.Prime ∧ n ≤ x := by
  simp only [primesSpec, List.mem_filter, List.mem_range, decide_eq_true_eq, survives_iff]
  constructor
  · rintro ⟨hx, h | h | h | ⟨hp, -⟩⟩
    · subst h; exact ⟨by norm_num, by omega⟩
    · subst h; exact ⟨by norm_num, by omega⟩
    · subst h; exact ⟨by norm_num, by omega⟩
    · exact ⟨hp, by omega⟩
  · rintro ⟨hp, hx⟩
    refine ⟨by omega, ?_⟩
    by_cases h5 : 5 < n
    · exact Or.inr (Or.inr (Or.inr ⟨hp, h5⟩))
    · have hn : n ≤ 5 := by omega
      interval_cases n
      · exact absurd hp Nat.not_prime_zero
      · exact absurd hp Nat.not_prime_one
      · exact Or.inl rfl
      · exact Or.inr (Or.inl rfl)
      · exact absurd hp (by norm_num)
      · exact Or.inr (Or.inr (Or.inl rfl))

/-! ## The method counts the primes exactly -/

/-- **The method gives exactly `π(x)`, for every `x ≥ 5`.** The numbers that survive the sieve on
    the 40% up to `x`, plus the three primes 2, 3 and 5 set aside, are exactly as many as the
    primes up to `x`. This proves for every `x` what the run to `10^10` checked at three points. -/
theorem survivor_count (x : ℕ) (hx : 5 ≤ x) :
    ((Finset.range (x + 1)).filter Survives).card + 3 = Nat.primeCounting x := by
  have hsplit : (Finset.range (x + 1)).filter Nat.Prime =
      (Finset.range (x + 1)).filter Survives ∪ {2, 3, 5} := by
    ext n
    simp only [Finset.mem_filter, Finset.mem_range, Finset.mem_union, Finset.mem_insert,
      Finset.mem_singleton, survives_iff]
    constructor
    · rintro ⟨hn, hp⟩
      by_cases h5 : 5 < n
      · exact Or.inl ⟨hn, hp, h5⟩
      · right
        interval_cases n <;> simp_all <;> norm_num at hp
    · rintro (⟨hn, hp, -⟩ | rfl | rfl | rfl)
      · exact ⟨hn, hp⟩
      all_goals exact ⟨by omega, by norm_num⟩
  have hdisj : Disjoint ((Finset.range (x + 1)).filter Survives) {2, 3, 5} := by
    rw [Finset.disjoint_left]
    intro n hn h
    simp only [Finset.mem_filter, survives_iff] at hn
    simp only [Finset.mem_insert, Finset.mem_singleton] at h
    omega
  rw [Nat.primeCounting, Nat.primeCounting', Nat.count_eq_card_filter_range, hsplit,
    Finset.card_union_of_disjoint hdisj]
  rfl

/-! ## Exact prime counts, computed by Lean's kernel through the method

`survivor_count` turns a count of survivors into a value of `π(x)`. Lean's kernel performs the
counts below itself, using `SurvivesBelow`, the same survival rule with divisors tested only below
a bound `B` (equivalent to `Survives` for `n < B * B`, by `survivesBelow_iff`). -/

/-- The survival rule with divisors tested only below `B`. -/
def SurvivesBelow (B n : ℕ) : Prop :=
  5 < n ∧ (n % 10 = 1 ∨ n % 10 = 3 ∨ n % 10 = 7 ∨ n % 10 = 9) ∧
    ∀ p < B, p * p ≤ n → p ∣ n → ¬ p.Prime

instance (B n : ℕ) : Decidable (SurvivesBelow B n) := by unfold SurvivesBelow; infer_instance

/-- For `n < B * B`, testing divisors below `B` is the same as testing all divisors. -/
theorem survivesBelow_iff {B n : ℕ} (hn : n < B * B) : SurvivesBelow B n ↔ Survives n := by
  unfold SurvivesBelow Survives
  constructor
  · rintro ⟨h5, hend, h⟩
    refine ⟨h5, hend, fun p _ hpp hdvd => h p ?_ hpp hdvd⟩
    by_contra hB
    have : B ≤ p := by omega
    nlinarith
  · rintro ⟨h5, hend, h⟩
    refine ⟨h5, hend, fun p _ hpp hdvd => h p ?_ hpp hdvd⟩
    by_contra hp
    have : n + 1 ≤ p := by omega
    nlinarith

theorem filter_survivesBelow {B x : ℕ} (hx : x < B * B) :
    (Finset.range (x + 1)).filter (SurvivesBelow B) = (Finset.range (x + 1)).filter Survives := by
  ext n
  simp only [Finset.mem_filter, Finset.mem_range]
  constructor
  · rintro ⟨hn, h⟩; exact ⟨hn, (survivesBelow_iff (by omega)).1 h⟩
  · rintro ⟨hn, h⟩; exact ⟨hn, (survivesBelow_iff (by omega)).2 h⟩

/-- The method leaves 22 survivors up to 100, so `π(100) = 25`. -/
theorem prime_count_100 : Nat.primeCounting 100 = 25 := by
  rw [← survivor_count 100 (by norm_num), ← filter_survivesBelow (B := 11) (by norm_num)]
  decide

set_option maxRecDepth 100000 in
/-- The method leaves 165 survivors up to 1,000, so `π(1000) = 168`. -/
theorem prime_count_1000 : Nat.primeCounting 1000 = 168 := by
  rw [← survivor_count 1000 (by norm_num), ← filter_survivesBelow (B := 32) (by norm_num)]
  decide


/-! ## Step 11: the square-root rule, and the sieve with 3 and 7 -/

/-- **The square-root rule, part 1 (enough).** If `1 < n ≤ x` and no prime `p` with `p * p ≤ x`
    divides `n`, then `n` is prime. So crossing out the multiples of the primes up to `√x`
    leaves only primes. -/
theorem sqrt_rule (x n : ℕ) (hn : 1 < n) (hx : n ≤ x)
    (h : ∀ p, p.Prime → p * p ≤ x → ¬ p ∣ n) : n.Prime := by
  by_contra hnp
  have hsq : n.minFac ^ 2 ≤ n := Nat.minFac_sq_le_self (by omega) hnp
  exact h n.minFac (Nat.minFac_prime (by omega)) (by nlinarith [hsq]) (Nat.minFac_dvd n)

/-- **The square-root rule, part 2 (nothing less works).** `p * p` is never prime ... -/
theorem square_not_prime (p : ℕ) (hp : p.Prime) : ¬ (p * p).Prime := by
  intro h
  rcases h.eq_one_or_self_of_dvd p (Dvd.intro p rfl) with h1 | h1
  · exact hp.one_lt.ne' h1
  · have := hp.one_lt
    nlinarith

/-- ... and the only prime dividing `p * p` is `p`. So if `p` is left out of the sieve,
    `p * p` survives: every prime is needed from its square on. -/
theorem square_needs_p (p q : ℕ) (hp : p.Prime) (hq : q.Prime) (h : q ∣ p * p) : q = p := by
  have h1 : q ∣ p := by
    rcases (Nat.Prime.dvd_mul hq).mp h with h1 | h1 <;> exact h1
  rcases hp.eq_one_or_self_of_dvd q h1 with h2 | h2
  · exact absurd h2 hq.one_lt.ne'
  · exact h2

/-- **3 and 7 are enough up to 120.** A number `5 < n ≤ 120` that ends in 1, 3, 7 or 9, is not a
    multiple of 3, and is not a multiple of 7 (other than 7 itself) is prime. -/
theorem three_seven_enough (n : ℕ) (h5 : 5 < n) (hn : n ≤ 120)
    (hend : n % 10 = 1 ∨ n % 10 = 3 ∨ n % 10 = 7 ∨ n % 10 = 9)
    (h3 : ¬ 3 ∣ n) (h7 : ¬ 7 ∣ n ∨ n = 7) : n.Prime := by
  by_contra hnp
  have hsq : n.minFac ^ 2 ≤ n := Nat.minFac_sq_le_self (by omega) hnp
  have hp : n.minFac.Prime := Nat.minFac_prime (by omega)
  have hdvd : n.minFac ∣ n := Nat.minFac_dvd n
  obtain ⟨m, hm⟩ : ∃ m, m = n.minFac := ⟨_, rfl⟩
  rw [← hm] at hsq hp hdvd
  have hm2 : 2 ≤ m := hp.two_le
  have hle : m ≤ 10 := by nlinarith
  interval_cases m
  all_goals omega

/-- **And 120 is the limit.** 121 = 11 × 11 ends in 1, is not a multiple of 3 or 7, and is not
    prime: 3 and 7 alone first fail at 121. -/
theorem three_seven_fails_at_121 :
    121 % 10 = 1 ∧ ¬ 3 ∣ 121 ∧ ¬ 7 ∣ 121 ∧ ¬ Nat.Prime 121 := by
  refine ⟨by norm_num, by norm_num, by norm_num, by norm_num⟩

/-- The counting formulas of step 11: `N y` numbers in `1..y` ending in 1, 3, 7, 9; `left37 x`
    numbers of the 40% up to `x` left after crossing out the multiples of 3 and 7. -/
def N (y : ℕ) : ℕ := y - y / 2 - y / 5 + y / 10

def left37 (x : ℕ) : ℕ := (N x - 2) - (N (x / 3) + N (x / 7) - N (x / 21) - 2)

theorem left37_100 : left37 100 = 22 := by decide
theorem left37_120 : left37 120 = 27 := by decide
theorem left37_121 : left37 121 = 28 := by decide

/-! ## The sieve on an arbitrary window `[a, b]` -/

/-- Lemma 1: for `p` coprime to 10, `p * k` is coprime to 10 exactly when `k` is. -/
theorem mul_coprime_ten {p k : ℕ} (hp : Nat.Coprime p 10) :
    Nat.Coprime (p * k) 10 ↔ Nat.Coprime k 10 := by
  rw [Nat.Coprime, Nat.Coprime, Nat.Coprime.gcd_mul_left_cancel k hp]

/-- The multiplier range of Definition 3: `max p ⌈a/p⌉ ≤ k ≤ ⌊b/p⌋` says exactly that
    `p ≤ k` and `a ≤ p * k ≤ b`. -/
theorem multiplier_range {a b p k : ℕ} (hp : 0 < p) :
    (max p ((a + p - 1) / p) ≤ k ∧ k ≤ b / p) ↔ (p ≤ k ∧ a ≤ p * k ∧ p * k ≤ b) := by
  rw [max_le_iff, Nat.div_le_iff_le_mul_add_pred hp, Nat.le_div_iff_mul_le hp]
  rw [show k * p = p * k from mul_comm k p]
  generalize p * k = m
  omega

/-- `n` is crossed out in the window `[a, b]`: `n = p * k` for a sieving prime
    `3 ≤ p`, `p ≠ 5`, `p * p ≤ b`, and a multiplier `k` coprime to 10 with
    `max p ⌈a/p⌉ ≤ k ≤ ⌊b/p⌋`. -/
def CrossedOut (a b n : ℕ) : Prop :=
  ∃ p k, p.Prime ∧ 3 ≤ p ∧ p ≠ 5 ∧ p * p ≤ b ∧ Nat.Coprime k 10 ∧
    max p ((a + p - 1) / p) ≤ k ∧ k ≤ b / p ∧ p * k = n

/-- Theorem 1 (sieve identity on any window). For `1 ≤ a ≤ b`, a number `n` is a candidate in
    `[a, b]` (above 5, coprime to 10) that is not crossed out exactly when `n` is a prime with
    `max a 6 ≤ n ≤ b`. -/
theorem window_sieve (a b n : ℕ) :
    (a ≤ n ∧ n ≤ b ∧ 5 < n ∧ Nat.Coprime n 10 ∧ ¬ CrossedOut a b n) ↔
      (n.Prime ∧ max a 6 ≤ n ∧ n ≤ b) := by
  constructor
  · rintro ⟨ha, hb, h5, hc, hno⟩
    refine ⟨?_, max_le ha (by omega), hb⟩
    by_contra hnp
    set q := n.minFac with hq
    have hqp : q.Prime := Nat.minFac_prime (by omega)
    have hsq : q ^ 2 ≤ n := Nat.minFac_sq_le_self (by omega) hnp
    obtain ⟨k, hk⟩ : q ∣ n := Nat.minFac_dvd n
    have hq2 : q ≠ 2 := by
      intro h; rw [h] at hk; have := Nat.Coprime.coprime_dvd_left (Dvd.intro k hk.symm) hc
      norm_num at this
    have hq5 : q ≠ 5 := by
      intro h; rw [h] at hk; have := Nat.Coprime.coprime_dvd_left (Dvd.intro k hk.symm) hc
      norm_num at this
    have hq3 : 3 ≤ q := by have := hqp.two_le; omega
    have hkq : q ≤ k := by
      have hk1 : k ≠ 1 := by intro h; rw [h, mul_one] at hk; exact hnp (hk ▸ hqp)
      have hk0 : k ≠ 0 := by intro h; rw [h, mul_zero] at hk; omega
      have := Nat.minFac_le_of_dvd (Nat.minFac_prime hk1).two_le
        ((Nat.minFac_dvd k).trans (Dvd.intro_left q hk.symm))
      exact this.trans (Nat.minFac_le (by omega))
    have hqpos : 0 < q := hqp.pos
    have hkc : Nat.Coprime k 10 := (mul_coprime_ten
      (Nat.Coprime.coprime_dvd_left (Dvd.intro k hk.symm) hc)).1 (hk ▸ hc)
    have hr := (multiplier_range (a := a) (b := b) (k := k) hqpos).2
      ⟨hkq, by omega, by omega⟩
    exact hno ⟨q, k, hqp, hq3, hq5, by nlinarith, hkc, hr.1, hr.2, hk.symm⟩
  · rintro ⟨hp, hmax, hb⟩
    have ha : a ≤ n := le_of_max_le_left hmax
    have h5 : 5 < n := by have := le_of_max_le_right hmax; omega
    refine ⟨ha, hb, h5, ?_, ?_⟩
    · exact (Nat.Prime.coprime_iff_not_dvd hp).2 fun h => by
        rcases (Nat.Prime.dvd_mul hp).mp (show n ∣ 2 * 5 from h) with h' | h' <;>
          · have := Nat.le_of_dvd (by norm_num) h'; omega
    · rintro ⟨p, k, hpp, hp3, -, -, -, hr, hk1, hpk⟩
      have hpk' := ((multiplier_range hpp.pos).1 ⟨hr, hk1⟩).1
      rcases hp.eq_one_or_self_of_dvd p (Dvd.intro k hpk) with h | h
      · omega
      · rw [h] at hpk'; have := hp.pos; nlinarith

/-! ## How far the primes we already know can reach -/

/-- **Known primes reach to the next square.** If every prime up to `Y` is known, they decide
    every number below `(Y + 1)²`: a number `1 < n < (Y + 1)²` that none of them divides is prime.
    So knowing the primes up to `Y` gives all primes up to about `Y²`, and those in turn give all
    primes up to about `Y⁴`: each round roughly doubles the number of digits covered. -/
theorem known_primes_reach (Y n : ℕ) (hn : 1 < n) (hY : n < (Y + 1) * (Y + 1))
    (h : ∀ p, p.Prime → p ≤ Y → ¬ p ∣ n) : n.Prime := by
  by_contra hnp
  have hsq : n.minFac ^ 2 ≤ n := Nat.minFac_sq_le_self (by omega) hnp
  have hle : n.minFac ≤ Y := by
    by_contra hgt
    have hY1 : Y + 1 ≤ n.minFac := by omega
    nlinarith
  exact h n.minFac (Nat.minFac_prime (by omega)) hle (Nat.minFac_dvd n)

/-- **The sieve finds its own primes (bootstrapping).** For every `n ≤ Y * Y`: `n` is prime exactly
    when `1 < n` and no prime up to `Y` other than `n` itself divides it. So the primes up to `Y`
    determine all primes up to `Y²`. Each prime `p` is found at `p` and first needed at `p * p`,
    so the sieve, run upwards from 1, always has every prime it needs before it needs it. -/
theorem bootstrap (Y n : ℕ) (hn : n ≤ Y * Y) :
    n.Prime ↔ (1 < n ∧ ∀ p, p.Prime → p ≤ Y → p ∣ n → p = n) := by
  constructor
  · intro hp
    refine ⟨hp.one_lt, fun p hpp _ hdvd => ?_⟩
    rcases hp.eq_one_or_self_of_dvd p hdvd with h | h
    · exact absurd h hpp.one_lt.ne'
    · exact h
  · rintro ⟨h1, h⟩
    by_contra hnp
    have hsq : n.minFac ^ 2 ≤ n := Nat.minFac_sq_le_self (by omega) hnp
    have hle : n.minFac ≤ Y := by
      by_contra hgt
      have hY1 : Y + 1 ≤ n.minFac := by omega
      nlinarith
    have hmp : n.minFac.Prime := Nat.minFac_prime (by omega)
    have := h n.minFac hmp hle (Nat.minFac_dvd n)
    exact hnp (this ▸ hmp)

/-- **No finite list of primes is enough forever.** Whatever `Y` is, some non-prime above 1 is
    divisible by no prime up to `Y`: the square of the first prime above `Y`. So the primes known
    at any moment can never cross out all the non-primes still to come. -/
theorem known_primes_not_enough (Y : ℕ) :
    ∃ n, 1 < n ∧ ¬ n.Prime ∧ ∀ p, p.Prime → p ≤ Y → ¬ p ∣ n := by
  obtain ⟨q, hqY, hq⟩ := Nat.exists_infinite_primes (Y + 1)
  refine ⟨q * q, by nlinarith [hq.one_lt], square_not_prime q hq, fun p hp hpY hdvd => ?_⟩
  have := square_needs_p q p hq hp hdvd
  omega

/-! ## The pick-up loop

The sieve as a loop: start with the kept numbers (above 5, ending in 1, 3, 7, 9); pick up a prime
`p`, remove `p * p` and then `p * k` for every larger `k` ending in 1, 3, 7, 9; the next prime to
pick up is the smallest number still standing above `p`; stop when `p * p > x`. -/

/-- `n` is still standing after every prime `q` with `3 ≤ q ≤ P`, `q ≠ 5`, has been picked up:
    `n` is above 5, ends in 1, 3, 7 or 9, and is not `q * k` for any picked `q` and any multiplier
    `k ≥ q` ending in 1, 3, 7 or 9. -/
def Alive (P n : ℕ) : Prop :=
  5 < n ∧ Nat.Coprime n 10 ∧
    ∀ q k, q.Prime → 3 ≤ q → q ≠ 5 → q ≤ P → Nat.Coprime k 10 → q ≤ k → q * k ≠ n

/-- A prime above 5 is never removed. -/
theorem prime_alive (P n : ℕ) (hp : n.Prime) (h5 : 5 < n) : Alive P n := by
  refine ⟨h5, ?_, ?_⟩
  · exact (Nat.Prime.coprime_iff_not_dvd hp).2 fun h => by
      rcases (Nat.Prime.dvd_mul hp).mp (show n ∣ 2 * 5 from h) with h' | h' <;>
        · have := Nat.le_of_dvd (by norm_num) h'; omega
  · intro q k hq hq3 _ _ _ hqk hn
    rcases hp.eq_one_or_self_of_dvd q (Dvd.intro k hn) with h | h
    · omega
    · subst h
      have hk : k = 1 := by
        have := hq.pos
        nlinarith [Nat.eq_of_mul_eq_mul_left this (hn.trans (mul_one q).symm)]
      omega

/-- The smallest prime factor of a number ending in 1, 3, 7 or 9 is neither 2 nor 5. -/
theorem minFac_ne_two_five {n : ℕ} (hc : Nat.Coprime n 10) :
    n.minFac ≠ 2 ∧ n.minFac ≠ 5 := by
  have hd : n.minFac ∣ n := Nat.minFac_dvd n
  have hcop : Nat.Coprime n.minFac 10 := Nat.Coprime.coprime_dvd_left hd hc
  constructor <;> intro h <;> rw [h] at hcop <;> norm_num at hcop

/-- A non-prime number ending in 1, 3, 7 or 9 whose smallest prime factor has been picked up is
    removed. -/
theorem composite_removed (P n : ℕ) (h5 : 5 < n) (hc : Nat.Coprime n 10) (hnp : ¬ n.Prime)
    (hle : n.minFac ≤ P) : ¬ Alive P n := by
  rintro ⟨-, -, h⟩
  have hq : n.minFac.Prime := Nat.minFac_prime (by omega)
  obtain ⟨h2, h5'⟩ := minFac_ne_two_five hc
  obtain ⟨k, hk⟩ : n.minFac ∣ n := Nat.minFac_dvd n
  have hsq : n.minFac ^ 2 ≤ n := Nat.minFac_sq_le_self (by omega) hnp
  have hkq : n.minFac ≤ k := by
    have hmul : n.minFac * n.minFac ≤ n.minFac * k := by rw [← hk]; nlinarith [hsq]
    exact Nat.le_of_mul_le_mul_left hmul hq.pos
  have hkc : Nat.Coprime k 10 :=
    Nat.Coprime.coprime_dvd_left (Dvd.intro_left _ hk.symm) hc
  exact h n.minFac k hq (by have := hq.two_le; omega) h5' hle hkc hkq hk.symm

/-- **The pick-up rule is right.** After the primes up to `P` have been picked up, the smallest
    number still standing above `P` is prime, and the only prime it skips over is 5. So the loop
    picks up exactly the primes 3, 7, 11, 13, 17, ... in order. -/
theorem next_pickup_prime (P n : ℕ) (hP : 3 ≤ P) (hPn : P < n) (ha : Alive P n)
    (hmin : ∀ m, P < m → m < n → ¬ Alive P m) :
    n.Prime ∧ ∀ q, q.Prime → P < q → q < n → q = 5 := by
  obtain ⟨h5, hc, hrest⟩ := ha
  refine ⟨?_, fun q hq hPq hqn => ?_⟩
  · by_contra hnp
    by_cases hle : n.minFac ≤ P
    · exact composite_removed P n h5 hc hnp hle ⟨h5, hc, hrest⟩
    · push Not at hle
      have hr : n.minFac.Prime := Nat.minFac_prime (by omega)
      obtain ⟨-, h5'⟩ := minFac_ne_two_five hc
      have hsq : n.minFac ^ 2 ≤ n := Nat.minFac_sq_le_self (by omega) hnp
      have h4 : n.minFac ≠ 4 := fun h => by rw [h] at hr; norm_num at hr
      have hrn : n.minFac < n := by have := hr.two_le; nlinarith
      exact hmin _ hle hrn (prime_alive P _ hr (by omega))
  · by_contra hq5
    have h4 : q ≠ 4 := fun h => by rw [h] at hq; norm_num at hq
    exact hmin q hPq hqn (prime_alive P q hq (by omega))

/-- **The stop rule is right.** If `p` is the next number to pick up and `p * p > x`, everything
    still standing up to `x` is prime. Together with `prime_alive`, the survivors are exactly the
    primes above 5 up to `x`. -/
theorem stop_rule (P p x m : ℕ) (hP : 3 ≤ P) (hPp : P < p)
    (hmin : ∀ m, P < m → m < p → ¬ Alive P m) (hx : x < p * p) (hm : m ≤ x)
    (ha : Alive P m) : m.Prime := by
  obtain ⟨h5, hc, hrest⟩ := ha
  by_contra hnp
  by_cases hle : m.minFac ≤ P
  · exact composite_removed P m h5 hc hnp hle ⟨h5, hc, hrest⟩
  · push Not at hle
    have hr : m.minFac.Prime := Nat.minFac_prime (by omega)
    obtain ⟨-, h5'⟩ := minFac_ne_two_five hc
    have hsq : m.minFac ^ 2 ≤ m := Nat.minFac_sq_le_self (by omega) hnp
    have h4 : m.minFac ≠ 4 := fun h => by rw [h] at hr; norm_num at hr
    have hrp : m.minFac < p := by nlinarith
    exact hmin _ hle hrp (prime_alive P _ hr (by omega))

/-- Challenge definition (Comparator Live, "There Are Infinitely Many Primes"). -/
def IsPrime (n : Nat) := 1 < n ∧ ∀ k, 1 < k → k < n → ¬ k ∣ n

/-- Infinitely many primes, obtained from `candidate_prime_above`. -/
theorem InfinitudeOfPrimes : ∀ n, ∃ p > n, IsPrime p := by
  intro n
  obtain ⟨p, hp, hnp, -⟩ := candidate_prime_above n
  refine ⟨p, hnp, ?_⟩
  unfold IsPrime
  refine ⟨hp.one_lt, fun k hk1 hkp hdvd => ?_⟩
  rcases hp.eq_one_or_self_of_dvd k hdvd with h | h <;> omega

theorem density_factor : (1 : ℚ) / (4 / 10) = 5 / 2 := by norm_num

theorem prime_97 : Nat.Prime 97 := by norm_num

theorem not_prime_91 : ¬ Nat.Prime 91 := by norm_num

/-! ## Candidate set -/

/-- `n` is a candidate: `n > 5` and `n % 10 ∈ {1, 3, 7, 9}`. -/
def isCandidate (n : ℕ) : Bool := decide (5 < n) && [1, 3, 7, 9].contains (n % 10)

/-- Number of candidates in `[1, y]`: `4⌊y/10⌋ + r - 2`, `r = #{d ∈ {1,3,7,9} : d ≤ y % 10}`. -/
def candidateCount (y : ℕ) : ℕ :=
  4 * (y / 10) + ([1, 3, 7, 9].filter fun d => decide (d ≤ y % 10)).length - 2

theorem candidateCount_100 : candidateCount 100 = 38 := by decide

theorem candidateCount_1e10 : candidateCount (10 ^ 10) = 3999999998 := by decide

theorem candidateCount_1000 : candidateCount 1000 = 398 := by decide

theorem candidateCount_10000 : candidateCount 10000 = 3998 := by decide

/-! ## Sieve -/

/-- Integer square root by Newton's method. -/
def isqrt (n : ℕ) : ℕ := Id.run do
  if n < 2 then return n
  let mut x := n
  let mut y := (x + 1) / 2
  while decide (y < x) do
    x := y
    y := (x + n / x) / 2
  return x

/-- Sieve of Eratosthenes on the candidates in `[0, x]`; entry `n` is `true` iff `n` survives. -/
def candidateSieve (x : ℕ) : Array Bool := Id.run do
  let mut keep : Array Bool := Array.ofFn (n := x + 1) fun i => isCandidate i.val
  let mut p := 3
  while decide (p * p ≤ x) do
    if p == 3 || keep[p]! then
      let mut m := p * p
      while decide (m ≤ x) do
        keep := keep.set! m false
        m := m + 2 * p
    p := p + 2
  return keep

/-- All primes in `[0, x]`. -/
def primesUpTo (x : ℕ) : Array ℕ := Id.run do
  let keep := candidateSieve x
  let mut out : Array ℕ := #[]
  for q in [2, 3, 5] do
    if decide (q ≤ x) then out := out.push q
  for i in [0:x + 1] do
    if keep[i]! then out := out.push i
  return out

/-! ## Miller-Rabin -/

/-- `b ^ e % m` by binary exponentiation. -/
def powMod (b e m : ℕ) : ℕ := Id.run do
  let mut r := 1 % m
  let mut base := b % m
  let mut ex := e
  while ex != 0 do
    if ex % 2 == 1 then r := r * base % m
    base := base * base % m
    ex := ex / 2
  return r

/-- `(d, s)` with `m = d · 2^s` and `d` odd. -/
def oddPart (m : ℕ) : ℕ × ℕ := Id.run do
  let mut d := m
  let mut s := 0
  while d != 0 && d % 2 == 0 do
    d := d / 2
    s := s + 1
  return (d, s)

def millerRabinRound (n a d s : ℕ) : Bool := Id.run do
  let mut x := powMod a d n
  if x == 1 || x == n - 1 then return true
  for _ in [1:s] do
    x := x * x % n
    if x == n - 1 then return true
  return false

def mrBases : List ℕ := [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71]

/-- Bound below which the first 13 prime bases make Miller-Rabin deterministic. -/
def mrDeterministicBound : ℕ := 3317044064679887385961981

def isPrimeMR (n : ℕ) : Bool :=
  if n < 2 then false
  else if mrBases.contains n then true
  else if mrBases.any (fun p => n % p == 0) then false
  else
    let ds := oddPart (n - 1)
    mrBases.all fun a => millerRabinRound n a ds.1 ds.2

/-! ## Primes in a window -/

def sieveLimit : ℕ := 2000000

/-- Primes in `[a, b]`: candidates, sieved by primes `3 ≤ p ≤ min(√b, sieveLimit)`, `p ≠ 5`;
    survivors are confirmed with Miller-Rabin when `√b > sieveLimit`. -/
def primesBetween (a b : ℕ) : Array ℕ := Id.run do
  if b < a then return #[]
  let r := isqrt b
  let base := (primesUpTo (min r sieveLimit)).filter fun p => decide (2 < p) && p != 5
  let w := b + 1 - a
  let mut keep : Array Bool := Array.ofFn (n := w) fun i => isCandidate (a + i.val)
  for p in base do
    let s0 := max (p * p) ((a + p - 1) / p * p)
    let mut m := if s0 % 2 == 0 then s0 + p else s0
    while decide (m ≤ b) do
      keep := keep.set! (m - a) false
      m := m + 2 * p
  let mut out : Array ℕ := #[]
  for q in [2, 3, 5] do
    if decide (a ≤ q) && decide (q ≤ b) then out := out.push q
  for i in [0:w] do
    if keep[i]! then
      let n := a + i
      if decide (r ≤ sieveLimit) || isPrimeMR n then out := out.push n
  return out

/-! ## Numerical helpers -/

def lnNat (x : ℕ) : Float :=
  if Nat.log2 x < 60 then Float.log x.toFloat
  else
    let k := Nat.log2 x - 60
    Float.log (x >>> k).toFloat + k.toFloat * Float.log 2

def eulerGamma : Float := 0.5772156649015329

/-- `li x` from `u = ln x`: `γ + ln u + Σ uⁿ / (n · n!)`; valid for `u ≲ 700`. -/
def liFromLn (u : Float) : Float := Id.run do
  let mut term := 1.0
  let mut sum := 0.0
  let mut n := 1.0
  while decide (n < 3 * u + 60) do
    term := term * u / n
    sum := sum + term / n
    n := n + 1
  return eulerGamma + Float.log u + sum

def sci (v : Float) : String :=
  if v < 1000000 then toString v
  else
    let e := (Float.log10 v).floor
    s!"{v / Float.pow 10 e} x 10^{e.toUInt64.toNat}"

def pct (num den : ℕ) : Float :=
  if den == 0 then 0 else 100 * num.toFloat / den.toFloat

/-! ## Report -/

def report (a b groups : ℕ) : IO Unit := do
  if b < a then
    IO.println "Error: end < start."
    return
  let exact := decide (isqrt b ≤ sieveLimit)
  if exact && decide (1000000 < b - a) then
    IO.println "Error: width exceeds 1,000,000 for exact sieving."
    return
  if !exact && decide (200000 < b - a) then
    IO.println "Error: width exceeds 200,000 above 4·10^12."
    return
  let ps := primesBetween a b
  let width := b - a + 1
  let cand := candidateCount b - candidateCount (a - 1)
  let big := ps.filter fun p => decide (5 < p)
  let fromStart := decide (a ≤ 10)
  let lnRef := if fromStart then lnNat (max b 3) else lnNat (max (a + (b - a) / 2) 3)
  let dens := if fromStart then 100 / (lnRef - 1) else 100 / lnRef
  let densLbl := if fromStart then "1/(ln b - 1)" else "1/ln(midpoint)"
  let gapPred := if fromStart then lnRef - 1 else lnRef
  let mut gaps : Array ℕ := #[]
  for i in [1:ps.size] do
    gaps := gaps.push (ps[i]! - ps[i - 1]!)
  let avgGap : Float :=
    if gaps.isEmpty then 0 else (gaps.foldl (· + ·) 0).toFloat / gaps.size.toFloat
  let ending := fun (d : ℕ) => (big.filter fun p => p % 10 == d).size
  let method :=
    if exact then "exact sieve"
    else if decide (b < mrDeterministicBound) then "sieve + Miller-Rabin (deterministic)"
    else "sieve + Miller-Rabin (probable primes)"
  let lnB := lnNat (max b 3)
  let estSimple : Float := 3 + (candidateCount b).toFloat * 2.5 / (lnB - 1)
  let estLi : Float := 3 + liFromLn lnB - liFromLn (Float.log 5.5)
  IO.println s!"Range:              {a} .. {b}"
  IO.println s!"Method:             {method}"
  IO.println s!"Width:              {width}"
  IO.println s!"Candidates:         {cand} ({pct cand width} %)"
  IO.println s!"Excluded:           {width - cand}"
  IO.println s!"Primes:             {ps.size} (above 5: {big.size})"
  IO.println s!"Density:            {pct ps.size width} %  [model {densLbl}: {dens} %]"
  IO.println s!"Candidate density:  {pct big.size cand} %  [model 2.5 x above: {2.5 * dens} %]"
  IO.println s!"Smallest / largest: {ps[0]?.getD 0} / {ps.back?.getD 0}"
  IO.println s!"Gaps min/max/mean:  {gaps.foldl min (gaps[0]?.getD 0)} / {gaps.foldl max 0} / {avgGap}  [model {gapPred}]"
  IO.println s!"Endings 1/3/7/9:    {ending 1} / {ending 3} / {ending 7} / {ending 9} (sum {big.size})"
  IO.println s!"P(b) estimates:     3 + C(b)·2.5/(ln b - 1) = {sci estSimple};  3 + li(b) - li(5.5) = {sci estLi}"
  if 1 < groups then
    let size := (width + groups - 1) / groups
    IO.println "Block | start | end | candidates | primes > 5 | candidate density %"
    for g in [0:groups] do
      let lo := a + g * size
      if decide (lo ≤ b) then
        let hi := min b (lo + size - 1)
        let k := candidateCount hi - candidateCount (lo - 1)
        let n := (big.filter fun p => decide (lo ≤ p) && decide (p ≤ hi)).size
        IO.println s!"{g + 1} | {lo} | {hi} | {k} | {n} | {pct n k}"
  if ps.size ≤ 300 then
    IO.println s!"Primes: {ps.toList}"
  else
    IO.println s!"First 50: {ps.toList.take 50}"
    IO.println s!"Last 50:  {ps.toList.drop (ps.size - 50)}"

/-! ## Mersenne numbers -/

/-- `⌊log₁₀ 2 · 10⁴⁰⌋`. -/
def log10Two40 : ℕ := 3010299956639811952137388947244930267681

/-- Number of decimal digits of `2^p - 1`. -/
def mersenneDigits (p : ℕ) : ℕ := p * log10Two40 / 10 ^ 40 + 1

/-- Least `p` such that `2^p - 1` has at least `d` digits. -/
def firstExponentWithDigits (d : ℕ) : ℕ :=
  ((d - 1) * 10 ^ 40 + log10Two40 - 1) / log10Two40

theorem record_digits : mersenneDigits 136279841 = 41024320 := by decide

theorem first_exponent_100M : firstExponentWithDigits 100000000 = 332192807 := by decide

/-- Lucas-Lehmer test for `2^p - 1`, `p` an odd prime (also accepts `p = 2`). -/
def lucasLehmer (p : ℕ) : Bool := Id.run do
  if p == 2 then return true
  let m := 2 ^ p - 1
  let mut s := 4
  for _ in [0:p - 2] do
    s := (s * s + m - 2) % m
  return s == 0

/-- Expected number of Mersenne primes with exponent in `[a, b]` under the
    Lenstra-Pomerance-Wagstaff heuristic: `(e^γ / ln 2) · ln(b / a)`. -/
def expectedMersenne (a b : ℕ) : Float :=
  Float.exp eulerGamma / Float.log 2 * Float.log (b.toFloat / a.toFloat)

def mersenneReport (record : ℕ) : IO Unit := do
  let frac : Float := (record * log10Two40 % 10 ^ 40).toFloat / 1e40
  let lead := (Float.pow 10 (frac + 5)).floor.toUInt64.toNat
  let last := (powMod 2 record (10 ^ 20) + 10 ^ 20 - 1) % 10 ^ 20
  let target := firstExponentWithDigits 100000000
  let nextExps := (primesBetween (record + 1) (record + 300)).toList.take 10
  let firstBig := (primesBetween target (target + 100))[0]?.getD 0
  let small := ((primesUpTo 1300).filter fun p => lucasLehmer p).toList
  IO.println s!"2^{record} - 1: {mersenneDigits record} digits, leading {lead}, trailing {last}"
  IO.println s!"Next 10 prime exponents: {nextExps}"
  IO.println s!"First exponent with 10^8 digits: {target}; first prime exponent: {firstBig}"
  IO.println s!"Expected Mersenne primes in between (heuristic): {expectedMersenne record firstBig}"
  IO.println s!"Mersenne prime exponents below 1300: {small}"

/-! ## Wheel benchmark: precision, recall and pass/fail checks (computation, not proof) -/

/-- Plain sieve of Eratosthenes over all numbers, using no wheel: the ground truth. -/
def plainSieve (x : ℕ) : Array Bool := Id.run do
  let mut s : Array Bool := Array.ofFn (n := x + 1) fun i => decide (2 ≤ i.val)
  let mut p := 2
  while decide (p * p ≤ x) do
    if s[p]! then
      let mut m := p * p
      while decide (m ≤ x) do
        s := s.set! m false
        m := m + p
    p := p + 1
  return s

/-- For the wheel mod `m` on `(big, x]`: candidates, primes among them, and all primes. -/
def wheelCounts (m big x : ℕ) (s : Array Bool) : ℕ × ℕ × ℕ := Id.run do
  let mut kept := 0
  let mut primesKept := 0
  let mut primesAll := 0
  for n in [big + 1:x + 1] do
    let isP := s[n]!
    let inWheel := Nat.gcd n m == 1
    if inWheel then kept := kept + 1
    if isP then primesAll := primesAll + 1
    if isP && inWheel then primesKept := primesKept + 1
  return (kept, primesKept, primesAll)

def wheelBenchmark : IO Unit := do
  let limits := [10000, 100000, 1000000]
  let s := plainSieve 1000000
  let wheels : List (ℕ × ℕ) := [(10, 5), (30, 5), (210, 7), (2310, 11)]
  let mut recallOk := true
  let mut fallsOk := true
  let mut modelOk := true
  let mut shareOk := true
  IO.println "Wheel | x | kept % | candidates | primes in them | precision % | model % | recall % | missed"
  for (m, big) in wheels do
    let residues := ((List.range m).filter fun r => Nat.gcd r m == 1).length
    let boost := m.toFloat / residues.toFloat
    let mut prev : Float := 101
    for x in limits do
      let (kept, pk, pa) := wheelCounts m big x s
      let prec := pct pk kept
      let model := 100 * boost / (lnNat x - 1)
      IO.println s!"mod {m} | {x} | {pct kept x} | {kept} | {pk} | {prec} | {model} | {pct pk pa} | {pa - pk}"
      if pk != pa then recallOk := false
      if !(decide (prec < prev)) then fallsOk := false
      if !(decide (Float.abs (prec - model) / model < 0.02)) then modelOk := false
      if x == 1000000 && !(decide (Float.abs (pct kept x - pct residues m) < 0.1)) then
        shareOk := false
      prev := prec
  let verdict := fun (ok : Bool) => if ok then "PASS" else "FAIL"
  IO.println s!"[{verdict recallOk}] Recall: no prime above the wheel's primes is ever missed"
  IO.println s!"[{verdict fallsOk}] Precision falls as x grows, for every wheel"
  IO.println s!"[{verdict modelOk}] Precision within 2% of boost / (ln x - 1) everywhere"
  IO.println s!"[{verdict shareOk}] Kept share at 10^6 within 0.1 points of phi(m) / m"
  IO.println (if recallOk && fallsOk && modelOk && shareOk then "ALL 4 CHECKS PASSED"
    else "AT LEAST ONE CHECK FAILED")

/-! ## Run -/

def rangeStart : ℕ := 10 ^ 28
def rangeEnd   : ℕ := 10 ^ 28 + 99999
def blocks     : ℕ := 10

-- Cross-check (computation, not proof): the fast array sieve agrees with `primesSpec`.
-- #eval (primesUpTo 3000).toList == primesSpec 3000   (switched off in the proofs-only version)

-- #eval report rangeStart rangeEnd blocks   (switched off in the proofs-only version)
-- #eval mersenneReport 136279841   (switched off in the proofs-only version)
-- #eval wheelBenchmark   (switched off in the proofs-only version)

-- `prime_count_10000` (π(10000) = 1229, counted by Lean's kernel) is in `Solution.lean` but left
-- out of this proofs-only version: the count needs about 10 GB of memory, more than Comparator Live
-- allows (its build was stopped with exit code 137).
