# Asset drop zone

Put your exported images in **`assets/raw/`**, then run:

```bash
./scripts/import-assets.sh
```

That copies them into `Rezi/Assets.xcassets/` and writes the `Contents.json`
files for you. Nothing else to do — rebuild and the app picks them up.

---

## What to export

Export from Figma at **@2x and @3x** (and @1x if you like). Name them exactly
as below. The `@2x` / `@3x` suffix is what the script reads, so keep it.

### Bitmaps

| Base name | @1x size (pt) | What it is | In repo? |
|---|---|---|---|
| `clouds` | — | The white cloud bank, **transparent PNG** | ✅ @2x |
| `phone-mockup` | 300 × 609 | The light "clay" iPhone the cards sit on | ✅ @2x |
| `rezi-icon` | 80 × 80 | The purple app icon with the white **R** | ✅ @2x |
| `onboarding-background` | 400 × 690 | The blue → purple sky gradient | ➖ drawn |
| `company-logo` | 36 × 36 | Round company mark on the job cards | ➖ drawn |

So `phone-mockup@3x.png` would be 900 × 1827 px, and so on.

The cloud is placed by measuring its own alpha: the code knows the silhouette
begins 29.3% down the image and turns fully opaque at 45.1%, and positions it
so those land where the design puts them. **If you swap in a different cloud
with a different profile, update `cloudSilhouetteStart` in
`Rezi/DesignSystem/Metrics.swift`.**

### Vector icons

Dropped in as SVG, kept as vectors, and template-rendered — so the Solar
duotone second tone survives as alpha and the icons stay sharp at any size.

| File | Where it goes | In repo? |
|---|---|---|
| `stat-applications.svg` | Above "Applications Sent" | ✅ |
| `stat-rating.svg` | Above "App Store Rating" | ✅ |
| `stat-seekers.svg` | Above "Job Seekers" | ✅ |

### Every asset is optional

Each one has a hand-drawn SwiftUI fallback — a gradient sky, drifting vector
clouds, a drawn phone frame, a drawn icon, SF Symbols for the stats. The app
looks correct with zero images. Each file you drop in replaces its fallback,
so you can add them one at a time and nothing breaks in between.

Still drawn rather than supplied, if you want to send them:

- **`onboarding-background`** — the sky gradient. Currently a real SwiftUI
  gradient that fades into the clouds, which honestly holds up well; only
  worth replacing if the design's gradient has texture or noise in it.
- **`company-logo`** — the round mark on the job cards. Currently a neutral
  geometric placeholder, deliberately not any real company's logo.

### Extra company logos (optional)

Drop in `company-logo-1.png`, `company-logo-2.png`, … and the card stack will
cycle through them instead of repeating one mark.

### App icon (optional)

Drop a single **1024 × 1024** PNG named `app-icon.png` into `assets/raw/` and
the script installs it as the real app icon.

---

## Formats

- **PNG** for anything with transparency (clouds, icons, logos).
- **JPG** is fine for the background gradient if you want a smaller file.
- Keep files under ~10 MB each. If a background export is huge, drop the @1x.

## Uploading from your Mac

```bash
git pull
cp ~/Downloads/onboarding-background@3x.png assets/raw/
./scripts/import-assets.sh
git add -A && git commit -m "Add onboarding assets" && git push
```

You can also drag files straight into `assets/raw/` on github.com.
