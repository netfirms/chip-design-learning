# Quiz answer keys

This branch holds the answers to the quiz at the end of every module deck.
It is kept off the main branch so students can try each quiz first.

| Module | Answers |
| -----: | ------- |
| 1 | [The flow, end to end](01-flow.md) |
| 2 | [Sequential control and timers](02-pwm.md) |
| 3 | [Fixed-point arithmetic](03-fixed-point.md) |
| 4 | [FIR filters](04-fir.md) |
| 5 | [IIR filters](05-iir.md) |
| 6 | [The FFT](06-fft.md) |
| 7 | [Timing, area and power](07-ppa.md) |
| 8 | [Your own design and tapeout](08-tapeout.md) |

## Changing a question

The questions and answers have one source, `quiz_data.py`. Edit it, then
from the repo root:

```sh
python3 slides/answers/make_quizzes.py --answers   # rewrites the quiz slides in every deck and these keys
```

Commit the deck changes (`slides/0*.md`) to the main branch, and keep the
files in `slides/answers/` only on this branch.
