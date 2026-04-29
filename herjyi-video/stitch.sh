#!/bin/bash
# HERJYI 40s Commercial — Stitch + Post-Production
# Requires: ffmpeg installed

set -e
mkdir -p output/final

# Rename your Hailuo downloads to these names:
# output/clips/scene1_origin.mp4
# output/clips/scene2_craft.mp4
# output/clips/scene3_pearls.mp4
# output/clips/scene4_hero.mp4

echo "=== Stitching 4 clips ==="

cat > output/clips/concat.txt << 'EOF'
file 'scene1_origin.mp4'
file 'scene2_craft.mp4'
file 'scene3_pearls.mp4'
file 'scene4_hero.mp4'
EOF

# Stitch raw clips
ffmpeg -f concat -safe 0 \
  -i output/clips/concat.txt \
  -c:v libx264 -crf 18 -preset slow \
  -vf "fps=24,scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2" \
  -pix_fmt yuv420p \
  output/final/herjyi_40s_raw.mp4

echo ""
echo "✅ Raw 40s video: output/final/herjyi_40s_raw.mp4"
echo ""
echo "Next steps in CapCut/DaVinci:"
echo "  1. Import herjyi_40s_raw.mp4"
echo "  2. Add text overlay PNGs from Canva (transparent) at timestamps:"
echo "     - 0:07  → scene1_title.png (EST. 1989 — KAOHSIUNG, TAIWAN)"
echo "     - 0:17  → scene2_overlay.png (NO PRESERVATIVES. PURE CANE.)"
echo "     - 0:27  → scene3_overlay.png (BOIL. DRINK. POWER.)"
echo "     - 0:33  → scene4_closing.png (PURE ENERGY. FROM TAIWAN.)"
echo "     - 0:37  → endcard.png (HERJYI logo)"
echo "  3. Color grade: Warm amber + desaturated beige"
echo "  4. Add music: Lo-fi ambient + subtle percussion"
echo "  5. Transitions: Cross-dissolve 0.5s between clips"
echo "  6. Export: H.264, 1080x1920, 24fps, High quality"
