"""STEP 2: How does density on the kept 40% change each time x grows ten-fold?

(a) relative DROP in density per decade      drop = 1 - D(10x)/D(x)
(b) GROWTH factor of the prime count         growth = P_kept(10x)/P_kept(x)
(c) the link between them, and the theory     growth = 10 * (1 - drop)  (almost exactly)
Also: per decade, how many numbers the filter keeps and removes, and primes in each.

Run:  python3 step2_relative_change.py
"""
import numpy as np

# ---------- Block 1: data ----------
# Prime counts at powers of ten. Up to 10^8 we recompute them with a sieve as a check;
# 10^9 to 10^13 are the fact-base values (primecount, tag C).
P = {1: 4, 2: 25, 3: 168, 4: 1_229, 5: 9_592, 6: 78_498, 7: 664_579, 8: 5_761_455,
     9: 50_847_534, 10: 455_052_511, 11: 4_118_054_813, 12: 37_607_912_018,
     13: 346_065_536_839}

LIMIT = 10**8
sieve = np.ones(LIMIT + 1, dtype=bool); sieve[:2] = False
for p in range(2, int(LIMIT**0.5) + 1):
    if sieve[p]:
        sieve[p * p :: p] = False
counts = np.cumsum(sieve)
mismatch = [k for k in range(1, 9) if counts[10**k] != P[k]]
print("check: sieve agrees with the table up to 10^8 ->", "yes" if not mismatch else mismatch)

kept = lambda k: 4 * 10 ** (k - 1) - 2          # |C(10^k)|, numbers kept
p_kept = lambda k: P[k] - 3                     # primes kept (all but 2, 3, 5)
dens = lambda k: p_kept(k) / kept(k)            # density on kept numbers

# ---------- Block 2: the filter, decade by decade ----------
print("\nA) NEW NUMBERS IN EACH DECADE (10^k, 10^(k+1)]")
print(f"{'decade':>14} {'kept':>18} {'removed':>18} {'new primes':>16} {'primes removed':>15}")
for k in range(1, 13):
    new_kept = kept(k + 1) - kept(k)
    new_all = 10 ** (k + 1) - 10**k
    print(f"{'1e' + str(k) + '..1e' + str(k + 1):>14} {new_kept:>18,} {new_all - new_kept:>18,} "
          f"{P[k + 1] - P[k]:>16,} {0:>15}")

# ---------- Block 3: (a) drop, (b) growth, (c) link + theory ----------
print("\nB) PER DECADE, ON THE KEPT 40%")
print(f"{'step':>12} {'density':>9} {'(a) drop':>9} {'theory':>8} "
      f"{'(b) growth':>11} {'10*(1-drop)':>12} {'drop*(ln10x-1)/ln10':>20}")
for k in range(2, 13):
    d0, d1 = dens(k), dens(k + 1)
    drop = 1 - d1 / d0                                         # (a)
    growth = p_kept(k + 1) / p_kept(k)                         # (b)
    lx, lten = k * np.log(10), np.log(10)
    theory_drop = 1 - (lx - 1) / (lx + lten - 1)               # from 2.5/(ln x - 1)
    print(f"{'1e' + str(k) + '->1e' + str(k + 1):>12} {d0:>9.4%} {drop:>9.3%} {theory_drop:>8.3%} "
          f"{growth:>11.4f} {10 * (1 - drop):>12.4f} {drop * (lx + lten - 1) / lten:>20.4f}")
