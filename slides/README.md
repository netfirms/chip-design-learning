# Learning decks

One slide deck per module of the [course](../docs/learning-path.md). Each
deck goes further than the module text: theory, diagrams, the RTL explained
line by line, tool commands with real output, results after place and route,
exercises, key takeaways and an end-of-module quiz.

## Quizzes

Every deck ends with a two-slide quiz: eight questions, a mix of multiple
choice and short answer, on the numbers and ideas from that module. Use them
as a self-check or as a ten-minute class quiz.

The answer keys, with an explanation for each answer, are kept off the main
branch so students can try the quiz first. They are on the
[`quiz-answers`](https://github.com/netfirms/chip-design-learning/tree/quiz-answers/slides/answers) branch, in
`slides/answers/`.

| #  | Deck | Design | Slides |
| -- | ---- | ------ | -----: |
| 1  | [The flow, end to end](01-flow.md) | `counter` | 24 |
| 2  | [Sequential control and timers](02-pwm.md) | `pwm` | 17 |
| 3  | [Fixed-point arithmetic](03-fixed-point.md) | primer | 18 |
| 4  | [FIR filters](04-fir.md) | `fir` | 20 |
| 5  | [IIR filters](05-iir.md) | `iir` | 17 |
| 6  | [The FFT](06-fft.md) | `fft` | 18 |
| 6b | [The FFT in software vs in hardware](06b-codesign.md) | `fft` + `codesign/` | 17 |
| 6c | [The analog bridge: ADC and DAC](06c-analog-bridge.md) | `analog/` | 24 |
| 7  | [Timing, area and power](07-ppa.md) | all | 18 |
| 8  | [Your own design and tapeout](08-tapeout.md) | yours | 18 |
| +  | [Verification with cocotb](09-verification.md) (side module) | all | 20 |
| 9  | [A RISC-V CPU that runs C](10-riscv.md) | `riscv` | 22 |
| 10 | [Capstone: the FIR on Tiny Tapeout](11-tinytapeout.md) | `tt_fir` | 17 |

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
  make slides-site  # build/slides-site/: index page with a card per deck (open index.html)
  ```

- **CI:** every push builds the PDFs and the deck site; download them from the
  `slides-pdf` and `slides-site` artifacts of the workflow run.

## Layout

```
slides/
  01-flow.md ... 11-tinytapeout.md  the decks
  site/index.html                the deck index page used by `make slides-site`
  theme/course.css               the Marp theme (title, exercise, quiz and small slide classes)
  images/                        diagrams and plots made by figures.py
  figures.py                     regenerates slides/images/ (numpy + matplotlib)
  figures_verification.py        the verif_*.png figures for 09-verification.md
  figures_riscv.py               the riscv_*.png figures for 10-riscv.md
```

Layout renders, simulation plots and SVG diagrams come from
[`docs/images/`](../docs/images/), so the decks and the docs show the same
pictures.

## Editing

- Slide classes: `<!-- _class: lead -->` for a title slide,
  `<!-- _class: exercise -->` for exercises, `<!-- _class: quiz -->` for the
  quiz, `<!-- _class: small -->` for a
  dense slide. Two columns: `<div class="cols"><div>...</div><div>...</div></div>`.
- Change a diagram in `figures.py`, then `python3 slides/figures.py`.
- Keep numbers in the decks in step with the designs: coefficients, widths
  and cycle counts come from the RTL, and area/timing/power from the Module 7
  table in `docs/learning-path.md`.
