#!/usr/bin/env python3
"""Generate 1x/2x variants for Twisty assets and update Contents.json.

Strategy:
- Treat current `Twisty*.png` as the 3x master.
- Generate `*-2x.png` and `*-1x.png` via Lanczos downsampling.
- Update each imageset `Contents.json` to reference explicit files for 1x/2x/3x.
"""

from __future__ import annotations

import json
from pathlib import Path

from PIL import Image


def resized_size(size: tuple[int, int], scale: float) -> tuple[int, int]:
    w, h = size
    return max(1, int(round(w * scale))), max(1, int(round(h * scale)))


def main() -> None:
    repo = Path(__file__).resolve().parent.parent
    assets_root = repo / "Untwist" / "Resources" / "Assets.xcassets"
    twisty_sets = sorted(assets_root.glob("Twisty*.imageset"))

    if not twisty_sets:
        raise SystemExit(f"No Twisty imagesets found under: {assets_root}")

    for imageset in twisty_sets:
        base_name = imageset.name.replace(".imageset", "")
        master_3x = imageset / f"{base_name}.png"
        if not master_3x.exists():
            raise FileNotFoundError(f"Missing 3x master: {master_3x}")

        img = Image.open(master_3x).convert("RGBA")

        out_2x = imageset / f"{base_name}-2x.png"
        out_1x = imageset / f"{base_name}-1x.png"

        img.resize(resized_size(img.size, 2.0 / 3.0), Image.Resampling.LANCZOS).save(out_2x)
        img.resize(resized_size(img.size, 1.0 / 3.0), Image.Resampling.LANCZOS).save(out_1x)

        contents_path = imageset / "Contents.json"
        contents = json.loads(contents_path.read_text())
        contents["images"] = [
            {"filename": out_1x.name, "idiom": "universal", "scale": "1x"},
            {"filename": out_2x.name, "idiom": "universal", "scale": "2x"},
            {"filename": master_3x.name, "idiom": "universal", "scale": "3x"},
        ]
        contents_path.write_text(json.dumps(contents, indent=2, ensure_ascii=False) + "\n")

        print(
            f"{imageset.name}: "
            f"3x={img.size[0]}x{img.size[1]} "
            f"2x={resized_size(img.size, 2.0/3.0)[0]}x{resized_size(img.size, 2.0/3.0)[1]} "
            f"1x={resized_size(img.size, 1.0/3.0)[0]}x{resized_size(img.size, 1.0/3.0)[1]}"
        )


if __name__ == "__main__":
    main()
