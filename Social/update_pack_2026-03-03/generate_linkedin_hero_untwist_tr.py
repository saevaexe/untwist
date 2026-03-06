#!/usr/bin/env python3
"""
Generate a simple LinkedIn hero visual for Untwist (TR).
"""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont, ImageOps


OUT = Path("/Users/osmanseven/Untwist/Social/update_pack_2026-03-03/images/1000kitap/Untwist_LinkedIn_Hero_TR.png")
SHOT = Path("/Users/osmanseven/Untwist/AppStore/screenshots/Simulator Screenshot - iPhone 16e - 2026-02-27 at 17.23.19.png")
ICON = Path("/Users/osmanseven/Untwist/Untwist/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png")

W, H = 1200, 628


def load_font(size: int, bold: bool = False):
    candidates = [
        "/Library/Fonts/SF-Pro-Display-Bold.otf" if bold else "/Library/Fonts/SF-Pro-Text-Regular.otf",
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf" if bold else "/System/Library/Fonts/Supplemental/Arial.ttf",
    ]
    for path in candidates:
        p = Path(path)
        if p.exists():
            try:
                return ImageFont.truetype(str(p), size)
            except OSError:
                pass
    return ImageFont.load_default()


def make_bg():
    grad = Image.linear_gradient("L").resize((W, H))
    bg = ImageOps.colorize(grad, "#0A1628", "#1C4D87").convert("RGBA")

    glow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    gd.ellipse((810, 140, 1180, 510), fill=(88, 136, 255, 88))
    glow = glow.filter(ImageFilter.GaussianBlur(52))
    bg.alpha_composite(glow, (0, 0))
    return bg


def wrap(draw: ImageDraw.ImageDraw, text: str, font, max_w: int):
    words = text.split()
    if not words:
        return [""]
    lines = []
    cur = words[0]
    for w in words[1:]:
        trial = cur + " " + w
        if draw.textbbox((0, 0), trial, font=font)[2] <= max_w:
            cur = trial
        else:
            lines.append(cur)
            cur = w
    lines.append(cur)
    return lines


def draw_button(draw: ImageDraw.ImageDraw, box, text: str):
    draw.rounded_rectangle(box, radius=14, fill="#0A84FF")
    font = load_font(20, bold=True)
    tw = draw.textlength(text, font=font)
    th = font.getbbox(text)[3] - font.getbbox(text)[1]
    x1, y1, x2, y2 = box
    draw.text((x1 + (x2 - x1 - tw) / 2, y1 + (y2 - y1 - th) / 2 - 1), text, fill="white", font=font)


def build_phone():
    screen_w, screen_h = 226, 488
    body_w, body_h = screen_w + 16, screen_h + 16
    phone = Image.new("RGBA", (body_w, body_h), (0, 0, 0, 0))
    d = ImageDraw.Draw(phone)

    d.rounded_rectangle((0, 0, body_w - 1, body_h - 1), radius=40, fill="#05070B")
    d.rounded_rectangle((2, 2, body_w - 3, body_h - 3), radius=38, outline=(255, 255, 255, 28), width=1)

    shot = ImageOps.fit(Image.open(SHOT).convert("RGB"), (screen_w, screen_h), method=Image.Resampling.LANCZOS)
    mask = Image.new("L", (screen_w, screen_h), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, screen_w - 1, screen_h - 1), radius=30, fill=255)
    phone.paste(shot, (8, 8), mask)

    notch = Image.new("RGBA", (112, 26), (0, 0, 0, 0))
    nd = ImageDraw.Draw(notch)
    nd.rounded_rectangle((0, 0, 111, 25), radius=13, fill="#020305")
    phone.alpha_composite(notch, ((body_w - 112) // 2, 10))
    return phone.rotate(-6, resample=Image.Resampling.BICUBIC, expand=True)


def draw_copy(draw: ImageDraw.ImageDraw):
    badge_font = load_font(13, bold=True)
    title_font = load_font(74, bold=True)
    accent_font = load_font(62, bold=True)
    line_font = load_font(19, bold=True)

    draw.rounded_rectangle((56, 146, 335, 184), radius=19, fill="#112C49", outline=(91, 200, 255, 110), width=2)
    draw.text((76, 157), "1000KİTAP İÇİN HAZIRLANDI", fill="#76D5FF", font=badge_font)

    draw.text((56, 220), "Düşünceyi", fill="white", font=title_font)
    draw.text((56, 302), "Sadeleştir,", fill="#5AC8FA", font=accent_font)
    draw.text((56, 368), "Nefes Al", fill="white", font=title_font)

    muted = (217, 226, 238, 184)
    draw.text((56, 466), "Düşünce çözücü • Duygu kaydı • Nefes egzersizi", fill=muted, font=line_font)
    draw.text((56, 501), "Kısa adımlar • Günlük pratik • İlerleme takibi", fill=muted, font=line_font)

    draw_button(draw, (56, 542, 314, 602), "Untwist'i İncele")


def draw_brand(draw: ImageDraw.ImageDraw, canvas: Image.Image):
    icon = ImageOps.fit(Image.open(ICON).convert("RGB"), (36, 36), method=Image.Resampling.LANCZOS).convert("RGBA")
    mask = Image.new("L", (36, 36), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, 35, 35), radius=9, fill=255)
    icon.putalpha(mask)
    canvas.alpha_composite(icon, (344, 554))
    draw.text((389, 557), "Untwist", fill=(219, 230, 246, 190), font=load_font(34, bold=True))


def main():
    OUT.parent.mkdir(parents=True, exist_ok=True)

    canvas = make_bg()
    draw = ImageDraw.Draw(canvas)
    draw_copy(draw)

    phone = build_phone()
    shadow = Image.new("RGBA", phone.size, (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.rounded_rectangle((22, 34, phone.size[0] - 10, phone.size[1] - 10), radius=60, fill=(0, 0, 0, 120))
    shadow = shadow.filter(ImageFilter.GaussianBlur(16))

    px, py = 882, 38
    canvas.alpha_composite(shadow, (px - 18, py + 20))
    canvas.alpha_composite(phone, (px, py))
    draw_brand(draw, canvas)

    canvas.convert("RGB").save(OUT, "PNG")
    print(OUT)


if __name__ == "__main__":
    main()
