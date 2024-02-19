import std/[os, strformat, strutils, sugar]
import nimsvg

const
  baseCSS = slurp "css/base.css"
  lightCSS = slurp "css/light.css"
  darkCSS = slurp "css/dark.css"
  animateCss = slurp "css/animation.css"
  version = staticExec "git describe --tags HEAD --always"
  scale = 800

type
  Style = enum
    stLight = "light"
    stDark = "dark"
  Background = enum
    bgNone = "none"
    bgCircle = "circle"
    bgSquare ="square"

  Point = object
    x, y: float64
  Logo = object
    background: Background
    animate, border: bool
    style: Style

  LogoContext = object
    border, animate: bool
    output: string
    backgrounds: seq[Background]
    styles: seq[Style]


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

  buildSvg:
    path(
      `class` ="m",
      d = &"""
        M {moveTo.x},{moveTo.y}
        l -{coord.mx2},0
        l {coord.mx2/2},-{coord.my2}
        l {coord.mx2/2+coord.mx1+startEndOffset},{coord.my2+coord.my1}
        l {coord.mx1+coord.mx2/2+startEndOffset},-{coord.my1+coord.my2}
        l {coord.mx2/2},{coord.my2}
        l -{coord.mx2}, 0
        """
    )


proc drawD(animate: bool): Nodes =
  let start = Point(x: coord.dc.x - coord.dr, y: coord.dc.y)
  buildSvg:
    g(class = "d"):
      if animate:
        let coords = $coord.dc.x & " " & $coord.dc.y
        animateTransform(attributeName="transform", begin="0s" ,dur="2.25s", type="rotate", `from`="0 " & coords, to="360 " & coords)
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

proc addStyle(l: Logo): Nodes =
  var css: string
  case l.style:
    of stDark: css &= darkCSS
    of stLight: css &= lightCSS
  css &= baseCSS
  if l.animate:
    css &= animateCss
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
  echo "generating logo at: ", fname
  buildSvgFile(fname):
    t: &"<!-- © 2024 Daylin Morgan | rev. {version} -->"
    svg(height = scale, width = scale):
      defs: embed addStyle(l)
      if l.background != bgNone: embed addBackground(l.background, l.border)
      g(class = "fg logo"):
        embed drawM()
        embed drawD(l.animate)

when isMainModule:
  import std/parseopt
  const usage = """
logo [opts]

options:
  -h, --help
    show this help
  -a, --animate
    add animation to logo
  -o, --output
    output file or path
  -b, --background
    comma-seperated list of backgrounds [none,square,circle]
  -s, --style
    comma-seperated list of styles [light,dark]
  --border
    add border
"""

  var c = LogoContext()
  for kind, key, val in getopt(shortNoVal = {'h','a'}, longNoVal = @["help","animate","border"]):
    case kind
    of cmdArgument: echo "unexpected positional arg: " & key; quit 1
    of cmdShortOption, cmdLongOption:
      case key
      of "h", "help":
        echo usage; quit 0;
      of "a","animate":
        c.animate = true
      of "o", "output":
        c.output = val
      of "b","background":
        for bg in val.split(","):
          c.backgrounds.add parseEnum[Background](bg)
      of "s","style":
        for s in val.split(","):
          c.styles.add parseEnum[Style](s)
      of "border":
        c.border = true
      else:
        echo "unknown key-value flag: " & key & "," & val
    of cmdEnd: discard

  if c.backgrounds.len == 0 or c.styles.len == 0:
    echo "must provide at least one value for background/style"
    quit 1

  let logos = collect:
    for bg in c.backgrounds:
      for style in c.styles:
        Logo(
            background: bg,
            border: c.border,
            style: style,
            animate: c.animate
          )
  if logos.len == 1:
    echo "treating output as filename"
    makeLogo(logos[0], prefix = "", fileName = c.output)
  else:
    for logo in logos:
      makeLogo(logo, prefix = c.output)

