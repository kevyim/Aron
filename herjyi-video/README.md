# HERJYI Brown Sugar Bubble Tea — 40s Premium Commercial

**Client:** Jin Hong Sugar Co., Ltd. (錦翃) — est. 1989, Kaohsiung, Taiwan
**Website:** https://en.herjyi.com
**Linear:** TRA-50

## Production Pipeline

```
Grok (image gen) → Hailuo 2.3 (I2V 10s clips) → CapCut/DaVinci (stitch + grade)
```

## Assets (in Canva account)

| Asset | Canva ID | Purpose |
|-------|----------|----------|
| Endcard | DAHIQlBtJ00 | Final frame — HERJYI logo + glow |
| Scene 1 Title | DAHIQthr-w0 | EST. 1989 — KAOHSIUNG, TAIWAN |
| Scene 2 Overlay | DAHIQoJokhI | NO PRESERVATIVES. PURE CANE. |
| Scene 3 Overlay | DAHIQqWhTus | BOIL. DRINK. POWER. |
| Scene 4 Closing | DAHIQjXOFIQ | PURE ENERGY. FROM TAIWAN. |

All exported as 1080x1920 transparent PNG (Pro quality).

## Quick Start

```bash
# Step 1: Generate hero stills
cd herjyi-video
bash grok-generate.sh

# Step 2: Upload to Hailuo 2.3 with prompts from hailuo-prompts.md

# Step 3: Stitch
bash stitch.sh
```
