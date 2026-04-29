#!/bin/bash
# HERJYI 40s Commercial — Stitch on Mac Mini
# All files on Raido external drive
# Requires: ffmpeg (brew install ffmpeg)

set -e

BASE="/Volumes/Raido - AI Video/HERJYI-Video"

echo "=== Checking clips ==="
for i in 1 2 3 4; do
  if [ ! -f "$BASE/clips/scene${i}.mp4" ]; then
    echo "Missing: $BASE/clips/scene${i}.mp4"
    echo "Download from Hailuo and rename to scene1.mp4, scene2.mp4, scene3.mp4, scene4.mp4"
    exit 1
  fi
done

echo "=== Stitching 4 clips ==="

cat > "$BASE/clips/concat.txt" << 'EOF'
file 'scene1.mp4'
file 'scene2.mp4'
file 'scene3.mp4'
file 'scene4.mp4'
EOF

ffmpeg -f concat -safe 0 \
  -i "$BASE/clips/concat.txt" \
  -c:v libx264 -crf 18 -preset slow \
  -vf "fps=24,scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2" \
  -pix_fmt yuv420p \
  "$BASE/final/herjyi_40s_raw.mp4"

echo ""
echo "Raw 40s video: $BASE/final/herjyi_40s_raw.mp4"
echo ""
echo "Next: Open in CapCut/DaVinci"
echo "  1. Add overlay PNGs from $BASE/overlays/ at timestamps"
echo "  2. Color grade: warm amber + desaturated beige"
echo "  3. Add audio: lo-fi ambient + foley SFX"
echo "  4. Export to $BASE/final/herjyi_40s_final.mp4"
