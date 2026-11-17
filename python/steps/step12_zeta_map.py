"""STEP 12: How the 40% filter, the sieve and the endings map onto the zeta function.

zeta(s) = 1 + 1/2^s + 1/3^s + ...  = product over primes p of 1 / (1 - 1/p^s)   (Euler product)

1. Throwing away multiples of 2 and 5 = multiplying zeta(s) by (1 - 1/2^s)(1 - 1/5^s).
   At s = 1 that factor is 1/2 x 4/5 = 0.4: the 40%.
2. The "40% zeta": zeta_40(s) = sum of 1/n^s over n ending in 1, 3, 7, 9.
3. Endings: the character chi(n) = +1 for endings 1, 9 and -1 for 3, 7 gives an L-function;
   its value at s = 1 is positive, which is behind Chebyshev's bias (1, 9 lag 3, 7).
4. Zeros: zeta(1/2 + i*gamma) = 0 at gamma = 14.1347...; each zero adds a wave to P(x).

Run:  python3 step12_zeta_map.py
"""
import mpmath as mp

mp.mp.dps = 25
print("1) THE 40% FACTOR, (1 - 2^-s)(1 - 5^-s)")
for s in (1, 2, 3):
    print(f"   s = {s}: factor = {mp.nstr((1 - mp.mpf(2) ** -s) * (1 - mp.mpf(5) ** -s), 12)}")

print("\n2) THE 40% ZETA AT s = 2: sum of 1/n^2 over n ending in 1, 3, 7, 9")
direct = mp.nsum(lambda k: sum(1 / (10 * k + r) ** 2 for r in (1, 3, 7, 9)), [0, mp.inf])
formula = mp.zeta(2) * (1 - mp.mpf(1) / 4) * (1 - mp.mpf(1) / 25)
print(f"   direct sum         = {mp.nstr(direct, 15)}")
print(f"   zeta(2) x 3/4 x 24/25 = {mp.nstr(formula, 15)}   (zeta(2) = pi^2/6 = {mp.nstr(mp.zeta(2), 12)})")

print("\n3) SIEVE PRODUCT = EULER PRODUCT AT s = 1 (Mertens)")
for top in (7, 97, 997, 9973):
    prod = mp.mpf(1)
    for p in [q for q in range(2, top + 1) if all(q % d for d in range(2, int(q ** 0.5) + 1))]:
        prod *= 1 - mp.mpf(1) / p
    print(f"   product of (1 - 1/p) for p <= {top:>5}: {mp.nstr(prod, 8)}"
          f"   vs e^-gamma / ln {top} = {mp.nstr(mp.exp(-mp.euler) / mp.log(top), 8)}")

print("\n4) ENDINGS: L-function of chi = +1 (endings 1, 9), -1 (endings 3, 7), 0 otherwise")
chi = [0, 1, 0, -1, 0, 0, 0, -1, 0, 1]
L1 = mp.nsum(lambda k: sum(chi[r] / (10 * k + r) for r in (1, 3, 7, 9)), [0, mp.inf])
print(f"   L(1, chi) direct            = {mp.nstr(L1, 15)}")
L5 = 2 * mp.log((1 + mp.sqrt(5)) / 2) / mp.sqrt(5)
print(f"   mod-5 version, 2 ln(golden ratio) / sqrt 5 = {mp.nstr(L5, 15)}")
print(f"   times (1 + 1/2) for removing the even numbers = {mp.nstr(L5 * mp.mpf(3) / 2, 15)}")

print("\n5) ZEROS OF ZETA: s = 1/2 + i*gamma")
for k in (1, 2, 3):
    z = mp.zetazero(k)
    print(f"   zero {k}: s = {mp.nstr(z, 12)}   |zeta(s)| = {mp.nstr(abs(mp.zeta(z)), 3)}")
