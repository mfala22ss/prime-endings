"""STEP 16: our method on a 42,000-digit number.

Window: the W numbers starting at a = 10^41999 (a has exactly 42,000 digits).
1. Strip the 60% by the last digit.
2. COUNT the multiples of p in the window that end in 1, 3, 7, 9 with one formula,
   K(floor(b/p)) - K(ceil(a/p) - 1), where K(y) = 4*floor(y/10) + #{d in 1,3,7,9 : d <= y mod 10};
   check it against crossing them out one by one.
3. Cross out the multiples of every prime p <= Y (a partial sieve: a full one is impossible).
4. Compare survivors with the estimate, and with the expected number of primes.
Run:  python3 step16_huge_numbers.py
"""
import math
import sys
import time

import numpy as np

DIGITS, W, Y = 42_000, 100_000, 1_000_000
sys.set_int_max_str_digits(0)
a = 10 ** (DIGITS - 1)
b = a + W - 1
assert len(str(a)) == DIGITS


def K(y):
    return 4 * (y // 10) + sum(1 for d in (1, 3, 7, 9) if d <= y % 10)


def small_primes(n):
    s = np.ones(n + 1, bool)
    s[:2] = False
    for i in range(2, math.isqrt(n) + 1):
        if s[i]:
            s[i * i::i] = False
    return [int(p) for p in np.flatnonzero(s)]


t0 = time.time()
pos = np.arange(W)
ending = (a % 10 + pos) % 10
alive = np.isin(ending, [1, 3, 7, 9])                       # step 1: strip the 60%
kept = int(alive.sum())
print(f"a = 10^{DIGITS - 1} ({DIGITS:,} digits); window of {W:,} numbers")
print(f"step 1: kept {kept:,} numbers ending in 1, 3, 7, 9 ({kept / W:.1%}), by the last digit alone")

print("\nstep 2: how many multiples of p lie in the window and end in 1, 3, 7, 9?")
print(f"{'p':>9} {'formula':>9} {'crossed one by one':>19} {'equal':>6}")
for p in (3, 7, 11, 997, 999_983):
    formula = K(b // p) - K(-(-a // p) - 1)
    first = (-a) % p                                        # position of the first multiple
    one_by_one = int(np.isin(ending[first::p], [1, 3, 7, 9]).sum())
    print(f"{p:>9,} {formula:>9,} {one_by_one:>19,} {str(formula == one_by_one):>6}")

primes = [p for p in small_primes(Y) if p not in (2, 5)]
for p in primes:                                            # step 3: partial sieve
    alive[(-a) % p::p] = False
survivors = int(alive.sum())
estimate = kept * math.prod(1 - 1 / p for p in primes)
ln_a = DIGITS * math.log(10)
expected_primes = W / ln_a
print(f"\nstep 3: crossed out the multiples of the {len(primes):,} primes from 3 to {Y:,} (not 5)")
print(f"        survivors: {survivors:,}   product-rule estimate: {estimate:,.0f}")
print(f"        primes expected in the window: W / ln a = {W:,} / {ln_a:,.0f} = {expected_primes:.2f}")
print(f"        so about 1 survivor in {survivors / expected_primes:,.0f} is prime; the rest need a primality test")
print(f"        a full sieve would need every prime up to sqrt(a), a {DIGITS // 2:,}-digit number")
print(f"time: {time.time() - t0:.1f} s")
