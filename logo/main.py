import svgwrite

from .cli import get_args
from .config import SCALE, coord
from .shapes import circle, m
from .utils import debug, get_style, minify_css


def generate(
    name, background, border, theme, comment=None, debug_mode=False, no_minify=False
):
    if comment and any([debug_mode, no_minify]):
        raise ValueError("Can't specify comment and pretty output (debug/no-minify)")

    print(f"generating: {name}")
    dwg = svgwrite.Drawing(filename=name, size=(SCALE, SCALE), debug=debug)
    style = get_style(theme)
    dwg.defs.add(dwg.style(style if (debug_mode or no_minify) else minify_css(style)))

    bg = dwg.add(dwg.g(id="bg", class_="background"))
    if background == "rect":
        bg.add(dwg.rect(insert=(0, 0), size=(SCALE,) * 2))
        if border:
            bg.add(
                dwg.rect(
                    insert=(coord.border_gap, coord.border_gap),
                    size=(
                        (SCALE - 2 * coord.border_gap),
                        (SCALE - 2 * coord.border_gap),
                    ),
                    class_="fg border",
                )
            )

    elif background == "circle":
        bg.add(dwg.circle((SCALE / 2,) * 2, r=SCALE / 2))
        if border:
            bg.add(
                dwg.circle(
                    (SCALE / 2,) * 2,
                    r=(SCALE - 2 * coord.border_gap) / 2,
                    class_="fg border",
                )
            )

    logo = dwg.add(dwg.g(id="m", class_="fg logo"))
    m(dwg, logo, coord)
    circle(dwg, logo, coord)

    if debug_mode:
        debug(dwg, SCALE)

    if comment:
        with open(name, "w") as f:
            f.write(f"<!-- {comment} -->\n")
            f.write(dwg.tostring())
    else:
        dwg.save(pretty=(debug_mode or no_minify))


def main():
    args = get_args()
    generate(
        args.output,
        args.background,
        args.border,
        args.theme,
        args.debug,
        args.no_minify,
    )
