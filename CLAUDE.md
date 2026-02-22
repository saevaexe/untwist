# Untwist — CBT Mental Health Companion

## What is this?
CBT-based self-help iOS app. Helps users identify cognitive distortions ("thought traps") and develop healthier thinking patterns.
Mascot: Twisty (yarn ball character, level 2.5 — present but not dominant).

## Architecture
- SwiftUI + MVVM + SwiftData + @Observable, iOS 17+
- Localization: TR + EN via Localizable.xcstrings
- Subscription: TBD (StoreKit 2 or RevenueCat)
- AI: None — on-device rule-based analysis only, no cloud API
- Analytics: Apple Analytics only — zero 3rd party SDKs
- Data: 100% on-device (SwiftData). No server. No cloud unless user opts into iCloud sync.

## Design Principles
- **Wellness/self-help positioning** — NEVER use "therapy", "treatment", "diagnose", "clinical"
- **Empathetic tone** — no judgment, no toxic positivity, no aggressive gamification
- **Zero guilt** — never punish missed days, broken streaks, or inactivity
- **Privacy sacred** — all data stays on device, no 3rd party SDKs, no content collection
- **Crisis safety** — emergency contacts always accessible (988 US, 182 TR)
- **Accessibility first** — VoiceOver, Dynamic Type, Reduce Motion, WCAG AA+ contrast

## Our Terminology (NOT Burns' terms)
| Concept | Our Term (EN) | Our Term (TR) |
|---------|---------------|---------------|
| Cognitive Distortions | Thought Traps | Düşünce Tuzakları |
| Daily Mood Log | Mood Check | Duygu Kaydı |
| Triple Column | Thought Unwinder | Düşünce Çözücü |
| Pleasure Predicting | Activity Forecast | Aktivite Tahmini |
| Cost-Benefit Analysis | Pros & Cons | Artı-Eksi Analizi |

## Mascot (Twisty) Rules
- Level 2.5: onboarding, empty states, milestones, soft feedback bubbles, mood-reactive
- Twisty's entanglement reflects user's mood (empathy, not mimicry)
- NEVER cutesy during serious moments — Twisty calms down in crisis mode
- Do NOT put Twisty on every screen — presence should feel natural
- Twisty is a companion learning alongside user — NOT an authority figure

## Crisis Protocol
- On-device keyword detection (string matching, no AI)
- High threshold — only clear crisis language triggers
- Never locks user out — "continue writing" always available
- Crisis screen: calm Twisty + hotline buttons + breathing exercise
- No auto-reporting to anyone — user controls everything

## Retention Strategy
- Zero guilt notifications — never "you missed X days"
- Progressive depth — features unlock gradually over weeks
- Micro-interactions — everything doable in under 2 minutes
- Progress visibility — stats, trends, Twisty visual evolution

## Clinical Positioning
- "Based on CBT principles" — YES
- "Clinically proven app" — NEVER
- "Dayalı" — YES, "Kanıtlanmış" — NEVER
- Disclaimer everywhere: onboarding, settings, App Store

## MVP Scope (v1.0) — FREE, no paywall
1. Onboarding — Twisty intro, disclaimer, notification permission
2. Mood Check — slider-based daily mood recording
3. Thought Unwinder — event → thought → trap → alternative thought
4. 10 Thought Traps — education cards with examples
5. Crisis Screen — hotlines (988 US, 182 TR) + breathing exercise
6. Breathing Exercise — standalone + accessible from crisis screen
7. Simple notification — single daily reminder
8. Basic settings — notification time, delete all data, disclaimer

## Screen Flow (v1.0)
- Navigation: Single-page home (NO tab bar) — simplicity first
- Splash → Onboarding (first launch only, 3 screens + disclaimer) → Home
- Home: Twisty greeting + 4 action cards (Mood Check, Thought Unwinder, Breathing, Thought Traps) + Settings gear + Crisis floating button
- Mood Check: slider (0-100) + optional note → save → soft redirect to Thought Unwinder
- Thought Unwinder: 4-step flow (Event → Thought + mood slider → Trap selection with suggestions → Alternative thought + mood slider)
- Thought Traps: list of 10 → detail card (definition + example + how to spot + Twisty illustration)
- Breathing Exercise: 4-7-8 technique, animated circle, 5 rounds default, Reduce Motion safe
- Crisis Screen: accessible from every screen via floating button — hotlines + breathing + "continue writing" option
- Settings: notification time, theme (system), delete all data, disclaimer, privacy, version, emergency contacts

## Data Models (v1.0)
- **MoodEntry** (SwiftData): id, date, score (0-100), note?, createdAt
- **ThoughtRecord** (SwiftData): id, date, event, automaticThought, moodBefore (0-100), moodAfter (0-100), selectedTraps [ThoughtTrapType], alternativeThought, createdAt
- **BreathingSession** (SwiftData): id, date, rounds, duration
- **ThoughtTrapType** (enum, Codable): 10 traps with name/description/example/keywords per locale
- **UserSettings** (@AppStorage): hasCompletedOnboarding, notificationEnabled, notificationTime, preferredTheme, appLanguage
- Crisis detection is real-time keyword matching — NO data stored about crisis events

## Thought Trap Engine (Rule-based, on-device)
- Keyword matching per locale (TR + EN separate word lists)
- Scoring: 1 keyword = 0.3, 2 = 0.6, 3+ = 0.9, full pattern = 0.9
- Display threshold: score ≥ 0.3, sorted highest first
- Suggestions only — NEVER definitive ("olabilir" / "might be", never "this is")
- User always has final say — can override, change, or dismiss suggestions
- Crisis detection: same engine, separate method, HIGH threshold — only clear crisis language
- No context analysis — accepts false positives as trade-off for no AI dependency

## Post-MVP (v1.1+)
- Progress / statistics graphs
- Activity Forecast
- Pros & Cons analysis
- Paywall / subscription
- iCloud Sync
- Advanced notifications (insight-based)

## Color Palette
- **Primary:** #7C6BC4 (soft purple), dark mode #9B8FD8
- **Secondary:** #A89BD4 (light lavender)
- **Background:** #FAF8FF (light), #1A1528 (dark)
- **Card:** #FFFFFF (light), #251E36 (dark)
- **Text Primary:** #2D2344 (light), #F0ECF8 (dark)
- **Text Secondary:** #6B6189
- **Success:** #5BBD8A (soft green)
- **Crisis/Warning:** #E8736C (soft red)
- **Twisty:** #F2A65A (warm orange-yellow, SAME in both modes)
- **Typography:** SF Pro Rounded (headings), SF Pro Text (body), system fonts only

## Naming Conventions
- Views: `{Feature}View.swift`
- ViewModels: `{Feature}ViewModel.swift`
- Models: descriptive names, avoid Foundation collisions
- Engines: `{Feature}Engine.swift`

## Do NOT
- Do NOT reference Burns, TEAM-CBT, "Feeling Good", or "Daily Mood Log" by name
- Do NOT make Twisty speak like a therapist — companion, not doctor
- Do NOT gamify aggressively (no leaderboards, no guilt-tripping, no Duolingo-style pressure)
- Do NOT store sensitive data in UserDefaults — SwiftData only
- Do NOT skip disclaimer screens — App Store will reject
- Do NOT use "Reframe" anywhere — name is taken
- Do NOT send thought content to any server, ever
- Do NOT use 3rd party analytics/crash SDKs — Apple only
- Do NOT make medical claims in App Store description or in-app copy
