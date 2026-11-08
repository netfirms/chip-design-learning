# Learning decks

One slide deck per module of the [course](../docs/learning-path.md). Each
deck goes further than the module text: theory, diagrams, the RTL explained
line by line, tool commands with real output, results after place and route,
exercises and key takeaways.

| #  | Deck | Design | Slides |
| -- | ---- | ------ | -----: |
| 1  | [The flow, end to end](01-flow.md) | `counter` | 22 |
| 2  | [Sequential control and timers](02-pwm.md) | `pwm` | 15 |
| 3  | [Fixed-point arithmetic](03-fixed-point.md) | primer | 16 |
| 4  | [FIR filters](04-fir.md) | `fir` | 18 |
| 5  | [IIR filters](05-iir.md) | `iir` | 15 |
| 6  | [The FFT](06-fft.md) | `fft` | 16 |
| 7  | [Timing, area and power](07-ppa.md) | all | 16 |
| 8  | [Your own design and tapeout](08-tapeout.md) | yours | 16 |
| 9  | [A RISC-V CPU that runs C](09-riscv.md) | `riscv` | 22 |

The decks are [Marp](https://marp.app/) Markdown: readable as plain Markdown
on GitHub, and rendered as slides by Marp.

## Viewing and presenting

- **VS Code:** install the "Marp for VS Code" extension, open a deck, and
  click the preview button. Set the theme by adding `slides/theme/course.css`
  to the extension's `markdown.marp.themes` setting.
- **HTML or PDF:** from the repo root (needs Node.js 18+; Chrome or Chromium
  for PDF):

  ```sh
  make slides       # slides/*.html, next to the decks (open in a browser, press F for full screen)
  make slides-pdf   # slides/pdf/*.pdf
  ```

- **CI:** every push builds the PDFs; download them from the `slides-pdf`
  artifact of the workflow run.

## Layout

```
slides/
  01-flow.md ... 09-riscv.md    the decks
  theme/course.css               the Marp theme (title, exercise and small slide classes)
  images/                        diagrams and plots made by figures.py
  figures.py                     regenerates slides/images/ (numpy + matplotlib)
  figures_riscv.py               the RISC-V deck's diagrams (python3 slides/figures_riscv.py)
```

Layout renders, simulation plots and SVG diagrams come from
[`docs/images/`](../docs/images/), so the decks and the docs show the same
pictures.

## Editing

- Slide classes: `<!-- _class: lead -->` for a title slide,
  `<!-- _class: exercise -->` for exercises, `<!-- _class: small -->` for a
  dense slide. Two columns: `<div class="cols"><div>...</div><div>...</div></div>`.
- Change a diagram in `figures.py`, then `python3 slides/figures.py`.
- Keep numbers in the decks in step with the designs: coefficients, widths
  and cycle counts come from the RTL, and area/timing/power from the Module 7
  table in `docs/learning-path.md`.
