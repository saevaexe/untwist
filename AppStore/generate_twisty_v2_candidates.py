"""
Generate Twisty V2 candidate set from AppIcon style.

Output:
  AppStore/tmp/twisty_v2_candidate/masters/*.png
  AppStore/tmp/twisty_v2_candidate/twisty_v2_contact_sheet.png

The script does NOT touch current production Assets.xcassets.
"""

from __future__ import annotations

from pathlib import Path
import colorsys
import math

from PIL import Image, ImageDraw, ImageFilter, ImageFont


ROOT = Path(__file__).resolve().parent.parent
APPICON = ROOT / "Untwist" / "Resources" / "Assets.xcassets" / "AppIcon.appiconset" / "AppIcon.png"
OUT_DIR = ROOT / "AppStore" / "tmp" / "twisty_v2_candidate"
MASTER_DIR = OUT_DIR / "masters"

MOODS = [
    "TwistyHappy",
    "TwistyNeutral",
    "TwistySad",
    "TwistyCalm",
    "TwistyWaving",
    "TwistyThinking",
    "TwistyCelebrating",
    "TwistyBreathing",
    "TwistyReading",
]


def is_purple_bg(r: int, g: int, b: int) -> float:
    h, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
    d1 = math.dist((r, g, b), (36, 18, 68))
    d2 = math.dist((r, g, b), (86, 52, 132))
    d = min(d1, d2)

    if 0.63 <= h <= 0.92 and s > 0.14:
        if d <= 48:
            return 1.0
        if d <= 98:
            return (98 - d) / 50

    # Also remove dark floor glow/background haze.
    if v < 0.38 and d < 80:
        return max(0.5, (80 - d) / 80)

    return 0.0


def extract_mascot(appicon: Image.Image) -> Image.Image:
    src = appicon.convert("RGBA")
    w, h = src.size
    px = src.load()

    out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    out_px = out.load()
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            bg = is_purple_bg(r, g, b)
            new_a = int(a * (1.0 - bg))
            out_px[x, y] = (r, g, b, new_a)

    alpha = out.split()[-1].filter(ImageFilter.GaussianBlur(radius=1.2))
    alpha = alpha.point(lambda v: 0 if v < 14 else min(255, int((v - 14) * 1.15)))
    out.putalpha(alpha)

    bbox = out.getbbox()
    if not bbox:
        raise RuntimeError("Could not extract mascot from AppIcon.")
    mascot = out.crop(bbox)

    # Normalize to 1024 transparent canvas with consistent visual size.
    canvas = Image.new("RGBA", (1024, 1024), (0, 0, 0, 0))
    target = 760
    scale = min(target / mascot.width, target / mascot.height)
    resized = mascot.resize((int(mascot.width * scale), int(mascot.height * scale)), Image.LANCZOS)
    ox = (1024 - resized.width) // 2
    oy = 512 - resized.height // 2 - 8
    canvas.paste(resized, (ox, oy), resized)

    return canvas


def overlay_layer(base: Image.Image, draw_fn) -> Image.Image:
    layer = Image.new("RGBA", base.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    draw_fn(draw)
    return Image.alpha_composite(base, layer)


def draw_arc_smile(draw: ImageDraw.ImageDraw, box, start, end, color, width):
    draw.arc(box, start=start, end=end, fill=color, width=width)


def add_expression(base: Image.Image, mood: str) -> Image.Image:
    yarn_fill = (246, 188, 95, 238)
    line_color = (112, 28, 24, 255)
    blush = (245, 130, 86, 208)
    accent = (255, 223, 98, 255)
    breeze = (171, 234, 216, 235)

    if mood == "TwistyHappy":
        return base

    if mood == "TwistyNeutral":
        def draw_fn(d):
            d.ellipse((462, 534, 560, 598), fill=yarn_fill)
            d.rounded_rectangle((482, 560, 542, 568), radius=10, fill=line_color)
        return overlay_layer(base, draw_fn)

    if mood == "TwistySad":
        def draw_fn(d):
            d.ellipse((456, 526, 566, 610), fill=yarn_fill)
            draw_arc_smile(d, (484, 560, 542, 606), 200, 340, line_color, 8)
            d.arc((404, 430, 452, 462), start=210, end=335, fill=line_color, width=7)
            d.arc((570, 430, 620, 462), start=205, end=330, fill=line_color, width=7)
        return overlay_layer(base, draw_fn)

    if mood == "TwistyCalm":
        def draw_fn(d):
            d.ellipse((395, 440, 470, 510), fill=yarn_fill)
            d.ellipse((554, 440, 629, 510), fill=yarn_fill)
            d.ellipse((462, 530, 560, 600), fill=yarn_fill)
            draw_arc_smile(d, (414, 458, 452, 485), 200, 340, line_color, 7)
            draw_arc_smile(d, (574, 458, 612, 485), 200, 340, line_color, 7)
            draw_arc_smile(d, (490, 556, 534, 582), 20, 160, line_color, 7)
        return overlay_layer(base, draw_fn)

    if mood == "TwistyThinking":
        def draw_fn(d):
            d.ellipse((465, 536, 558, 602), fill=yarn_fill)
            d.ellipse((503, 564, 522, 582), fill=line_color)
            d.arc((392, 430, 452, 468), start=190, end=320, fill=line_color, width=8)
            d.ellipse((624, 328, 648, 352), fill=(250, 250, 250, 235))
            d.ellipse((652, 304, 686, 338), fill=(250, 250, 250, 235))
            d.ellipse((690, 268, 736, 314), fill=(250, 250, 250, 240))
        return overlay_layer(base, draw_fn)

    if mood == "TwistyWaving":
        def draw_fn(d):
            d.ellipse((700, 356, 756, 412), fill=accent)
            d.arc((742, 334, 790, 384), start=110, end=220, fill=accent, width=8)
            d.arc((766, 318, 814, 370), start=110, end=220, fill=accent, width=8)
        return overlay_layer(base, draw_fn)

    if mood == "TwistyCelebrating":
        def draw_fn(d):
            # Star-like sparkles around top.
            for cx, cy, r in [(398, 318, 18), (512, 282, 22), (626, 324, 16)]:
                d.polygon(
                    [
                        (cx, cy - r), (cx + r // 3, cy - r // 3), (cx + r, cy),
                        (cx + r // 3, cy + r // 3), (cx, cy + r), (cx - r // 3, cy + r // 3),
                        (cx - r, cy), (cx - r // 3, cy - r // 3),
                    ],
                    fill=accent
                )
            d.ellipse((448, 548, 572, 620), fill=yarn_fill)
            draw_arc_smile(d, (484, 560, 542, 602), 10, 170, line_color, 9)
            d.ellipse((430, 490, 470, 522), fill=blush)
            d.ellipse((554, 490, 594, 522), fill=blush)
        return overlay_layer(base, draw_fn)

    if mood == "TwistyBreathing":
        def draw_fn(d):
            d.ellipse((464, 538, 560, 604), fill=yarn_fill)
            draw_arc_smile(d, (488, 560, 538, 586), 20, 160, line_color, 7)
            for i, y in enumerate([468, 502, 536]):
                x0 = 690 + i * 10
                d.rounded_rectangle((x0, y, x0 + 92, y + 12), radius=8, fill=breeze)
                d.ellipse((x0 + 85, y - 4, x0 + 102, y + 16), fill=breeze)
        return overlay_layer(base, draw_fn)

    if mood == "TwistyReading":
        def draw_fn(d):
            d.rounded_rectangle((430, 618, 598, 710), radius=16, fill=(130, 108, 214, 255))
            d.rectangle((512, 622, 518, 704), fill=(236, 230, 252, 255))
            d.rounded_rectangle((441, 628, 507, 694), radius=10, fill=(168, 144, 228, 255))
            d.rounded_rectangle((523, 628, 587, 694), radius=10, fill=(168, 144, 228, 255))
            d.ellipse((462, 536, 560, 602), fill=yarn_fill)
            draw_arc_smile(d, (488, 560, 538, 588), 20, 160, line_color, 7)
        return overlay_layer(base, draw_fn)

    return base


def make_contact_sheet(masters: dict[str, Image.Image], out_path: Path) -> None:
    card_w, card_h = 360, 420
    cols = 3
    rows = 3
    sheet = Image.new("RGB", (cols * card_w + 80, rows * card_h + 120), (246, 243, 252))
    draw = ImageDraw.Draw(sheet)

    try:
        font = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial Bold.ttf", 22)
        title_font = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial Bold.ttf", 34)
    except Exception:
        font = ImageFont.load_default()
        title_font = ImageFont.load_default()

    draw.text((40, 24), "Twisty V2 Candidate Set", fill=(48, 35, 86), font=title_font)

    names = list(masters.keys())
    for idx, name in enumerate(names):
        r = idx // cols
        c = idx % cols
        x = 40 + c * card_w
        y = 80 + r * card_h
        draw.rounded_rectangle((x, y, x + 320, y + 380), radius=28, fill=(255, 255, 255), outline=(218, 210, 241), width=2)

        img = masters[name].copy().resize((250, 250), Image.LANCZOS)
        sheet.paste(img, (x + 35, y + 44), img)

        draw.text((x + 20, y + 320), name.replace("Twisty", ""), fill=(63, 52, 108), font=font)

    sheet.save(out_path, format="PNG")


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    MASTER_DIR.mkdir(parents=True, exist_ok=True)

    appicon = Image.open(APPICON).convert("RGBA")
    base = extract_mascot(appicon)
    base.save(MASTER_DIR / "TwistyBase.png")

    masters: dict[str, Image.Image] = {}
    for mood in MOODS:
        img = add_expression(base.copy(), mood)
        masters[mood] = img
        img.save(MASTER_DIR / f"{mood}.png")

    make_contact_sheet(masters, OUT_DIR / "twisty_v2_contact_sheet.png")
    print(f"Generated {len(MOODS)} candidates in: {MASTER_DIR}")
    print(f"Contact sheet: {OUT_DIR / 'twisty_v2_contact_sheet.png'}")


if __name__ == "__main__":
    main()
