#!/bin/sh
# Build both papers with XeLaTeX and BibTeX. Needs a TeX distribution and the STIX Two fonts.
set -e
cd "$(dirname "$0")"
for p in sieve-window zeta-map; do
  (cd "$p" && xelatex -interaction=nonstopmode "$p.tex" >/dev/null && bibtex "$p" >/dev/null \
    && xelatex -interaction=nonstopmode "$p.tex" >/dev/null && xelatex -interaction=nonstopmode "$p.tex" >/dev/null \
    && rm -f "$p".aux "$p".log "$p".blg "$p".out "$p".bbl && echo "built $p/$p.pdf")
done
