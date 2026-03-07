"""
Untwist — App Store Preview Generator v5
Custom layout per screen — inspired by Calm, Shopify, Reddit reference apps.
Each screen has a unique composition: pill badges, serif italic accents,
decorative circles, and varied phone placements.

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


# ── Fonts ────────────────────────────────────────────────────────────────────

FONT_BOLD = "/System/Library/Fonts/Supplemental/Arial Bold.ttf"
FONT_REG = "/System/Library/Fonts/Supplemental/Arial.ttf"
SF_BOLD = "/System/Library/Fonts/SFNS.ttf"
SF_ITALIC = "/System/Library/Fonts/SFNSItalic.ttf"
NY_SERIF = "/System/Library/Fonts/NewYork.ttf"
NY_SERIF_ITALIC = "/System/Library/Fonts/NewYorkItalic.ttf"
FALLBACK_ITALIC = "/System/Library/Fonts/Supplemental/Georgia Italic.ttf"


def _try_font(paths, size):
    for p in paths:
        if os.path.exists(p):
            try:
                return ImageFont.truetype(p, size)
            except Exception:
                continue
    return ImageFont.truetype(FONT_BOLD, size)


def get_bold_font(size):
    return _try_font([SF_BOLD, FONT_BOLD], size)


def get_serif_italic_font(size):
    return _try_font([NY_SERIF_ITALIC, FALLBACK_ITALIC], size)


def get_body_font(size):
    return _try_font([SF_BOLD, FONT_BOLD], size)


# App Store required sizes
SIZES = {
    "iphone67": (1290, 2796),
    "iphone61": (1179, 2556),
}

# ── Brand Colors ─────────────────────────────────────────────────────────────

PURPLE_DEEP = (75, 50, 140)
PURPLE = (124, 107, 196)
PURPLE_LIGHT = (155, 143, 216)
LAVENDER = (168, 155, 212)
LAVENDER_BG = (240, 235, 252)
BG_DARK = (26, 21, 40)
WHITE = (255, 255, 255)
TEXT_DARK = (45, 35, 68)
TEXT_MID = (107, 97, 137)

# Phone bezel
BEZEL_BLACK = (20, 20, 22)
BEZEL_EDGE = (40, 40, 42)

# iPhone screen aspect ratio (1290:2796 ≈ 1:2.168)
IPHONE_ASPECT = 2796 / 1290

# ── Localized Copy ───────────────────────────────────────────────────────────

COPY = {
    "en": [
        {  # Screen 1 — Hero
            "tag": "CBT COMPANION",
            "line1": "UNTWIST",
            "line2": "your mind.",
            "sub": "Mood tracking, thought journaling,\nbreathing — all in one app.",
        },
        {  # Screen 2 — Thought Unwinder
            "tag": "THOUGHT JOURNAL",
            "line1": "SPOT",
            "line2": "thought traps.",
            "pills": ["4-step reframing", "10 thought traps", "Smart suggestions"],
        },
        {  # Screen 3 — Mood Check
            "tag": "MOOD TRACKER",
            "line1": "TRACK",
            "line2": "your mood.",
            "badge": "10 sec",
        },
        {  # Screen 4 — Insights
            "tag": "INSIGHTS",
            "line1": "SEE your",
            "line2": "progress.",
            "pills": ["Mood trends", "Trap frequency"],
        },
        {  # Screen 5 — Breathing
            "tag": "BREATHE",
            "line1": "BREATHE",
            "line2": "& calm down.",
            "pills": ["4-7-8 technique", "60 seconds"],
        },
    ],
    "tr": [
        {
            "tag": "BDT ARKADAŞIN",
            "line1": "UNTWIST",
            "line2": "zihnini çöz.",
            "sub": "Duygu takibi, düşünce günlüğü,\nnefes egzersizi — tek uygulamada.",
        },
        {
            "tag": "DÜŞÜNCE GÜNLÜĞÜ",
            "line1": "TUZAKLARI",
            "line2": "fark et.",
            "pills": ["4 adımlı çözüm", "10 düşünce tuzağı", "Akıllı öneriler"],
        },
        {
            "tag": "DUYGU TAKİBİ",
            "line1": "DUYGUNU",
            "line2": "takip et.",
            "badge": "10 sn",
        },
        {
            "tag": "İSTATİSTİKLER",
            "line1": "İLERLEMENİ",
            "line2": "gör.",
            "pills": ["Duygu trendleri", "Tuzak sıklığı"],
        },
        {
            "tag": "NEFES AL",
            "line1": "NEFES AL,",
            "line2": "sakinleş.",
            "pills": ["4-7-8 tekniği", "60 saniye"],
        },
    ],
}


# ── Drawing Helpers ──────────────────────────────────────────────────────────

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


def draw_decorative_circles(canvas, circles):
    """Draw semi-transparent decorative circles on canvas.
    circles: list of (cx, cy, radius, (r,g,b), alpha)
    """
    overlay = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(overlay)
    for (cx, cy, rad, color, alpha) in circles:
        d.ellipse([(cx - rad, cy - rad), (cx + rad, cy + rad)], fill=(*color, alpha))
    return Image.alpha_composite(canvas, overlay)


def draw_pill_badge(draw, text, x, y, font, bg_color, text_color, padding=(24, 10)):
    """Draw a pill-shaped badge with text. Returns (width, height)."""
    bbox = draw.textbbox((0, 0), text, font=font)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    w, h = tw + padding[0] * 2, th + padding[1] * 2
    draw.rounded_rectangle([(x, y), (x + w, y + h)], radius=h // 2, fill=bg_color)
    draw.text((x + padding[0], y + padding[1]), text, font=font, fill=text_color)
    return w, h


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

    # Drop shadow behind phone
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


# ── Screen 1: Hero/Home ─────────────────────────────────────────────────────

def generate_screen_1_hero(size, lang, screenshots):
    """Text left-top, phone shifted right & overflowing bottom.
    Dark purple gradient + large decorative circle top-right."""
    w, h = size
    s = w / 1290
    copy = COPY[lang][0]

    # Background: dark purple gradient
    canvas = create_gradient(size, (30, 20, 55), (50, 35, 85)).convert("RGBA")

    # Decorative circle — top-right
    canvas = draw_decorative_circles(canvas, [
        (int(w * 0.85), int(h * 0.08), int(w * 0.45), PURPLE_LIGHT, 25),
        (int(w * 0.1), int(h * 0.75), int(w * 0.25), PURPLE, 15),
    ])

    draw = ImageDraw.Draw(canvas)
    margin = int(75 * s)

    # Pill badge tag
    tag_font = get_bold_font(int(28 * s))
    tag_y = int(130 * s)
    draw_pill_badge(draw, copy["tag"], margin, tag_y, tag_font,
                    (*PURPLE_LIGHT, 40), PURPLE_LIGHT, padding=(int(24 * s), int(10 * s)))

    # Headline: line1 bold, line2 serif italic
    title_font = get_bold_font(int(130 * s))
    italic_font = get_serif_italic_font(int(120 * s))

    line1_y = int(240 * s)
    draw.text((margin, line1_y), copy["line1"], font=title_font, fill=WHITE)

    line2_y = line1_y + int(145 * s)
    draw.text((margin, line2_y), copy["line2"], font=italic_font, fill=PURPLE_LIGHT)

    # Subtitle
    sub_font = get_body_font(int(34 * s))
    sub_y = line2_y + int(150 * s)
    for i, line in enumerate(copy.get("sub", "").split("\n")):
        draw.text((margin, sub_y + i * int(48 * s)), line, font=sub_font, fill=(190, 180, 210))

    # Phone: 55% width, shifted right, overflowing bottom ~15%
    screen_w = int(590 * s)
    screen_h = int(screen_w * IPHONE_ASPECT)
    phone_center_x = int(w * 0.62)
    phone_top_y = int(h * 0.42)  # starts below text, overflows bottom

    draw_phone_bezel(canvas, screenshots["home"], phone_center_x, phone_top_y, screen_w, screen_h)

    return canvas


# ── Screen 2: Thought Unwinder ───────────────────────────────────────────────

def generate_screen_2_unwinder(size, lang, screenshots):
    """Text top-center, phone center, feature pills at bottom.
    Light lavender background + subtle decorative arcs."""
    w, h = size
    s = w / 1290
    copy = COPY[lang][1]

    # Background: light lavender
    canvas = create_gradient(size, LAVENDER_BG, (245, 240, 255)).convert("RGBA")

    # Subtle decorative circles
    canvas = draw_decorative_circles(canvas, [
        (int(w * 0.9), int(h * 0.3), int(w * 0.18), PURPLE_LIGHT, 18),
        (int(w * 0.05), int(h * 0.55), int(w * 0.12), LAVENDER, 20),
    ])

    draw = ImageDraw.Draw(canvas)

    # Pill badge tag — centered
    tag_font = get_bold_font(int(28 * s))
    tag_bbox = draw.textbbox((0, 0), copy["tag"], font=tag_font)
    tag_tw = tag_bbox[2] - tag_bbox[0]
    tag_pad_x = int(24 * s)
    tag_total_w = tag_tw + tag_pad_x * 2
    tag_x = (w - tag_total_w) // 2
    tag_y = int(110 * s)
    draw_pill_badge(draw, copy["tag"], tag_x, tag_y, tag_font,
                    (*PURPLE, 35), PURPLE, padding=(tag_pad_x, int(10 * s)))

    # Headline — centered
    title_font = get_bold_font(int(105 * s))
    italic_font = get_serif_italic_font(int(95 * s))

    line1_y = int(210 * s)
    l1_bbox = draw.textbbox((0, 0), copy["line1"], font=title_font)
    l1_w = l1_bbox[2] - l1_bbox[0]
    draw.text(((w - l1_w) // 2, line1_y), copy["line1"], font=title_font, fill=TEXT_DARK)

    line2_y = line1_y + int(120 * s)
    l2_bbox = draw.textbbox((0, 0), copy["line2"], font=italic_font)
    l2_w = l2_bbox[2] - l2_bbox[0]
    draw.text(((w - l2_w) // 2, line2_y), copy["line2"], font=italic_font, fill=PURPLE)

    # Phone — centered, standard size
    screen_w = int(540 * s)
    screen_h = int(screen_w * IPHONE_ASPECT)
    phone_top_y = int(h * 0.28)

    draw_phone_bezel(canvas, screenshots["unwinder"], w // 2, phone_top_y, screen_w, screen_h)

    # Feature pills at bottom — 3 pills in a row
    pill_font = get_bold_font(int(26 * s))
    pill_y = int(h * 0.90)
    pills = copy.get("pills", [])
    if pills:
        # Calculate total width
        pill_pad_x = int(20 * s)
        pill_pad_y = int(8 * s)
        pill_gap = int(16 * s)
        pill_widths = []
        for text in pills:
            bb = draw.textbbox((0, 0), text, font=pill_font)
            pill_widths.append(bb[2] - bb[0] + pill_pad_x * 2)

        total_pills_w = sum(pill_widths) + pill_gap * (len(pills) - 1)
        px = (w - total_pills_w) // 2

        for i, text in enumerate(pills):
            pw, ph = draw_pill_badge(draw, text, px, pill_y, pill_font,
                                     (*PURPLE, 30), TEXT_DARK, padding=(pill_pad_x, pill_pad_y))
            px += pw + pill_gap

    return canvas


# ── Screen 3: Mood Check ────────────────────────────────────────────────────

def generate_screen_3_mood(size, lang, screenshots):
    """Short headline top, very large phone centered.
    Warm lavender gradient + '10 sec' badge near phone."""
    w, h = size
    s = w / 1290
    copy = COPY[lang][2]

    # Background: warm lavender gradient
    canvas = create_gradient(size, (245, 240, 255), LAVENDER_BG).convert("RGBA")

    # Decorative circles
    canvas = draw_decorative_circles(canvas, [
        (int(w * 0.15), int(h * 0.12), int(w * 0.2), PURPLE_LIGHT, 15),
        (int(w * 0.88), int(h * 0.85), int(w * 0.22), LAVENDER, 18),
    ])

    draw = ImageDraw.Draw(canvas)

    # Pill badge tag — centered
    tag_font = get_bold_font(int(28 * s))
    tag_bbox = draw.textbbox((0, 0), copy["tag"], font=tag_font)
    tag_tw = tag_bbox[2] - tag_bbox[0]
    tag_pad_x = int(24 * s)
    tag_total_w = tag_tw + tag_pad_x * 2
    tag_x = (w - tag_total_w) // 2
    tag_y = int(110 * s)
    draw_pill_badge(draw, copy["tag"], tag_x, tag_y, tag_font,
                    (*PURPLE, 35), PURPLE, padding=(tag_pad_x, int(10 * s)))

    # Headline — centered, compact
    title_font = get_bold_font(int(105 * s))
    italic_font = get_serif_italic_font(int(95 * s))

    line1_y = int(210 * s)
    l1_bbox = draw.textbbox((0, 0), copy["line1"], font=title_font)
    l1_w = l1_bbox[2] - l1_bbox[0]
    draw.text(((w - l1_w) // 2, line1_y), copy["line1"], font=title_font, fill=TEXT_DARK)

    line2_y = line1_y + int(120 * s)
    l2_bbox = draw.textbbox((0, 0), copy["line2"], font=italic_font)
    l2_w = l2_bbox[2] - l2_bbox[0]
    draw.text(((w - l2_w) // 2, line2_y), copy["line2"], font=italic_font, fill=PURPLE)

    # Phone — large (65%), centered, slightly overflowing bottom
    screen_w = int(700 * s)
    screen_h = int(screen_w * IPHONE_ASPECT)
    phone_top_y = int(h * 0.32)

    draw_phone_bezel(canvas, screenshots["mood"], w // 2, phone_top_y, screen_w, screen_h)

    # "10 sec" badge — top-right of phone
    badge_text = copy.get("badge", "10 sec")
    badge_font = get_bold_font(int(26 * s))
    badge_x = w // 2 + int(screen_w * 0.45)
    badge_y = phone_top_y + int(60 * s)
    draw_pill_badge(draw, badge_text, badge_x, badge_y, badge_font,
                    (*PURPLE_DEEP, 200), WHITE, padding=(int(20 * s), int(10 * s)))

    return canvas


# ── Screen 4: Insights ──────────────────────────────────────────────────────

def generate_screen_4_insights(size, lang, screenshots):
    """Phone left side, text right side (horizontal split).
    Medium-dark purple gradient + decorative circles."""
    w, h = size
    s = w / 1290
    copy = COPY[lang][3]

    # Background: medium-dark purple gradient
    canvas = create_gradient(size, (55, 40, 100), (75, 55, 130)).convert("RGBA")

    # Decorative circles
    canvas = draw_decorative_circles(canvas, [
        (int(w * 0.85), int(h * 0.15), int(w * 0.3), PURPLE_LIGHT, 18),
        (int(w * 0.7), int(h * 0.75), int(w * 0.2), PURPLE, 15),
    ])

    draw = ImageDraw.Draw(canvas)

    # Phone — left side, 50% width, overflowing bottom
    screen_w = int(540 * s)
    screen_h = int(screen_w * IPHONE_ASPECT)
    phone_center_x = int(w * 0.32)
    phone_top_y = int(h * 0.22)

    draw_phone_bezel(canvas, screenshots["insights"], phone_center_x, phone_top_y, screen_w, screen_h)

    # Text — right side
    right_x = int(w * 0.62)
    right_w = int(w * 0.34)

    # Pill badge tag
    tag_font = get_bold_font(int(28 * s))
    tag_y = int(h * 0.28)
    draw_pill_badge(draw, copy["tag"], right_x, tag_y, tag_font,
                    (*PURPLE_LIGHT, 40), PURPLE_LIGHT, padding=(int(24 * s), int(10 * s)))

    # Headline — right side, vertical
    title_font = get_bold_font(int(90 * s))
    italic_font = get_serif_italic_font(int(85 * s))

    line1_y = tag_y + int(80 * s)
    draw.text((right_x, line1_y), copy["line1"], font=title_font, fill=WHITE)

    line2_y = line1_y + int(110 * s)
    draw.text((right_x, line2_y), copy["line2"], font=italic_font, fill=PURPLE_LIGHT)

    # Stat pills — right side, stacked
    pills = copy.get("pills", [])
    pill_font = get_bold_font(int(26 * s))
    pill_y = line2_y + int(140 * s)
    pill_pad_x = int(20 * s)
    pill_pad_y = int(10 * s)
    for text in pills:
        pw, ph = draw_pill_badge(draw, text, right_x, pill_y, pill_font,
                                 (*WHITE, 35), WHITE, padding=(pill_pad_x, pill_pad_y))
        pill_y += ph + int(16 * s)

    return canvas


# ── Screen 5: Breathing ─────────────────────────────────────────────────────

def generate_screen_5_breathing(size, lang, screenshots):
    """Phone upper-center, text at bottom.
    Deep purple gradient + large decorative circles."""
    w, h = size
    s = w / 1290
    copy = COPY[lang][4]

    # Background: deep purple gradient
    canvas = create_gradient(size, (65, 45, 125), (35, 25, 70)).convert("RGBA")

    # Large decorative circles
    canvas = draw_decorative_circles(canvas, [
        (int(w * 0.2), int(h * 0.15), int(w * 0.35), PURPLE, 20),
        (int(w * 0.8), int(h * 0.7), int(w * 0.4), PURPLE_DEEP, 22),
        (int(w * 0.5), int(h * 0.45), int(w * 0.15), PURPLE_LIGHT, 12),
    ])

    draw = ImageDraw.Draw(canvas)

    # Pill badge tag — top center
    tag_font = get_bold_font(int(28 * s))
    tag_bbox = draw.textbbox((0, 0), copy["tag"], font=tag_font)
    tag_tw = tag_bbox[2] - tag_bbox[0]
    tag_pad_x = int(24 * s)
    tag_total_w = tag_tw + tag_pad_x * 2
    tag_x = (w - tag_total_w) // 2
    tag_y = int(110 * s)
    draw_pill_badge(draw, copy["tag"], tag_x, tag_y, tag_font,
                    (*WHITE, 35), WHITE, padding=(tag_pad_x, int(10 * s)))

    # Phone — upper-center
    screen_w = int(560 * s)
    screen_h = int(screen_w * IPHONE_ASPECT)
    phone_top_y = int(h * 0.13)

    draw_phone_bezel(canvas, screenshots["breathing"], w // 2, phone_top_y, screen_w, screen_h)

    # Headline — bottom, large
    title_font = get_bold_font(int(110 * s))
    italic_font = get_serif_italic_font(int(100 * s))

    line1_y = int(h * 0.78)
    l1_bbox = draw.textbbox((0, 0), copy["line1"], font=title_font)
    l1_w = l1_bbox[2] - l1_bbox[0]
    draw.text(((w - l1_w) // 2, line1_y), copy["line1"], font=title_font, fill=WHITE)

    line2_y = line1_y + int(125 * s)
    l2_bbox = draw.textbbox((0, 0), copy["line2"], font=italic_font)
    l2_w = l2_bbox[2] - l2_bbox[0]
    draw.text(((w - l2_w) // 2, line2_y), copy["line2"], font=italic_font, fill=PURPLE_LIGHT)

    # Feature pills — below headline
    pills = copy.get("pills", [])
    if pills:
        pill_font = get_bold_font(int(26 * s))
        pill_y = line2_y + int(115 * s)
        pill_pad_x = int(20 * s)
        pill_pad_y = int(8 * s)
        pill_gap = int(16 * s)

        pill_widths = []
        for text in pills:
            bb = draw.textbbox((0, 0), text, font=pill_font)
            pill_widths.append(bb[2] - bb[0] + pill_pad_x * 2)

        total_pills_w = sum(pill_widths) + pill_gap * (len(pills) - 1)
        px = (w - total_pills_w) // 2

        for text in pills:
            pw, ph = draw_pill_badge(draw, text, px, pill_y, pill_font,
                                     (*WHITE, 30), (215, 205, 235),
                                     padding=(pill_pad_x, pill_pad_y))
            px += pw + pill_gap

    return canvas


# ── Dispatcher ───────────────────────────────────────────────────────────────

GENERATORS = [
    generate_screen_1_hero,
    generate_screen_2_unwinder,
    generate_screen_3_mood,
    generate_screen_4_insights,
    generate_screen_5_breathing,
]


def generate_preview(size, prefix, lang, idx, screenshots):
    """Generate a single preview image using the screen-specific layout."""
    canvas = GENERATORS[idx](size, lang, screenshots)

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
