#!/usr/bin/env python3

from logo import generate
from pathlib import Path
import sys

def main():
    rev = sys.argv[1]
    comment =f"© 2022 Daylin Morgan | rev. {rev}"

    if not (Path.cwd() / "docs" / "svg").is_dir():
        print("making docs directory")
        (Path.cwd() / "docs" / "svg").mkdir(exist_ok=True)

    for theme in ['dark','light']:
        for background in ['rect','circle',None]:
            for border in [True,False]:
                name = ['logo']
                if background:
                    name.append(f"bg-{background}")
                if border:
                    name.append(f"b")

                name.append(theme)
                name = f"docs/svg/{'-'.join(name)}.svg"
                generate(name=name,background=background,border=border,theme=theme,comment=comment)

        generate(name=f"docs/{theme}.svg",background="circle",border=True,theme=theme,comment=comment)

if __name__ == "__main__":
    main()
