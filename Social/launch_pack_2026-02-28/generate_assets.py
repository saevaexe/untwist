#!/usr/bin/env python3
"""
Generate Untwist launch social assets (IG + X + profile).

Outputs:
- images/instagram/*.png   (1080x1350)
- images/x/*.png           (1600x900 + 1500x500 header)
- images/profile/*.png     (1024x1024)
"""

from __future__ import annotations

from pathlib import Path
from typing import Iterable

from PIL import Image, ImageDraw, ImageFilter, ImageFont, ImageOps


THIS_DIR = Path(__file__).resolve().parent
ROOT = THIS_DIR.parents[1]
OUT_IG = THIS_DIR / "images" / "instagram"
OUT_X = THIS_DIR / "images" / "x"
OUT_PROFILE = THIS_DIR / "images" / "profile"


PALETTES = [
    {"top": (24, 18, 44), "bottom": (77, 58, 132), "text": (255, 255, 255), "muted": (215, 206, 236), "cta": (244, 239, 255), "cta_text": (58, 38, 110)},
    {"top": (244, 238, 255), "bottom": (223, 213, 246), "text": (53, 38, 87), "muted": (92, 79, 126), "cta": (110, 88, 182), "cta_text": (255, 255, 255)},
    {"top": (35, 26, 60), "bottom": (93, 72, 156), "text": (255, 255, 255), "muted": (214, 206, 236), "cta": (255, 255, 255), "cta_text": (63, 47, 116)},
    {"top": (238, 232, 252), "bottom": (203, 192, 238), "text": (45, 34, 76), "muted": (80, 65, 115), "cta": (71, 49, 132), "cta_text": (255, 255, 255)},
]


POSTS = [
    {
        "slug": "01_untwist_nedir",
        "tag": "UNTWIST",
        "title": "Zihnindeki düğümü çöz.",
        "subtitle": "BDT temelli mini egzersizlerle zor anlarda netleş.",
        "cta": "Ücretsiz başla",
        "source_candidates": [
            "AppStore/screenshots/Simulator Screenshot - iPhone 16e - 2026-02-27 at 17.47.20.png",
            "AppStore/screenshots/tr/Simulator Screenshot - iPhone 16e - 2026-02-27 at 17.51.49.png",
            "AppStore/Previews/appstore_tr_5.png",
        ],
    },
    {
        "slug": "02_10_saniye_duygu",
        "tag": "DUYGU KAYDI",
        "title": "10 saniyede duygu kaydı",
        "subtitle": "0-100 arası seç, istersen kısa not ekle. Bu kadar.",
        "cta": "Bugün dene",
        "source_candidates": [
            "AppStore/screenshots/Simulator Screenshot - iPhone 17 - 2026-02-26 at 13.49.01.png",
            "AppStore/screenshots/mood_tr.png",
        ],
    },
    {
        "slug": "03_4_adim_cozucu",
        "tag": "DÜŞÜNCE ÇÖZÜCÜ",
        "title": "4 adımda düşünceyi aç",
        "subtitle": "Olayı yaz, otomatik düşünceyi yakala, tuzağı gör, alternatifi kur.",
        "cta": "2 dk sürer",
        "source_candidates": [
            "AppStore/screenshots/Simulator Screenshot - iPhone 17 - 2026-02-26 at 13.49.19.png",
            "AppStore/screenshots/Simulator Screenshot - iPhone 16e - 2026-02-27 at 17.21.13.png",
            "AppStore/screenshots/unwinder_tr.png",
        ],
    },
    {
        "slug": "04_tuzaklari_farket",
        "tag": "10 DÜŞÜNCE TUZAĞI",
        "title": "Tuzakları adlandırmak rahatlatır",
        "subtitle": "Ya hep ya hiç, felaketleştirme, zihin okuma ve daha fazlası.",
        "cta": "Listeyi keşfet",
        "source_candidates": [
            "AppStore/screenshots/Simulator Screenshot - iPhone 17 - 2026-02-26 at 13.52.19.png",
            "AppStore/screenshots/traps_list_after_cleanup_v2.png",
            "AppStore/screenshots/traps_list_manuel.png",
        ],
    },
    {
        "slug": "05_simdi_sakinles",
        "tag": "ŞİMDİ SAKİNLEŞ",
        "title": "Bunaldığında tek dokunuş",
        "subtitle": "Duraksama + 3 rehberli nefes + istersen yazmaya dönüş.",
        "cta": "Nefese geç",
        "source_candidates": [
            "AppStore/screenshots/Simulator Screenshot - iPhone 17 - 2026-02-26 at 13.55.26.png",
            "AppStore/screenshots/Simulator Screenshot - iPhone 17 - 2026-02-26 at 13.50.21.png",
        ],
    },
    {
        "slug": "06_478_nefes",
        "tag": "NEFES EGZERSİZİ",
        "title": "4-7-8 ile ritmi yakala",
        "subtitle": "4 sn al, 7 sn tut, 8 sn ver. 5 tur boyunca görsel eşlik.",
        "cta": "Hemen uygula",
        "source_candidates": [
            "AppStore/screenshots/Simulator Screenshot - iPhone 17 - 2026-02-26 at 13.50.43.png",
            "AppStore/screenshots/Simulator Screenshot - iPhone 17 - 2026-02-26 at 13.52.06.png",
            "AppStore/screenshots/twisty_breathing_fix_check_breathing_screen_v3.png",
        ],
    },
    {
        "slug": "07_gizlilik_oncelikli",
        "tag": "PRIVACY FIRST",
        "title": "Verilerin sende kalır",
        "subtitle": "Hesap yok. Bulut yok. Üçüncü parti izleme yok.",
        "cta": "Gizliliği seç",
        "source_candidates": [
            "AppStore/screenshots/Simulator Screenshot - iPhone 17 - 2026-02-26 at 13.55.16.png",
            "AppStore/screenshots/Simulator Screenshot - iPhone 17 - 2026-02-26 at 13.55.07.png",
        ],
    },
    {
        "slug": "08_twisty_yaninda",
        "tag": "TWISTY",
        "title": "Asla terapist değil, hep arkadaş",
        "subtitle": "Twisty ruh haline eşlik eder, yargılamaz, baskı kurmaz.",
        "cta": "Twisty ile tanış",
        "source_candidates": [
            "AppStore/screenshots/Simulator Screenshot - iPhone 16e - 2026-02-27 at 17.47.01.png",
            "AppStore/Previews/appstore_tr_3.png",
        ],
    },
    {
        "slug": "09_baslamak_kolay",
        "tag": "İLK ADIM",
        "title": "Bugün sadece 2 dakika ayır",
        "subtitle": "Küçük adımlar, sürdürülebilir fark. Sıfır suçluluk.",
        "cta": "Şimdi indir",
        "source_candidates": [
            "AppStore/screenshots/tr/Simulator Screenshot - iPhone 16e - 2026-02-27 at 17.51.49.png",
            "AppStore/Previews/appstore_tr_5.png",
        ],
    },
]


APP_ICON = ROOT / "Untwist/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png"
TWISTY_WAVING = ROOT / "Untwist/Resources/Assets.xcassets/TwistyWaving.imageset/TwistyWaving.png"
TWISTY_CALM = ROOT / "Untwist/Resources/Assets.xcassets/TwistyCalm.imageset/TwistyCalm.png"


def ensure_dirs() -> None:
    OUT_IG.mkdir(parents=True, exist_ok=True)
    OUT_X.mkdir(parents=True, exist_ok=True)
    OUT_PROFILE.mkdir(parents=True, exist_ok=True)


def pick_path(candidates: Iterable[str]) -> Path:
    for candidate in candidates:
        path = ROOT / candidate
        if path.exists() and path.stat().st_size > 0:
            return path
    raise FileNotFoundError(f"No valid source found in: {list(candidates)}")


def load_font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    if bold:
        candidates = [
            "/Library/Fonts/SF-Pro-Display-Black.otf",
            "/Library/Fonts/SF-Pro-Display-Bold.otf",
            "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
        ]
    else:
        candidates = [
            "/Library/Fonts/SF-Pro-Text-Regular.otf",
            "/System/Library/Fonts/Supplemental/Arial.ttf",
        ]

    for font_path in candidates:
        path = Path(font_path)
        if path.exists():
            try:
                return ImageFont.truetype(str(path), size)
            except OSError:
                continue
    return ImageFont.load_default()


def make_vertical_gradient(size: tuple[int, int], top: tuple[int, int, int], bottom: tuple[int, int, int]) -> Image.Image:
    w, h = size
    image = Image.new("RGB", size)
    draw = ImageDraw.Draw(image)
    for y in range(h):
        t = y / max(1, h - 1)
        color = tuple(int(top[i] * (1 - t) + bottom[i] * t) for i in range(3))
        draw.line([(0, y), (w, y)], fill=color)
    return image


def draw_soft_blobs(canvas: Image.Image, palette: dict, seed: int) -> None:
    w, h = canvas.size
    overlay = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    blobs = [
        (int(w * 0.1), int(h * 0.08), int(w * 0.7), int(h * 0.45), 32),
        (int(w * 0.35), int(h * 0.55), int(w * 0.95), int(h * 0.98), 26),
    ]
    for i, (x1, y1, x2, y2, alpha) in enumerate(blobs):
        a = alpha + (seed * 3 + i * 5) % 12
        color = (*palette["muted"], min(255, a))
        draw.ellipse((x1, y1, x2, y2), fill=color)
    overlay = overlay.filter(ImageFilter.GaussianBlur(radius=36))
    canvas.alpha_composite(overlay)


def wrap_text(draw: ImageDraw.ImageDraw, text: str, font: ImageFont.FreeTypeFont, max_width: int) -> list[str]:
    words = text.split()
    if not words:
        return [""]

    lines: list[str] = []
    current = words[0]
    for word in words[1:]:
        trial = f"{current} {word}"
        bbox = draw.textbbox((0, 0), trial, font=font)
        if (bbox[2] - bbox[0]) <= max_width:
            current = trial
        else:
            lines.append(current)
            current = word
    lines.append(current)
    return lines


def fit_source(path: Path, size: tuple[int, int]) -> Image.Image:
    source = Image.open(path).convert("RGB")
    return ImageOps.fit(source, size, method=Image.Resampling.LANCZOS)


def paste_phone(canvas: Image.Image, screenshot_path: Path, center_x: int, top_y: int, screen_w: int, screen_h: int) -> None:
    bezel = int(screen_w * 0.045)
    outer_radius = int(screen_w * 0.14)
    inner_radius = int(screen_w * 0.11)
    phone_w = screen_w + bezel * 2
    phone_h = screen_h + bezel * 2
    phone_x = center_x - phone_w // 2
    phone_y = top_y

    phone = Image.new("RGBA", (phone_w, phone_h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(phone)
    draw.rounded_rectangle((0, 0, phone_w - 1, phone_h - 1), radius=outer_radius, fill=(22, 22, 26, 255))
    draw.rounded_rectangle((2, 2, phone_w - 3, phone_h - 3), radius=outer_radius, fill=(35, 35, 42, 255))
    draw.rounded_rectangle((4, 4, phone_w - 5, phone_h - 5), radius=outer_radius - 2, fill=(18, 18, 22, 255))

    screen_x = bezel
    screen_y = bezel
    draw.rounded_rectangle((screen_x, screen_y, screen_x + screen_w, screen_y + screen_h), radius=inner_radius, fill=(255, 255, 255, 255))

    shot = fit_source(screenshot_path, (screen_w, screen_h)).convert("RGBA")
    mask = Image.new("L", (screen_w, screen_h), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, screen_w - 1, screen_h - 1), radius=inner_radius, fill=255)
    phone.paste(shot, (screen_x, screen_y), mask)

    notch_w = int(screen_w * 0.3)
    notch_h = int(screen_w * 0.08)
    notch_x = phone_w // 2 - notch_w // 2
    notch_y = bezel + int(screen_h * 0.02)
    draw.rounded_rectangle(
        (notch_x, notch_y, notch_x + notch_w, notch_y + notch_h),
        radius=notch_h // 2,
        fill=(10, 10, 14, 255),
    )

    shadow = Image.new("RGBA", (phone_w + 80, phone_h + 80), (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(shadow)
    sdraw.rounded_rectangle((40, 40, 40 + phone_w - 1, 40 + phone_h - 1), radius=outer_radius, fill=(0, 0, 0, 95))
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=22))

    canvas.alpha_composite(shadow, (phone_x - 40, phone_y - 30))
    canvas.alpha_composite(phone, (phone_x, phone_y))


def draw_cta(draw: ImageDraw.ImageDraw, text: str, center_x: int, y: int, font: ImageFont.FreeTypeFont, bg_color: tuple[int, int, int], text_color: tuple[int, int, int]) -> None:
    bbox = draw.textbbox((0, 0), text, font=font)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    pad_x = 28
    pad_y = 14
    w = tw + pad_x * 2
    h = th + pad_y * 2
    x = center_x - w // 2
    draw.rounded_rectangle((x, y, x + w, y + h), radius=h // 2, fill=bg_color)
    draw.text((center_x - tw // 2, y + (h - th) // 2 - 1), text, font=font, fill=text_color)


def render_instagram_post(idx: int, cfg: dict) -> Path:
    size = (1080, 1350)
    palette = PALETTES[idx % len(PALETTES)]
    bg = make_vertical_gradient(size, palette["top"], palette["bottom"]).convert("RGBA")
    draw_soft_blobs(bg, palette, seed=idx + 7)
    draw = ImageDraw.Draw(bg)

    font_tag = load_font(34, bold=True)
    font_title = load_font(90, bold=True)
    font_body = load_font(42, bold=False)
    font_cta = load_font(40, bold=True)

    margin = 72
    draw.text((margin, 58), cfg["tag"], font=font_tag, fill=palette["muted"])

    title_lines = wrap_text(draw, cfg["title"], font_title, size[0] - margin * 2)
    y = 108
    for line in title_lines:
        draw.text((margin, y), line, font=font_title, fill=palette["text"])
        y += 92

    sub_lines = wrap_text(draw, cfg["subtitle"], font_body, size[0] - margin * 2)
    y += 16
    for line in sub_lines:
        draw.text((margin, y), line, font=font_body, fill=palette["muted"])
        y += 48

    source = pick_path(cfg["source_candidates"])
    paste_phone(bg, source, center_x=size[0] // 2, top_y=390, screen_w=430, screen_h=930)
    draw_cta(draw, cfg["cta"], center_x=size[0] // 2, y=1244, font=font_cta, bg_color=palette["cta"], text_color=palette["cta_text"])

    output = OUT_IG / f"ig_{cfg['slug']}.png"
    bg.convert("RGB").save(output, "PNG")
    return output


def render_x_post(idx: int, cfg: dict) -> Path:
    size = (1600, 900)
    palette = PALETTES[(idx + 1) % len(PALETTES)]
    bg = make_vertical_gradient(size, palette["top"], palette["bottom"]).convert("RGBA")
    draw_soft_blobs(bg, palette, seed=idx + 21)
    draw = ImageDraw.Draw(bg)

    font_tag = load_font(30, bold=True)
    font_title = load_font(86, bold=True)
    font_body = load_font(36, bold=False)
    font_cta = load_font(34, bold=True)

    text_left = 86
    text_width = 780

    draw.text((text_left, 72), cfg["tag"], font=font_tag, fill=palette["muted"])

    title_lines = wrap_text(draw, cfg["title"], font_title, text_width)
    y = 118
    for line in title_lines[:2]:
        draw.text((text_left, y), line, font=font_title, fill=palette["text"])
        y += 92

    y += 14
    sub_lines = wrap_text(draw, cfg["subtitle"], font_body, text_width)
    for line in sub_lines[:3]:
        draw.text((text_left, y), line, font=font_body, fill=palette["muted"])
        y += 46

    source = pick_path(cfg["source_candidates"])
    paste_phone(bg, source, center_x=1240, top_y=75, screen_w=355, screen_h=770)
    draw_cta(draw, cfg["cta"], center_x=330, y=760, font=font_cta, bg_color=palette["cta"], text_color=palette["cta_text"])

    output = OUT_X / f"x_{cfg['slug']}.png"
    bg.convert("RGB").save(output, "PNG")
    return output


def render_profile_assets() -> list[Path]:
    outputs: list[Path] = []

    if APP_ICON.exists():
        square = Image.open(APP_ICON).convert("RGBA").resize((1024, 1024), Image.Resampling.LANCZOS)
        square_path = OUT_PROFILE / "profile_square_appicon_1024.png"
        square.save(square_path, "PNG")
        outputs.append(square_path)

        # Circular-safe preview to check center composition.
        circle_bg = Image.new("RGBA", (1024, 1024), (255, 255, 255, 0))
        mask = Image.new("L", (1024, 1024), 0)
        ImageDraw.Draw(mask).ellipse((60, 60, 964, 964), fill=255)
        circle_bg.paste(square, (0, 0), mask)
        circle_path = OUT_PROFILE / "profile_circle_preview_1024.png"
        circle_bg.save(circle_path, "PNG")
        outputs.append(circle_path)

    # X Header (1500x500)
    size = (1500, 500)
    palette = PALETTES[2]
    header = make_vertical_gradient(size, palette["top"], palette["bottom"]).convert("RGBA")
    draw_soft_blobs(header, palette, seed=99)
    draw = ImageDraw.Draw(header)

    title_font = load_font(96, bold=True)
    sub_font = load_font(40, bold=False)
    cta_font = load_font(34, bold=True)

    draw.text((390, 120), "Untwist", font=title_font, fill=(255, 255, 255))
    draw.text((390, 220), "Zihnindeki düğümü çöz.", font=sub_font, fill=(218, 208, 239))

    cta_text = "Ücretsiz indir"
    bbox = draw.textbbox((0, 0), cta_text, font=cta_font)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    x = 390
    y = 300
    draw.rounded_rectangle((x, y, x + tw + 56, y + th + 24), radius=(th + 24) // 2, fill=(245, 238, 255))
    draw.text((x + 28, y + 10), cta_text, font=cta_font, fill=(72, 53, 125))

    mascot = TWISTY_WAVING if TWISTY_WAVING.exists() else TWISTY_CALM
    if mascot.exists():
        twisty = Image.open(mascot).convert("RGBA")
        twisty = ImageOps.contain(twisty, (300, 300), Image.Resampling.LANCZOS)
        shadow = Image.new("RGBA", (340, 340), (0, 0, 0, 0))
        ImageDraw.Draw(shadow).ellipse((20, 30, 280, 300), fill=(0, 0, 0, 80))
        shadow = shadow.filter(ImageFilter.GaussianBlur(radius=16))
        header.alpha_composite(shadow, (60, 88))
        header.alpha_composite(twisty, (95, 95))

    header_path = OUT_X / "x_header_1500x500.png"
    header.convert("RGB").save(header_path, "PNG")
    outputs.append(header_path)

    return outputs


def main() -> None:
    ensure_dirs()

    ig_outputs = [render_instagram_post(i, cfg) for i, cfg in enumerate(POSTS)]
    x_outputs = [render_x_post(i, cfg) for i, cfg in enumerate(POSTS[:6])]
    profile_outputs = render_profile_assets()

    print("Generated Instagram images:")
    for path in ig_outputs:
        print(f"  - {path.relative_to(THIS_DIR)}")

    print("\nGenerated X images:")
    for path in x_outputs:
        print(f"  - {path.relative_to(THIS_DIR)}")

    print("\nGenerated profile/header assets:")
    for path in profile_outputs:
        print(f"  - {path.relative_to(THIS_DIR)}")


if __name__ == "__main__":
    main()
