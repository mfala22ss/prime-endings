"""STEP 7: Audit. Check the code first, then 40/60, then the model, then the sieve.

Every check prints PASS or FAIL. Ground truth = two independent tools that must agree:
our own numpy sieve (to 10^8) and primecount (to 10^13).

Run:  python3 step7_audit.py     (about 30 s)
"""
import subprocess
from math import log

import numpy as np

X = 10**8
results = []


def check(name, ok, detail=""):
    results.append(ok)
    print(f"  [{'PASS' if ok else 'FAIL'}] {name}" + (f"   ({detail})" if detail else ""))


def primecount(x):
    return int(subprocess.run(["primecount", str(int(x))], capture_output=True, text=True).stdout)


# ======================= STAGE 1: is the code itself correct? =======================
print("STAGE 1  ground truth and building blocks")
is_prime = np.ones(X + 1, dtype=bool); is_prime[:2] = False
for p in range(2, int(X**0.5) + 1):
    if is_prime[p]:
        is_prime[p * p :: p] = False
P = np.cumsum(is_prime)                                   # P[x] = primes <= x

pts = [10, 100, 7919, 10**4, 123_456, 10**6, 9_999_991, 10**7, 54_321_987, 10**8]
check("sieve agrees with primecount at 10 points", all(P[x] == primecount(x) for x in pts))
small = [n for n in range(2, 200) if all(n % d for d in range(2, int(n**0.5) + 1))]
check("sieve's first primes match trial division up to 200",
      list(np.flatnonzero(is_prime[:200])) == small)


def kept_count(x):                                        # formula used in steps 1-4
    return 4 * (x // 10) + sum(1 for r in (1, 3, 7, 9) if r <= x % 10) - 2


n = np.arange(X + 1)
kept_mask = (n > 5) & np.isin(n % 10, [1, 3, 7, 9])
kept_cum = np.cumsum(kept_mask)
sample = np.random.default_rng(1).integers(3, X, 20_000)
check("kept_count formula = brute force at 20,000 random x and every x <= 10,000",
      all(kept_count(int(x)) == kept_cum[x] for x in sample)
      and all(kept_count(x) == kept_cum[x] for x in range(3, 10_001)))


def fit_model(xs, dens):                                  # same fit as steps 1 and 3
    slope, icpt = np.polyfit(np.log(xs), 1 / dens, 1)
    return 1 / slope, -icpt / slope                       # a, b in a / (ln x - b)


xs = np.geomspace(1e3, 4e5, 200)
a, b = fit_model(xs, 2.5 / (np.log(xs) - 1))              # synthetic data, answer known
check("fitter recovers known a = 2.5, b = 1 from synthetic data",
      abs(a - 2.5) < 1e-9 and abs(b - 1) < 1e-9, f"a={a:.6f}, b={b:.6f}")

# ======================= STAGE 2: the 40/60 rule =======================
print("\nSTAGE 2  apply the 40/60 rule")
kept = int(kept_mask.sum()); removed = X - kept
primes_in_removed = int((is_prime & ~kept_mask).sum())
check("kept + removed = all numbers", kept + removed == X, f"{kept:,} + {removed:,}")
check("kept is 40% (minus the numbers 1 and 3)", kept == 4 * X // 10 - 2, f"{kept / X:.6%}")
check("removed 60% contains exactly 3 primes (2, 3, 5)",
      primes_in_removed == 3 and list(np.flatnonzero(is_prime & ~kept_mask)) == [2, 3, 5])
check("every prime above 5 is in the kept 40%",
      int((is_prime & kept_mask).sum()) == int(P[X]) - 3)

# ======================= STAGE 3: can the model predict density on the 40%? ===========
print("\nSTAGE 3  model trained on x <= 400,000, tested against ground truth")
train = np.unique(np.geomspace(1_000, 400_000, 200).astype(int))
a, b = fit_model(train, np.array([(P[x] - 3) / kept_count(x) for x in train]))
model = lambda x: a / (log(x) - b)
theory = lambda x: 2.5 / (log(x) - 1)
print(f"  model: {a:.4f} / (ln x - {b:.4f})     theory: 2.5 / (ln x - 1)")
print(f"  {'x':>6} {'truth':>9} {'model':>9} {'err':>8} {'theory':>9} {'err':>8}")
worst_model = worst_theory = 0.0
for k in range(4, 14):
    x = 10**k
    true = (primecount(x) - 3) / kept_count(x)            # ground truth from primecount
    em, et = model(x) / true - 1, theory(x) / true - 1
    worst_model, worst_theory = max(worst_model, abs(em)), max(worst_theory, abs(et))
    print(f"  {'1e' + str(k):>6} {true:>9.4%} {model(x):>9.4%} {em:>+8.3%} "
          f"{theory(x):>9.4%} {et:>+8.3%}")
check("model within 2% of truth at every power of ten to 10^13", worst_model < 0.02,
      f"worst {worst_model:.3%}")
check("theory within 1% of truth at every power of ten to 10^13", worst_theory < 0.01,
      f"worst {worst_theory:.3%}")

# ======================= STAGE 4: the sieve on the 40% =======================
print("\nSTAGE 4  sieve the 40%; predictions vs ground truth after each prime")
alive = kept_mask.copy()
truth_primes = int(P[X]) - 3
sieving = [p for p in np.flatnonzero(is_prime[: int(X**0.5) + 1]) if p not in (2, 5)]
pred_left, boost = float(kept), 2.5
print(f"  {'after':>7} {'left (truth)':>13} {'left (product)':>15} {'err':>7} "
      f"{'prime share truth':>18} {'boost/(ln x-1)':>15}")
for p in sieving:
    alive[p * p :: 2 * p] = False
    pred_left *= 1 - 1 / p
    boost *= p / (p - 1)
    if p in (3, 7, 13, 31, 97, 997, sieving[-1]):
        left = int(alive.sum())
        print(f"  {p:>7,} {left:>13,} {pred_left:>15,.0f} {pred_left / left - 1:>+7.2%} "
              f"{truth_primes / left:>18.3%} {boost / (log(X) - 1):>15.3%}")
left = int(alive.sum())
check("survivor COUNT equals the number of primes above 5", left == truth_primes,
      f"{left:,} vs {truth_primes:,}")
check("survivor SET equals the prime set, number by number",
      bool(np.array_equal(alive, is_prime & (n > 5))))
check("no survivor is composite (checked by trial division on 2,000 random survivors)",
      all(all(int(s) % d for d in range(2, int(int(s) ** 0.5) + 1))
          for s in np.random.default_rng(2).choice(np.flatnonzero(alive), 2000)))

print(f"\n{sum(results)} of {len(results)} checks passed")
