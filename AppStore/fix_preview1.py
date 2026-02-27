"""Fix preview 1: Replace UNTANGLE with UNTWIST — pixel-perfect"""
from PIL import Image, ImageDraw, ImageFont
import os

SRC = "/Users/osmanseven/Downloads/files (2)/appstore_en_1.png"
OUT = "/Users/osmanseven/Untwist/AppStore/Previews/appstore_en_1_fixed.png"

img = Image.open(SRC).convert("RGBA")
w, h = img.size
pixels = img.load()

# UNTANGLE text: y=225..370, x=100..1130
# Background is flat dark purple ~(24, 20, 54) in this region
TEXT_Y1 = 222
TEXT_Y2 = 375
TEXT_X1 = 90
TEXT_X2 = 1140

# Paint over UNTANGLE with background gradient
overlay = Image.new("RGBA", img.size, (0, 0, 0, 0))
op = overlay.load()

for y in range(TEXT_Y1, TEXT_Y2):
    # Sample bg from far left edge (x=10..30, guaranteed no text)
    rs = [pixels[x, y][0] for x in range(8, 30)]
    gs = [pixels[x, y][1] for x in range(8, 30)]
    bs = [pixels[x, y][2] for x in range(8, 30)]
    bg = (sum(rs) // len(rs), sum(gs) // len(gs), sum(bs) // len(bs))

    for x in range(TEXT_X1, min(TEXT_X2, w)):
        op[x, y] = (*bg, 255)

img = Image.alpha_composite(img, overlay)
draw = ImageDraw.Draw(img)

# Draw "UNTWIST" matching original style
# Original UNTANGLE: white, ~130pt heavy/black, x starts at ~104, y starts at ~232
for p in ["/Library/Fonts/SF-Pro-Display-Black.otf",
          "/Library/Fonts/SF-Pro-Display-Heavy.otf",
          "/System/Library/Fonts/Supplemental/Arial Bold.ttf"]:
    if os.path.exists(p):
        font_path = p
        break

# Test sizes to match original UNTANGLE width (~1020px)
# UNTWIST is 7 chars vs UNTANGLE 8 chars, so same size font = ~890px width
font = ImageFont.truetype(font_path, 148)
text = "UNTWIST"
bbox = draw.textbbox((0, 0), text, font=font)
tw = bbox[2] - bbox[0]
print(f"Font: {font_path}, size 148, text width: {tw}px")

# Match original x position (104) and y position (232)
draw.text((104, 228), text, font=font, fill=(255, 255, 255, 255))

os.makedirs(os.path.dirname(OUT), exist_ok=True)
img.convert("RGB").save(OUT, quality=95)
print(f"Saved: {OUT}")
