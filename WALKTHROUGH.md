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

## Step 10. Count, filter and find the multiples at x = 10^29

**Question.** Take x = 100,000,000,000,000,000,000,000,000,000 (10^29). How many numbers are kept and removed, how many are prime, and which primes' multiples make up the rest?

**Built.** [`python/steps/step10_one_hundred_octillion.py`](python/steps/step10_one_hundred_octillion.py). Counting, filtering and multiples are exact whole-number arithmetic. The prime count P(10^29) = 1,520,698,109,714,272,166,094,258,063 is quoted from published tables ([OEIS A006880](https://oeis.org/A006880); primecount records, Baugh and Walisch, 2022), because computing it here would take days.

**How the multiples are counted without listing them.** A multiple of p in the 40% is p x m where m itself ends in 1, 3, 7 or 9, so their number is the count of such m up to x / p. "Caught first by p" (p is the smallest prime factor) is counted by inclusion-exclusion over the smaller primes.

**Checked by.** The same formulas run at 10^6 and are compared with a real sieve: PASS.

**Result.**

| Step | Count | Share |
|---|---:|---:|
| All numbers | 100,000,000,000,000,000,000,000,000,000 | 100% |
| Removed (60%) | 60,000,000,000,000,000,000,000,000,002 | 60% |
| Kept (40%) | 39,999,999,999,999,999,999,999,999,998 | 40% |
| Primes in the 40% | 1,520,698,109,714,272,166,094,258,060 | 3.80% of the 40% |
| Non-primes in the 40% | 38,479,301,890,285,727,833,905,741,938 | 96.20% of the 40% |

| Prime p | Multiples of p in the 40% | Non-primes caught first by p | Share of non-primes |
|---|---:|---:|---:|
| 3 | 13,333,333,333,333,333,333,333,333,333 | 13,333,333,333,333,333,333,333,333,333 | 34.65% |
| 7 | 5,714,285,714,285,714,285,714,285,713 | 3,809,523,809,523,809,523,809,523,808 | 9.90% |
| 11 | 3,636,363,636,363,636,363,636,363,635 | 2,077,922,077,922,077,922,077,922,077 | 5.40% |
| 13 | 3,076,923,076,923,076,923,076,923,076 | 1,598,401,598,401,598,401,598,401,597 | 4.15% |
| 3 to 31 together | | 24,714,784,861,101,396,232,412,567,843 | 64.23% |
| primes above 31 | | 13,764,517,029,184,331,601,493,174,095 | 35.77% |

A full sieve would need every prime up to the square root of 10^29 (316,227,766,016,837): 9,773,865,306,519 of them, leaving out 2 and 5 (counted by primecount). The estimate li(x) is off by 3 x 10^-13 %; the simple 2.5 / (ln x - 1) formula by -0.024%.

---

## Tables: the multiples of 3 and 7

**Built.** `python/tables/multiples.py`, producing the tables as a PDF and the grids as CSV files (kept in the private companion repository since 18 November 2026).

For each prime, the first 111 multiples in rows of 10, then a 33 x 33 grid of the first 1,089 multiples. Amber cells are inside the 40% and crossed out first by that prime in the sieve; grey cells are inside the 40% but were already crossed out by 3.

| Table | Multiples | Crossed out first by this prime | Already removed by 3 |
|---|---:|---:|---:|
| 3, up to 333 | 111 | 44 | 0 |
| 3, 33 x 33 (to 3,267) | 1,089 | 435 | 0 |
| 7, up to 777 | 111 | 29 | 15 |
| 7, 33 x 33 (to 7,623) | 1,089 | 289 | 146 |

In every row of 10 multiples, 4 land in the 40% (p x k ends in 1, 3, 7 or 9 exactly when k does). For 7, about one third of those are also multiples of 3, so 7 is left with the other two thirds: the 1/7 x 2/3 share seen in step 10.

## Step 11. The full method, from the 60/40 split to the square-root rule, worked for 3 and 7

**Question.** After throwing away 60% and keeping 40%, what exactly is needed to finish the job, and how far do the primes 3 and 7 alone get?

**Built.** [`python/steps/step11_three_and_seven.py`](python/steps/step11_three_and_seven.py). Every formula below is checked against a real sieve for every x from 1 to 100,000 ([`results/step11_three_and_seven.txt`](results/step11_three_and_seven.txt)): PASS.

### The method in four steps

**Step A. Throw away 60%.** Remove every number ending in 0, 2, 4, 5, 6 or 8 (multiples of 2 or 5), and 1 and 3. No prime above 5 is lost (`prime_ending`, proved in Lean).

**Step B. Count what is kept.** Let N(y) be how many of 1, ..., y end in 1, 3, 7 or 9:

    N(y) = y − ⌊y/2⌋ − ⌊y/5⌋ + ⌊y/10⌋

The kept 40% up to x (numbers above 5) is

    C(x) = N(x) − 2        (the 2 removes the numbers 1 and 3)

which equals the earlier formula 4⌊x/10⌋ + r − 2.

**Step C. The square-root rule: which primes are needed.** To leave only primes up to x, cross out the multiples of every prime p with p x p ≤ x, that is, every prime up to √x, except 2 and 5 (already gone in step A).

*Why it is enough.* If n ≤ x is not prime, write n = a x b with a ≤ b. Then a x a ≤ a x b = n ≤ x, so a ≤ √x, and the smallest prime factor of n is at most a. So some prime up to √x divides n and crosses it out (`smallest_factor_le_sqrt`, proved in Lean).

*Why nothing smaller works.* The number p x p is not prime, and its only prime factor is p. Leave p out and p x p survives. So each prime p is needed from p x p on: 3 from 9, 7 from 49, 11 from 121, 13 from 169.

**Step D. Cross out, starting at p x p.** Multiples of p below p x p have a smaller factor, which has already crossed them out. The prime p itself is never crossed out.

### Worked for 3 and 7

The multiples of a number d that end in 1, 3, 7 or 9 are d x m with m ending in 1, 3, 7 or 9 (because d does). So up to x there are N(⌊x/d⌋) of them, d itself included. By inclusion-exclusion, 3 and 7 together cross out

    R(x) = N(⌊x/3⌋) + N(⌊x/7⌋) − N(⌊x/21⌋) − 2        (x ≥ 7)

The − N(⌊x/21⌋) stops multiples of both (21, 63, 147, ...) from being counted twice; the − 2 takes out 3 and 7 themselves, which are primes. What is left is

    L(x) = C(x) − R(x)

**Worked example, x = 100.**

| Quantity | Formula | Value |
|---|---|---:|
| Numbers ending in 1, 3, 7, 9 | N(100) = 100 − 50 − 20 + 10 | 40 |
| Kept 40% | C(100) = 40 − 2 | 38 |
| Multiples of 3 in it (with 3) | N(33) = 33 − 16 − 6 + 3 | 14 |
| Multiples of 7 in it (with 7) | N(14) = 14 − 7 − 2 + 1 | 6 |
| Multiples of 21 in it | N(4) = 4 − 2 − 0 + 0 | 2 |
| Crossed out | R(100) = 14 + 6 − 2 − 2 | 16 |
| **Left** | L(100) = 38 − 16 | **22** |

The 22 left are exactly the primes from 7 to 97.

### The rule for 3 and 7

**3 and 7 alone leave exactly the primes for every x up to 120.** The first failure is 121 = 11 x 11: 11 x 11 = 121 is the first number above 7 x 7 whose smallest prime factor is above 7.

| x | Kept C(x) | Crossed out R(x) | Left L(x) | Primes above 5 | Non-primes left |
|---:|---:|---:|---:|---:|---:|
| 100 | 38 | 16 | 22 | 22 | 0 |
| 120 | 46 | 19 | 27 | 27 | 0 |
| 121 | 47 | 19 | 28 | 27 | 1 (121) |
| 169 | 66 | 27 | 39 | 36 | 3 (121, 143, 169) |
| 1,000 | 398 | 170 | 228 | 165 | 63 |
| 100,000 | 39,998 | 17,141 | 22,857 | 9,589 | 13,268 |

The non-primes that survive 3 and 7 are 121, 143, 169, 187, 209, 221, 247, 253, 289, ...: every one is a product of primes 11 or larger.

**The long-run share after 3 and 7.** Each prime p removes 1 in p of what is left, so the share of all numbers left after 2, 5, 3 and 7 tends to

    (1 − 1/2)(1 − 1/5)(1 − 1/3)(1 − 1/7) = 4/10 x 2/3 x 6/7 = 8/35 = 22.857%

which is exactly what the table reaches at 100,000. It is the mod-210 wheel of step 8: 48 numbers kept in every 210.

### The rule for any x

1. Keep the 40%: C(x) numbers.
2. List the primes p with 3 ≤ p ≤ √x, p ≠ 5. There are P(√x) − 2 of them.
3. For each, cross out its multiples in the 40% from p x p upwards.
4. What is left is exactly the primes from 7 to x; add 2, 3 and 5.

New primes join only at prime squares (9, 49, 121, 169, 289, 361, 529, 841, 961, ...); between two of them the list does not change. Each prime p first catches p x p, then p times the next numbers with no factor below p: 11 x 11, 11 x 13, 11 x 17, 11 x 19, ...

---

## Step 12. Mapping the findings onto the zeta function

**Built.** [`python/steps/step12_zeta_map.py`](python/steps/step12_zeta_map.py) ([output](results/step12_zeta_map.txt)).

The zeta function takes a number s and returns ζ(s) = 1 + 1/2^s + 1/3^s + ... Euler showed it equals a product over all primes, ζ(s) = ∏ 1/(1 − 1/p^s). Each step of this project is one piece of that product, at a particular s.

| Finding in this project | Zeta-function counterpart | s | Checked value |
|---|---|---|---|
| Throw away multiples of 2 and 5, keep 40% | multiply by (1 − 2^−s)(1 − 5^−s) | 1 | 1/2 x 4/5 = 0.4 |
| The 40% as a sum | ζ₄₀(s) = Σ 1/n^s over n ending in 1, 3, 7, 9 = ζ(s)(1 − 2^−s)(1 − 5^−s) | 2 | 1.18435252813072 both ways (ζ(2) = π²/6) |
| Sieving by each prime p removes 1/p of what is left | the Euler factor (1 − 1/p) at s = 1 | 1 | product to 9,973 = 0.0608847 vs e^−γ / ln 9,973 = 0.0609776 (Mertens) |
| Endings 1 and 9 lag behind 3 and 7 (Chebyshev's bias) | the L-function of χ = +1 on endings 1, 9 and −1 on 3, 7 | 1 | L(1, χ) = 0.645613411446006 = (3/2) x 2 ln φ / √5 |
| The wobble of P(x) around li(x) (steps with zeta-zero waves) | zeros ρ = 1/2 + iγ, one wave each | 1/2 + iγ | γ₁ = 14.1347251417, |ζ| below 10^−25 |

**What number to enter.**

* s = 1: the density of primes. ζ has a pole there (the harmonic series diverges), which is why there are infinitely many primes and why density falls like 1/ln x.
* s = 2: the clean, convergent version. ζ(2) = π²/6, and the 40% version is π²/6 x 3/4 x 24/25.
* s = 1/2 + iγ at the zeros (14.1347..., 21.0220..., 25.0109...): these control the error in counting primes. The Riemann hypothesis says every non-trivial zero has real part 1/2.

---

## Step 13. Simple zeta workings, and finding the zeros ourselves

**Built.** [`python/steps/step13_find_zeros.py`](python/steps/step13_find_zeros.py) ([output](results/step13_find_zeros.txt)).

**s = 1, one prime at a time.** Each Euler factor (1 − 1/p) is the share a wheel keeps: x 1/2 gives 50%, x 4/5 gives 40% (the 40% filter), x 2/3 gives 26.67% (mod 30), x 6/7 gives 22.86% (mod 210), x 10/11 gives 20.78% (mod 2310). These are exactly the kept shares measured in step 8.

**s = 2, one multiplication at a time.** ζ(2) = 1 + 1/4 + 1/9 + ... = π²/6 = 1.64493406685. Dropping the even numbers multiplies by 3/4 (1.23370055014); dropping the multiples of 5 multiplies by 24/25 (1.18435252813). That is the sum of 1/n² over the numbers ending in 1, 3, 7, 9 (here the number 1 is included, and 3 counts as ending in 3).

**Finding the zeros.** Hardy's function Z(t) is real and |Z(t)| = |ζ(1/2 + it)|, so every sign change of Z is a zero on the critical line. Scanning t from 1 to 300 in steps of 0.02 and refining each sign change found 138 zeros. The exact number of zeros up to 300, counted independently by the argument principle, is 138, so none were missed (the Riemann-von Mangoldt formula estimates 137.7). Every 10th zero agrees with `mpmath.zetazero` to 2 x 10^−19. The closest pair below 300 is 0.608 apart; the average gap near 300 is 1.625.

**Scaling up.** Large computations use the same idea with faster evaluation of Z (the Riemann-Siegel formula, and the Odlyzko-Schönhage algorithm for many points at once) and a count check (Turing's method) to prove no zero was skipped. All zeros up to height 3 x 10^12 have been verified to lie on the critical line (Platt and Trudgian, 2021). There are infinitely many zeros, so they can never all be listed; the Riemann hypothesis is the statement that every one of them has real part 1/2.

---

## Step 14. The window proof, and the two papers

**What was asked.** Fix the errors found in the two short PDFs, rewrite them as journal papers with no names, and prove the items in "what the proofs do not establish" where possible.

**Step 1: what could be proved now.** Of the four open items, only the window sieve (a > 1) can be proved with what Mathlib has today. The density formulas need the prime number theorem, which is not in Mathlib. The fast array code cannot be reasoned about until its `while` loops are rewritten. `#eval` outputs are computations, not statements.

**Step 2: the window proof in Lean.** Three new theorems in [`lean/Solution.lean`](lean/Solution.lean):
1. `mul_coprime_ten`: multiplying by a number that ends in 1, 3, 7 or 9 keeps you inside the 40% exactly when the multiplier is inside it.
2. `multiplier_range`: the program's start and stop values, `max(p, (a + p − 1) / p)` and `b / p`, are exactly "p ≤ k and a ≤ p × k ≤ b".
3. `window_sieve`: in any window [a, b], the numbers that end in 1, 3, 7 or 9, are above 5 and are not crossed out are exactly the primes in [max(a, 6), b].

Result: compiled with 0 errors against Mathlib (Lean 4.34, Mathlib commit 818f61d), using only Lean's three standard axioms. `Challenge.lean` and `config.json` now name 19 theorems. Status: ESTABLISHED, locally and on Comparator Live (run 9, 18 November 2026).

**Step 3: corrections carried into the papers.**
* The counting formula (Legendre on the 40%) needs x ≥ 25. Below 25 it is right only at x = 4 (checked for every x from 2 to 3,000).
* The Mertens product overshoots the true prime share by 5.6% at 9,973² (ratio 1.05645), not 5.7%.
* L(1, χ) ≠ 0 gives infinitely many primes per ending and equal shares in the Dirichlet-density sense; the plain "a quarter each up to x" needs the prime number theorem for progressions.
* The ending counts up to 10^7 are for primes above 5.
* Unchecked figures (the "67 to 10" error, the prize amount) were removed rather than kept.

**Step 4: the papers.** [`papers/`](papers) holds two papers in AMS journal format (XeLaTeX, STIX Two fonts), (on 18 November 2026 the "Anonymous" author line was replaced by the repository link at the foot of every page, and an AI-use statement citing Claude Opus 5.5 was added), with a shared bibliography of 16 references, each checked against Crossref. [`papers/verify_numbers.py`](papers/verify_numbers.py) recomputes every number in both papers: 29 of 29 checks pass ([`results/papers_verify_numbers.txt`](results/papers_verify_numbers.txt)).

**Step 5: license and citation.** Code stays MIT. The papers are CC BY 4.0, which requires credit on reuse. [`CITATION.cff`](CITATION.cff) adds GitHub's "Cite this repository" button.

## Step 15. Running our method itself to 10^10

**What was asked.** Was our model actually tested: the method (strip the 60%, keep 1, 3, 7, 9, cross out multiples up to √x) and its derived prediction 2.5 / (ln x − 1)?

**What had been tested before.** The method was run end to end only up to 10^8 (step 6, checked number by number) and on windows. Above 10^8 the true counts came from primecount and from a standard sieve, not from our method.

**What was done.** [`python/steps/step14_method_to_1e10.py`](python/steps/step14_method_to_1e10.py) runs exactly our three steps in blocks of 10^8 up to 10^10. For each prime p from 3 to 100,000 (not 5) it crosses out p × k for k ≥ p ending in 1, 3, 7 or 9, starting each block at max(p, ⌈lo / p⌉), the rule proved in Lean as `window_sieve`.

**Result** ([`results/step14_method_to_1e10.txt`](results/step14_method_to_1e10.txt), 55 seconds):

| x | Survivors + 2, 3, 5 | primecount | Equal | Share | Prediction | Error |
|---|---:|---:|:---:|---:|---:|---:|
| 10^8 | 5,761,455 | 5,761,455 | yes | 14.4036% | 14.3508% | −0.37% |
| 10^9 | 50,847,534 | 50,847,534 | yes | 12.7119% | 12.6754% | −0.29% |
| 10^10 | 455,052,511 | 455,052,511 | yes | 11.3763% | 11.3503% | −0.23% |

Status: ESTABLISHED by this run. The method gives the exact prime count at every checkpoint, and the prediction is within 0.4%, improving with x.

Also added to paper 1 (section 4.5, "A complete run to 10^10").

## Step 16. The method on a 42,000-digit number

**What was asked.** For a number with tens of thousands of digits, how can the 60% be stripped, and how can the multiples be found and counted?

**What was done.** [`python/steps/step16_huge_numbers.py`](python/steps/step16_huge_numbers.py) takes the window of 100,000 numbers starting at a = 10^41999, which has exactly 42,000 digits ([`results/step16_huge_numbers.txt`](results/step16_huge_numbers.txt), 1.3 seconds).

1. **Strip the 60%:** by the last digit only. 40,000 of the 100,000 numbers are kept.
2. **Count the multiples of p without listing them:** the multiples of p that end in 1, 3, 7, 9 in [a, b] are p × k with k from ⌈a/p⌉ to ⌊b/p⌋ and k ending in 1, 3, 7, 9, so their number is K(⌊b/p⌋) − K(⌈a/p⌉ − 1), with K(y) = 4⌊y/10⌋ + (how many of 1, 3, 7, 9 are ≤ the last digit of y). One division per prime. Checked against crossing them out one by one: 13,332 for p = 3, 5,715 for p = 7, 3,637 for p = 11, 40 for p = 997, 0 for p = 999,983. All equal.
3. **Cross out the multiples of every prime up to 1,000,000** (78,496 primes). 4,094 numbers survive; the product rule estimated 4,064.
4. **What this cannot do:** a full sieve needs every prime up to √a, a 21,000-digit number; there are far too many of them to list. The window is expected to hold about 100,000 / ln a = 100,000 / 96,709 ≈ 1 prime, so about 1 survivor in 4,000 is prime. The survivors must each be checked with a primality test (Miller-Rabin, as in the Lean report).

Status: ESTABLISHED by this run for steps 1 to 3; step 4 is the known limit of sieving.

Also added to paper 1 (sections 4.3 and 4.4: the counting formula and the 42,000-digit window); [`papers/verify_numbers.py`](papers/verify_numbers.py) now re-checks these numbers too (34 of 34 checks pass).

## Step 17. Can the primes we already know cross out all the numbers to come?

**What was asked.** For arbitrarily long numbers, do the primes we already know cross out every non-prime to come, and can that be proved?

**The answer, in two parts, both proved in Lean** (compiled locally with no errors, only the standard axioms, and passed on Comparator Live as run 10 on 18 November 2026):

1. **The sieve finds each prime before it needs it** (`known_primes_reach`, `bootstrap`). Knowing the primes up to Y settles every number up to Y × Y. A prime p is discovered at p and first needed at p × p, which is always later. So the sieve, run upwards from 1, never runs out: 11 is found at 11 and starts working at 121; 13 is found at 13 and starts at 169. Each round of known primes covers about twice as many digits as the last.
2. **But a fixed list is never enough** (`known_primes_not_enough`). If the list stops at some prime, the square of the next prime gets through as a fake prime. Stop at 11, and 169 = 13 × 13 survives.

**What it means for huge numbers.** Nothing in the logic breaks at any size. What breaks is the work: to sieve a window of 42,000-digit numbers completely, the sieve must first have found every prime up to a 21,000-digit number, and there are far too many to list. That is why huge windows are pre-sieved with the small primes and the survivors are tested one by one (step 16).

## Step 18. Putting the tested counts into Lean

**What was asked.** Include in the Lean file whatever had only been tested, so that Lean checks it.

**What was added** (38 theorems in total, all compiling locally with only the standard axioms; Comparator run pending):
1. **`survivor_count`:** for every x ≥ 5, survivors + 3 = π(x), where π is Mathlib's own prime-counting function. The run to 10^10 had checked this at three points; Lean now proves it for every x.
2. **Exact values computed by Lean's own checker:** π(100) = 25, π(1,000) = 168, π(10,000) = 1,229. The checker counts the survivors itself (22, 165 and 1,226) using `SurvivesBelow`, the same rule with divisors tested only below a bound, proved equivalent to the original rule (`survivesBelow_iff`). The count to 10,000 takes about 1.5 minutes.
3. **Kept-number counts:** 398 up to 1,000 and 3,998 up to 10,000.

**What cannot be added, and why.**
* **The counts at 10^8, 10^9, 10^10:** Lean's checker would have to count that far itself, which is far too slow; the shortcut `native_decide` adds an axiom Comparator does not allow. The rule "count = π(x)" is proved for all x; the three values themselves remain computed (Python run of the method, and primecount).
* **The density 2.5 / (ln x − 1):** needs the prime number theorem, not yet in Mathlib.

## Interactive multiples grid

**Built.** `web/multiples-grid.html`, a single file that works offline, from the module `web/multiples-grid.snippet.html` (both kept in the private companion repository since 18 November 2026). The same module is added as a "Multiples grid" tab to the Prime Pyramid page in `~/Primes` (open it directly with `#multiples` at the end of the address).

**What it does.**

* A grid with adjustable rows (up to 60), columns (up to 40) and starting number.
* Any set of numbers whose multiples are coloured, each with its own colour; shared multiples are striped. Presets: 3 and 7; 2, 3, 5, 7; and "Sieve primes" (every prime up to the square root of the last number).
* Two modes: every multiple, or sieve mode, where each number is coloured only by the smallest number that crosses it out (starting at that number squared), so the uncoloured cells are the primes.
* Play, Step, Reset and Show all, with a speed control; multiples appear one at a time. With the system's reduced-motion setting, they appear without animation.
* Non-primes that no chosen number divides get a dashed outline, and a warning lists them with their factors (for 3 and 7 on 1 to 200: 121 = 11 x 11, 143 = 11 x 13, 169 = 13 x 13, 187 = 11 x 17) and the primes to add. This is the square-root rule: 3 and 7 cover the 40% only up to 120; from 121 = 11 x 11 the prime 11 is needed, and from 169 the prime 13.
* A switch, "Colour only multiples inside the 40%", limits the colouring, the play sequence and the "caught first" counts to multiples ending in 1, 3, 7 or 9.
* Clicking a number shows its factors, whether it is in the 40%, and what caught it; double-clicking adds it as a divisor. A table counts the multiples, those in the 40%, and those caught first.

**Checked by.** Headless Chrome screenshots of the default view, a sieve run, and a phone-width view; a sieve run on 1 to 100 leaves exactly the primes uncoloured and reports 91 = 7 x 13 caught first by 7; no JavaScript errors in the page console.

---

## The Lean proofs, in the order they were built

File: [`lean/Solution.lean`](lean/Solution.lean). Challenge statements: [`lean/Challenge.lean`](lean/Challenge.lean). Checker settings: [`lean/config.json`](lean/config.json).

Status: stages L1 to L6 are ESTABLISHED on Comparator Live (runs 1, 2, 4, 8 and 9 of the run log below; run 9 on 18 November 2026 compiled all 27 theorems, including the window theorems). Stage L7 is ESTABLISHED on Comparator Live too (run 10, all 30 theorems). Stage L8 compiles with no errors locally (ESTABLISHED locally); its Comparator run is PENDING.

| Stage | Added | What it proves |
|---|---|---|
| L1 | `prime_ending` | Every prime above 5 ends in 1, 3, 7 or 9 |
| L1 | `removed_not_prime` | No number above 5 ending in 0, 2, 4, 5, 6 or 8 is prime |
| L1 | `smallest_factor_le_sqrt` | A composite's smallest prime factor, squared, is at most the number |
| L1 | `density_factor`, `prime_97`, `not_prime_91` | 1 / 0.4 = 5/2; 97 is prime; 91 is not |
| L1 | `candidateCount_100`, `candidateCount_1e10` | The candidate-count formula gives 38 at 100 and 3,999,999,998 at 10^10 |
| L1 | `record_digits`, `first_exponent_100M` | With a 40-digit log10 2: the record prime has 41,024,320 digits; 332,192,807 is the first exponent with 100 million digits |
| L2 | `candidate_prime_above` | Infinitely many primes lie in the 40% (Euclid's argument with 10 · (n + 5)! + 1) |
| L2 | `InfinitudeOfPrimes` | Comparator Live's built-in challenge: infinitely many primes |
| L3 | `infinitely_many_ending` | Infinitely many primes end in each of 1, 3, 7 and 9 (Mathlib's Dirichlet theorem) |
| L3 | `survives_iff`, `mem_primesSpec` | Sieve correctness: the reference sieve lists exactly the primes up to x |
| L4 | `prime_mod30` | Every prime above 5 leaves remainder 1, 7, 11, 13, 17, 19, 23 or 29 mod 30 |
| L5 | `sqrt_rule` | If 1 < n ≤ x and no prime p with p x p ≤ x divides n, then n is prime: sieving by the primes up to √x is enough |
| L5 | `square_not_prime`, `square_needs_p` | p x p is never prime and its only prime factor is p: leave p out and p x p survives, so every prime is needed from its square on |
| L5 | `three_seven_enough` | Every n with 5 < n ≤ 120 ending in 1, 3, 7 or 9 and not a multiple of 3 or 7 (other than 7) is prime |
| L5 | `three_seven_fails_at_121` | 121 ends in 1, is not a multiple of 3 or 7, and is not prime: 120 is the limit for 3 and 7 |
| L5 | `left37_100`, `left37_120`, `left37_121` | The step-11 counting formula gives 22, 27 and 28 left after 3 and 7 |
| L6 | `mul_coprime_ten` | If p ends in 1, 3, 7 or 9, then p × k ends in one of them exactly when k does: multiples of p inside the 40% are p × (numbers ending in 1, 3, 7, 9) |
| L6 | `multiplier_range` | Starting at k = max(p, ⌈a/p⌉) and stopping at ⌊b/p⌋ is exactly the same as asking p ≤ k and a ≤ p × k ≤ b |
| L6 | `window_sieve` | The sieve on any window [a, b]: a number in the window that ends in 1, 3, 7 or 9, is above 5, and is not crossed out, is prime; and every prime in [max(a, 6), b] survives |
| L7 | `known_primes_reach` | If every prime up to Y is known, any number below (Y + 1)² that none of them divides is prime |
| L7 | `bootstrap` | The primes up to Y determine all primes up to Y × Y: each prime is found before it is needed |
| L7 | `known_primes_not_enough` | No fixed, finite list of primes crosses out every non-prime: the square of the next prime always gets through |
| L8 | `survivor_count` | For every x ≥ 5, the survivors of the method plus 2, 3, 5 number exactly π(x) |
| L8 | `prime_count_100`, `prime_count_1000`, `prime_count_10000` | Lean's kernel runs the method: π(100) = 25, π(1,000) = 168, π(10,000) = 1,229 |
| L8 | `survivesBelow_iff`, `filter_survivesBelow`, `candidateCount_1000`, `candidateCount_10000` | The faster equivalent survival rule used for those counts; 398 and 3,998 kept numbers |

<a id="run-log"></a>

### Run log

| Run | Challenge | File | Outcome |
|---|---|---|---|
| 1 | Local challenge, 6 theorems | L1 version | Passed |
| 2 | Built-in "There Are Infinitely Many Primes" | L2 version | Passed |
| 3 | Built-in "There Are Infinitely Many Primes" | L3 version, first try | Failed: a documentation comment placed before an `#eval` line (not a proof error) |
| 4 | Built-in "There Are Infinitely Many Primes" | L3 version, fixed (SHA-256 57b52a1d...) | Passed; the `#eval` cross-check printed `true` |
| 5 | Built-in "There Are Infinitely Many Primes" | L4 version, adds `prime_mod30` and `wheelBenchmark` | Failed: the last step of `prime_mod30` (`omega` cannot combine "not divisible by 2, 3, 5" into the 8 remainders mod 30; Lean's `omega` is incomplete for this). The benchmark ran in the same run: ALL 4 CHECKS PASSED, every count equal to the Python values |
| 6 | Built-in "There Are Infinitely Many Primes" | L4 fixed: `prime_mod30` splits into the 30 possible remainders; the fix was compiled first with a local Lean 4.35 | Covered by run 8 |
| local | (compile only) | L5 version: full `Solution.lean` and `Challenge.lean` (16 theorems) compiled against Mathlib (build files from `lake exe cache get`, Lean 4.34) | No errors; cross-check `true`; benchmark ALL 4 CHECKS PASSED |
| 7 | Built-in "There Are Infinitely Many Primes" | L5 version | Covered by run 8 |
| 8 | Built-in "There Are Infinitely Many Primes" | [`lean/SolutionProofsOnly.lean`](lean/SolutionProofsOnly.lean) (SHA-256 886b839d...): all 24 theorems up to step 11, with the `#eval` lines switched off; does not yet contain the three window theorems | **Passed**, 18 November 2026 (Lean v4.36, latest Mathlib). Every proof in the file compiled, including the fixed `prime_mod30` |
| 9 | Built-in "There Are Infinitely Many Primes" | Updated [`lean/SolutionProofsOnly.lean`](lean/SolutionProofsOnly.lean): all 27 theorems, including `mul_coprime_ten`, `multiplier_range` and `window_sieve` | **Passed**, 18 November 2026 (Lean v4.36, latest Mathlib). Every proof in the file compiled |
| 10 | Built-in "There Are Infinitely Many Primes" | [`lean/runs/run10_SolutionProofsOnly_30_theorems.lean`](lean/runs/run10_SolutionProofsOnly_30_theorems.lean) (SHA-256 050ccaf2...): all 30 theorems, adding `known_primes_reach`, `bootstrap`, `known_primes_not_enough` | **Passed**, 18 November 2026 (Lean v4.36, latest Mathlib) |
| local | (compile only) | L8 version: adds the exact-count theorems; 38 theorems, `Challenge.lean` and `config.json` list 26 | No errors; only the standard axioms. Comparator run **PENDING** (the kernel count to 10,000 takes about 1.5 minutes) |
| local | (compile only) | L7 version: adds `known_primes_reach`, `bootstrap`, `known_primes_not_enough`; 30 theorems, `Challenge.lean` and `config.json` list 22 | No errors; only the standard axioms. Then passed on Comparator as run 10 |
| local | (compile only) | L6 version: adds the window theorems; `Challenge.lean` and `config.json` now list 19 theorems | No errors; `#print axioms window_sieve` shows only `propext`, `Classical.choice`, `Quot.sound` |

All runs used Comparator Live with Lean v4.36 and the latest Mathlib. A pass against the built-in challenge certifies `InfinitudeOfPrimes` by name and shows that the whole file compiled with no errors. It does not by itself rule out a `sorry` or an extra `axiom` in another theorem (those compile with a warning), so that is checked separately by [`lean/check_axioms.sh`](lean/check_axioms.sh): no `sorry`, no `axiom` declaration, and all 38 theorems depend only on the standard axioms ([output](results/lean_axioms.txt), 18 November 2026). The site's challenge, the results and the printed axioms are collected in [lean/site-challenge](lean/site-challenge/README.md).

---

## What is still open

* The fast array sieve used for reports is compared with the proved reference sieve by computation (up to 3,000), not by proof. Route: rewrite its loops without `while`, prove a loop invariant.
* The counting formula (Legendre on the 40%) is checked by computation only; it holds for every x ≥ 25 and, below 25, only at x = 4.
* The 2.5 / (ln x − 1) share is measured and matches the prime number theorem but is not proved in Lean.
* Lean's reports above 3.317 x 10^24 list probable primes (Miller-Rabin bound of Sorenson and Webster, 2017).
