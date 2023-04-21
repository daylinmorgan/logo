#!/usr/bin/env -S nim e --hints:off
import std/[strformat]

type
  AsciiLogo = object
    braille: bool
    threshold: int
    color: bool
    height: int
    baseFile: string

const baseImg = "./docs/png/logo-dark.png"

proc fileName(al: AsciiLogo): string =
  result = "./docs/ascii-variants/logo"
  if al.braille:
    result &= "-braille"
  if al.threshold != 0:
    result &= &"-threshold{al.threshold}"
  if al.color:
    result &= "-color"
  if al.height != 0:
    result &= &"-h{al.height}"
  result &= ".txt"

proc make(al: AsciiLogo) =
  var cmd: string
  if al.baseFile != "":
    cmd = &"ascii-image-converter {al.baseFile}"
  else:
    cmd = &"ascii-image-converter {baseImg}"

  if al.braille:
    cmd &= " --braille "
  if al.threshold != 0:
    cmd &= &" --threshold {al.threshold} "
  if al.color:
    cmd &= &" --color "
  if al.height != 0:
    cmd &= &" --height {al.height} "

  cmd &= &" > {al.fileName}"
  exec cmd

when isMainModule:
  mkDir("./docs/ascii-variants/")
  for al in @[
    AsciiLogo(braille: true, threshold: 20),
    AsciiLogo(braille: true, height: 15, threshold: 20),
    AsciiLogo(braille: false, height: 50),
    AsciiLogo(color: true, height: 30, baseFile: "./docs/png/logo-bg-circle-b-dark.png")
  ]:
    al.make()

  cpFile("./docs/ascii-variants/logo-color-h30.txt", "./docs/ascii")
