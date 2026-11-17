"""Recompute every number quoted in the two papers in this folder.

Requires: python3 with sympy, mpmath and numpy; the `primecount` command-line tool.
Run:      python3 papers/verify_numbers.py      (about one minute)
Each line prints the quantity, the value used in the paper, the recomputed value and PASS/FAIL.
"""
import random
import subprocess
from itertools import combinations
from math import gcd, isqrt, prod

import mpmath as mp
import numpy as np
import sympy

mp.mp.dps = 30
results = []


def check(label, paper, computed):
    ok = paper == computed
    results.append(ok)
    print(f"[{'PASS' if ok else 'FAIL'}] {label}: paper {paper} | computed {computed}")


def pi(x):
    return int(subprocess.run(["primecount", str(x)], capture_output=True, text=True).stdout)


def K(y):
    """Integers in [1, y] coprime to 10."""
    return 4 * (y // 10) + sum(1 for r in (1, 3, 7, 9) if r <= y % 10)


def sieving_primes(b):
    return [p for p in sympy.primerange(3, isqrt(b) + 1) if p != 5]


def window_survivors(a, b):
    alive = {n for n in range(a, b + 1) if n > 5 and gcd(n, 10) == 1}
    for p in sieving_primes(b):
        k0, k1 = max(p, -(-a // p)), b // p
        alive -= {p * k for k in range(k0, k1 + 1) if gcd(k, 10) == 1}
    return alive


def legendre40(x):
    q = sieving_primes(x)
    s = sum((-1) ** j * K(x // prod(c)) for j in range(len(q) + 1) for c in combinations(q, j))
    return sympy.primepi(isqrt(x)) - 1 + s


print("== Paper 1: the window sieve")
check("|C(100)|", 38, K(100) - 2)
check("window [1000,1100] survivors are its primes", True,
      sorted(window_survivors(1000, 1100)) == list(sympy.primerange(1000, 1101)))
check("number of survivors in [1000,1100]", 16, len(window_survivors(1000, 1100)))
random.seed(2026)
wins = [(a, a + random.randint(0, 2000)) for a in (random.randint(1, 10**6) for _ in range(500))]
check("Theorem 1 on 500 random windows", True,
      all(window_survivors(a, b) == set(sympy.primerange(max(a, 6), b + 1)) for a, b in wins))
c = -(-10**28 // 7)
check("first multiple of 7 at or above 10^28 minus 10^28", 3, 7 * c - 10**28)
check("ceil(10^28/7) ends in 9", 9, c % 10)
check("pi(10^14)", 3204941750802, pi(10**14))
check("Legendre-40 at x = 100", 25, legendre40(100))
check("Legendre-40 at x = 24 (outside range)", 8, legendre40(24))
check("Legendre-40 exact for all 25 <= x <= 3000", True,
      all(legendre40(x) == sympy.primepi(x) for x in range(25, 3001)))
check("x in [2, 24] where Legendre-40 is exact", [4],
      [x for x in range(2, 25) if legendre40(x) == sympy.primepi(x)])

print("== Paper 2: the zeta map")
z40 = mp.zeta(2) * mp.mpf(3) / 4 * mp.mpf(24) / 25
direct = mp.nsum(lambda k: sum(1 / (10 * k + r) ** 2 for r in (1, 3, 7, 9)), [0, mp.inf])
check("zeta_(10)(2)", "1.184352528130723", mp.nstr(z40, 16))
check("zeta_(10)(2) direct sum agrees to 25 digits", True, abs(z40 - direct) < mp.mpf(10) ** -25)
mert = mp.mpf(1)
for p in sympy.primerange(2, 9974):
    mert *= 1 - mp.mpf(1) / p
check("prod_{p<=9973}(1-1/p)", "0.0608846925", mp.nstr(mert, 9))
check("e^-gamma / ln 9973", "0.0609775886", mp.nstr(mp.exp(-mp.euler) / mp.log(9973), 9))
x = 9973**2
share = mp.mpf(pi(x)) / x
check("pi(9973^2)/9973^2", "0.0576316608", mp.nstr(share, 9))
check("overshoot ratio", "1.0564", mp.nstr(mert / share, 5))
check("2 e^-gamma", "1.122918967", mp.nstr(2 * mp.exp(-mp.euler), 10))
L5 = 2 * mp.log((1 + mp.sqrt(5)) / 2) / mp.sqrt(5)
chi = {1: 1, 3: -1, 7: -1, 9: 1}
L10 = mp.nsum(lambda k: sum(chi[r] / (10 * k + r) for r in (1, 3, 7, 9)), [0, mp.inf])
check("L(1, chi_5) = 2 log(phi)/sqrt 5", "0.430408940964", mp.nstr(L5, 12))
check("L(1, chi) direct sum", "0.645613411446", mp.nstr(L10, 12))
check("L(1, chi) = (3/2) L(1, chi_5) to 25 digits", True, abs(L10 - 1.5 * L5) < mp.mpf(10) ** -25)
N = 10**7
s = np.ones(N + 1, bool)
s[:2] = False
for i in range(2, isqrt(N) + 1):
    if s[i]:
        s[i * i::i] = False
ps = np.nonzero(s)[0]
ps = ps[ps > 5]
counts = [int((ps % 10 == d).sum()) for d in (1, 3, 7, 9)]
check("primes 5 < p <= 10^7 by ending 1,3,7,9", [166104, 166229, 166211, 166032], counts)
check("lag (3,7) minus (1,9)", 304, counts[1] + counts[2] - counts[0] - counts[3])
for k, g in ((1, "14.1347251417"), (2, "21.0220396388"), (3, "25.0108575801")):
    z = mp.zetazero(k)
    check(f"zero {k} height", g, mp.nstr(z.imag, 12))
    check(f"|zeta(rho_{k})| < 1e-25", True, abs(mp.zeta(z)) < mp.mpf(10) ** -25)

print(f"\n{sum(results)} of {len(results)} checks passed")
