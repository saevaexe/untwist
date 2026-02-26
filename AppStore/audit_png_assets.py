#!/usr/bin/env python3
"""Audit PNG assets in an Xcode .xcassets catalog.

Usage:
  python3 AppStore/audit_png_assets.py
  python3 AppStore/audit_png_assets.py --contact-sheet /tmp/untwist_assets.png
"""

from __future__ import annotations

import argparse
import datetime as dt
import json
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

try:
    from PIL import Image, ImageDraw
except Exception as exc:  # pragma: no cover
    raise SystemExit(
        "Pillow is required. Install with: python3 -m pip install pillow\n"
        f"Import error: {exc}"
    )


@dataclass
class AssetStat:
    path: Path
    name: str
    imageset: str
    width: int
    height: int
    transparent_pct: float
    partial_pct: float
    white_partial_pct: float
    margins: tuple[int, int, int, int]  # left, right, top, bottom


def parse_args() -> argparse.Namespace:
    here = Path(__file__).resolve().parent
    default_assets = (here.parent / "Untwist" / "Resources" / "Assets.xcassets").resolve()
    today = dt.date.today().isoformat()
    default_output = (here / f"PNG_ASSET_AUDIT_{today}.md").resolve()

    parser = argparse.ArgumentParser(description="Audit PNG assets in xcassets")
    parser.add_argument("--assets", type=Path, default=default_assets, help="Path to Assets.xcassets")
    parser.add_argument("--output", type=Path, default=default_output, help="Markdown report output")
    parser.add_argument(
        "--contact-sheet",
        type=Path,
        default=None,
        help="Optional image output path for a checkerboard contact sheet",
    )
    return parser.parse_args()


def png_files(assets_root: Path) -> list[Path]:
    return sorted(assets_root.rglob("*.png"))


def file_stats(path: Path) -> AssetStat:
    img = Image.open(path).convert("RGBA")
    w, h = img.size
    total = w * h
    data = list(img.getdata())

    transparent = 0
    opaque = 0
    partial = 0
    white_partial = 0

    for r, g, b, a in data:
        if a == 0:
            transparent += 1
        elif a == 255:
            opaque += 1
        else:
            partial += 1
            if r > 220 and g > 220 and b > 220:
                white_partial += 1

    alpha_bbox = img.getchannel("A").getbbox()
    if alpha_bbox:
        l, t, r, b = alpha_bbox
        margins = (l, w - r, t, h - b)
    else:
        margins = (0, 0, 0, 0)

    return AssetStat(
        path=path,
        name=path.name,
        imageset=path.parent.name,
        width=w,
        height=h,
        transparent_pct=(transparent * 100.0 / total),
        partial_pct=(partial * 100.0 / total),
        white_partial_pct=(white_partial * 100.0 / partial) if partial else 0.0,
        margins=margins,
    )


def scale_map(assets_root: Path) -> dict[str, list[str]]:
    out: dict[str, list[str]] = {}
    for cjson in sorted(assets_root.glob("*.imageset/Contents.json")):
        try:
            content = json.loads(cjson.read_text())
        except Exception:
            continue
        scales: list[str] = []
        for image_entry in content.get("images", []):
            if "filename" in image_entry:
                scales.append(image_entry.get("scale", "?"))
        out[cjson.parent.name] = scales
    return out


def flagged(stats: Iterable[AssetStat]) -> tuple[list[AssetStat], list[AssetStat], list[AssetStat]]:
    partial_outliers = [s for s in stats if s.partial_pct > 20.0]
    white_halo_risk = [s for s in stats if s.white_partial_pct > 25.0 and s.partial_pct > 1.0]
    low_resolution = [s for s in stats if max(s.width, s.height) < 420]
    return partial_outliers, white_halo_risk, low_resolution


def write_report(
    output: Path,
    assets_root: Path,
    stats: list[AssetStat],
    scale_info: dict[str, list[str]],
    partial_outliers: list[AssetStat],
    white_halo_risk: list[AssetStat],
    low_resolution: list[AssetStat],
    contact_sheet: Path | None,
) -> None:
    today = dt.date.today().isoformat()

    lines: list[str] = []
    lines.append(f"# PNG Asset Audit ({today})")
    lines.append("")
    lines.append("Scope:")
    lines.append(f"- Path: `{assets_root}`")
    lines.append(f"- Total PNG files: `{len(stats)}`")
    if contact_sheet is not None:
        lines.append(f"- Contact sheet: `{contact_sheet}`")
    lines.append("")
    lines.append("## Executive Summary")
    lines.append("")
    lines.append(f"1. Assets audited: `{len(stats)}` PNG files.")
    lines.append(f"2. High partial-alpha outliers: `{len(partial_outliers)}`.")
    lines.append(f"3. White-halo risk candidates: `{len(white_halo_risk)}`.")
    lines.append(f"4. Low-resolution candidates (<420 max dimension): `{len(low_resolution)}`.")
    lines.append("")
    lines.append("## Scale Coverage")
    lines.append("")
    lines.append("| Imageset | Scales With Filename |")
    lines.append("|---|---|")
    for imageset, scales in sorted(scale_info.items()):
        shown = ", ".join(scales) if scales else "-"
        lines.append(f"| `{imageset}` | `{shown}` |")
    lines.append("")
    lines.append("## High Partial-Alpha Outliers")
    lines.append("")
    lines.append("| File | Size | Partial % | Transparent % |")
    lines.append("|---|---:|---:|---:|")
    for s in sorted(partial_outliers, key=lambda x: x.partial_pct, reverse=True):
        lines.append(
            f"| `{s.imageset}/{s.name}` | `{s.width}x{s.height}` | `{s.partial_pct:.2f}` | `{s.transparent_pct:.2f}` |"
        )
    if not partial_outliers:
        lines.append("| _None_ | - | - | - |")
    lines.append("")
    lines.append("## White Halo Risk")
    lines.append("")
    lines.append("| File | White Partial % | Partial % |")
    lines.append("|---|---:|---:|")
    for s in sorted(white_halo_risk, key=lambda x: x.white_partial_pct, reverse=True):
        lines.append(f"| `{s.imageset}/{s.name}` | `{s.white_partial_pct:.2f}` | `{s.partial_pct:.2f}` |")
    if not white_halo_risk:
        lines.append("| _None_ | - | - |")
    lines.append("")
    lines.append("## Full Asset Table")
    lines.append("")
    lines.append("| File | Size | Transparent % | Partial % | White Partial % | Margins (L,R,T,B) |")
    lines.append("|---|---:|---:|---:|---:|---|")
    for s in sorted(stats, key=lambda x: x.path.as_posix()):
        lines.append(
            f"| `{s.imageset}/{s.name}` | `{s.width}x{s.height}` | "
            f"`{s.transparent_pct:.2f}` | `{s.partial_pct:.2f}` | `{s.white_partial_pct:.2f}` | "
            f"`{s.margins}` |"
        )
    lines.append("")
    lines.append("## Next Actions")
    lines.append("")
    lines.append("1. Replace manual/AI-exported images with master-source exports where possible.")
    lines.append("2. Keep true alpha; avoid baked checkerboard or matte edges.")
    lines.append("3. For Twisty set, normalize canvas/export pipeline and verify on device.")
    lines.append("")

    output.write_text("\n".join(lines) + "\n")


def make_contact_sheet(paths: list[Path], out_path: Path) -> None:
    cell_w, cell_h = 300, 320
    cols = 4
    rows = (len(paths) + cols - 1) // cols
    sheet = Image.new("RGB", (cols * cell_w + 40, rows * cell_h + 40), (18, 18, 24))
    draw = ImageDraw.Draw(sheet)

    for idx, p in enumerate(paths):
        r = idx // cols
        c = idx % cols
        x = 20 + c * cell_w
        y = 20 + r * cell_h

        draw.rounded_rectangle(
            (x, y, x + cell_w - 16, y + cell_h - 16),
            radius=20,
            fill=(34, 32, 48),
            outline=(76, 72, 108),
            width=2,
        )

        bg_x0, bg_y0 = x + 24, y + 24
        bg_x1, bg_y1 = x + cell_w - 40, y + cell_h - 90
        tile = 16
        for yy in range(bg_y0, bg_y1, tile):
            for xx in range(bg_x0, bg_x1, tile):
                color = (58, 58, 70) if ((xx // tile + yy // tile) % 2 == 0) else (44, 44, 56)
                draw.rectangle((xx, yy, min(xx + tile, bg_x1), min(yy + tile, bg_y1)), fill=color)

        img = Image.open(p).convert("RGBA")
        target_w = bg_x1 - bg_x0
        target_h = bg_y1 - bg_y0
        img.thumbnail((target_w, target_h), Image.Resampling.LANCZOS)
        paste_x = bg_x0 + (target_w - img.width) // 2
        paste_y = bg_y0 + (target_h - img.height) // 2
        sheet.paste(img, (paste_x, paste_y), img)

        draw.text((x + 24, y + cell_h - 60), p.stem, fill=(220, 218, 238))

    out_path.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(out_path)


def main() -> None:
    args = parse_args()
    assets_root: Path = args.assets.resolve()
    output: Path = args.output.resolve()
    contact_sheet: Path | None = args.contact_sheet.resolve() if args.contact_sheet else None

    files = png_files(assets_root)
    stats = [file_stats(p) for p in files]
    scale_info = scale_map(assets_root)
    partial_outliers, white_halo_risk, low_resolution = flagged(stats)

    if contact_sheet is not None:
        make_contact_sheet(files, contact_sheet)

    output.parent.mkdir(parents=True, exist_ok=True)
    write_report(
        output=output,
        assets_root=assets_root,
        stats=stats,
        scale_info=scale_info,
        partial_outliers=partial_outliers,
        white_halo_risk=white_halo_risk,
        low_resolution=low_resolution,
        contact_sheet=contact_sheet,
    )

    print(f"Audit report written: {output}")
    if contact_sheet is not None:
        print(f"Contact sheet written: {contact_sheet}")


if __name__ == "__main__":
    main()
