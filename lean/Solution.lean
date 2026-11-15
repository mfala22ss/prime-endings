import Mathlib

/-!
# Primes in the residue classes 1, 3, 7, 9 (mod 10)

Main results:
* `prime_ending`: every prime `p > 5` satisfies `p % 10 ∈ {1, 3, 7, 9}`.
* `removed_not_prime`: no `n > 5` with `n % 10 ∈ {0, 2, 4, 5, 6, 8}` is prime.
* `smallest_factor_le_sqrt`: a composite `n` has `minFac n ^ 2 ≤ n`, so sieving by primes up to
  `√x` suffices.
* `survives_iff`, `mem_primesSpec`: the sieve rule on the 40% keeps exactly the primes above 5,
  and the reference sieve `primesSpec x` lists exactly the primes up to `x`.
* `infinitely_many_ending`: infinitely many primes end in each of 1, 3, 7 and 9 (Dirichlet).

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

/-! ## Run -/

def rangeStart : ℕ := 10 ^ 28
def rangeEnd   : ℕ := 10 ^ 28 + 99999
def blocks     : ℕ := 10

-- Cross-check (computation, not proof): the fast array sieve agrees with `primesSpec`.
#eval (primesUpTo 3000).toList == primesSpec 3000

#eval report rangeStart rangeEnd blocks
#eval mersenneReport 136279841
