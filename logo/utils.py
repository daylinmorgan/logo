from importlib.resources import files


def read_css(file):
    return files("logo").joinpath(f"css/{file}").read_text()


def minify_css(style):
    return "".join(style.split())


def get_style(theme="dark"):
    style = read_css(f"{theme}.css")
    style += read_css("base.css")
    return style


def debug(dwg, scale):
    hlines = dwg.add(dwg.g(id="hlines", stroke="green"))
    for y in range(0, scale, int(scale / 20)):
        hlines.add(dwg.line(start=(0, y), end=(scale, y)))
    vlines = dwg.add(dwg.g(id="vline", stroke="blue"))
    for x in range(0, scale, int(scale / 20)):
        vlines.add(dwg.line(start=(x, 0), end=(x, scale)))
