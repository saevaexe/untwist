"""
Untwist — App Store Preview Generator
Generates 5 preview images per language (EN + TR) for 6.7" and 6.1" devices.
Requires raw simulator screenshots in AppStore/Screenshots/ folder.

Usage:
  1. Take screenshots from simulator (xcrun simctl io booted screenshot)
  2. Place in AppStore/Screenshots/ with naming convention below
  3. Run: python3 AppStore/generate_previews.py
"""

from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os

# Paths
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
OUT_DIR = os.path.join(SCRIPT_DIR, "Previews")
SCREENSHOTS_DIR = os.path.join(SCRIPT_DIR, "Screenshots")

# Screenshot naming: {screen}_{lang}.png
# Required screenshots per language:
#   home_en.png, mood_en.png, unwinder_en.png, unwinding_en.png, insights_en.png
#   home_tr.png, mood_tr.png, unwinder_tr.png, unwinding_tr.png, insights_tr.png
SCREENS = ["home", "mood", "unwinder", "unwinding", "insights"]

def screenshots_for(lang):
    return {s: os.path.join(SCREENSHOTS_DIR, f"{s}_{lang}.png") for s in SCREENS}

# Fonts
FONT_BOLD = "/System/Library/Fonts/Supplemental/Arial Bold.ttf"
FONT_REG = "/System/Library/Fonts/Supplemental/Arial.ttf"

# App Store required sizes
SIZES = {
    "iphone67": (1290, 2796),   # iPhone 6.7" (iPhone 14 Pro Max / 15 Pro Max)
    "iphone61": (1179, 2556),   # iPhone 6.1" (iPhone 14 Pro / 15 Pro)
}

# Untwist brand colors
PURPLE = (124, 107, 196)        # primaryPurple
PURPLE_DARK = (155, 143, 216)   # dark mode purple
LAVENDER = (168, 155, 212)      # secondaryLavender
BG_LIGHT = (250, 248, 255)      # appBackground light
BG_DARK = (26, 21, 40)          # appBackground dark
ORANGE = (242, 166, 90)         # twistyOrange
GREEN = (91, 189, 138)          # successGreen
CRISIS_RED = (232, 115, 108)    # crisisWarning
WHITE = (255, 255, 255)
TEXT_PRIMARY = (45, 35, 68)
TEXT_SECONDARY = (107, 97, 137)

# Localized texts for preview cards
TEXTS = {
    "en": {
        # Preview 1: Hero
        "hero_1": "Untwist",
        "hero_2": "Your Thoughts",
        "hero_sub": "CBT-based self-help companion",
        # Preview 2: Mood Check
        "mood_title": "Check In With",
        "mood_title2": "How You Feel",
        "mood_sub": "Simple mood tracking in 10 seconds",
        # Preview 3: Thought Unwinder
        "unwinder_title": "Spot Thought",
        "unwinder_title2": "Traps",
        "unwinder_sub": "4-step guided reframing process",
        # Preview 4: Unwinding Now
        "unwinding_title": "Instant Calm",
        "unwinding_title2": "When You Need It",
        "unwinding_sub": "Guided breathing in under a minute",
        # Preview 5: Insights
        "insights_title": "See Your",
        "insights_title2": "Progress",
        "insights_sub": "Trends and stats, zero guilt",
    },
    "tr": {
        "hero_1": "Düşüncelerini",
        "hero_2": "Çöz",
        "hero_sub": "BDT tabanlı kişisel gelişim arkadaşın",
        "mood_title": "Nasıl",
        "mood_title2": "Hissediyorsun?",
        "mood_sub": "10 saniyede duygu kaydı",
        "unwinder_title": "Düşünce",
        "unwinder_title2": "Tuzaklarını Bul",
        "unwinder_sub": "4 adımlı yeniden çerçeveleme",
        "unwinding_title": "Anında",
        "unwinding_title2": "Sakinleş",
        "unwinding_sub": "1 dakikada rehberli nefes",
        "insights_title": "İlerlemeni",
        "insights_title2": "Gör",
        "insights_sub": "Trendler ve istatistikler, baskı yok",
    },
}


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


def add_phone_frame(canvas, screenshot_path, pos, phone_size):
    """Frameless modern style: rounded screenshot + drop shadow."""
    if not os.path.exists(screenshot_path):
        print(f"    ⚠ Missing: {os.path.basename(screenshot_path)}")
        # Draw placeholder
        ph = Image.new("RGBA", phone_size, (*LAVENDER, 180))
        d = ImageDraw.Draw(ph)
        d.text((phone_size[0] // 4, phone_size[1] // 2), "Screenshot\nNeeded", fill=WHITE)
        rounded = round_corners(ph, int(phone_size[0] * 0.1))
        canvas.paste(rounded, pos, rounded)
        return

    screenshot = Image.open(screenshot_path).convert("RGBA")
    screenshot = screenshot.resize(phone_size, Image.LANCZOS)
    radius = int(phone_size[0] * 0.1)
    rounded = round_corners(screenshot, radius)

    # Drop shadow
    shadow_pad = 40
    shadow = Image.new("RGBA",
                        (phone_size[0] + shadow_pad * 2, phone_size[1] + shadow_pad * 2),
                        (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle(
        [(shadow_pad, shadow_pad),
         (phone_size[0] + shadow_pad - 1, phone_size[1] + shadow_pad - 1)],
        radius=radius, fill=(0, 0, 0, 50)
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=25))
    canvas.paste(shadow, (pos[0] - shadow_pad, pos[1] - shadow_pad + 10), shadow)
    canvas.paste(rounded, pos, rounded)


def text_centered(draw, text, y, font, fill, w):
    bbox = draw.textbbox((0, 0), text, font=font)
    draw.text(((w - (bbox[2] - bbox[0])) // 2, y), text, font=font, fill=fill)


def generate_preview(size, prefix, lang, screen_idx, screenshots):
    """Generate a single preview image with gradient bg + text + device mockup."""
    w, h = size
    s = w / 1290  # scale factor based on 6.7" width
    t = TEXTS[lang]

    screen_name = SCREENS[screen_idx]
    screen_keys = [
        ("hero_1", "hero_2", "hero_sub"),
        ("mood_title", "mood_title2", "mood_sub"),
        ("unwinder_title", "unwinder_title2", "unwinder_sub"),
        ("unwinding_title", "unwinding_title2", "unwinding_sub"),
        ("insights_title", "insights_title2", "insights_sub"),
    ]

    # Color themes per preview
    gradients = [
        (PURPLE, (90, 70, 160)),       # Hero: purple
        (BG_LIGHT, (235, 230, 250)),   # Mood: light lavender
        (BG_DARK, (40, 30, 60)),       # Unwinder: dark
        (GREEN, (60, 150, 110)),       # Unwinding: green
        (PURPLE, (90, 70, 160)),       # Insights: purple
    ]

    text_colors = [
        (WHITE, (255, 255, 255, 200)),          # Hero
        (TEXT_PRIMARY, (*TEXT_SECONDARY, 200)),   # Mood
        (WHITE, (200, 200, 220, 200)),           # Unwinder
        (WHITE, (255, 255, 255, 200)),           # Unwinding
        (WHITE, (255, 255, 255, 200)),           # Insights
    ]

    top_c, bot_c = gradients[screen_idx]
    title_c, sub_c = text_colors[screen_idx]
    t1_key, t2_key, sub_key = screen_keys[screen_idx]

    canvas = create_gradient(size, top_c, bot_c).convert("RGBA")
    draw = ImageDraw.Draw(canvas)

    # Title text
    tf = ImageFont.truetype(FONT_BOLD, int(78 * s))
    sf = ImageFont.truetype(FONT_REG, int(36 * s))

    text_centered(draw, t[t1_key], int(120 * s), tf, title_c, w)
    text_centered(draw, t[t2_key], int(120 * s + 95 * s), tf, title_c, w)
    text_centered(draw, t[sub_key], int(120 * s + 220 * s), sf, sub_c, w)

    # Device mockup
    pw = int(580 * s)
    ph = int(1250 * s)
    px = (w - pw) // 2
    py = int(460 * s)

    add_phone_frame(canvas, screenshots[screen_name], (px, py), (pw, ph))

    out_name = f"{prefix}_preview_{screen_idx + 1}_{lang}.png"
    canvas.convert("RGB").save(os.path.join(OUT_DIR, out_name))
    print(f"  ✓ {out_name}")


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

    print(f"\n✓ Done! Output: {OUT_DIR}")
    print(f"\nTo capture screenshots, run in simulator:")
    print(f"  xcrun simctl status_bar booted override --time '09:41' --batteryState charged --batteryLevel 100")
    print(f"  xcrun simctl io booted screenshot AppStore/Screenshots/home_en.png")
