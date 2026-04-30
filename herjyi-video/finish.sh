#!/bin/bash
set -e
SRC="$HOME/Downloads/Grok Video"
BASE="/Volumes/RAID0/HERJYI-Video/final"
mkdir -p "$BASE"

# Auto-find all grok mp4 files, sorted by name
FILES=$(find "$SRC" -name "grok-*.mp4" | sort)
COUNT=$(echo "$FILES" | wc -l | xargs)
echo "Found $COUNT clips in $SRC"

# Build concat file
> /tmp/grok_concat.txt
while IFS= read -r f; do
  echo "file '$f'" >> /tmp/grok_concat.txt
  DUR=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$f" 2>/dev/null)
  echo "  $f (${DUR}s)"
done <<< "$FILES"

# Stitch all clips
echo ""
echo "Stitching $COUNT clips..."
ffmpeg -y -f concat -safe 0 -i /tmp/grok_concat.txt -c:v libx264 -crf 18 -preset slow -pix_fmt yuv420p "$BASE/herjyi_stitched.mp4" 2>/dev/null

# Get stitched duration
DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$BASE/herjyi_stitched.mp4")
echo "Stitched: ${DURATION}s"

# Stretch to 50 seconds
FACTOR=$(python3 -c "print(round(50.0 / $DURATION, 4))")
echo "Stretching ${DURATION}s -> 50s (factor: ${FACTOR}x)..."
ffmpeg -y -i "$BASE/herjyi_stitched.mp4" -filter:v "setpts=PTS*$FACTOR" -an -c:v libx264 -crf 18 -preset slow -pix_fmt yuv420p "$BASE/herjyi_50s_final.mp4" 2>/dev/null

echo ""
echo "DONE"
echo "Stitched: $BASE/herjyi_stitched.mp4 (${DURATION}s)"
echo "Final:    $BASE/herjyi_50s_final.mp4 (50s)"
ls -lh "$BASE/"*.mp4
