# Package

version       = "0.1.0"
author        = "Daylin Morgan"
description   = "Daylin's handy logo generator"
license       = "MIT"
srcDir        = "src"
bin           = @["logo"]
binDir        = "bin"


# Dependencies

requires "nim >= 2.0.0",
         "nimsvg"

proc getSvgs(): seq[string] =
  (gorgeEx "find -type f -wholename \"./docs/*.svg\"").output.split("\n")

proc makePng(svg: string) =
  echo svg & " -> " & svg.replace("svg","png")
  exec "inkscape --export-filename=" & svg.replace("svg","png") & " " & svg

task pngs, "generate pngs":
  for svg in getSvgs():
    makePng(svg)
