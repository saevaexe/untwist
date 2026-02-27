"""Fix preview 5: Replace phone emoji with arrow in CTA button"""
from PIL import Image, ImageDraw, ImageFont
import os

SRC = "/Users/osmanseven/Untwist/AppStore/Previews/appstore_en_5.png"
OUT = "/Users/osmanseven/Untwist/AppStore/Previews/appstore_en_5.png"

img = Image.open(SRC).convert("RGBA")
draw = ImageDraw.Draw(img)

# Emoji location: roughly x=775..810, y=2630..2672
# Button is white background
# Cover emoji with white
EMOJI_X1, EMOJI_Y1 = 770, 2625
EMOJI_X2, EMOJI_Y2 = 815, 2675

draw.rectangle([(EMOJI_X1, EMOJI_Y1), (EMOJI_X2, EMOJI_Y2)], fill=(255, 255, 255, 255))

# Draw arrow "→" in same position
# Text color matches "Let's Go!" which is ~(107, 95, 212) purple
text_color = (107, 95, 212)

for p in ["/System/Library/Fonts/Supplemental/Arial Bold.ttf",
          "/System/Library/Fonts/Supplemental/Arial.ttf"]:
    if os.path.exists(p):
        font = ImageFont.truetype(p, 42)
        break

# Center arrow in the cleared area
arrow = "\u2192"
bbox = draw.textbbox((0, 0), arrow, font=font)
aw = bbox[2] - bbox[0]
ah = bbox[3] - bbox[1]
ax = EMOJI_X1 + (EMOJI_X2 - EMOJI_X1 - aw) // 2
ay = EMOJI_Y1 + (EMOJI_Y2 - EMOJI_Y1 - ah) // 2
draw.text((ax, ay), arrow, font=font, fill=(*text_color, 255))

img.convert("RGB").save(OUT, quality=95)
print(f"Saved: {OUT}")
