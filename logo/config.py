from collections import namedtuple
from dataclasses import dataclass

Center = namedtuple("Center", "x y")

SCALE = 800


@dataclass
class Coordinates:
    """Class for housing/calculating relevant cordinates"""

    my1: int
    my1: int
    my2: int
    mx1: int
    mx2: int
    dr: int
    border_gap: int

    def __post_init__(self):
        self.scale_coordinates(SCALE)

        # Nominal Values
        u = (SCALE - self.my1 - self.my2 - self.dr) / 2
        # v = SCALE / 2 - (self.mx1 + self.mx2)
        # assert D_R < M_X1 + M_X2/2

        # Coordinate Shape Centers
        self.mc = Center(SCALE / 2, u + self.dr + self.my2)
        self.dc = Center(SCALE / 2, u + self.dr)

    def scale_coordinates(self, scale):
        for k in self.__dataclass_fields__:
            v = getattr(self, k)
            setattr(self, k, v * scale)


coord = Coordinates(
    my1=0.15,
    my2=0.35,
    mx1=0.13,
    mx2=0.2,
    dr=0.17,
    border_gap=0.025,
)
