# Papers

Two short manuscripts written in journal format (AMS article class), prepared for double-blind review.

| Folder | Paper | Pages |
|---|---|---|
| [`sieve-window/`](sieve-window/sieve-window.pdf) | *A window form of the sieve of Eratosthenes on the residues prime to ten, with a machine-checked proof* | 5 |
| [`zeta-map/`](zeta-map/zeta-map.pdf) | *The decimal sieve through the Riemann zeta function and a Dirichlet L-function: an expository account with numerical checks* | 4 |

Shared files:

* [`references.bib`](references.bib): every reference, each checked against its Crossref record (DOI included where one exists).
* [`verify_numbers.py`](verify_numbers.py): recomputes every number quoted in both papers (29 checks; output in [`../results/papers_verify_numbers.txt`](../results/papers_verify_numbers.txt)).
* [`build.sh`](build.sh): rebuilds both PDFs (XeLaTeX, BibTeX, STIX Two fonts).

The formal proofs cited in the first paper are in [`../lean/Solution.lean`](../lean/Solution.lean): `mul_coprime_ten`, `multiplier_range` and `window_sieve`, with the earlier `survives_iff`, `mem_primesSpec`, `sqrt_rule` and `prime_ending`.

## License

The papers, this folder and the repository's written documentation are licensed under [Creative Commons Attribution 4.0 International](LICENSE-CC-BY-4.0.txt) (CC BY 4.0): anyone may reuse or adapt them, provided they give appropriate credit. The code in the rest of the repository is under the MIT license. To cite this work, use [`../CITATION.cff`](../CITATION.cff).
