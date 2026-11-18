# Contributing

Thank you for your interest. Contributions are welcome **by request**: nobody but the owner can change this repository directly. Every change from anyone else goes through a pull request that the owner reviews and approves before it is merged.

## How to propose a change

1. **Open an issue first** describing what you want to add, fix or check, and why. This avoids work on something that will not be merged.
2. **Fork** the repository and make your change on a branch in your fork.
3. **Open a pull request** against `main`, linking the issue. Explain what changed and how you checked it.
4. The owner reviews it. It is merged only after approval.

## What a change must include

This project's rule is that every result is computed, checked and documented in the same change:

* **Code:** a script in `python/steps/` (or a Lean change in `lean/`), with its output saved in `results/`.
* **Lean:** proofs must compile against current Mathlib with no `sorry` and only the standard axioms (`propext`, `Quot.sound`, `Classical.choice`). Add new theorems to `lean/Challenge.lean` and `lean/config.json`.
* **Documentation:** a new step in `WALKTHROUGH.md`, and an update to every part of `README.md` that the change affects.
* **Papers:** if a number quoted in `papers/` changes, update the paper and `papers/verify_numbers.py` so that all checks still pass.
* **Accuracy:** state what was measured and how. Mark anything not proved as tested or as unproved; do not present a known result as new.

## Licensing of contributions

By contributing, you agree that code you contribute is licensed under the MIT License and written material under CC BY 4.0, as described in [LICENSE](LICENSE).

## Citing

If this work helps you, please cite it using [CITATION.cff](CITATION.cff).
