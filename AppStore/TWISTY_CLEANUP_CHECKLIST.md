# Twisty Cleanup Checklist

Goal: make all Twisty assets look clean on any background and stay sharp on @3x devices.

## 1) Source and Export Rules

- [ ] Use a single master canvas size for every Twisty (recommended: `1024x1024`).
- [ ] Keep true transparency (no fake checkerboard texture, no baked matte).
- [ ] Keep consistent safe padding (recommended: `~8-10%` on each edge).
- [ ] Export as PNG with alpha.
- [ ] Generate `1x / 2x / 3x` outputs per imageset.

## 2) Visual Consistency

- [ ] Align eye/mouth style across moods (line thickness and color harmony).
- [ ] Normalize body size so mood switches do not jump in perceived scale.
- [ ] Remove aggressive glow/matte artifacts (`TwistyCalm` currently most visible).
- [ ] Keep thread/limb detail readable at smallest in-app size (~48pt).

## 3) Asset Catalog Integration

- [ ] Update each `Twisty*.imageset` with proper scale entries.
- [ ] Keep names unchanged to avoid code-side refactors.
- [ ] Verify `Contents.json` for all Twisty sets points to the correct files.

## 4) QA Pass (Device)

- [ ] Test on at least one `@3x` iPhone (real device).
- [ ] Check on light and dark themes.
- [ ] Check on gradient backgrounds used in Home/Onboarding/Unwinding.
- [ ] Verify no halo edges around Twisty in cards and full-screen views.

## 5) Acceptance Criteria

- [ ] No checkerboard or matte edges visible on any screen.
- [ ] Twisty mood transitions look size-consistent.
- [ ] Images stay crisp in App Store screenshots and in-app at large sizes.

