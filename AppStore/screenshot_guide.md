# Screenshot Capture Guide

## Prerequisites
- Simulator running (iPhone 17 Pro for 6.7", iPhone 17 for 6.1")
- App installed and onboarding completed

## Step 1: Clean status bar
```bash
xcrun simctl status_bar booted override --time "09:41" --batteryState charged --batteryLevel 100
```

## Step 2: Take screenshots (EN locale)
Navigate to each screen and capture:

```bash
# Home screen
xcrun simctl io booted screenshot AppStore/Screenshots/home_en.png

# Mood Check (set slider to ~72 for "Good" mood)
xcrun simctl io booted screenshot AppStore/Screenshots/mood_en.png

# Thought Unwinder (step 3 — trap selection with suggestions)
xcrun simctl io booted screenshot AppStore/Screenshots/unwinder_en.png

# Unwinding Now (breathing phase with animated circle)
xcrun simctl io booted screenshot AppStore/Screenshots/unwinding_en.png

# Insights (after some test data)
xcrun simctl io booted screenshot AppStore/Screenshots/insights_en.png
```

## Step 3: Take screenshots (TR locale)
Switch simulator to Turkish:
- Settings → General → Language & Region → Turkish

Repeat same screens:
```bash
xcrun simctl io booted screenshot AppStore/Screenshots/home_tr.png
xcrun simctl io booted screenshot AppStore/Screenshots/mood_tr.png
xcrun simctl io booted screenshot AppStore/Screenshots/unwinder_tr.png
xcrun simctl io booted screenshot AppStore/Screenshots/unwinding_tr.png
xcrun simctl io booted screenshot AppStore/Screenshots/insights_tr.png
```

## Step 4: Generate previews
```bash
python3 AppStore/generate_previews.py
```

Output will be in `AppStore/Previews/` — ready for App Store Connect upload.

## Required sizes
| Device | Resolution | Slot |
|--------|-----------|------|
| iPhone 6.7" | 1290 x 2796 | iPhone 15 Pro Max |
| iPhone 6.1" | 1179 x 2556 | iPhone 15 Pro |

## Tips
- Show "Good" mood (score ~72) in mood screenshot — positive first impression
- Unwinder step 3 is the most visually interesting (trap cards with suggestions)
- For Insights, create 3-4 test mood entries first so the chart has data
- Unwinding Now: capture during breathing phase (animated circle visible)
