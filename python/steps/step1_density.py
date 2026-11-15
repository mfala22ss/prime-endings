"""STEP 1: Does prime density on the kept 40% fall in a predictable way?

Kept  = numbers 5 < n <= x ending in 1, 3, 7 or 9   (the candidates, C(x))
Removed = everything else (even numbers, numbers ending in 5, and 1..5)

Run:  python3 step1_density.py
"""
import numpy as np

# ---------- Block 1: make the data (which numbers up to 10^8 are prime) ----------
LIMIT = 10**8
is_prime = np.ones(LIMIT + 1, dtype=bool)   # start by assuming every number is prime
is_prime[:2] = False                         # 0 and 1 are not prime
for p in range(2, int(LIMIT**0.5) + 1):      # sieve of Eratosthenes
    if is_prime[p]:
        is_prime[p * p :: p] = False         # cross out every multiple of p
prime_count = np.cumsum(is_prime)            # prime_count[x] = P(x), primes <= x


# ---------- Block 2: the 40% kept and the 60% removed ----------
def kept_count(x):
    """|C(x)|: numbers 5 < n <= x ending in 1, 3, 7, 9 (fact base, result 1)."""
    tail = sum(1 for r in (1, 3, 7, 9) if r <= x % 10)
    return 4 * (x // 10) + tail - 2


def split_report(x):
    kept = kept_count(x)
    removed = x - kept
    primes_all = int(prime_count[x])
    primes_kept = primes_all - 3                 # every prime except 2, 3, 5
    return kept, removed, primes_all, primes_kept


print("A) WHAT THE FILTER KEEPS AND REMOVES")
print(f"{'x':>12} {'kept':>12} {'removed':>12} {'kept %':>7} "
      f"{'primes kept':>12} {'primes removed':>15}")
for k in range(2, 9):
    x = 10**k
    kept, removed, p_all, p_kept = split_report(x)
    print(f"{x:>12,} {kept:>12,} {removed:>12,} {kept / x:>7.2%} "
          f"{p_kept:>12,} {p_all - p_kept:>15}")


# ---------- Block 3: density on the kept numbers ----------
def density_kept(x):
    """Average density on candidates: primes kept / numbers kept."""
    kept, _, _, p_kept = split_report(x)
    return p_kept / kept


# ---------- Block 4: train the model on x up to 400,000 only ----------
# Model:  density = a / (ln x - b).   Flip it:  1/density = (1/a) * ln x - b/a
# That is a straight line in ln x, so ordinary least squares finds a and b exactly.
train_x = np.unique(np.geomspace(1_000, 400_000, 200).astype(int))
train_y = np.array([1 / density_kept(x) for x in train_x])
slope, intercept = np.polyfit(np.log(train_x), train_y, 1)   # fit the straight line
a = 1 / slope
b = -intercept * a
predict = lambda x: a / (np.log(x) - b)
print(f"\nB) MODEL TRAINED ON x = 1,000 to 400,000:  density = {a:.4f} / (ln x - {b:.4f})")
print("   theory (fact base, result 3): 2.5 / (ln x - 1)")

# ---------- Block 5: test it, including far beyond the training range ----------
# Values above 10^8 come from the fact base (primecount, tag C).
fact_base_P = {10**9: 50_847_534, 10**10: 455_052_511, 10**11: 4_118_054_813,
               10**12: 37_607_912_018, 10**13: 346_065_536_839}
theory = lambda x: 2.5 / (np.log(x) - 1)        # nothing fitted: 2.5 = 10/4
print(f"\n{'x':>8} {'density kept':>13} {'model':>9} {'model err':>10} "
      f"{'theory':>9} {'theory err':>11} {'density all':>12}")
for k in range(4, 14):
    x = 10**k
    if x <= LIMIT:
        true = density_kept(x); p_all = int(prime_count[x])
    else:
        p_all = fact_base_P[x]; true = (p_all - 3) / kept_count(x)
    pred, th = predict(x), theory(x)
    print(f"{'1e' + str(k):>8} {true:>13.4%} {pred:>9.4%} {(pred - true) / true:>+10.3%} "
          f"{th:>9.4%} {(th - true) / true:>+11.3%} {p_all / x:>12.4%}")
