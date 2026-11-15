# Walkthrough: what was done, step by step

This document follows the project in the order it was carried out. Each step states the question, what was built, how to reproduce it, the result, and how the result was checked. Every number is copied from a file in [`results`](results) or from a recorded Lean run.

For the summary and the explanation of the proofs, see the [README](README.md).

---

## Step 0. The starting idea

**Question.** Which last digits can a prime have?

**Reasoning.** A number ending in 0, 2, 4, 6 or 8 is even, so 2 divides it. A number ending in 5 is divisible by 5. So apart from 2 and 5, every prime ends in 1, 3, 7 or 9.

**Consequence.** Keeping only the numbers above 5 that end in 1, 3, 7 or 9 keeps 40% of all numbers (4 endings out of 10) and loses no prime above 5. These kept numbers are called *candidates* below.

**Checked by.** A proof in Lean (`prime_ending`, Step L1) and a computer check of all 5,761,452 primes between 5 and 100 million (Step 7).

---

## Step 1. Can a model predict how density falls on the 40%?

**Built.** [`python/steps/step1_density.py`](python/steps/step1_density.py).

**What it does.**

1. Sieves every number up to 10^8 to get the true prime counts.
2. Counts candidates with the exact formula |C(x)| = 4⌊x/10⌋ + r − 2, where r is how many of 1, 3, 7, 9 are at most the last digit of x.
3. Fits the model density = a / (ln x − b) by least squares, using only 200 points between 1,000 and 400,000 (roughly the range of the prime tables Legendre had in 1808).
4. Tests the model up to 10^13, far outside the training range.

**Run.** `python3 python/steps/step1_density.py`

**Result.** The fitted model is 2.5694 / (ln x − 0.7918). The theory, with nothing fitted, is 2.5 / (ln x − 1), where 2.5 = 1 / 0.4.

| x | True share of candidates that are prime | Model error | Theory error |
|---|---:|---:|---:|
| 10^5 | 23.97% | −0.03% | −0.81% |
| 10^8 | 14.40% | +1.19% | −0.37% |
| 10^13 | 8.65% | +1.91% | −0.13% |

**Meaning.** The fall in density is predictable. A fitted model is best near its data; the theory is best far from it.

---

## Step 2. How does density change each time x grows ten-fold?

**Built.** [`python/steps/step2_relative_change.py`](python/steps/step2_relative_change.py).

**What it does.** For each power of ten it computes the relative drop in density, the growth factor of the prime count, and compares the drop with theory, ln 10 / (ln 10x − 1).

**Result.**

| Step | Drop | Growth of prime count | Measured / theory |
|---|---:|---:|---:|
| 10^4 to 10^5 | 21.82% | x 7.82 | 0.996 |
| 10^8 to 10^9 | 11.75% | x 8.83 | 1.006 |
| 10^12 to 10^13 | 7.98% | x 9.20 | 1.003 |

**Meaning.** The density drops by about 2.3 / ln x per power of ten, and the drop shrinks every time. Growth and drop are the same fact: growth = 10 x (1 − drop).

**Checked by.** The script re-counts primes to 10^8 with its own sieve and confirms they match the known table.

---

## Step 3. Does it hold up to 10 trillion?

**Built.** [`python/steps/step3_to_10_trillion.py`](python/steps/step3_to_10_trillion.py), using the program primecount, which counts primes without listing them.

**Result.** Up to 10^13 there are 3,999,999,999,998 candidates, of which 346,065,536,836 are prime (8.65%) and 3,653,934,463,162 are not (91.35%). The removed 60% (6,000,000,000,002 numbers) contains only the primes 2, 3 and 5.

**Checked by.** primecount agrees with the sieve at 10^6 and 10^8 before any other number is used.

---

## Step 4. Do the four endings behave the same?

**Built.** [`python/steps/step4_endings.py`](python/steps/step4_endings.py), a segmented sieve to 10^10 that counts primes by last digit.

**Result at 10^10.**

| Ending | Candidates | Prime | % prime |
|---|---:|---:|---:|
| 1 | 999,999,999 | 113,761,519 | 11.37615% |
| 3 | 999,999,999 | 113,765,624 | 11.37656% |
| 7 | 1,000,000,000 | 113,764,039 | 11.37640% |
| 9 | 1,000,000,000 | 113,761,326 | 11.37613% |

**Meaning.** Each ending holds almost exactly a quarter of the primes. Endings 1 and 9 sit very slightly below 3 and 7; this is Chebyshev's bias (1 and 9 are the last digits of squares).

**Checked by.** The four counts plus the primes 2 and 5 add up to primecount's total, 455,052,511, at 10^6, 10^8 and 10^10.

---

## Step 5. How are primes ending in 1 spaced?

**Built.** [`python/steps/step5_ending1_spacing.py`](python/steps/step5_ending1_spacing.py), for the 1,209,307 primes ending in 1 between 900 million and 1 billion.

**Result.**

* Mean gap 82.69; prediction 4 ln x = 82.69.
* Most common gap: 30 (14.37% of gaps).
* Gaps divisible by 30: 44.53%, against 29.02% under a pattern-free model.
* Pairs (p, p + 10) both prime: 103,368 counted, 102,995 predicted by the Hardy-Littlewood pair formula.

**Meaning.** If a gap is divisible by 3, the next number can never be a multiple of 3, so such gaps survive twice as often.

**Correction recorded.** An earlier version reported 43.9% because it divided gaps up to 300 by all gaps; it was fixed after an independent re-check.

---

## Step 6. Sieving the 40% down to the primes

**Built.** [`python/steps/step6_sieve_the_40.py`](python/steps/step6_sieve_the_40.py).

**What it does.** Starts from the candidates up to 10^8 and crosses out the odd multiples of 3, 7, 11, 13, ... (each from p x p), up to the last prime below 10,000.

**Result.**

| After removing multiples of | Numbers left | Prime share of what is left |
|---|---:|---:|
| (start) | 39,999,998 | 14.40% |
| 3 | 26,666,665 | 21.6% |
| 13 | 19,180,822 | 30.0% |
| 997 | 8,087,521 | 71.2% |
| every prime up to 9,973 | 5,761,452 | 100% |

**Meaning.** What is left is exactly the primes. Small primes each remove 1/p of what is left; the simple product formula overshoots at the end by 5.7% (Mertens' theorem).

---

## Step 7. Audit: is all of this code correct?

**Built.** [`python/steps/step7_audit.py`](python/steps/step7_audit.py), 13 checks in four stages:

1. the sieve against primecount, the candidate formula against brute force, the fitting code against data with a known answer;
2. the 40/60 split, including that the removed 60% holds exactly 2, 3 and 5;
3. the model against ground truth up to 10^13;
4. the sieve of the 40%, with the survivors compared to the prime set number by number.

**Result.** 13 of 13 checks pass ([`results/step7_audit.txt`](results/step7_audit.txt)).

---

## Step 8. Precision, recall, and bigger wheels

**Built.** [`python/steps/step8_precision_recall_wheels.py`](python/steps/step8_precision_recall_wheels.py).

**Definitions.**

* *Precision*: the share of candidates that are prime.
* *Recall*: the share of primes (above the wheel's own primes) that the filter keeps.
* *Wheel mod m*: keep only numbers sharing no factor with m. Mod 10 is the 40% filter; mod 30 also removes multiples of 3; mod 210 also 7; mod 2310 also 11.

**Result A: precision and recall, against every prime up to 10^8.**

| Wheel | Kept | Precision at 10^8 | Theory, boost / (ln x − 1) | Recall |
|---|---:|---:|---:|---:|
| mod 10 | 40.0% | 14.404% | 14.351% | 100% |
| mod 30 | 26.7% | 21.605% | 21.526% | 100% |
| mod 210 | 22.9% | 25.206% | 25.114% | 100% |
| mod 2310 | 20.8% | 27.727% | 27.625% | 100% |

The boost is m divided by the number of kept residues: 2.5, 3.75, 4.375 and 4.8125.

**Result B: speed of finding the 36,249 primes in [10^12, 10^12 + 10^6).**

| Filter | Numbers tested | Time | Speed-up |
|---|---:|---:|---:|
| none | 1,000,000 | 1.08 s | 1.00 |
| mod 10 | 400,000 | 0.97 s | 1.11 |
| mod 30 | 266,668 | 0.94 s | 1.15 |
| mod 2310 | 207,793 | 0.90 s | 1.19 |

**Meaning.** No wheel ever loses a prime. Testing 60% fewer numbers saves only about 10% of the time, because a primality test already rejects multiples of small primes almost instantly; the time goes on the numbers that pass those checks, which every wheel still tests. Wheels pay off far more inside a sieve, where they shrink the memory and crossing-out work directly. Times were measured once on an Apple-silicon Mac and will vary by machine.

**Checked by.** Every wheel returned exactly the same 36,249 primes as testing every number.

---

## Step 9. The same benchmark inside Lean, with pass/fail rules

**Question.** Can one run on Comparator Live check both the proofs and the benchmark?

**Built.** A `wheelBenchmark` section in [`lean/Solution.lean`](lean/Solution.lean), run by `#eval wheelBenchmark`.

**What it does.**

1. Builds the ground truth with `plainSieve`, a sieve over all numbers that uses no wheel, so it does not depend on the filter being tested.
2. For the wheels mod 10, 30, 210 and 2310 at x = 10^4, 10^5 and 10^6, counts candidates, primes among them, and all primes above the wheel's own primes.
3. Applies four rules fixed before running, and prints PASS or FAIL for each:

| Rule | Passes when |
|---|---|
| Recall | no prime above the wheel's own primes is missed, at every wheel and x |
| Falling precision | precision drops from 10^4 to 10^5 to 10^6 for every wheel |
| Model | precision is within 2% (relative) of boost / (ln x − 1) everywhere |
| Kept share | at 10^6 the kept share is within 0.1 points of φ(m) / m |

**How to know it passed.** Two separate signals, both needed:

* Comparator shows **Success**: every proof in the file compiled, and `InfinitudeOfPrimes` is certified.
* The output of `#eval wheelBenchmark` ends with **ALL 4 CHECKS PASSED**, and its numbers match the expected values below, computed independently in Python.

**Expected values (Python, numpy sieve).**

| Wheel | x | Candidates | Primes in them | Precision | Model | Missed |
|---|---:|---:|---:|---:|---:|---:|
| mod 10 | 10,000 | 3,998 | 1,226 | 30.665% | 30.449% | 0 |
| mod 10 | 1,000,000 | 399,998 | 78,495 | 19.624% | 19.508% | 0 |
| mod 30 | 10,000 | 2,665 | 1,226 | 46.004% | 45.674% | 0 |
| mod 30 | 1,000,000 | 266,665 | 78,495 | 29.436% | 29.261% | 0 |
| mod 210 | 1,000,000 | 228,570 | 78,494 | 34.341% | 34.138% | 0 |
| mod 2310 | 1,000,000 | 207,791 | 78,493 | 37.775% | 37.552% | 0 |

The largest model gap in the full Python table is 1.1% (relative), inside the 2% rule.

**Status.** The benchmark ran on Comparator Live in run 5 and printed ALL 4 CHECKS PASSED; every candidate and prime count equals the Python values above, and every precision agrees to six decimals. The run as a whole failed on an unrelated proof (`prime_mod30`), fixed for run 6.

---

## The Lean proofs, in the order they were built

File: [`lean/Solution.lean`](lean/Solution.lean). Challenge statements: [`lean/Challenge.lean`](lean/Challenge.lean). Checker settings: [`lean/config.json`](lean/config.json).

Status: stages L1 to L3 are ESTABLISHED (kernel-checked in runs 1, 2 and 4 of the run log below); stage L4 is PENDING until run 5.

| Stage | Added | What it proves |
|---|---|---|
| L1 | `prime_ending` | Every prime above 5 ends in 1, 3, 7 or 9 |
| L1 | `removed_not_prime` | No number above 5 ending in 0, 2, 4, 5, 6 or 8 is prime |
| L1 | `smallest_factor_le_sqrt` | A composite's smallest prime factor, squared, is at most the number |
| L1 | `density_factor`, `prime_97`, `not_prime_91` | 1 / 0.4 = 5/2; 97 is prime; 91 is not |
| L2 | `candidate_prime_above` | Infinitely many primes lie in the 40% (Euclid's argument with 10 · (n + 5)! + 1) |
| L2 | `InfinitudeOfPrimes` | Comparator Live's built-in challenge: infinitely many primes |
| L3 | `infinitely_many_ending` | Infinitely many primes end in each of 1, 3, 7 and 9 (Mathlib's Dirichlet theorem) |
| L3 | `survives_iff`, `mem_primesSpec` | Sieve correctness: the reference sieve lists exactly the primes up to x |
| L4 | `prime_mod30` | Every prime above 5 leaves remainder 1, 7, 11, 13, 17, 19, 23 or 29 mod 30 |

### Run log

| Run | Challenge | File | Outcome |
|---|---|---|---|
| 1 | Local challenge, 6 theorems | L1 version | Passed |
| 2 | Built-in "There Are Infinitely Many Primes" | L2 version | Passed |
| 3 | Built-in "There Are Infinitely Many Primes" | L3 version, first try | Failed: a documentation comment placed before an `#eval` line (not a proof error) |
| 4 | Built-in "There Are Infinitely Many Primes" | L3 version, fixed (SHA-256 57b52a1d...) | Passed; the `#eval` cross-check printed `true` |
| 5 | Built-in "There Are Infinitely Many Primes" | L4 version, adds `prime_mod30` and `wheelBenchmark` | Failed: the last step of `prime_mod30` (`omega` cannot combine "not divisible by 2, 3, 5" into the 8 remainders mod 30; Lean's `omega` is incomplete for this). The benchmark ran in the same run: ALL 4 CHECKS PASSED, every count equal to the Python values |
| 6 | Built-in "There Are Infinitely Many Primes" | L4 fixed: `prime_mod30` splits into the 30 possible remainders; the fix was compiled first with a local Lean 4.35 | **Not yet run** |

All runs used Comparator Live with Lean v4.36 and the latest Mathlib. A pass against the built-in challenge also means the whole file compiled, so every proof in it was checked by the Lean kernel; Comparator's certificate itself names only `InfinitudeOfPrimes`. Running the local challenge would add all 11 theorems to the certificate.

---

## What is still open

* The fixed `prime_mod30` must be run on Comparator (run 6).
* The fast array sieve used for reports is compared with the proved reference sieve by computation (up to 3,000), not by proof.
* The 2.5 / (ln x − 1) share is measured and matches the prime number theorem but is not proved in Lean.
* Lean's reports above 3.317 x 10^24 list probable primes (Miller-Rabin bound of Sorenson and Webster, 2017).
