"""STEP 6: Sieve only the kept 40% until nothing but primes is left.

Start: numbers 5 < n <= x ending in 1, 3, 7, 9.
Then for each prime p = 3, 7, 11, 13, ... up to sqrt(x): cross out p*p, p*p + 2p, ...
(odd multiples; those ending in 5 were never kept). Report after selected primes.

Run:  python3 step6_sieve_the_40.py     (about 30 s for x = 10^8)
"""
import subprocess

import numpy as np

X = 10**8
ROOT = int(X**0.5)                                   # 10,000
REPORT_AT = {3, 7, 11, 13, 17, 19, 23, 29, 31, 97, 997, 9973}

n = np.arange(X + 1)
alive = (n > 5) & np.isin(n % 10, [1, 3, 7, 9])      # the kept 40%
del n
start = int(alive.sum())
primes_kept = int(subprocess.run(["primecount", str(X)], capture_output=True,
                                 text=True).stdout) - 3   # all primes except 2, 3, 5

print(f"x = {X:,}   sqrt(x) = {ROOT:,}   primes above 5 = {primes_kept:,}")
print(f"start (the 40%): {start:,} numbers = {start / X:.4%} of all, "
      f"prime share {primes_kept / start:.3%}\n")
print(f"{'after removing':>18} {'removed by it':>14} {'left':>12} {'% of all':>9} "
      f"{'% of the 40%':>13} {'prime share':>12}")

small = np.ones(ROOT + 1, dtype=bool); small[:2] = False
for p in range(2, int(ROOT**0.5) + 1):
    if small[p]:
        small[p * p :: p] = False
sieving_primes = [p for p in np.flatnonzero(small) if p not in (2, 5)]

left = start
for p in sieving_primes:
    before = int(alive[p * p :: 2 * p].sum())        # still-alive odd multiples from p^2
    alive[p * p :: 2 * p] = False
    left -= before
    if p in REPORT_AT or p == sieving_primes[-1]:
        print(f"{'+' + format(p, ','):>18} {before:>14,} {left:>12,} {left / X:>9.4%} "
              f"{left / start:>13.3%} {primes_kept / left:>12.3%}")

print(f"\nsurvivors = {left:,}   primes above 5 = {primes_kept:,}   "
      f"only primes left: {left == primes_kept}")
