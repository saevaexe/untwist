#!/usr/bin/env python3
"""
Generate one very simple 1000Kitap announcement visual:
only user message + home screen screenshot.
"""

from pathlib import Path
import shutil

from PIL import Image, ImageDraw, ImageFilter, ImageFont, ImageOps


OUT_DIR = Path("/Users/osmanseven/Untwist/Social/update_pack_2026-03-03/images/1000kitap")
SHOT = Path("/Users/osmanseven/Untwist/AppStore/screenshots/Simulator Screenshot - iPhone 16e - 2026-02-27 at 17.23.19.png")
DEFAULT_OUT = OUT_DIR / "1000kitap_hikaye_sade_1080x1350.png"

W, H = 1080, 1350
BG = (246, 245, 241)
INK = (38, 44, 52)
MUTED = (92, 100, 108)

VARIANTS = [
    (
        "1000kitap_hikaye_sade_1080x1350_v1.png",
        [
            ("Merhaba 1000Kitap dostları.", INK, 52, True),
            ("Bazı günler, olan şeyden çok ona yüklediğimiz anlam yoruyor.", MUTED, 34, False),
            ("Ben de bu yükü hafifletmek için düşünceyi sadeleştiren bir uygulama yaptım.", MUTED, 34, False),
        ],
    ),
    (
        "1000kitap_hikaye_sade_1080x1350_v2.png",
        [
            ("Selam 1000Kitap.", INK, 52, True),
            ("Kafamızdaki ses büyüdükçe, en küçük konu bile içimizi daraltabiliyor.", MUTED, 34, False),
            ("Bu anlarda durup nefes almak ve düşünceyi toparlamak için Untwist'i geliştirdim.", MUTED, 34, False),
        ],
    ),
    (
        "1000kitap_hikaye_sade_1080x1350_v3.png",
        [
            ("Herkese merhaba.", INK, 52, True),
            ("Düşünce bazen yol gösterir, bazen de aynı yerde döndürür.", MUTED, 34, False),
            ("Döngüye takıldığımız anlarda bir çıkış bulmak için bu uygulamayı hazırladım.", MUTED, 34, False),
        ],
    ),
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


def render(output_path: Path, paragraphs):
    output_path.parent.mkdir(parents=True, exist_ok=True)

    img = Image.new("RGB", (W, H), BG)
    draw = ImageDraw.Draw(img)

    y = 74
    for text, color, size, is_bold in paragraphs:
        font = load_font(size, bold=is_bold)
        for line in wrap(draw, text, font, 952):
            draw.text((64, y), line, font=font, fill=color)
            y += 62 if is_bold else 47
        y += 20

    shot = ImageOps.fit(Image.open(SHOT).convert("RGB"), (952, 840), method=Image.Resampling.LANCZOS)
    mask = Image.new("L", (952, 840), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, 951, 839), radius=36, fill=255)

    card = Image.new("RGBA", (952, 840), (255, 255, 255, 0))
    card.paste(shot, (0, 0), mask)

    shadow = Image.new("RGBA", (1008, 896), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle((28, 28, 980, 868), radius=42, fill=(0, 0, 0, 60))
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=14))

    img = img.convert("RGBA")
    img.alpha_composite(shadow, (36, 430))
    img.alpha_composite(card, (64, 458))

    img.convert("RGB").save(output_path, "PNG")
    print(output_path)


def main():
    generated = []
    for file_name, paragraphs in VARIANTS:
        out_path = OUT_DIR / file_name
        render(out_path, paragraphs)
        generated.append(out_path)
    if generated:
        shutil.copyfile(generated[0], DEFAULT_OUT)
        print(DEFAULT_OUT)


if __name__ == "__main__":
    main()
