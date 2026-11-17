"""STEP 14: run OUR method itself up to 10^10 and test it.

Our method: (1) take 1..x; (2) keep only numbers above 5 ending in 1, 3, 7, 9 and set
2, 3, 5 aside; (3) cross out p*k for every prime 3 <= p <= sqrt(x), p != 5, with k >= p and
k ending in 1, 3, 7, 9 (the multiplier range proved in Lean as `window_sieve`).
Done in blocks of 10^8 so it fits in memory. At each power of ten the survivors + 3 are
compared with primecount, and the share with our model's prediction 2.5 / (ln x - 1).
Run:  python3 step14_method_to_1e10.py      (a few minutes)
"""
import math
import subprocess
import time

import numpy as np

TOP, BLOCK = 10**10, 10**8
ENDINGS = np.array([1, 3, 7, 9])


def base_primes(n):
    s = np.ones(n + 1, bool)
    s[:2] = False
    for i in range(2, math.isqrt(n) + 1):
        if s[i]:
            s[i * i::i] = False
    return [int(p) for p in np.flatnonzero(s) if p >= 3 and p != 5]


def primecount(x):
    return int(subprocess.run(["primecount", str(x)], capture_output=True, text=True).stdout)


primes = base_primes(math.isqrt(TOP))
survivors, kept_total, t0 = 0, 0, time.time()
print(f"{'x':>6} {'kept (step 2)':>15} {'survivors+3':>14} {'primecount':>14} {'equal':>6} "
      f"{'true share':>11} {'predicted':>10} {'error':>8}")
for lo in range(0, TOP, BLOCK):
    hi = lo + BLOCK                               # block covers [lo, hi)
    n = np.arange(lo, hi)
    alive = np.isin(n % 10, ENDINGS) & (n > 5)    # step 2: strip the 60%
    kept_total += int(alive.sum())
    for p in primes:                              # step 3: cross out multiples
        if p * p >= hi:
            break
        k0 = max(p, -(-lo // p))
        for r in (1, 3, 7, 9):                    # multipliers k ending in r
            k = k0 + (r - k0) % 10
            start = p * k
            if start < hi:
                alive[start - lo::10 * p] = False
    survivors += int(alive.sum())
    if math.log10(hi).is_integer():
        x = hi - 1 + 1                            # checkpoint x = hi (hi itself is not prime)
        true = primecount(x)
        share = survivors / kept_total
        pred = 2.5 / (math.log(x) - 1)
        print(f"{'1e' + str(int(math.log10(x))):>6} {kept_total:>15,} {survivors + 3:>14,} {true:>14,} "
              f"{str(survivors + 3 == true):>6} {share:>11.4%} {pred:>10.4%} {(pred - share) / share:>+8.2%}",
              flush=True)
print(f"time: {time.time() - t0:.0f} s")
