#!/usr/bin/env python3
"""
Generate one minimal, human-style post image for 1000Kitap.

Output:
- images/1000kitap/1000kitap_samimi_paylasim_1080x1350.png
"""

from __future__ import annotations

from pathlib import Path
from typing import Iterable

from PIL import Image, ImageDraw, ImageFilter, ImageFont, ImageOps


THIS_DIR = Path(__file__).resolve().parent
ROOT = THIS_DIR.parents[1]
OUT_DIR = THIS_DIR / "images" / "1000kitap"
OUT_PATH = OUT_DIR / "1000kitap_samimi_paylasim_1080x1350.png"

SIZE = (1080, 1350)
BG = (248, 246, 241)
TEXT = (40, 47, 53)
MUTED = (94, 102, 109)
STROKE = (219, 214, 204)

SCREENSHOT_CANDIDATES = [
    "AppStore/screenshots/Simulator Screenshot - iPhone 17 - 2026-02-26 at 13.50.09.png",
    "AppStore/screenshots/Simulator Screenshot - iPhone 16e - 2026-02-27 at 17.21.13.png",
]


def pick_path(candidates: Iterable[str]) -> Path:
    for candidate in candidates:
        path = ROOT / candidate
        if path.exists() and path.stat().st_size > 0:
            return path
    raise FileNotFoundError(f"No valid source found in: {list(candidates)}")


def load_font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    if bold:
        font_paths = [
            "/Library/Fonts/SF-Pro-Display-Bold.otf",
            "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
        ]
    else:
        font_paths = [
            "/Library/Fonts/SF-Pro-Text-Regular.otf",
            "/System/Library/Fonts/Supplemental/Arial.ttf",
        ]
    for p in font_paths:
        if Path(p).exists():
            try:
                return ImageFont.truetype(p, size)
            except OSError:
                continue
    return ImageFont.load_default()


def fit_image(path: Path, size: tuple[int, int]) -> Image.Image:
    return ImageOps.fit(Image.open(path).convert("RGB"), size, method=Image.Resampling.LANCZOS)


def wrap_text(draw: ImageDraw.ImageDraw, text: str, font: ImageFont.FreeTypeFont, max_width: int) -> list[str]:
    words = text.split()
    if not words:
        return [""]
    lines: list[str] = []
    current = words[0]
    for word in words[1:]:
        trial = f"{current} {word}"
        w = draw.textbbox((0, 0), trial, font=font)[2]
        if w <= max_width:
            current = trial
        else:
            lines.append(current)
            current = word
    lines.append(current)
    return lines


def draw_phone(canvas: Image.Image, screenshot_path: Path, x: int, y: int, screen_w: int, screen_h: int) -> None:
    bezel = int(screen_w * 0.045)
    outer_radius = int(screen_w * 0.14)
    inner_radius = int(screen_w * 0.11)
    phone_w = screen_w + bezel * 2
    phone_h = screen_h + bezel * 2

    phone = Image.new("RGBA", (phone_w, phone_h), (0, 0, 0, 0))
    pd = ImageDraw.Draw(phone)
    pd.rounded_rectangle((0, 0, phone_w - 1, phone_h - 1), radius=outer_radius, fill=(16, 18, 22, 255))
    pd.rounded_rectangle((3, 3, phone_w - 4, phone_h - 4), radius=outer_radius - 2, fill=(29, 31, 36, 255))

    shot = fit_image(screenshot_path, (screen_w, screen_h)).convert("RGBA")
    mask = Image.new("L", (screen_w, screen_h), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, screen_w - 1, screen_h - 1), radius=inner_radius, fill=255)
    phone.paste(shot, (bezel, bezel), mask)

    notch_w = int(screen_w * 0.3)
    notch_h = int(screen_w * 0.08)
    notch_x = phone_w // 2 - notch_w // 2
    notch_y = bezel + int(screen_h * 0.02)
    pd.rounded_rectangle((notch_x, notch_y, notch_x + notch_w, notch_y + notch_h), radius=notch_h // 2, fill=(9, 9, 11, 255))

    shadow = Image.new("RGBA", (phone_w + 60, phone_h + 60), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.rounded_rectangle((30, 30, 30 + phone_w - 1, 30 + phone_h - 1), radius=outer_radius, fill=(0, 0, 0, 80))
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=14))

    canvas.alpha_composite(shadow, (x - 30, y - 24))
    canvas.alpha_composite(phone, (x, y))


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    canvas = Image.new("RGB", SIZE, BG)
    draw = ImageDraw.Draw(canvas)

    h_font = load_font(56, bold=True)
    p_font = load_font(35, bold=False)
    n_font = load_font(31, bold=False)
    s_font = load_font(24, bold=False)

    x_text = 64
    max_w = 620
    y = 82

    for line in wrap_text(draw, "Dün gece okurken bir cümlede takılı kaldım.", h_font, max_w):
        draw.text((x_text, y), line, font=h_font, fill=TEXT)
        y += 64

    y += 14
    for line in wrap_text(draw, "Aynı sayfayı dönüp dönüp okuyunca iyice gerildim.", p_font, max_w):
        draw.text((x_text, y), line, font=p_font, fill=MUTED)
        y += 45

    y += 22
    note_box = (x_text, y, x_text + 620, y + 372)
    draw.rounded_rectangle(note_box, radius=20, fill=(255, 255, 255), outline=STROKE, width=2)

    y2 = y + 26
    draw.text((x_text + 20, y2), "Böyle anlarda 2 dakikalık mola veriyorum:", font=n_font, fill=TEXT)
    y2 += 66

    bullet_lines = [
        "Duygumu bir cümleyle yazıyorum.",
        "Düşünceyi tek cümleye indiriyorum.",
        "4-7-8 nefes alıp kaldığım yere dönüyorum.",
    ]
    for line in bullet_lines:
        draw.ellipse((x_text + 22, y2 + 12, x_text + 38, y2 + 28), fill=(84, 98, 128))
        draw.text((x_text + 52, y2), line, font=n_font, fill=TEXT)
        y2 += 78

    draw.text((x_text + 20, y + 320), "Ben bunu Untwist'te yapıyorum.", font=n_font, fill=MUTED)

    screenshot = pick_path(SCREENSHOT_CANDIDATES)

    # draw_phone works on RGBA; keep final text after conversion
    canvas = canvas.convert("RGBA")
    draw = ImageDraw.Draw(canvas)
    draw_phone(canvas, screenshot, x=700, y=250, screen_w=312, screen_h=676)
    draw.text((700, 952), "Kullandığım ekran", font=s_font, fill=MUTED)
    draw.line((64, 1238, 326, 1238), fill=STROKE, width=2)
    draw.text((64, 1254), "Belki sana da iyi gelir.", font=n_font, fill=TEXT)

    canvas.convert("RGB").save(OUT_PATH, "PNG")
    print(f"Generated: {OUT_PATH.relative_to(THIS_DIR)}")


if __name__ == "__main__":
    main()
