"""STEP 8: Precision, recall and bigger wheels.

A "wheel" keeps only numbers sharing no factor with its modulus:
  mod 10   (removes multiples of 2, 5)        -> your 40% filter
  mod 30   (removes multiples of 2, 3, 5)
  mod 210  (also 7)
  mod 2310 (also 11)

precision = primes among the candidates / candidates      (how often a kept number is prime)
recall    = primes kept / all primes above the wheel's primes (does the filter ever lose a prime?)
speed     = time to find the primes in a window near 10^12 by testing only the candidates

Run:  python3 step8_precision_recall_wheels.py     (about 1 minute)
"""
import time
from math import gcd, log

import numpy as np
import sympy

WHEELS = {"mod 10": (10, [2, 5]), "mod 30": (30, [2, 3, 5]),
          "mod 210": (210, [2, 3, 5, 7]), "mod 2310": (2310, [2, 3, 5, 7, 11])}
LIMITS = [10**4, 10**6, 10**8]

# ---------- ground truth: every prime up to 10^8 ----------
N = LIMITS[-1]
is_prime = np.ones(N + 1, dtype=bool); is_prime[:2] = False
for p in range(2, int(N**0.5) + 1):
    if is_prime[p]:
        is_prime[p * p :: p] = False
n = np.arange(N + 1)

print("A) PRECISION AND RECALL")
print(f"{'wheel':>9} {'x':>12} {'kept %':>8} {'candidates':>12} {'primes in them':>15} "
      f"{'precision':>10} {'theory':>8} {'recall':>8} {'missed':>7}")
for name, (m, small) in WHEELS.items():
    residues = [r for r in range(m) if gcd(r, m) == 1]
    boost = m / len(residues)                       # = product of p / (p - 1)
    keep = np.isin(n % m, residues) & (n > max(small))
    for x in LIMITS:
        cand = int(keep[: x + 1].sum())
        hits = int((keep[: x + 1] & is_prime[: x + 1]).sum())
        all_big = int((is_prime[: x + 1] & (n[: x + 1] > max(small))).sum())
        theory = boost / (log(x) - 1)
        print(f"{name:>9} {x:>12,} {cand / x:>8.3%} {cand:>12,} {hits:>15,} "
              f"{hits / cand:>10.3%} {theory:>8.3%} {hits / all_big:>8.2%} {all_big - hits:>7}")

print("\nB) SPEED: find all primes in [10^12, 10^12 + 10^6) by testing only the candidates")
LO, W = 10**12, 10**6
reference = None
print(f"{'wheel':>9} {'tests':>9} {'seconds':>8} {'primes':>7} {'speed-up vs no filter':>22}")
t0 = time.perf_counter()
base = [k for k in range(LO, LO + W) if sympy.isprime(k)]
t_none = time.perf_counter() - t0
print(f"{'none':>9} {W:>9,} {t_none:>8.2f} {len(base):>7} {1.0:>22.2f}")
for name, (m, small) in WHEELS.items():
    residues = set(r for r in range(m) if gcd(r, m) == 1)
    cands = [k for k in range(LO, LO + W) if k % m in residues]
    t0 = time.perf_counter()
    found = [k for k in cands if sympy.isprime(k)]
    t = time.perf_counter() - t0
    assert found == base, f"{name} lost or added a prime"
    print(f"{name:>9} {len(cands):>9,} {t:>8.2f} {len(found):>7} {t_none / t:>22.2f}")
print("every wheel found exactly the same primes as testing every number: recall 100%")
