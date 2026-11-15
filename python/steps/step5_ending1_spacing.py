"""STEP 5: Spacing between consecutive primes that end in 1.

Gap = next prime ending in 1 minus this one. It is always a multiple of 10.
Window: primes between 900 million and 1 billion (all about the same size,
so the average spacing does not drift inside the sample).

Known method compared against: Hardy-Littlewood. A gap g is favoured by the factor
    f(g) = product over primes q dividing g, q not 2 or 5, of (q - 1) / (q - 2)
because if q divides g, then p and p + g cannot both be hit by the same multiple of q.
Example: f(30) = 2 (from q = 3), f(70) = 1.2 (q = 7), f(210) = 2 * 1.2 = 2.4.

Run:  python3 step5_ending1_spacing.py   (about 15 s, uses ~1 GB RAM)
"""
from math import log

import numpy as np

LO, HI = 900_000_000, 1_000_000_000

# ---------- Block 1: primes up to 10^9 (sieve), keep those ending in 1 ----------
s = np.ones(HI + 1, dtype=bool); s[:2] = False; s[4::2] = False
for p in range(3, int(HI**0.5) + 1, 2):
    if s[p]:
        s[p * p :: 2 * p] = False
pr = np.flatnonzero(s); del s
ones = pr[(pr % 10 == 1) & (pr >= LO)]
gaps = np.diff(ones)
print(f"primes ending in 1 between {LO:,} and {HI:,}: {len(ones):,}")
print(f"gaps measured: {len(gaps):,}   all multiples of 10: {bool(np.all(gaps % 10 == 0))}")

# ---------- Block 2: average spacing vs the simple prediction ----------
mid = (LO + HI) / 2
print(f"average gap: {gaps.mean():.2f}    prediction 4 * ln x at the middle: {4 * log(mid):.2f}")
print(f"smallest gap: {gaps.min()}   largest gap: {gaps.max()}")


# ---------- Block 3: how often each gap occurs, vs Hardy-Littlewood ----------
def hl_factor(g):
    f = 1.0
    for q in range(3, g + 1):
        if q != 5 and g % q == 0 and all(q % r for r in range(2, int(q**0.5) + 1)):
            f *= (q - 1) / (q - 2)
    return f


# Model: count(g) = A * f(g) * exp(-g / m). Without f it is the "random primes" model.
# A and m are fitted by least squares on log(count / f) for gaps 10..300.
G = np.arange(10, 310, 10)
obs = np.array([(gaps == g).sum() for g in G], dtype=float)
f = np.array([hl_factor(g) for g in G])
slope, icpt = np.polyfit(G, np.log(obs / f), 1)
expected_hl = np.exp(icpt) * f * np.exp(slope * G)
slope0, icpt0 = np.polyfit(G, np.log(obs), 1)
expected_plain = np.exp(icpt0 + slope0 * G)

print(f"\n{'gap':>5} {'count':>9} {'share':>7} {'HL factor':>10} "
      f"{'random model':>13} {'HL model':>9} {'obs/random':>11}")
for g, o, ff, e0, e1 in zip(G, obs, f, expected_plain, expected_hl):
    if g <= 150 or g % 30 == 0:
        print(f"{g:>5} {o:>9,.0f} {o / len(gaps):>7.2%} {ff:>10.3f} "
              f"{e0:>13,.0f} {e1:>9,.0f} {o / e0:>11.2f}")

err_plain = np.sqrt(np.mean((obs - expected_plain) ** 2))
err_hl = np.sqrt(np.mean((obs - expected_hl) ** 2))
print(f"\nRMSE over gaps 10..300:  random-primes model {err_plain:,.0f}   "
      f"Hardy-Littlewood model {err_hl:,.0f}")
m30 = (gaps % 30 == 0).mean()            # numerator and denominator over ALL gaps
r = np.exp(10 * slope0)                  # decay ratio per step of 10 in the random model
base = r**2 / (1 + r + r**2)             # share of multiples of 30 under that model
print(f"share of gaps that are multiples of 30: {m30:.2%}  "
      f"(random decay model, ratio {r:.3f} per 10, would give {base:.2%})")

# Gap 10 is a pure pair count: nothing ending in 1 lies between p and p + 10.
# Exact Hardy-Littlewood pair formula: (1/4) * 2*C2 * (4/3) * integral dt / ln^2 t
import mpmath as mp
q = pr[(pr > 2) & (pr < 10**7)].astype(float)
C2 = float(np.prod(1 - 1 / (q - 1) ** 2))            # twin-prime constant, computed
pair_pred = 0.25 * 2 * C2 * (4 / 3) * float(mp.quad(lambda t: 1 / mp.log(t) ** 2, [LO, HI]))
print(f"gap 10 as a pair count: observed {int(obs[0]):,}, exact HL pair formula {pair_pred:,.0f} "
      f"(C2 = {C2:.7f})")
