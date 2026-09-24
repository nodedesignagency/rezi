# Rezi — Onboarding

Animated SwiftUI onboarding screens for **Rezi**, built from the
[Figma design](https://www.figma.com/design/Zt2Iyj5bgcr6cohbuBHQsj/Untitled?node-id=1-342).
There are two complete designs in the app:

| | |
|---|---|
| **Marquee** — `MarqueeOnboardingView` | Figma's "Different Style". The job feed streams past in four rows around the Rezi icon, over a drifting purple ribbon. **The app opens on this one.** |
| **Card stack** — `OnboardingView` | The first design. One deck of job cards over a sky and clouds, swiped a card at a time. |

To switch, change one word in `Rezi/ReziApp.swift`:

```swift
private static let design: OnboardingDesign = .marquee   // or .cardStack
```

Both files also have an Xcode preview, so you can put them side by side in the
canvas without running the app.

> **Swipe right on your next job.**
> Every job scored against your resume. Skip the bad fits, apply to the rest in a tap.

---

## Run it

```bash
git clone https://github.com/nodedesignagency/rezi.git
cd rezi
./scripts/run.sh          # builds, boots a simulator, installs, launches
```

Or just open `Rezi.xcodeproj` in Xcode and hit **Cmd-R**.

Requires **Xcode 16+** (iOS 17 deployment target). No packages, no CocoaPods,
no SPM dependencies — it builds straight out of the box.

---

## Adding your images

Already wired up: the cloud bank, the clay iPhone, the Rezi icon, and the three
duotone stat icons.

To add more, drop exports into **`assets/raw/`** and run:

```bash
./scripts/import-assets.sh
```

See **[assets/README.md](assets/README.md)** for filenames and sizes.

**Every asset is optional.** Each one has a hand-drawn SwiftUI fallback, so the
screen looks right whether or not the art is there — the sky gradient and the
job-card company mark are still drawn rather than supplied.

---

## What's animated — Marquee

| | |
|---|---|
| **Entrance** | The ribbon fades in, the rows slide in the way they will run, the icon springs in and its rings ripple out after it, then the copy, stats and button |
| **Marquee rows** | Four rows cruise in alternate directions (right, left, right, left) at slightly different speeds, looping forever with no seam |
| **Drag a row** | Grab any row and scrub it. Let go and it coasts with your throw, then eases back into its own pace |
| **Tap a card** | The card rises under a green APPLY stamp, with a haptic. The row pauses so you can read it, then picks back up |
| **Score gauges** | Each card's arc fills as it slides onto the screen |
| **Ribbon** | Rectangle 65 sways and turns slowly, and Figma's sine-wave Warp runs live as a Metal shader so its edges keep rippling |
| **Icon rings** | Breathe outward, inner ring first |
| **Button** | Same as the card stack, in this design's purple |

Reduce Motion freezes the rows, the ribbon and the rings. The rows can still
be dragged.

## What's animated — Card stack

| | |
|---|---|
| **Entrance** | Everything staggers in on springs — sky, phone, cards, icon, copy, stats, button |
| **Card stack** | Auto-cycles: the front job card swipes away and the stack promotes behind it |
| **Drag to swipe** | Grab the cards and throw them left or right. Pass / Apply overlays track your drag |
| **Score gauges** | The arc sweeps up to its score when a card reaches the front |
| **Counting stats** | 1.2M / 4.7 / 4.2M count up on first appearance |
| **Ambient** | Two cloud layers drift at different speeds, the glow behind the phone breathes |
| **Button** | Press-down spring, a slow shine sweep, haptics on tap |

All of it honours **Reduce Motion** — with the system setting on, the screen
cross-fades into its final state instead of moving, and the auto-cycle stops.

---

## Layout

```
Rezi/
├── ReziApp.swift               app entry
├── DesignSystem/
│   ├── ReziColor.swift         palette pulled from the design
│   ├── ReziFont.swift          type scale
│   ├── Metrics.swift           every position/size from the Figma frame
│   └── Motion.swift            springs, delays, Reduce-Motion handling
├── Onboarding/                 the card-stack screen
│   ├── OnboardingView.swift    the screen
│   ├── OnboardingModel.swift   card-stack state machine
│   ├── JobCard.swift           model + sample data
│   └── Components/             sky, clouds, phone, cards, gauge, stats, button
├── MarqueeOnboarding/          the marquee screen
│   ├── MarqueeOnboardingView.swift   the screen
│   ├── MarqueeDesign.swift     its sizes, timings and colours, in one place
│   ├── MarqueeTrack.swift      row motion: cruise, drag, fling, catch
│   ├── MarqueeFeed.swift       the cards in each row
│   ├── Components/             ribbon, rows, cards, icon rings
│   └── Shaders/SineWarp.metal  Figma's Warp effect, live
└── Assets.xcassets/            filled in by scripts/import-assets.sh
```

The marquee screen reuses the card, gauge, stats panel, button and entrance
from the first one. Its own numbers are kept in `MarqueeDesign.swift`, so
tuning one screen never moves the other.

`Metrics.swift` holds the numbers straight from the 393 × 852 Figma frame, so
nudging the design means editing one file. Layout scales proportionally on other
device sizes.

---

## Scripts

| | |
|---|---|
| `./scripts/run.sh` | Build → boot simulator → install → launch |
| `./scripts/run.sh --device "iPhone 16 Pro Max"` | Pick a specific simulator |
| `./scripts/run.sh --list` | Show available simulators |
| `./scripts/import-assets.sh` | Pull `assets/raw/` into the asset catalog |
