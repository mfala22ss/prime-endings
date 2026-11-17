"""Tables of the multiples of 3, highlighting those inside the 40% (ending in 1, 3, 7, 9).

Page 1: multiples of 3 up to 333 in rows of 10 (111 numbers).
Page 2: a 33 x 33 grid of the first 1,089 multiples of 3 (3 to 3,267).

Writes data/multiples_of_3_33x33.csv and docs/tables/Multiples_of_3.pdf.
Run from the repository root:  python3 python/tables/multiples_of_3.py
"""
import csv
import pathlib
import subprocess

ROOT = pathlib.Path(__file__).resolve().parents[2]
in40 = lambda n: n > 5 and n % 10 in (1, 3, 7, 9)

small = [3 * k for k in range(1, 112)]                       # 3 .. 333
grid = [[3 * (33 * r + c + 1) for c in range(33)] for r in range(33)]
flat = [v for row in grid for v in row]

with open(ROOT / "data" / "multiples_of_3_33x33.csv", "w", newline="") as f:
    w = csv.writer(f); w.writerows(grid)

n_small = sum(map(in40, small)); n_grid = sum(map(in40, flat))


def cells(values):
    out = []
    for v in values:
        out.append(f'hl[{v}]' if in40(v) else f'[{v}]')
    return ", ".join(out)


rows_small = [small[i:i + 10] for i in range(0, len(small), 10)]
typ = f"""
#set page(paper: "a3", flipped: true, margin: 1.4cm, fill: rgb("#202124"))
#set text(font: "Helvetica Neue", fill: rgb("#e8eaed"))
#let hl(body) = box(fill: rgb("#f2b84b"), inset: (x: 3pt, y: 1.5pt), radius: 2pt,
  text(fill: rgb("#202124"), weight: "bold", body))
#let legend = [#hl[51] = ends in 1, 3, 7 or 9: inside the 40%, a non-prime that 3 removes in the sieve]

#text(size: 20pt, weight: "bold")[Multiples of 3 up to 333]
#v(2pt)
#text(size: 10pt, fill: rgb("#9aa0a6"))[111 multiples in rows of 10. {n_small} of them are inside the 40%. #legend]
#v(10pt)
#set text(size: 14pt)
#table(columns: 10, stroke: (x, y) => (bottom: 0.5pt + rgb("#3c4043")), inset: (x: 8pt, y: 9pt),
  {cells(small)})

#pagebreak()
#set text(size: 9pt)
#text(size: 20pt, weight: "bold")[33 × 33 grid of multiples of 3 (3 to 3,267)]
#v(2pt)
#text(size: 10pt, fill: rgb("#9aa0a6"))[1,089 multiples; row r, column c holds 3 × (33(r − 1) + c). {n_grid} of them are inside the 40%. #legend]
#v(8pt)
#table(columns: 33, stroke: (x, y) => (bottom: 0.4pt + rgb("#3c4043")), inset: (x: 2.2pt, y: 4.2pt),
  {cells(flat)})
"""
out_dir = ROOT / "docs" / "tables"; out_dir.mkdir(parents=True, exist_ok=True)
src = ROOT / "_multiples.typ"; src.write_text(typ)
subprocess.run(["typst", "compile", str(src), str(out_dir / "Multiples_of_3.pdf")], check=True)
src.unlink()
print(f"up to 333: {len(small)} multiples, {n_small} inside the 40%")
print(f"33 x 33:   {len(flat)} multiples (last {flat[-1]}), {n_grid} inside the 40%")
print("wrote data/multiples_of_3_33x33.csv and docs/tables/Multiples_of_3.pdf")
