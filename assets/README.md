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

| Base name | @1x size (pt) | What it is | Required? |
|---|---|---|---|
| `onboarding-background` | 400 × 690 | The blue → purple sky gradient behind everything | optional |
| `clouds` | 1990 × 828 | The white cloud band, **transparent PNG** | optional |
| `phone-mockup` | 300 × 609 | The light "clay" iPhone the cards sit on | optional |
| `rezi-icon` | 80 × 80 | The purple app icon with the white **R** | optional |
| `company-logo` | 36 × 36 | Round blue company mark on the job cards | optional |

So `onboarding-background@3x.png` should be 1200 × 2070 px, and so on.

### Every asset is optional

The screen ships with a hand-drawn SwiftUI fallback for each one — a real
gradient, real drifting clouds, a vector phone frame, a drawn icon. The app
looks correct **right now** with zero images. Each file you drop in simply
replaces its fallback. Add them one at a time if you want; nothing breaks.

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
