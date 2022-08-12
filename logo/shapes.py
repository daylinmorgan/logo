def circle(dwg, g, coord):
    move_to = (str(coord.dc.x - coord.dr), str(coord.dc.y))

    circle = dwg.circle(center=coord.dc, r=coord.dr, class_="d")
    filled = dwg.path(
        d=f"M {','.join(move_to)} a 1 1 0 0 0 {coord.dr*2} 0 z", class_="fg d"
    )
    g.add(circle)
    g.add(filled)


def m(dwg, g, coord):
    start_end_offset = 0.15 * (coord.mx1)
    move_to = (str(coord.mc.x - coord.mx1 - start_end_offset), str(coord.mc.y))
    m = dwg.path(
        d=f"M {','.join(move_to)}"
        f"l -{coord.mx2},0 "
        f"l {coord.mx2/2},-{coord.my2} "
        f"l {coord.mx2/2+coord.mx1+start_end_offset},{coord.my2+coord.my1} "
        f"l {coord.mx1+coord.mx2/2+start_end_offset},-{coord.my1+coord.my2} "
        f"l {coord.mx2/2},{coord.my2} "
        f"l -{coord.mx2}, 0"
    )

    g.add(m)
