#!/bin/bash
# HERJYI 40s Commercial — Stitch
# Mac Mini + RAID0

set -e
BASE="/Volumes/RAID0/HERJYI-Video"

echo "=== Checking clips ==="
MISSING=0
for f in scene1_origin scene2_craft scene3_pearls scene4_hero; do
  if [ ! -f "$BASE/clips/${f}.mp4" ]; then
    echo "Missing: $BASE/clips/${f}.mp4"
    MISSING=1
  fi
done

if [ "$MISSING" -eq 1 ]; then
  echo "Download missing clips first."
  exit 1
fi

echo "=== Stitching ==="

cat > "$BASE/clips/concat.txt" << 'EOF'
file 'scene1_origin.mp4'
file 'scene2_craft.mp4'
file 'scene3_pearls.mp4'
file 'scene4_hero.mp4'
EOF

ffmpeg -y -f concat -safe 0 \
  -i "$BASE/clips/concat.txt" \
  -c:v libx264 -crf 18 -preset slow \
  -vf "fps=24,scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2" \
  -pix_fmt yuv420p \
  "$BASE/final/herjyi_40s_raw.mp4"

echo ""
echo "Done: $BASE/final/herjyi_40s_raw.mp4"
ls -lh "$BASE/final/herjyi_40s_raw.mp4"
