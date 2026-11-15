"""STEP 3: Steps 1 and 2 again, up to 10 trillion (10^13), every count computed here.

Counts come from primecount (brew install primecount), which counts primes up to x
without listing them, so 10^13 takes a fraction of a second.

Run:  python3 step3_to_10_trillion.py
"""
import subprocess

import numpy as np


def P(x):
    """Number of primes <= x, from the primecount program."""
    out = subprocess.run(["primecount", str(int(x))], capture_output=True, text=True)
    return int(out.stdout)


def kept_count(x):
    """Numbers 5 < n <= x ending in 1, 3, 7, 9 (fact base result 1; checked to 10^6)."""
    return 4 * (x // 10) + sum(1 for r in (1, 3, 7, 9) if r <= x % 10) - 2


def density_kept(x):
    return (P(x) - 3) / kept_count(x)        # primes kept = all primes except 2, 3, 5


# ---------- Block 1: sanity check against values known from step 2's sieve ----------
known = {10**6: 78_498, 10**8: 5_761_455}
print("check primecount vs sieve:", all(P(x) == c for x, c in known.items()))

# ---------- Block 2: train the same model as step 1, on x <= 400,000 only ----------
train_x = np.unique(np.geomspace(1_000, 400_000, 200).astype(int))
train_y = np.array([1 / density_kept(x) for x in train_x])
slope, intercept = np.polyfit(np.log(train_x), train_y, 1)
a, b = 1 / slope, -intercept / slope
model = lambda x: a / (np.log(x) - b)
theory = lambda x: 2.5 / (np.log(x) - 1)           # average density, nothing fitted
theory_local = lambda x: 2.5 / np.log(x)           # local density, nothing fitted
print(f"model: density = {a:.4f} / (ln x - {b:.4f})      theory: 2.5 / (ln x - 1)\n")

# ---------- Block 3: kept / removed, and the average density test ----------
rows = {}
print(f"{'x':>6} {'kept':>18} {'removed':>18} {'primes kept':>16} {'primes rem.':>11} "
      f"{'density':>9} {'model err':>10} {'theory err':>11}")
for k in range(4, 14):
    x = 10**k
    kept, p = kept_count(x), P(x)
    d = (p - 3) / kept
    rows[k] = (kept, p, d)
    print(f"{'1e' + str(k):>6} {kept:>18,} {x - kept:>18,} {p - 3:>16,} {3:>11} {d:>9.4%} "
          f"{(model(x) - d) / d:>+10.3%} {(theory(x) - d) / d:>+11.3%}")

# ---------- Block 4: local density in a window ending at x (fact-base convention) ----------
print(f"\n{'x':>6} {'window':>10} {'local density':>14} {'theory 2.5/ln x':>16} {'error':>8}")
for k in range(4, 14):
    x = 10**k
    w = x // 2 if x <= 10**6 else 10**6
    d_loc = (P(x) - P(x - w)) / (0.4 * w)        # 0.4*w kept numbers in the window
    print(f"{'1e' + str(k):>6} {w:>10,} {d_loc:>14.4%} {theory_local(x):>16.4%} "
          f"{(theory_local(x) - d_loc) / d_loc:>+8.3%}")

# ---------- Block 5: per power of ten: drop, growth, and the 2.3 / ln x law ----------
print(f"\n{'step':>12} {'drop':>8} {'theory drop':>12} {'growth':>8} {'measured/theory':>16}")
for k in range(4, 13):
    (k0, p0, d0), (k1, p1, d1) = rows[k], rows[k + 1]
    drop = 1 - d1 / d0
    lx = k * np.log(10)
    th = np.log(10) / (lx + np.log(10) - 1)
    print(f"{'1e' + str(k) + '->1e' + str(k + 1):>12} {drop:>8.3%} {th:>12.3%} "
          f"{(p1 - 3) / (p0 - 3):>8.4f} {drop / th:>16.4f}")
