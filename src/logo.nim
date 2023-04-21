import std/[os, strformat, strutils]
import nimsvg

const
  baseCSS = slurp "css/base.css"
  lightCSS = slurp "css/light.css"
  darkCSS = slurp "css/dark.css"
  version = staticExec "git describe --tags HEAD --always"

type
  Style = enum
    stLight, stDark
  Background = enum
    bgNone, bgCircle, bgSquare
  Point = object
    x, y: float64
  Logo = object
    background: Background
    border: bool
    style: Style


const scale = 800


proc calcCoordinates(my1, my2, mx1, mx2, dr, gap: float64): tuple[my1, my2, mx1,
      mx2, dr, gap: float64, mc, dc: Point] =

  # not very DRY...
  result.my1 = my1 * scale
  result.my2 = my2 * scale
  result.mx1 = mx1 * scale
  result.mx2 = mx2 * scale
  result.dr = dr * scale
  result.gap = gap * scale

  let u = (scale - result.my1 - result.my2 - result.dr) / 2
  # v = SCALE / 2 - (self.mx1 + self.mx2)
  # assert D_R < M_X1 + M_X2/2

  # Coordinate Shape Centers
  result.mc = Point(x: scale / 2, y: u + result.dr + result.my2)
  result.dc = Point(x: scale / 2, y: u + result.dr)


const coord = calcCoordinates(
    my1 = 0.15,
    my2 = 0.35,
    mx1 = 0.13,
    mx2 = 0.2,
    dr = 0.17,
    gap = 0.025,
)

proc drawM(): Nodes =
  let startEndOffset = 0.15 * (coord.mx1)
  let moveTo = Point(x: coord.mc.x - coord.mx1 - startEndOffset, y: coord.mc.y)

  # path(
  buildSvg:
    path(d = &"""
        M {moveTo.x},{moveTo.y}
        l -{coord.mx2},0
        l {coord.mx2/2},-{coord.my2}
        l {coord.mx2/2+coord.mx1+startEndOffset},{coord.my2+coord.my1}
        l {coord.mx1+coord.mx2/2+startEndOffset},-{coord.my1+coord.my2}
        l {coord.mx2/2},{coord.my2}
        l -{coord.mx2}, 0
        """
    )


proc drawD(): Nodes =
  let start = Point(x: coord.dc.x - coord.dr, y: coord.dc.y)
  buildSvg:
    g(class = "d"):
      circle(cx = coord.dc.x, cy = coord.dc.y, r = coord.dr)
      path(class = "fg", d = &"M {start.x},{start.y} a 1 1 0 0 0 {coord.dr*2} 0 z")

proc addBackground(bg: Background, border: bool = true): Nodes =
  buildSvg:
    g:
      if bg == bgCircle:
        circle(class = "background", cx = scale/2, cy = scale/2, r = scale/2)
        if border:
          circle(class = "fg border", cx = scale/2, cy = scale/2, r = (
              scale-2*coord.gap)/2)
      elif bg == bgSquare:
        rect(class = "background", height = scale, width = scale, x = 0, y = 0)
        if border:
          rect(class = "fg border", height = scale-2*coord.gap,
              width = scale-2*coord.gap, x = coord.gap, y = coord.gap)

proc addStyle(s: Style): Nodes =
  var css: string
  case s:
    of stDark: css &= darkCSS
    of stLight: css &= lightCSS
  css &= baseCSS
  buildSvg:
    style(type = "text/css"):
      t: css

proc fname(l: Logo): string =
  var name = @["logo"]
  case l.background
    of bgSquare: name.add("bg-rect")
    of bgCircle: name.add("bg-circle")
    else: discard
  case l.border:
    of true: name.add("b")
    else: discard
  case l.style:
    of stLight: name.add("light")
    of stDark: name.add("dark")

  name.join("-") & ".svg"

proc makeLogo(l: Logo, prefix = "docs/svg", fileName = "") =
  if not dirExists(prefix): createDir(prefix)
  let fname = prefix / (if fileName == "": l.fname() else: fileName)

  buildSvgFile(fname):
    t: &"<!-- © 2023 Daylin Morgan | rev. {version} -->"
    svg(height = scale, width = scale):
      defs: embed addStyle(l.style)
      if l.background != bgNone: embed addBackground(l.background, l.border)
      g(class = "fg logo"):
        embed drawM()
        embed drawD()

when isMainModule:
  for bg in @[bgNone, bgSquare, bgCircle]:
    for style in @[stLight, stDark]:
      for border in @[true, false]:
        Logo(
          background: bg,
          border: border,
          style: style
        ).makeLogo()

  let defaults = @[
    (Logo(background: bgCircle, border: true, style: stDark), "light.svg"),
    (Logo(background: bgCircle, border: true, style: stLight), "dark.svg")
  ]
  for (logo, fname) in defaults:
    logo.makeLogo(fileName = fname, prefix = "docs")

  when defined(makeDefault):
    Logo(background: bgCircle, border: true, style: stDark).makeLogo(
      prefix = "assets", "logo.svg")
