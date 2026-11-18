"""STEP 19: the sieve on the 40% as a pick-up loop.

Start with the kept numbers (above 5, ending in 1, 3, 7, 9).
Pick up a prime p, remove p*p, then p*k for every larger k ending in 1, 3, 7, 9.
The next prime to pick up is the smallest number still standing above p.
Stop when p*p > x. What is left, plus 2, 3 and 5, is exactly the primes up to x.

Each rule is proved in Lean (lean/Solution.lean): `prime_alive` (no prime is removed),
`next_pickup_prime` (the next pick-up is always the next prime; only 5 is skipped) and
`stop_rule` (once p*p > x, everything still standing up to x is prime).

Run:  python3 step19_pickup_loop.py [x]      (shows the loop for x, default 300, then checks it)
"""
import sys

import sympy

STEP = {1: 2, 3: 4, 7: 2, 9: 2}          # next k ending in 1,3,7,9: 1->3->7->9->11


def pickup_sieve(x, show=False):
    alive = bytearray(x + 1)                 # alive[n] = 1 if n is still standing
    for n in range(7, x + 1):
        if n % 10 in (1, 3, 7, 9):
            alive[n] = 1                     # the kept 40%
    p = 3                                    # seed: 3 is not in the 40%, so start with it
    while p * p <= x:                        # stop rule: p^2 > x
        k, crossed = p, []
        while p * k <= x:                    # remove p*p, then p*k with k ending 1,3,7,9
            if alive[p * k]:
                alive[p * k] = 0
                crossed.append(p * k)
            k += STEP[k % 10]
        if show:
            print(f"pick up {p:>3}: remove from {p*p}, new removals {len(crossed):>4}"
                  f"  first {crossed[:6]}")
        q = p + 1                            # next pick-up = smallest survivor above p
        while q <= x and not alive[q]:
            q += 1
        p = q
    if show:
        print(f"stop: next pick-up {p}, and {p}^2 = {p*p} > {x}")
    return [q for q in (2, 3, 5) if q <= x] + [n for n in range(7, x + 1) if alive[n]]


if __name__ == "__main__":
    x = int(sys.argv[1]) if len(sys.argv) > 1 else 300
    primes = pickup_sieve(x, show=True)
    print(f"{len(primes)} primes up to {x}; last ten: {primes[-10:]}")
    print("\nCHECK against sympy's list of primes:")
    bad = [y for y in range(10, 5001) if pickup_sieve(y) != list(sympy.primerange(2, y + 1))]
    print(f"  every x from 10 to 5,000: {'PASS' if not bad else 'FAIL ' + str(bad[:5])}")
    big = pickup_sieve(10**6) == list(sympy.primerange(2, 10**6 + 1))
    print(f"  x = 1,000,000: {'PASS' if big else 'FAIL'}")
