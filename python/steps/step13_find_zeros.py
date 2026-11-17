"""STEP 13: Simple zeta workings, and finding the zeros ourselves.

Part A: the 40% inside zeta, one multiplication at a time (s = 1 and s = 2).
Part B: find every zero up to height T by watching Hardy's Z(t) change sign:
  Z(t) is a real number with |Z(t)| = |zeta(1/2 + i t)|, so each sign change of Z
  is a zero on the critical line. Then check the count against the exact number of
  zeros up to T (argument principle, mpmath.nzeros) and the Riemann-von Mangoldt
  formula N(T) ~ (T / 2pi) ln(T / 2pi e) + 7/8. If the counts agree, none were missed.

Run:  python3 step13_find_zeros.py     (about 1 minute)
"""
import mpmath as mp

mp.mp.dps = 20

print("PART A1: s = 1, removing one prime at a time (share of numbers kept)")
share = mp.mpf(1)
for p in (2, 5, 3, 7, 11):
    share *= 1 - mp.mpf(1) / p
    print(f"   remove multiples of {p:>2}: x (1 - 1/{p}) -> {mp.nstr(share * 100, 6)}% kept")

print("\nPART A2: s = 2, the sum 1 + 1/4 + 1/9 + 1/16 + ... and the 40% part of it")
z2 = mp.zeta(2)
print(f"   all numbers:            zeta(2) = pi^2 / 6           = {mp.nstr(z2, 12)}")
print(f"   drop even numbers:      x (1 - 1/4)  = x 3/4          = {mp.nstr(z2 * 3 / 4, 12)}")
print(f"   drop multiples of 5:    x (1 - 1/25) = x 24/25        = {mp.nstr(z2 * 3 / 4 * 24 / 25, 12)}")
first = [n for n in range(1, 60) if n % 10 in (1, 3, 7, 9)]
print("   first terms of the 40% sum: " + " + ".join(f"1/{n}^2" for n in first[:6]) + " + ...")
print(f"   those 6 terms already add to {mp.nstr(sum(mp.mpf(1) / n ** 2 for n in first[:6]), 8)}")

print("\nPART B: finding the zeros by sign changes of Z(t)")
T, step = 300, mp.mpf("0.02")
found, t, prev = [], mp.mpf(1), mp.siegelz(1)
while t < T:
    t2 = t + step
    cur = mp.siegelz(t2)
    if prev * cur < 0:
        found.append(mp.findroot(mp.siegelz, (t, t2), solver="bisect"))
    t, prev = t2, cur
exact = mp.nzeros(T)
formula = T / (2 * mp.pi) * mp.log(T / (2 * mp.pi * mp.e)) + mp.mpf(7) / 8
print(f"   zeros found by sign change up to T = {T}: {len(found)}")
print(f"   exact number of zeros up to T (argument principle): {exact}")
print(f"   Riemann-von Mangoldt estimate: {mp.nstr(formula, 6)}")
print(f"   all found, none missed: {'PASS' if len(found) == exact else 'FAIL'}")
print("   first five found:   " + ", ".join(mp.nstr(g, 10) for g in found[:5]))
print("   mpmath.zetazero:    " + ", ".join(mp.nstr(mp.zetazero(k).imag, 10) for k in range(1, 6)))
worst = max(abs(found[k - 1] - mp.zetazero(k).imag) for k in range(1, len(found) + 1, 10))
print(f"   largest difference (every 10th zero checked): {mp.nstr(worst, 3)}")
gaps = [b - a for a, b in zip(found, found[1:])]
print(f"   closest pair of zeros below {T}: gap {mp.nstr(min(gaps), 5)}; average gap near {T}: "
      f"{mp.nstr(2 * mp.pi / mp.log(T / (2 * mp.pi)), 5)}")
