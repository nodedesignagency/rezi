# Rezi — Onboarding

An animated SwiftUI onboarding screen for **Rezi**, built from the
[Figma design](https://www.figma.com/design/Zt2Iyj5bgcr6cohbuBHQsj/Untitled?node-id=1-342).

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

Drop exports into **`assets/raw/`**, then:

```bash
./scripts/import-assets.sh
```

See **[assets/README.md](assets/README.md)** for the exact filenames and sizes.

**Every asset is optional.** Each one has a hand-drawn SwiftUI fallback — a real
gradient sky, drifting vector clouds, a drawn phone frame and app icon. The
screen looks right with zero images in the repo; each file you add just replaces
its fallback. So you can start the app today and add art as it lands.

---

## What's animated

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
├── Onboarding/
│   ├── OnboardingView.swift    the screen
│   ├── OnboardingModel.swift   card-stack state machine
│   ├── JobCard.swift           model + sample data
│   └── Components/             sky, clouds, phone, cards, gauge, stats, button
└── Assets.xcassets/            filled in by scripts/import-assets.sh
```

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
