"""STEP 10: count, filter and find the multiples at x = 10^29, exactly.

1. Count all numbers.                         exact
2. Apply the 40% filter (endings 1, 3, 7, 9).  exact
3. Primes and non-primes in the 40%.           P(10^29) from published tables (see below)
4. Multiples of each small prime in the 40%,
   and which prime "catches" each non-prime.   exact, by inclusion-exclusion
5. How many primes the sieve would need.       exact, by primecount (P(sqrt x))

P(10^29) = 1,520,698,109,714,272,166,094,258,063: OEIS A006880 and the primecount records
list (Baugh and Walisch, 2022). Computing it here would take days, so it is quoted.

Run:  python3 step10_one_hundred_octillion.py     (a few seconds)
"""
import subprocess
from itertools import combinations
from math import isqrt, prod

import mpmath as mp
import numpy as np

SIEVE_PRIMES = [3, 7, 11, 13, 17, 19, 23, 29, 31]
P_1E29 = 1_520_698_109_714_272_166_094_258_063


def coprime10_upto(y):
    """How many m in 1..y share no factor with 10 (end in 1, 3, 7, 9)."""
    return y - y // 2 - y // 5 + y // 10


def candidates(x):
    """Numbers 5 < n <= x ending in 1, 3, 7, 9 (removes 1 and 3)."""
    return coprime10_upto(x) - (1 if x >= 1 else 0) - (1 if x >= 3 else 0)


def multiples_in_40(x, p):
    """Multiples of p in the 40%, other than p itself: n = p*m with m ending in 1,3,7,9, m > 1."""
    return coprime10_upto(x // p) - 1


def caught_by(x, p, smaller):
    """Non-primes in the 40% whose smallest prime factor is p (inclusion-exclusion)."""
    total = 0
    for k in range(len(smaller) + 1):
        for s in combinations(smaller, k):
            total += (-1) ** k * coprime10_upto(x // (p * prod(s)))
    return total - 1                      # remove n = p itself, which is prime


def table(x):
    rows = []
    for i, p in enumerate(SIEVE_PRIMES):
        rows.append((p, multiples_in_40(x, p), caught_by(x, p, SIEVE_PRIMES[:i])))
    return rows


# ---------- check the method at 10^6 against a real sieve ----------
N = 10**6
spf = np.zeros(N + 1, dtype=np.int64)
for q in range(2, N + 1):
    if spf[q] == 0:
        spf[q::q][spf[q::q] == 0] = q
n = np.arange(N + 1)
cand = (n > 5) & np.isin(n % 10, [1, 3, 7, 9])
ok = candidates(N) == int(cand.sum())
for p, mult, caught in table(N):
    ok &= mult == int((cand & (n % p == 0) & (n != p)).sum())
    ok &= caught == int((cand & (spf == p) & (n != p)).sum())
print(f"method check at 10^6 against a real sieve: {'PASS' if ok else 'FAIL'}\n")

# ---------- 10^29 ----------
X = 10**29
kept = candidates(X)
primes_kept = P_1E29 - 3                      # every prime except 2, 3, 5
non_primes = kept - primes_kept
print("STEP 1  all numbers")
print(f"  1 .. 10^29 holds {X:,} numbers\n")
print("STEP 2  the 40% filter")
print(f"  kept (above 5, ending 1, 3, 7, 9): {kept:,}  ({100 * kept / X:.4f}%)")
print(f"  removed:                           {X - kept:,}  ({100 * (X - kept) / X:.4f}%)\n")
print("STEP 3  primes and non-primes in the 40%")
print(f"  primes:     {primes_kept:,}  ({100 * primes_kept / kept:.4f}% of the 40%)")
print(f"  non-primes: {non_primes:,}  ({100 * non_primes / kept:.4f}% of the 40%)")
mp.mp.dps = 40
li_est = mp.li(X) - mp.li(5.5) + 3
simple = 2.5 / (mp.log(X) - 1) * kept + 3
print(f"  check: li estimate of P(10^29) = {mp.nstr(li_est, 30)}  (off by {mp.nstr((li_est - P_1E29) / P_1E29 * 100, 3)}%)")
print(f"         2.5/(ln x - 1) estimate = {mp.nstr(simple, 30)}  (off by {mp.nstr((simple - P_1E29) / P_1E29 * 100, 3)}%)\n")
print("STEP 4  multiples of each small prime inside the 40%")
print(f"  {'prime':>5} {'multiples in the 40%':>30} {'caught first by this prime':>30} {'share of non-primes':>20}")
running = 0
for p, mult, caught in table(X):
    running += caught
    print(f"  {p:>5} {mult:>30,} {caught:>30,} {100 * caught / non_primes:>19.3f}%")
print(f"  {'':>5} {'caught by 3 .. 31 together:':>30} {running:>30,} {100 * running / non_primes:>19.3f}%")
print(f"  {'':>5} {'left for primes above 31:':>30} {non_primes - running:>30,} {100 * (non_primes - running) / non_primes:>19.3f}%\n")
root = isqrt(X)
sieve_count = int(subprocess.run(["primecount", str(root)], capture_output=True, text=True).stdout)
print("STEP 5  what a full sieve would need")
print(f"  sqrt(10^29) = {root:,}")
print(f"  primes up to sqrt(x): {sieve_count:,}  -> sieve uses {sieve_count - 2:,} of them (all but 2 and 5)")
