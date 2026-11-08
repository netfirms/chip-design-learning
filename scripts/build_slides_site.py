#!/usr/bin/env python3
"""Assemble the browsable learning-deck site in build/slides-site/.

Run `make slides-site`, which renders the decks first. This script:
  * copies slides/site/index.html (the deck index page),
  * copies every rendered deck (slides/NN-*.html) into slides/,
  * adds an "All decks" button to each deck that links back to the index,
  * copies only the images the decks reference (slides/images, docs/images),
  * checks that every deck has a card on the index page.

Title-slide thumbnails (thumbs/*.png) are rendered by the Makefile with Marp.
The site is static: open build/slides-site/index.html or serve the folder.
"""
import re
import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SLIDES = ROOT / "slides"
OUT = ROOT / "build" / "slides-site"

BACK = (
    '<a href="../index.html" style="position:fixed;'
    "top:calc(10px + env(safe-area-inset-top,0px));"
    "left:calc(10px + env(safe-area-inset-left,0px));z-index:9999;"
    "font:600 13px system-ui,sans-serif;color:#fff;"
    "background:rgba(15,110,140,.85);padding:6px 12px;border-radius:6px;"
    'text-decoration:none">&larr; All decks</a>'
)
IMAGE = re.compile(r"(?:\.\./docs/images|images)/[A-Za-z0-9_.-]+")


def main() -> int:
    decks = sorted(SLIDES.glob("[0-9]*.md"))
    (OUT / "slides").mkdir(parents=True, exist_ok=True)
    index = (SLIDES / "site" / "index.html").read_text()
    (OUT / "index.html").write_text(index)

    images = set()
    missing_cards = []
    for md in decks:
        html = md.with_suffix(".html")
        if not html.exists():
            print(f"error: {html.relative_to(ROOT)} not rendered, run `make slides`", file=sys.stderr)
            return 1
        text = html.read_text()
        cut = text.rfind("</body>")
        (OUT / "slides" / html.name).write_text(text[:cut] + BACK + text[cut:])
        images.update(IMAGE.findall(md.read_text()))
        if f'href="slides/{html.name}"' not in index:
            missing_cards.append(md.name)

    for ref in sorted(images):
        src = (SLIDES / ref).resolve()
        dst = OUT / src.relative_to(ROOT)
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dst)

    print(f"slides-site: {len(decks)} decks, {len(images)} images -> {OUT.relative_to(ROOT)}/")
    if missing_cards:
        print("warning: no card in slides/site/index.html for: " + ", ".join(missing_cards), file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
