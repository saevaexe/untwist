"""
Untwist — App Store Preview Generator v4
Generates 5 app-feature preview images per language (EN + TR) for 6.7" and 6.1" devices.
Uses actual app screenshots with phone bezel frame and marketing copy overlay.

Usage:
  1. Take app screenshots from simulator (with sample data)
  2. Place in AppStore/Screenshots/ with naming: {screen}_{lang}.png
     e.g. home_en.png, unwinder_tr.png, mood_en.png, insights_tr.png, breathing_en.png
  3. Run: python3 AppStore/generate_previews.py
"""

from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os

# Paths
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
OUT_DIR = os.path.join(SCRIPT_DIR, "Previews")
SCREENSHOTS_DIR = os.path.join(SCRIPT_DIR, "Screenshots")

# Screenshot naming: {screen}_{lang}.png
SCREENS = ["home", "unwinder", "mood", "insights", "breathing"]


def screenshots_for(lang):
    return {s: os.path.join(SCREENSHOTS_DIR, f"{s}_{lang}.png") for s in SCREENS}


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


# App Store required sizes
SIZES = {
    "iphone67": (1290, 2796),
    "iphone61": (1179, 2556),
}

# Untwist brand colors
PURPLE_DEEP = (75, 50, 140)
PURPLE = (124, 107, 196)
PURPLE_LIGHT = (155, 143, 216)
LAVENDER = (168, 155, 212)
LAVENDER_BG = (240, 235, 252)
BG_LIGHT = (250, 248, 255)
BG_DARK = (26, 21, 40)
BLACK = (0, 0, 0)
WHITE = (255, 255, 255)
TEXT_DARK = (45, 35, 68)
TEXT_MID = (107, 97, 137)

# Phone bezel colors
BEZEL_BLACK = (20, 20, 22)
BEZEL_EDGE = (40, 40, 42)

# 5-screen color themes (matched to content)
THEMES = [
    # 1. Home — deep purple (dark, hero feel)
    {
        "bg_top": (30, 20, 55),
        "bg_bot": (50, 35, 85),
        "title": WHITE,
        "accent": PURPLE_LIGHT,
        "sub": (190, 180, 210),
        "tag": PURPLE_LIGHT,
    },
    # 2. Thought Unwinder — warm lavender
    {
        "bg_top": LAVENDER_BG,
        "bg_bot": (245, 240, 255),
        "title": TEXT_DARK,
        "accent": PURPLE,
        "sub": TEXT_MID,
        "tag": PURPLE,
    },
    # 3. Mood Check — soft lavender
    {
        "bg_top": (245, 240, 255),
        "bg_bot": LAVENDER_BG,
        "title": TEXT_DARK,
        "accent": PURPLE,
        "sub": TEXT_MID,
        "tag": PURPLE,
    },
    # 4. Insights — medium transitional
    {
        "bg_top": (235, 228, 252),
        "bg_bot": (215, 205, 245),
        "title": TEXT_DARK,
        "accent": PURPLE_DEEP,
        "sub": TEXT_MID,
        "tag": PURPLE_DEEP,
    },
    # 5. Breathing — rich purple (dark, calming)
    {
        "bg_top": PURPLE,
        "bg_bot": (90, 70, 165),
        "title": WHITE,
        "accent": WHITE,
        "sub": (215, 205, 235),
        "tag": (215, 205, 235),
    },
]

# Localized copy — feature-focused headlines
COPY = {
    "en": [
        {
            "tag": "CBT COMPANION",
            "line1": "YOUR CBT",
            "line2": "companion.",
            "sub": "Mood tracking, thought journaling,\nbreathing — all in one app.",
        },
        {
            "tag": "THOUGHT JOURNAL",
            "line1": "SPOT",
            "line2": "thought traps.",
            "sub": "4-step guided reframing.\nFind a healthier perspective.",
        },
        {
            "tag": "MOOD TRACKER",
            "line1": "TRACK",
            "line2": "your mood.",
            "sub": "Quick slider check-in with notes.\nSee patterns over time.",
        },
        {
            "tag": "INSIGHTS & STATS",
            "line1": "SEE",
            "line2": "your progress.",
            "sub": "Mood trends, trap frequency,\nactivity heatmaps at a glance.",
        },
        {
            "tag": "BREATHING EXERCISE",
            "line1": "BREATHE",
            "line2": "& calm down.",
            "sub": "4-7-8 guided breathing.\n60 seconds to feel better.",
        },
    ],
    "tr": [
        {
            "tag": "BDT ARKADAŞIN",
            "line1": "BDT",
            "line2": "arkadaşın.",
            "sub": "Duygu takibi, düşünce günlüğü,\nnefes egzersizi — tek uygulamada.",
        },
        {
            "tag": "DÜŞÜNCE GÜNLÜĞÜ",
            "line1": "TUZAKLARI",
            "line2": "fark et.",
            "sub": "4 adımlı rehberli yeniden çerçeveleme.\nDaha sağlıklı bir bakış aç.",
        },
        {
            "tag": "DUYGU TAKİBİ",
            "line1": "DUYGUNU",
            "line2": "takip et.",
            "sub": "Hızlı kaydırmalı kayıt ve notlar.\nZamanla kalıplarını gör.",
        },
        {
            "tag": "İSTATİSTİKLER",
            "line1": "İLERLEMENİ",
            "line2": "gör.",
            "sub": "Duygu trendleri, tuzak sıklığı,\naktivite haritası bir bakışta.",
        },
        {
            "tag": "NEFES EGZERSİZİ",
            "line1": "NEFES AL,",
            "line2": "sakinleş.",
            "sub": "4-7-8 rehberli nefes tekniği.\n60 saniyede rahatlama.",
        },
    ],
}


# ── Drawing helpers ──────────────────────────────────────────────────────────

def create_gradient(size, top_color, bot_color):
    """Create a vertical gradient image."""
    w, h = size
    img = Image.new("RGB", size)
    px = img.load()
    for y in range(h):
        r = y / h
        for x in range(w):
            px[x, y] = tuple(int(top_color[i] + (bot_color[i] - top_color[i]) * r) for i in range(3))
    return img


def round_corners(img, radius):
    """Round the corners of an image with alpha mask."""
    mask = Image.new("L", img.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([(0, 0), img.size], radius=radius, fill=255)
    result = img.copy()
    result.putalpha(mask)
    return result


def draw_phone_bezel(canvas, screenshot_path, center_x, top_y, screen_w, screen_h):
    """Draw a realistic iPhone bezel frame with Dynamic Island."""
    bezel_thickness = int(screen_w * 0.04)
    outer_radius = int(screen_w * 0.14)
    inner_radius = int(screen_w * 0.10)

    phone_w = screen_w + bezel_thickness * 2
    phone_h = screen_h + bezel_thickness * 2
    phone_x = center_x - phone_w // 2
    phone_y = top_y

    phone = Image.new("RGBA", (phone_w, phone_h), (0, 0, 0, 0))
    pd = ImageDraw.Draw(phone)

    # Outer bezel
    pd.rounded_rectangle(
        [(0, 0), (phone_w - 1, phone_h - 1)],
        radius=outer_radius, fill=(*BEZEL_BLACK, 255)
    )
    # Subtle edge highlight
    pd.rounded_rectangle(
        [(1, 1), (phone_w - 2, phone_h - 2)],
        radius=outer_radius, fill=(*BEZEL_EDGE, 255)
    )
    # Inner bezel fill
    pd.rounded_rectangle(
        [(3, 3), (phone_w - 4, phone_h - 4)],
        radius=outer_radius - 2, fill=(*BEZEL_BLACK, 255)
    )

    # Screen area
    screen_x = bezel_thickness
    screen_y = bezel_thickness
    pd.rounded_rectangle(
        [(screen_x, screen_y), (screen_x + screen_w - 1, screen_y + screen_h - 1)],
        radius=inner_radius, fill=(200, 200, 200, 255)
    )

    # Dynamic Island
    di_w = int(screen_w * 0.28)
    di_h = int(screen_w * 0.075)
    di_x = phone_w // 2 - di_w // 2
    di_y = bezel_thickness + int(screen_h * 0.015)
    di_radius = di_h // 2
    pd.rounded_rectangle(
        [(di_x, di_y), (di_x + di_w, di_y + di_h)],
        radius=di_radius, fill=(*BEZEL_BLACK, 255)
    )

    # Load and paste screenshot
    if os.path.exists(screenshot_path):
        screenshot = Image.open(screenshot_path).convert("RGBA")
        screenshot = screenshot.resize((screen_w, screen_h), Image.LANCZOS)
        ss_mask = Image.new("L", (screen_w, screen_h), 0)
        ImageDraw.Draw(ss_mask).rounded_rectangle(
            [(0, 0), (screen_w - 1, screen_h - 1)],
            radius=inner_radius, fill=255
        )
        phone.paste(screenshot, (screen_x, screen_y), ss_mask)
        # Re-draw Dynamic Island on top
        pd2 = ImageDraw.Draw(phone)
        pd2.rounded_rectangle(
            [(di_x, di_y), (di_x + di_w, di_y + di_h)],
            radius=di_radius, fill=(*BEZEL_BLACK, 255)
        )
    else:
        print(f"    ! Missing: {os.path.basename(screenshot_path)}")
        try:
            pf = ImageFont.truetype(FONT_REG, 32)
        except Exception:
            pf = ImageFont.load_default()
        pd.text((screen_x + screen_w // 4, screen_y + screen_h // 2),
                "Screenshot\nNeeded", fill=WHITE, font=pf)

    # Drop shadow
    shadow_pad = 60
    shadow_img = Image.new("RGBA",
                           (phone_w + shadow_pad * 2, phone_h + shadow_pad * 2),
                           (0, 0, 0, 0))
    ImageDraw.Draw(shadow_img).rounded_rectangle(
        [(shadow_pad, shadow_pad),
         (phone_w + shadow_pad - 1, phone_h + shadow_pad - 1)],
        radius=outer_radius, fill=(0, 0, 0, 55)
    )
    shadow_img = shadow_img.filter(ImageFilter.GaussianBlur(radius=35))

    canvas.paste(shadow_img,
                 (phone_x - shadow_pad, phone_y - shadow_pad + 15),
                 shadow_img)
    canvas.paste(phone, (phone_x, phone_y), phone)


# ── Main generation ──────────────────────────────────────────────────────────

def generate_preview(size, prefix, lang, idx, screenshots):
    """Generate a single preview image with bezel phone frame."""
    w, h = size
    s = w / 1290  # scale factor
    theme = THEMES[idx]
    copy = COPY[lang][idx]

    # Background gradient
    canvas = create_gradient(size, theme["bg_top"], theme["bg_bot"]).convert("RGBA")
    draw = ImageDraw.Draw(canvas)

    # Fonts
    tag_font = get_body_font(int(32 * s))
    title_font = get_title_font(int(115 * s))
    sub_font = get_sub_font(int(36 * s))

    # ── Text layout ──
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

    # ── Phone mockup with bezel ──
    screen_w = int(590 * s)

    sub_lines = len(copy["sub"].split("\n"))
    text_bottom = sub_y + sub_lines * int(50 * s)
    phone_top = text_bottom + int(30 * s)

    # Screen fills remaining space to bottom with padding
    bezel_thickness = int(screen_w * 0.04)
    bottom_pad = int(80 * s)
    available_for_phone = h - phone_top - bottom_pad
    screen_h = available_for_phone - bezel_thickness * 2

    screen_name = SCREENS[idx]
    draw_phone_bezel(canvas, screenshots[screen_name], w // 2, phone_top, screen_w, screen_h)

    # Save
    out_name = f"{prefix}_preview_{idx + 1}_{lang}.png"
    canvas.convert("RGB").save(os.path.join(OUT_DIR, out_name), quality=95)
    print(f"  + {out_name}")


if __name__ == "__main__":
    os.makedirs(OUT_DIR, exist_ok=True)
    os.makedirs(SCREENSHOTS_DIR, exist_ok=True)

    print(f"Screenshots: {SCREENSHOTS_DIR}")
    print(f"Output: {OUT_DIR}\n")

    for lang in ["en", "tr"]:
        shots = screenshots_for(lang)
        print(f"\n=== {lang.upper()} ===")
        for name, size in SIZES.items():
            print(f"\n--- {name} ({size[0]}x{size[1]}) ---")
            for i in range(len(SCREENS)):
                generate_preview(size, name, lang, i, shots)

    print(f"\nDone! Output: {OUT_DIR}")
    print(f"\nRequired screenshots (place in {SCREENSHOTS_DIR}):")
    for lang in ["en", "tr"]:
        print(f"  {lang.upper()}: " + ", ".join(f"{s}_{lang}.png" for s in SCREENS))
