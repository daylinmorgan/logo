import argparse


def get_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("-bg", "--background", help="background")
    parser.add_argument("-b", "--border", help="include border", action="store_true")
    parser.add_argument("--debug", help="add grid to debug logo", action="store_true")
    parser.add_argument(
        "-o", "--output", help="output file to save to", default="logo.svg"
    )
    parser.add_argument(
        "-t",
        "--theme",
        help="theme for color [light,dark][default: dark]",
        default="dark",
    )
    parser.add_argument("--no-minify", help="pretty print svg", action="store_true")

    return parser.parse_args()
