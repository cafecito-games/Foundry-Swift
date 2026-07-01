# FoundrySwift logo

The FoundrySwift mark forges the **Swift bird** into the Foundry **forged hex**,
using the Foundry **Iron & Ember** palette. It signals the fork's identity (Swift
bindings for Foundry, Apple platforms) while staying visually part of the Foundry
family alongside the Foundry-Tools anvil mark.

- **Palette:** Iron & Ember — forge charcoal `#14161B`, steel `#3A4250`/`#6B7686`,
  ember `#FF6A13`/`#FF8A3D`/`#FFD76B`, bone-white ink `#ECE7DC`.
- **Wordmark:** Cinzel (700 for `FOUNDRY`, 600 for `SWIFT`), outlined to paths —
  no font dependency.
- The bird's ember fill is a vertical gradient (spark at top → ember at base),
  matching the Foundry mark convention.

## Files

| File | Role |
|------|------|
| `foundryswift-mark.svg` | Primary mark — hex + ember bird, transparent. Use on dark surfaces. |
| `foundryswift-mark-tile.svg` | Mark on the dark rounded forge tile — app / project icon. |
| `foundryswift-mark-mono.svg` | Single-color mark (`currentColor`) for busy / light / one-color contexts. |
| `foundryswift-lockup-horizontal.svg` | Primary lockup — mark + divider + FOUNDRY / SWIFT. |
| `foundryswift-lockup-horizontal-mono.svg` | One-color horizontal lockup (`currentColor`). |
| `foundryswift-lockup-stacked.svg` | Centered lockup for square-ish spaces. |
| `foundryswift-banner.svg` | Wide banner (README / social), dark panel. |

Rasterized PNGs live in `png/` (mark 32–512, mono 32–512, tile 256/512/1024,
lockups, banner). The mono PNGs are rendered in bone-white `#ECE7DC` for dark
backgrounds.

## Regenerating PNGs

```sh
rsvg-convert -w 512 -h 512 foundryswift-mark.svg -o png/foundryswift-mark-512.png
```

> The Swift bird is Apple's trademark, re-tinted here for this community fork's
> identity. Not an official Apple or Swift project.
