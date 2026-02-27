"""
Generate TR App Store previews by reusing the same layout as EN previews.
Uses TR onboarding screenshots + proper Turkish copy with correct characters.
"""

from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
OUT_DIR = os.path.join(SCRIPT_DIR, "Previews")
SCREENSHOTS_DIR = os.path.join(SCRIPT_DIR, "Screenshots")

SCREENS = ["welcome", "name", "story", "needs", "ready"]

# Fonts
FONT_BOLD = "/System/Library/Fonts/Supplemental/Arial Bold.ttf"
FONT_REG = "/System/Library/Fonts/Supplemental/Arial.ttf"
SF_HEAVY = "/Library/Fonts/SF-Pro-Display-Heavy.otf"
SF_BLACK = "/Library/Fonts/SF-Pro-Display-Black.otf"
SF_BOLD = "/System/Library/Fonts/SFNS.ttf"

def _try_font(paths, size):
    for p in paths:
        if os.path.exists(p):
            try:
                return ImageFont.truetype(p, size)
            except Exception:
                continue
    return ImageFont.truetype(FONT_BOLD, size)

def get_title_font(size):
    return _try_font([SF_BLACK, SF_HEAVY, SF_BOLD, FONT_BOLD], size)

def get_body_font(size):
    return _try_font([SF_BOLD, FONT_BOLD], size)

def get_sub_font(size):
    return _try_font([FONT_REG], size)

# Untwist brand colors
PURPLE_DEEP = (75, 50, 140)
PURPLE = (124, 107, 196)
PURPLE_LIGHT = (155, 143, 216)
LAVENDER = (168, 155, 212)
LAVENDER_BG = (240, 235, 252)
BG_LIGHT = (250, 248, 255)
BG_DARK = (26, 21, 40)
WHITE = (255, 255, 255)
TEXT_DARK = (45, 35, 68)
TEXT_MID = (107, 97, 137)
BEZEL_BLACK = (20, 20, 22)
BEZEL_EDGE = (40, 40, 42)

THEMES = [
    {"bg_top": (30, 20, 55), "bg_bot": (50, 35, 85), "title": WHITE, "accent": PURPLE_LIGHT, "sub": (190, 180, 210), "tag": PURPLE_LIGHT, "cta_bg": PURPLE, "cta_text": WHITE},
    {"bg_top": LAVENDER_BG, "bg_bot": (245, 240, 255), "title": TEXT_DARK, "accent": PURPLE, "sub": TEXT_MID, "tag": PURPLE, "cta_bg": PURPLE, "cta_text": WHITE},
    {"bg_top": (245, 240, 255), "bg_bot": LAVENDER_BG, "title": TEXT_DARK, "accent": PURPLE, "sub": TEXT_MID, "tag": PURPLE, "cta_bg": PURPLE, "cta_text": WHITE},
    {"bg_top": (235, 228, 252), "bg_bot": (215, 205, 245), "title": TEXT_DARK, "accent": PURPLE_DEEP, "sub": TEXT_MID, "tag": PURPLE_DEEP, "cta_bg": PURPLE_DEEP, "cta_text": WHITE},
    {"bg_top": PURPLE, "bg_bot": (90, 70, 165), "title": WHITE, "accent": WHITE, "sub": (215, 205, 235), "tag": (215, 205, 235), "cta_bg": WHITE, "cta_text": PURPLE_DEEP},
]

# TR copy with proper Turkish characters
COPY_TR = [
    {
        "tag": "BDT TEMELLİ ZİHİNSEL İYİ OLUŞ",
        "line1": "ZİHNİNDEKİ",
        "line2": "düğümü çöz.",
        "sub": "Düşünceler, duygular, stres —\nbirlikte adım adım ilerleyelim.",
        "cta": "Ücretsiz Başla  →",
    },
    {
        "tag": "SANA ÖZEL",
        "line1": "GERÇEKTEN",
        "line2": "kişisel.",
        "sub": "İsminle başlıyoruz, ihtiyacına göre\nmini plan oluşturuyoruz.",
        "cta": "Başlayalım  →",
    },
    {
        "tag": "SENİ ANLIYORUZ",
        "line1": "\"Senin suçun",
        "line2": "değil.\"",
        "sub": "Untwist yargılamadan dinler,\ndüşüncelerini yeniden çerçeveler.",
        "cta": "Bu Bende Var  →",
    },
    {
        "tag": "KİŞİSEL EGZERSİZLER",
        "line1": "PLANIN",
        "line2": "hazır.",
        "sub": "Seni en çok zorlayanı seç,\nbirlikte net bir yol çizelim.",
        "cta": "Planımı Oluştur  →",
    },
    {
        "tag": "YOLCULUK BAŞLIYOR",
        "line1": "HAZIRSIN.",
        "line2": "",
        "sub": "Kişisel planın hazır.\nKüçük adımlarla güçlü ilerleme.",
        "cta": "Hadi Başlayalım!",
    },
]


def create_gradient(size, top_color, bot_color):
    w, h = size
    img = Image.new("RGB", size)
    px = img.load()
    for y in range(h):
        r = y / h
        for x in range(w):
            px[x, y] = tuple(int(top_color[i] + (bot_color[i] - top_color[i]) * r) for i in range(3))
    return img


def draw_phone_bezel(canvas, screenshot_path, center_x, top_y, screen_w, screen_h):
    bezel_thickness = int(screen_w * 0.04)
    outer_radius = int(screen_w * 0.14)
    inner_radius = int(screen_w * 0.10)
    phone_w = screen_w + bezel_thickness * 2
    phone_h = screen_h + bezel_thickness * 2
    phone_x = center_x - phone_w // 2
    phone_y = top_y

    phone = Image.new("RGBA", (phone_w, phone_h), (0, 0, 0, 0))
    pd = ImageDraw.Draw(phone)
    pd.rounded_rectangle([(0, 0), (phone_w - 1, phone_h - 1)], radius=outer_radius, fill=(*BEZEL_BLACK, 255))
    pd.rounded_rectangle([(1, 1), (phone_w - 2, phone_h - 2)], radius=outer_radius, fill=(*BEZEL_EDGE, 255))
    pd.rounded_rectangle([(3, 3), (phone_w - 4, phone_h - 4)], radius=outer_radius - 2, fill=(*BEZEL_BLACK, 255))

    screen_x = bezel_thickness
    screen_y = bezel_thickness
    pd.rounded_rectangle([(screen_x, screen_y), (screen_x + screen_w - 1, screen_y + screen_h - 1)], radius=inner_radius, fill=(200, 200, 200, 255))

    di_w = int(screen_w * 0.28)
    di_h = int(screen_w * 0.075)
    di_x = phone_w // 2 - di_w // 2
    di_y = bezel_thickness + int(screen_h * 0.015)
    di_radius = di_h // 2
    pd.rounded_rectangle([(di_x, di_y), (di_x + di_w, di_y + di_h)], radius=di_radius, fill=(*BEZEL_BLACK, 255))

    if os.path.exists(screenshot_path):
        screenshot = Image.open(screenshot_path).convert("RGBA")
        screenshot = screenshot.resize((screen_w, screen_h), Image.LANCZOS)
        ss_mask = Image.new("L", (screen_w, screen_h), 0)
        ImageDraw.Draw(ss_mask).rounded_rectangle([(0, 0), (screen_w - 1, screen_h - 1)], radius=inner_radius, fill=255)
        phone.paste(screenshot, (screen_x, screen_y), ss_mask)
        pd2 = ImageDraw.Draw(phone)
        pd2.rounded_rectangle([(di_x, di_y), (di_x + di_w, di_y + di_h)], radius=di_radius, fill=(*BEZEL_BLACK, 255))
    else:
        print(f"    ! Missing: {screenshot_path}")

    shadow_pad = 60
    shadow_img = Image.new("RGBA", (phone_w + shadow_pad * 2, phone_h + shadow_pad * 2), (0, 0, 0, 0))
    ImageDraw.Draw(shadow_img).rounded_rectangle([(shadow_pad, shadow_pad), (phone_w + shadow_pad - 1, phone_h + shadow_pad - 1)], radius=outer_radius, fill=(0, 0, 0, 55))
    shadow_img = shadow_img.filter(ImageFilter.GaussianBlur(radius=35))
    canvas.paste(shadow_img, (phone_x - shadow_pad, phone_y - shadow_pad + 15), shadow_img)
    canvas.paste(phone, (phone_x, phone_y), phone)


def draw_cta_button(draw, text, center_x, y, font, bg_color, text_color, s):
    bbox = draw.textbbox((0, 0), text, font=font)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    pad_x = int(80 * s)
    pad_y = int(28 * s)
    btn_w = tw + pad_x * 2
    btn_h = th + pad_y * 2
    btn_x = center_x - btn_w // 2
    btn_y = y
    radius = btn_h // 2
    draw.rounded_rectangle([(btn_x, btn_y), (btn_x + btn_w, btn_y + btn_h)], radius=radius, fill=bg_color)
    text_y = btn_y + (btn_h - th) // 2
    draw.text((center_x - tw // 2, text_y), text, font=font, fill=text_color)


def generate_tr_preview(size, idx):
    w, h = size
    s = w / 1290
    theme = THEMES[idx]
    copy = COPY_TR[idx]

    canvas = create_gradient(size, theme["bg_top"], theme["bg_bot"]).convert("RGBA")
    draw = ImageDraw.Draw(canvas)

    tag_font = get_body_font(int(32 * s))
    title_font = get_title_font(int(115 * s))
    sub_font = get_sub_font(int(36 * s))
    cta_font = get_body_font(int(38 * s))

    margin_left = int(65 * s)

    # Tag
    tag_y = int(110 * s)
    draw.text((margin_left, tag_y), copy["tag"], font=tag_font, fill=theme["tag"])

    # Title line 1
    line1_y = int(175 * s)
    draw.text((margin_left, line1_y), copy["line1"], font=title_font, fill=theme["title"])

    # Title line 2
    line2_y = line1_y + int(125 * s)
    if copy["line2"]:
        draw.text((margin_left, line2_y), copy["line2"], font=title_font, fill=theme["accent"])
        sub_y = line2_y + int(150 * s)
    else:
        sub_y = line1_y + int(150 * s)

    # Subtitle
    for i, line in enumerate(copy["sub"].split("\n")):
        draw.text((margin_left, sub_y + i * int(50 * s)), line, font=sub_font, fill=theme["sub"])

    # Phone mockup
    screen_w = int(590 * s)
    sub_lines = len(copy["sub"].split("\n"))
    text_bottom = sub_y + sub_lines * int(50 * s)
    phone_top = text_bottom + int(30 * s)
    cta_y = int(h - 170 * s)
    cta_gap = int(55 * s)
    bezel_thickness = int(screen_w * 0.04)
    available_for_phone = cta_y - cta_gap - phone_top
    screen_h = available_for_phone - bezel_thickness * 2

    screenshot_path = os.path.join(SCREENSHOTS_DIR, f"onboard_{SCREENS[idx]}_tr.png")
    draw_phone_bezel(canvas, screenshot_path, w // 2, phone_top, screen_w, screen_h)
    draw_cta_button(draw, copy["cta"], w // 2, cta_y, cta_font, theme["cta_bg"], theme["cta_text"], s)

    return canvas.convert("RGB")


if __name__ == "__main__":
    os.makedirs(OUT_DIR, exist_ok=True)

    # Generate 6.7" (1290x2796)
    print("=== TR 6.7\" (1290x2796) ===")
    for i in range(5):
        img = generate_tr_preview((1290, 2796), i)
        path = os.path.join(OUT_DIR, f"appstore_tr_{i+1}.png")
        img.save(path, "PNG")
        print(f"  + appstore_tr_{i+1}.png: {img.size}")

    # Generate 6.5" (1284x2778) by resize
    print("\n=== TR 6.5\" (1284x2778) ===")
    for i in range(5):
        src = Image.open(os.path.join(OUT_DIR, f"appstore_tr_{i+1}.png"))
        resized = src.resize((1284, 2778), Image.LANCZOS)
        path = os.path.join(OUT_DIR, f"appstore_tr_65_{i+1}.png")
        resized.save(path, "PNG")
        print(f"  + appstore_tr_65_{i+1}.png: {resized.size}")

    print("\nDone!")
