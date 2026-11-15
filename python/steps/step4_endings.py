"""STEP 4: For each ending 1, 3, 7, 9 separately: kept, prime, not prime, and how fast
the prime share falls per power of ten. Up to 10^10, counted here with a segmented sieve.

Run:  python3 step4_endings.py     (about 1-2 minutes)
"""
import subprocess

import numpy as np

TOP = 10**10
BLOCK = 10**8
ENDINGS = (1, 3, 7, 9)

# ---------- Block 1: base primes up to sqrt(10^10) = 100,000 ----------
base = np.ones(100_001, dtype=bool); base[:2] = False
for p in range(2, 317):
    if base[p]:
        base[p * p :: p] = False
base_primes = np.flatnonzero(base)

# ---------- Block 2: sieve 1..10^10 in blocks; count primes by ending ----------
# counts[k][d] = primes <= 10^k ending in d (k = 1..10)
checkpoints = [10**k for k in range(1, 11)]
running = {d: 0 for d in ENDINGS}
counts = {}
for lo in range(0, TOP, BLOCK):                     # block covers lo .. lo+BLOCK-1
    seg = np.ones(BLOCK, dtype=bool)
    if lo == 0:
        seg[:2] = False
    for p in base_primes:
        start = max(p * p, ((lo + p - 1) // p) * p)
        seg[start - lo :: p] = False                # cross out multiples of p
    primes = np.flatnonzero(seg) + lo
    for cp in checkpoints:                          # a checkpoint inside this block
        if lo <= cp < lo + BLOCK:
            part = primes[primes <= cp] % 10
            counts[int(np.log10(cp))] = {d: running[d] + int((part == d).sum()) for d in ENDINGS}
    last = primes % 10
    for d in ENDINGS:
        running[d] += int((last == d).sum())
counts[10] = dict(running) | {}                     # 10^10 itself is even, not prime

# ---------- Block 3: check against primecount ----------
for k in (6, 8, 10):
    total = sum(counts[k].values()) + 2             # + the primes 2 and 5
    pc = int(subprocess.run(["primecount", str(10**k)], capture_output=True, text=True).stdout)
    print(f"check 10^{k}: endings sum + 2 = {total:,}  primecount = {pc:,}  ->", total == pc)


# ---------- Block 4: tables per ending ----------
def kept(d, k):
    """Numbers 5 < n <= 10^k ending in d: 10^(k-1) of them, minus 1 and 3 themselves."""
    return 10 ** (k - 1) - (1 if d in (1, 3) else 0)


def primes_kept(d, k):
    return counts[k][d] - (1 if d == 3 else 0)       # the prime 3 is not above 5


for d in ENDINGS:
    print(f"\nENDING {d}")
    print(f"{'up to':>6} {'kept':>15} {'prime':>14} {'not prime':>15} {'% prime':>9} "
          f"{'% not':>8} {'drop of % prime':>16}")
    prev = None
    for k in range(2, 11):
        kp, pr = kept(d, k), primes_kept(d, k)
        share = pr / kp
        drop = f"{1 - share / prev:>15.3%}" if prev else f"{'':>15}"
        print(f"{'1e' + str(k):>6} {kp:>15,} {pr:>14,} {kp - pr:>15,} {share:>9.4%} "
              f"{1 - share:>8.4%} {drop:>16}")
        prev = share

print("\nALL FOUR ENDINGS SIDE BY SIDE: % prime among kept, and theory 2.5/(ln x - 1)")
print(f"{'up to':>6} " + " ".join(f"{'end ' + str(d):>10}" for d in ENDINGS) + f" {'theory':>9}")
for k in range(2, 11):
    print(f"{'1e' + str(k):>6} " + " ".join(f"{primes_kept(d, k) / kept(d, k):>10.4%}" for d in ENDINGS)
          + f" {2.5 / (k * np.log(10) - 1):>9.4%}")
