"""STEP 11: The 3-and-7 sieve on the 40%, with exact formulas.

Formulas (all floors are whole-number division):
  N(y)   = y - y//2 - y//5 + y//10           numbers 1..y ending in 1, 3, 7, 9
  C(x)   = N(x) - 2                          the 40%: numbers 5 < n <= x ending in 1, 3, 7, 9
  A3(x)  = N(x//3)                           multiples of 3 ending in 1, 3, 7, 9 (includes 3)
  A7(x)  = N(x//7)                           multiples of 7 ending in 1, 3, 7, 9 (includes 7)
  A21(x) = N(x//21)                          multiples of both (of 21)
  R(x)   = A3 + A7 - A21 - 2                 removed by 3 or 7 (minus 3 and 7 themselves)
  L(x)   = C(x) - R(x)                       left after crossing out multiples of 3 and 7
Rule: L(x) = P(x) - 3 (exactly the primes above 5) for every x <= 120 = 11*11 - 1, and
      L(x) > P(x) - 3 from x = 121 on, by the non-primes whose smallest factor is 11 or more.

Run:  python3 step11_three_and_seven.py
"""
import numpy as np

LIMIT = 100_000


def N(y):
    return y - y // 2 - y // 5 + y // 10 if y > 0 else 0


def C(x):
    return max(N(x) - (1 if x >= 1 else 0) - (1 if x >= 3 else 0), 0)


def R(x):
    if x < 7:
        return 0
    return N(x // 3) + N(x // 7) - N(x // 21) - 2


def L(x):
    return C(x) - R(x)


# ---------- ground truth ----------
is_prime = np.ones(LIMIT + 1, dtype=bool); is_prime[:2] = False
for p in range(2, int(LIMIT**0.5) + 1):
    if is_prime[p]:
        is_prime[p * p :: p] = False
n = np.arange(LIMIT + 1)
cand = (n > 5) & np.isin(n % 10, [1, 3, 7, 9])
left = cand & (n % 3 != 0) & ((n % 7 != 0) | (n == 7))       # survivors of 3 and 7
P = np.cumsum(is_prime); Ccum = np.cumsum(cand); Lcum = np.cumsum(left)

ok_C = all(C(x) == Ccum[x] for x in range(1, LIMIT + 1))
ok_L = all(L(x) == Lcum[x] for x in range(1, LIMIT + 1))
exact = [x for x in range(6, LIMIT + 1) if L(x) == P[x] - 3]
print(f"C(x) formula matches the sieve for every x up to {LIMIT:,}: {'PASS' if ok_C else 'FAIL'}")
print(f"L(x) formula matches the sieve for every x up to {LIMIT:,}: {'PASS' if ok_L else 'FAIL'}")
print(f"3 and 7 leave exactly the primes for x = 6 .. {max(x for x in exact if x < 200)}, "
      f"and first fail at x = {min(x for x in range(6, LIMIT + 1) if L(x) != P[x] - 3)}\n")

print(f"{'x':>8} {'C(x) kept':>10} {'by 3':>8} {'by 7':>8} {'by both':>8} {'removed':>8} {'left':>8} "
      f"{'primes>5':>9} {'extra':>7} {'left % of all':>14}")
for x in [100, 120, 121, 168, 169, 1000, 10_000, 100_000]:
    a3, a7, a21 = N(x // 3) - 1, N(x // 7) - 1, N(x // 21)
    extra = L(x) - (P[x] - 3)
    print(f"{x:>8,} {C(x):>10,} {a3:>8,} {a7:>8,} {a21:>8,} {R(x):>8,} {L(x):>8,} {P[x] - 3:>9,} "
          f"{extra:>7,} {100 * L(x) / x:>13.3f}%")

extras = [int(v) for v in np.flatnonzero(left & ~is_prime)[:12]]
print("\nfirst non-primes that survive 3 and 7:", extras)
print("long-run share left after 3 and 7: 4/10 x 2/3 x 6/7 = 8/35 =", f"{100 * 8 / 35:.3f}% of all numbers")
