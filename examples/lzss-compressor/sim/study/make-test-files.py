# This script turns an image into uncompressed pixel files (raw RGB and raw grayscale) that the codecs can meaningfully test.
# Usage: python make-test-files.py picture.png   (needs: pip install pillow; writes picture_raw_rgb.bin and picture_raw_gray.bin next to it)
import os, sys
from PIL import Image

# This function converts one image file into raw pixel dumps, shrinking it so it fits easily on the board side.
# path: the image to convert.  max_side: the longest side in pixels after shrinking.
def convert(path, max_side=200):
    # Open the image and force plain RGB (drops palettes and transparency).
    img = Image.open(path).convert("RGB")
    # Shrink so the longest side is at most max_side pixels (keeps the aspect ratio).
    img.thumbnail((max_side, max_side))
    # Name the outputs after the input file.
    stem = os.path.splitext(path)[0]
    # Write the raw RGB bytes: 3 bytes per pixel, row by row, no header.
    open(stem + "_raw_rgb.bin", "wb").write(img.tobytes())
    # Write the raw grayscale bytes: 1 byte per pixel.
    open(stem + "_raw_gray.bin", "wb").write(img.convert("L").tobytes())
    # Report what was written.
    print("%s -> %dx%d pixels, %d bytes RGB, %d bytes gray" % (path, img.width, img.height, img.width * img.height * 3, img.width * img.height))

# This runs the conversion for every file named on the command line.
if __name__ == "__main__":
    for p in sys.argv[1:]:
        convert(p)
