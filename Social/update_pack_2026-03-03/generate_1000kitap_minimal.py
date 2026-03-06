#!/usr/bin/env python3
"""
Generate one minimal 1000Kitap visual with sincere copy + current home screenshot.
"""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont, ImageOps


OUT = Path("/Users/osmanseven/Untwist/Social/update_pack_2026-03-03/images/1000kitap/1000kitap_minimal_1080x1350.png")
SHOT = Path("/Users/osmanseven/Untwist/AppStore/screenshots/Simulator Screenshot - iPhone 16e - 2026-02-27 at 17.23.19.png")

W, H = 1080, 1350
BG = (246, 245, 241)
INK = (38, 44, 52)
MUTED = (92, 100, 108)

TEXT_BLOCKS = [
    ("Merhaba 1000Kitap ailesi.", INK, 56, True),
    ("Bazen bizi yoran şey, yaşadığımızdan çok zihnimizde büyüttüğümüz düşünceler oluyor.", MUTED, 35, False),
    ("Bu döngüyü çözmek için Untwist'i geliştirdim.", MUTED, 35, False),
]


def load_font(size: int, bold: bool = False):
    paths = [
        "/Library/Fonts/SF-Pro-Display-Bold.otf" if bold else "/Library/Fonts/SF-Pro-Text-Regular.otf",
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf" if bold else "/System/Library/Fonts/Supplemental/Arial.ttf",
    ]
    for p in paths:
        fp = Path(p)
        if fp.exists():
            try:
                return ImageFont.truetype(str(fp), size)
            except OSError:
                continue
    return ImageFont.load_default()


def wrap(draw: ImageDraw.ImageDraw, text: str, font: ImageFont.FreeTypeFont, max_w: int):
    words = text.split()
    if not words:
        return [""]
    lines = []
    cur = words[0]
    for w in words[1:]:
        t = cur + " " + w
        if draw.textbbox((0, 0), t, font=font)[2] <= max_w:
            cur = t
        else:
            lines.append(cur)
            cur = w
    lines.append(cur)
    return lines


def main():
    OUT.parent.mkdir(parents=True, exist_ok=True)

    img = Image.new("RGB", (W, H), BG)
    draw = ImageDraw.Draw(img)

    y = 74
    for text, color, size, is_bold in TEXT_BLOCKS:
        font = load_font(size, bold=is_bold)
        for line in wrap(draw, text, font, 952):
            draw.text((64, y), line, font=font, fill=color)
            y += 66 if is_bold else 48
        y += 18

    shot_h = 812
    shot = ImageOps.fit(Image.open(SHOT).convert("RGB"), (952, shot_h), method=Image.Resampling.LANCZOS)
    mask = Image.new("L", (952, shot_h), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, 951, shot_h - 1), radius=36, fill=255)

    card = Image.new("RGBA", (952, shot_h), (255, 255, 255, 0))
    card.paste(shot, (0, 0), mask)

    shadow = Image.new("RGBA", (1008, shot_h + 56), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle((28, 28, 980, shot_h + 28), radius=42, fill=(0, 0, 0, 58))
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=14))

    top = y + 14
    img = img.convert("RGBA")
    img.alpha_composite(shadow, (36, top - 10))
    img.alpha_composite(card, (64, top))

    img.convert("RGB").save(OUT, "PNG")
    print(OUT)


if __name__ == "__main__":
    main()
