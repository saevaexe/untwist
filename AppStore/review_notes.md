# App Store Review Notes — Untwist

## Test Account
No account or login is required. The app launches directly into the experience with no authentication.

## Demo Instructions

### First Launch (Onboarding)
1. Launch the app — you will see a 4-step onboarding flow
2. Step 1: Introduction to the app concept
3. Step 2: Select areas of interest (optional)
4. Step 3: Quick mood check
5. Step 4: Ready screen — tap to enter the app
6. A disclaimer is shown during onboarding (wellness tool, not therapy)

### Home Screen
- Twisty (yarn ball mascot) greets the user with a mood-reactive illustration
- 4 main action cards: Mood Check, Thought Unwinder, Breathing Exercise, Thought Traps
- Quick mood row at top for fast mood logging
- Settings gear icon in the top-right corner

### Key Features to Test
- **Mood Check:** Tap the Mood Check card → use the 0-100 slider → optionally add a note → save
- **Thought Unwinder:** Tap the card → follow the 4-step guided flow (event → thought → trap identification → alternative thought)
- **Breathing Exercise:** Tap the card → animated 4-7-8 breathing technique (5 rounds)
- **Thought Traps:** Tap the card → browse 10 cognitive patterns → tap any for detail view

### Crisis Button
- A **floating red button** (heart icon) is visible on every screen
- Tapping it opens the Crisis Screen with:
  - Emergency hotline buttons based on the user's region — these use `tel://` URL scheme. If the region is not recognized, the app falls back to findahelpline.com
  - A breathing exercise shortcut
  - A "continue writing" option to return to the previous screen
- Crisis detection also activates automatically if crisis-related keywords are typed in the Thought Unwinder or Mood Check note fields

### Disclaimer Access
- Shown during first-launch onboarding
- Always accessible via **Settings → Disclaimer**
- Contains wellness positioning statement and emergency contact information

### Settings
- Notification toggle + time picker for daily reminders
- Theme selector (System / Light / Dark)
- Emergency contacts (hotlines)
- Delete All Data option
- Disclaimer, Privacy Policy, Support links

## In-App Purchases
None. Version 1.0 is completely free with no subscriptions or in-app purchases.

## Privacy
All data is stored on-device using SwiftData. No data is collected, transmitted, or shared. No third-party SDKs are used. Privacy nutrition label: "Data Not Collected."

## Content
The app is based on CBT (Cognitive Behavioral Therapy) principles and provides educational content about common thinking patterns. All content is original — no copyrighted clinical material is used.

## Supported Languages
- English (EN)
- Turkish (TR)
