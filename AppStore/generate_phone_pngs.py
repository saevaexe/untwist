"""
Generate phone bezel PNG images for HTML/CSS App Store previews.
Reuses bezel drawing logic from generate_previews.py.

Usage: python3 AppStore/generate_phone_pngs.py
Output: AppStore/previews-html/phones/{screen}_{lang}.png
"""

from PIL import Image, ImageDraw, ImageFilter, ImageFont
import os

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
SCREENSHOTS_DIR = os.path.join(SCRIPT_DIR, "Screenshots")
OUT_DIR = os.path.join(SCRIPT_DIR, "previews-html", "phones")

SCREENS = ["home", "unwinder", "mood", "insights", "breathing"]
LANGS = ["en", "tr"]

# Bezel colors
BEZEL_BLACK = (20, 20, 22)
BEZEL_EDGE = (40, 40, 42)

# Target screen size inside bezel (iPhone 6.7" aspect ratio)
SCREEN_W = 560
SCREEN_H = int(SCREEN_W * (2796 / 1290))  # ~1214


def generate_phone_png(screenshot_path, output_path):
    """Render a phone bezel around a screenshot and save as transparent PNG."""
    screen_w, screen_h = SCREEN_W, SCREEN_H
    bezel_thickness = int(screen_w * 0.04)
    outer_radius = int(screen_w * 0.14)
    inner_radius = int(screen_w * 0.10)

    phone_w = screen_w + bezel_thickness * 2
    phone_h = screen_h + bezel_thickness * 2

    # Shadow padding
    shadow_pad = 50
    canvas_w = phone_w + shadow_pad * 2
    canvas_h = phone_h + shadow_pad * 2

    # Create canvas with transparency
    canvas = Image.new("RGBA", (canvas_w, canvas_h), (0, 0, 0, 0))

    # Draw shadow
    shadow = Image.new("RGBA", (canvas_w, canvas_h), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.rounded_rectangle(
        [(shadow_pad, shadow_pad + 12),
         (shadow_pad + phone_w - 1, shadow_pad + phone_h + 11)],
        radius=outer_radius, fill=(0, 0, 0, 50)
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=30))
    canvas = Image.alpha_composite(canvas, shadow)

    # Create phone frame
    phone = Image.new("RGBA", (phone_w, phone_h), (0, 0, 0, 0))
    pd = ImageDraw.Draw(phone)

    # Outer bezel
    pd.rounded_rectangle(
        [(0, 0), (phone_w - 1, phone_h - 1)],
        radius=outer_radius, fill=(*BEZEL_BLACK, 255)
    )
    # Edge highlight
    pd.rounded_rectangle(
        [(1, 1), (phone_w - 2, phone_h - 2)],
        radius=outer_radius, fill=(*BEZEL_EDGE, 255)
    )
    # Inner bezel
    pd.rounded_rectangle(
        [(3, 3), (phone_w - 4, phone_h - 4)],
        radius=outer_radius - 2, fill=(*BEZEL_BLACK, 255)
    )

    # Screen area
    screen_x = bezel_thickness
    screen_y = bezel_thickness
    pd.rounded_rectangle(
        [(screen_x, screen_y),
         (screen_x + screen_w - 1, screen_y + screen_h - 1)],
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

        # Mask for rounded corners
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
        print(f"  ! Missing screenshot: {screenshot_path}")

    # Paste phone onto canvas
    canvas.paste(phone, (shadow_pad, shadow_pad), phone)

    # Save
    canvas.save(output_path, "PNG")
    print(f"  + {os.path.basename(output_path)} ({canvas_w}x{canvas_h})")


if __name__ == "__main__":
    os.makedirs(OUT_DIR, exist_ok=True)

    for lang in LANGS:
        print(f"\n=== {lang.upper()} ===")
        for screen in SCREENS:
            src = os.path.join(SCREENSHOTS_DIR, f"{screen}_{lang}.png")
            dst = os.path.join(OUT_DIR, f"{screen}_{lang}.png")
            generate_phone_png(src, dst)

    print(f"\nDone! Output: {OUT_DIR}")
