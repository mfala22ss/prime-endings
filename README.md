# Prime Endings

**Primes through their last digit: a measured, audited and machine-verified study.**

Every prime above 5 ends in 1, 3, 7 or 9. This project starts from that one fact and follows it as far as it goes: how many primes the 40% of numbers with those endings contain, how fast that share falls, how the four endings compare, how primes ending in 1 are spaced, and what it takes to get from the 40% down to the primes alone. Every number is computed and checked against independent software. The central facts are proved in Lean 4 and checked by the Lean kernel.

> **What this is and is not.** Every result here is already known to mathematics, most of it for over a century (see [Prior work](#prior-work)). This is not a new discovery. It is a careful rediscovery: each claim is computed from scratch, tested against ground truth, audited, and where possible formally proved.

---

## Contents

1. [The idea in one table](#the-idea-in-one-table)
2. [How the project came about](#how-the-project-came-about)
3. [Results](#results)
4. [The Lean proofs](#the-lean-proofs)
5. [What "verified by Lean" means](#what-verified-by-lean-means)
6. [What the code can do](#what-the-code-can-do)
7. [How to run it](#how-to-run-it)
8. [Prior work](#prior-work)
9. [Limits](#limits)

---

## The idea in one table

Take every number from 1 to x. Numbers ending in 0, 2, 4, 6 or 8 are even, so they are divisible by 2. Numbers ending in 5 are divisible by 5. So apart from 2 and 5 themselves, no prime can end in those digits. Remove them and 40% of the numbers remain. All primes above 5 are in that 40%.

Up to **x = 10,000,000,000**, as shares of all numbers (counted exactly; [`data/breakdown_by_ending.csv`](data/breakdown_by_ending.csv)):

| Group | Count | Prime | Not prime | Total |
|--------------------------|----------------:|------------------:|----------------:|--------:|
| Ends in 1 | 999,999,999 | 1.1376% | 8.8624% | 10% |
| Ends in 3 | 999,999,999 | 1.1377% | 8.8623% | 10% |
| Ends in 7 | 1,000,000,000 | 1.1376% | 8.8624% | 10% |
| Ends in 9 | 1,000,000,000 | 1.1376% | 8.8624% | 10% |
| **Kept (40%)** | **3,999,999,998** | **4.5505%** | **35.4495%** | **40%** |
| Even numbers | 5,000,000,000 | only the prime 2 | 4,999,999,999 | 50% |
| Ends in 5 | 1,000,000,000 | only the prime 5 | 999,999,999 | 10% |
| The numbers 1 and 3 | 2 | only the prime 3 | 1 | 0% |
| **Removed (60%)** | **6,000,000,002** | **3 primes** | **5,999,999,999** | **60%** |
| **All numbers** | **10,000,000,000** | **4.5505%** | **95.4495%** | **100%** |

So the filter keeps 40% of the numbers and loses no prime above 5. Within the kept 40%, **11.38%** are prime at this size (4.5505 / 40), and that share keeps falling as x grows.

---

## How the project came about

The project grew one question at a time. Each step has its own script in [`python/steps`](python/steps) and its saved output in [`results`](results).

| Step | Question | Answer |
|-------|----------------------------|--------------------------------------------------|
| 1 | Can a model predict how prime density falls on the kept 40%? | Yes. A model trained only on x up to 400,000 stays within 2% out to 10^13. The theory formula 2.5 / (ln x - 1) is within 0.13% there. |
| 2 | How does the density change each time x grows ten-fold? | The drop shrinks every time, following about 2.3 / ln x. The number of new primes grows by a factor that rises towards 10 but never reaches it. |
| 3 | Does this hold up to 10 trillion, with every count computed locally? | Yes, using primecount. 346,065,536,836 of the 3,999,999,999,998 kept numbers up to 10^13 are prime (8.65%). |
| 4 | Do the four endings behave the same? | Almost exactly. At 10^10 each is 11.376% prime. Endings 1 and 9 sit very slightly lower (Chebyshev's bias). |
| 5 | How are primes ending in 1 spaced? | Average spacing is exactly 4 ln x (82.69 near 10^9). Spacings divisible by 30 are strongly favoured (44.5% of gaps against 29% under a no-pattern model), as Hardy and Littlewood predicted. |
| 6 | Sieving the 40% by 3, 7, 11, ... up to the square root of x: what is left? | Exactly the primes, verified number by number. Each small prime p removes 1/p of what is left. |
| 7 | Is all of the above code actually correct? | An audit with 13 checks against independent ground truth. 13 of 13 pass. |

A Lean 4 file then proves the central facts formally (status: ESTABLISHED, kernel-checked on Comparator Live with Lean v4.36; see [The Lean proofs](#the-lean-proofs)).

---

## Results

All figures below are copied from [`results`](results), produced by the scripts in this repository.

### The prime share of the kept 40% falls predictably

From [`results/step3_to_10_trillion.txt`](results/step3_to_10_trillion.txt). The model was trained only on x up to 400,000.

| x | True share | Model, 2.5694 / (ln x - 0.7918) | Error | Theory, 2.5 / (ln x - 1) | Error |
|--------|-------------:|----------------------:|----------:|---------------------:|----------:|
| 10^4 | 30.6653% | 30.5207% | -0.47% | 30.4494% | -0.70% |
| 10^6 | 19.6238% | 19.7286% | +0.53% | 19.5076% | -0.59% |
| 10^8 | 14.4036% | 14.5749% | +1.19% | 14.3508% | -0.37% |
| 10^10 | 11.3763% | 11.5562% | +1.58% | 11.3503% | -0.23% |
| 10^13 | 8.6516% | 8.8169% | +1.91% | 8.6405% | **-0.13%** |

The fitted model is better near its training range. The theory, which uses no data at all, is better far beyond it. The 2.5 is simply 1 / 0.4: the same primes in 40% of the numbers.

### The density drops by a shrinking amount each power of ten

From [`results/step3_to_10_trillion.txt`](results/step3_to_10_trillion.txt):

| Step | Drop | Theory drop | Growth of prime count | Measured / theory |
|--------------------|---------:|-------------:|----------------------:|------------------:|
| 10^4 to 10^5 | 21.82% | 21.90% | x 7.82 | 0.996 |
| 10^8 to 10^9 | 11.75% | 11.67% | x 8.83 | 1.006 |
| 10^12 to 10^13 | 7.98% | 7.96% | x 9.20 | 1.003 |

### Sieving the 40% leaves exactly the primes

From [`results/step7_audit.txt`](results/step7_audit.txt), up to 10^8:

| After removing multiples of | Numbers left | Predicted by the product rule | Prime share of what is left |
|----------------------------|---------------:|-----------------------:|--------------------:|
| (start: the 40%) | 39,999,998 | | 14.40% |
| 3 | 26,666,665 | 26,666,665 | 21.6% |
| 13 | 19,180,822 | 19,180,818 | 30.0% |
| 97 | 12,029,474 | 12,031,728 | 47.9% |
| 997 | 8,087,521 | 8,096,526 | 71.2% |
| every prime up to 9,973 | **5,761,452** | 6,088,469 | **100%** |

The survivors equal the 5,761,452 primes above 5, checked number by number across all 100 million numbers. The product rule overshoots at the end by 5.7%; that is Mertens' theorem, not an error in the sieve.

### Spacing between primes ending in 1

From [`results/step5_ending1_spacing.txt`](results/step5_ending1_spacing.txt), for the 1,209,307 primes ending in 1 between 900 million and 1 billion:

* mean gap **82.69**, against the prediction 4 ln x = **82.69**;
* the most common gap is **30** (14.37% of gaps);
* gaps divisible by 30 make up **44.53%** of all gaps, against 29.02% under a pattern-free decay model;
* pairs (p, p + 10) with both prime: 103,368 counted, 102,995 predicted by the Hardy-Littlewood pair formula (0.4% off).

The reason for 30: if a gap is divisible by 3, the next number can never be a multiple of 3, so it survives the "divisible by 3" test twice as often.

### Very large numbers

The Lean report lists primes in windows at any size. In the 100,000 numbers from 10^28 to 10^28 + 99,999 it finds 1,554 primes (1.554%, against 1.551% predicted), with a mean gap of 64.17 (predicted 64.47). Python's sympy confirms the same 1,554 primes independently.

---

## The Lean proofs

File: [`lean/Solution.lean`](lean/Solution.lean). Checked with Lean v4.36 and the latest Mathlib on [Comparator Live](https://comparator.live.lean-lang.org).

| Theorem | Statement in plain words |
|------------------------|--------------------------------------------------------|
| `prime_ending` | Every prime above 5 ends in 1, 3, 7 or 9. |
| `removed_not_prime` | No number above 5 ending in 0, 2, 4, 5, 6 or 8 is prime. The removed 60% holds no primes above 5. |
| `smallest_factor_le_sqrt` | A composite number's smallest prime factor, squared, is at most the number. This is why the sieve may stop at the square root. |
| `candidate_prime_above` | For every n there is a prime above n ending in 1, 3, 7 or 9. So the 40% holds infinitely many primes. |
| `InfinitudeOfPrimes` | For every n there is a prime above n (Comparator Live's built-in challenge). |
| `density_factor` | 1 / 0.4 = 5/2, the source of the 2.5. |
| `prime_97`, `not_prime_91` | 97 is prime; 91 = 7 x 13 is not. |
| `candidateCount_100`, `candidateCount_1e10` | The counting formula gives 38 kept numbers at 100 and 3,999,999,998 at 10^10. |
| `record_digits`, `first_exponent_100M` | With a 40-digit value of log10 2: the record prime 2^136,279,841 - 1 has 41,024,320 digits, and 332,192,807 is the first exponent with 100 million digits. |

### Proof 1: why every prime above 5 ends in 1, 3, 7 or 9

The last digit of p is the remainder when p is divided by 10.

1. If p ended in 0, 2, 4, 6 or 8, then 2 would divide p. A prime is divisible only by 1 and itself, so p would have to be 2. But p > 5.
2. If p ended in 5, then 5 would divide p, so p would have to be 5. But p > 5.
3. So 2 does not divide p and 5 does not divide p. The only remainders mod 10 with that property are 1, 3, 7 and 9.

In Lean, steps 1 and 2 are the two `have` blocks, using `Nat.Prime.eq_one_or_self_of_dvd` (a prime's only divisors are 1 and itself). Step 3 is a single call to `omega`, Lean's decision procedure for whole-number arithmetic, which checks every remainder automatically.

### Proof 2: infinitely many primes, through the 40%

This is Euclid's argument, adapted so that the prime it produces lands in the 40%.

Fix any number n. Let

$$N = 10 \cdot (n+5)! + 1,$$

where (n + 5)! = 1 x 2 x 3 x ... x (n + 5). Let p be the smallest prime factor of N (it exists because N > 1).

1. **p is larger than n + 5.** Suppose not, so p is at most n + 5. Then p is one of the factors of (n + 5)!, so p divides 10 x (n + 5)!. It also divides N = 10 x (n + 5)! + 1. A number that divides both A and A + 1 divides their difference, which is 1. No prime divides 1. Contradiction.
2. **p ends in 1, 3, 7 or 9.** p is prime and p > n + 5 > 5, so Proof 1 applies.
3. So p is a prime above n in the 40%. Since n was arbitrary, there are infinitely many.

In Lean this is `candidate_prime_above`:

| Lean line | Meaning |
|--------------------------------------|----------------------------------------------|
| `Nat.factorial_pos` | (n + 5)! is positive, so N is not 1 |
| `Nat.minFac_prime` | the smallest factor of N is prime |
| `Nat.minFac_dvd` | that factor divides N |
| `by_contra` ... `Nat.dvd_factorial` | if p were at most n + 5, it would divide (n + 5)! |
| `Nat.dvd_add_right` ... `Nat.dvd_one` | then p would divide 1, which is impossible |
| `prime_ending _ hp` | so p ends in 1, 3, 7 or 9 |

`InfinitudeOfPrimes` then takes this p and shows it meets the challenge's definition `IsPrime p := 1 < p ∧ ∀ k, 1 < k → k < p → ¬ k ∣ p`: p > 1, and any divisor k of p is 1 or p, so no k strictly between 1 and p divides it.

The factor 10 is what ties the proof to this project. Euclid's classical version uses n! + 1. Here the prime's ending is guaranteed by `prime_ending`.

---

## What "verified by Lean" means

**Lean** is a programming language and proof assistant. A theorem in Lean is a precise statement plus a proof built from basic logical steps. The **Lean kernel**, a small trusted program, checks every step. If a single step is missing or wrong, the file does not compile. **Mathlib** is Lean's community library of mathematics, more than 200,000 checked definitions and theorems that proofs can build on.

**Comparator** is the Lean project's tool for judging a proof against a statement someone else wrote. It takes a *challenge* file (statements with `sorry` in place of proofs) and a *solution* file, and confirms three things for each named theorem:

1. the solution proves exactly the statement in the challenge (ESTABLISHED as Comparator's documented guarantee, per its [README](https://github.com/leanprover/comparator));
2. it uses no axioms beyond the standard three of Lean's logic (`propext`, `Quot.sound`, `Classical.choice`);
3. the Lean kernel accepts it.

Two runs were made on Comparator Live:

* **The built-in challenge "There Are Infinitely Many Primes"**: passed. Because the challenge is the site's own, its statement did not have to be trusted by us.

  ![Comparator Live: InfinitudeOfPrimes verified](docs/img/comparator-infinitude-success.png)

* **A local challenge, [`lean/Challenge.lean`](lean/Challenge.lean), with [`lean/config.json`](lean/config.json)**: passed for `prime_ending`, `removed_not_prime`, `smallest_factor_le_sqrt`, `density_factor`, `prime_97` and `not_prime_91`. `candidate_prime_above` was added to the challenge afterwards and is checked by the successful build of the whole solution, which compiles every proof in the file.

**What verification does and does not give.**

* It guarantees the proofs are correct. Nothing is assumed or skipped.
* It does not guarantee that a self-written challenge says what was intended. That is why the local challenge must be marked "trusted" by the person running it, and why the built-in challenge carries more weight.
* The `#eval` lines that print reports are computations, not proofs. Their results are checked separately, against primecount and sympy.

---

## What the code can do

### Python ([`python`](python))

| Script | What it does | Time |
|--------------------------------|--------------------------------------------|------|
| `steps/step1_density.py` | Trains the density model on x up to 400,000 and tests it to 10^13 | 1 s |
| `steps/step2_relative_change.py` | Per power of ten: kept, removed, density drop, prime growth | 1 s |
| `steps/step3_to_10_trillion.py` | Steps 1 and 2 to 10^13 with every count from primecount | 1 s |
| `steps/step4_endings.py` | Primes by ending up to 10^10, segmented sieve, checked against primecount | 1 min |
| `steps/step5_ending1_spacing.py` | Gaps between primes ending in 1 near 10^9 against Hardy-Littlewood | 4 s |
| `steps/step6_sieve_the_40.py` | Sieves the 40% prime by prime to 10^8 and confirms only primes remain | 2 s |
| `steps/step7_audit.py` | 13 checks of the code and results against independent ground truth | 5 s |
| `make_prime_tables.py` | Writes `data/primes_40pct_up_to_1e6.csv` and `data/breakdown_by_ending.csv` | 1 min |
| `extras/density_models.py` | Compares fitted models with li(x), Riemann's R(x) and up to 1,000 zeta-zero waves | 6 s |
| `extras/legendre_endings.py` | Refits Legendre's 1808 constant from density data; models the bias between endings | 5 s |
| `extras/primes_ml.py` | Density regression, a primality classifier, and gap statistics | 5 s |

Times were measured on an Apple-silicon Mac. Scripts that sieve to 10^9 need about 1 GB of memory.

### Lean ([`lean/Solution.lean`](lean/Solution.lean))

Set `rangeStart`, `rangeEnd` and `blocks` at the bottom of the file and evaluate it in a Lean editor. It prints, for the range:

* how many numbers are kept and removed, and how many primes there are;
* measured density against the model;
* smallest, largest and every gap between primes;
* counts by ending;
* estimates of the total number of primes up to the range's end, using the 2.5 formula and li(x);
* a table per block, and the primes themselves.

It works at any size:

* **up to about 4 x 10^12**: exact, by the sieve, for ranges up to 1,000,000 numbers wide;
* **above that**: the window is sieved by all primes up to 2,000,000 and the survivors are tested with Miller-Rabin. This is a proof of primality below 3.3 x 10^24 and gives "probable primes" above it. Ranges up to 200,000 numbers wide.

It also reports on the largest known prime, 2^136,279,841 - 1: its digit count, first and last digits, the next candidate exponents, and the Mersenne primes with exponent below 1,300 (by the Lucas-Lehmer test).

**What it cannot do:** predict which number is prime without testing it. No known method can. The code finds primes by sieving and testing; what it predicts accurately is how many there are.

---

## How to run it

```bash
git clone <this repository>
cd prime-endings
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
brew install primecount          # macOS; on Linux use your package manager
python3 python/steps/step7_audit.py
```

For the Lean file, paste [`lean/Solution.lean`](lean/Solution.lean) into [live.lean-lang.org](https://live.lean-lang.org) to see the reports, or into [Comparator Live](https://comparator.live.lean-lang.org) with [`lean/Challenge.lean`](lean/Challenge.lean) to check the proofs.

---

## Prior work

| Result here | Known as | Origin |
|------------------------------|--------------------------|----------------------------|
| Infinitely many primes | Euclid's theorem | Euclid, about 300 BC |
| Each ending holds about a quarter of the primes | Prime number theorem for arithmetic progressions | de la Vallée Poussin, 1896 |
| Endings 1 and 9 lag slightly behind 3 and 7 | Chebyshev's bias | Chebyshev, 1853; Rubinstein and Sarnak, 1994 |
| Density 2.5 / (ln x - 1) on the kept numbers | Prime number theorem, scaled by 10 / φ(10) | Hadamard and de la Vallée Poussin, 1896 |
| Consecutive primes avoid repeating their ending | Consecutive-prime bias | Lemke Oliver and Soundararajan, 2016 |
| Gaps divisible by 30 are favoured | Hardy-Littlewood singular series | Hardy and Littlewood, 1923 |
| Keep only endings 1, 3, 7, 9, then sieve | Wheel factorisation | Pritchard, *Communications of the ACM* 24 (1981) |
| The sieve product overshoots near the square root | Mertens' theorem | Mertens, 1874 |
| Counting without listing (primecount) | Meissel-Lehmer methods | Meissel, 1870; Lehmer, 1959 |

---

## Limits

* Counts above 10^10 by ending were not computed: primecount counts all primes, not primes by ending, and the sieve would take about 15 hours to reach 10^13.
* The Lean report's results above 3.3 x 10^24 are probable primes, as stated in its output.
* The Lean theorems `record_digits` and `first_exponent_100M` prove what the formula gives with a 40-digit value of log10 2; they match an independent high-precision calculation but are not a proof from first principles.
* Density "predictions" describe how many primes there are, not which numbers are prime.

## License

MIT. See [LICENSE](LICENSE).
