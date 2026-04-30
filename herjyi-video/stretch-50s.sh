#!/bin/bash
# Find Grok video in Downloads, copy to RAID0, stretch to 50 seconds
set -e

BASE="/Volumes/RAID0/HERJYI-Video/final"
mkdir -p "$BASE"

echo "=== Recent videos in Downloads ==="
VIDEOS=$(find ~/Downloads -maxdepth 2 \( -name "*.mp4" -o -name "*.mov" -o -name "*.webm" \) -mtime -1 2>/dev/null | sort)

if [ -z "$VIDEOS" ]; then
  echo "No videos found in last 24h. Checking all videos..."
  VIDEOS=$(find ~/Downloads -maxdepth 2 \( -name "*.mp4" -o -name "*.mov" -o -name "*.webm" \) 2>/dev/null | sort)
fi

echo "$VIDEOS"
echo ""

# Pick the most recent video
LATEST=$(echo "$VIDEOS" | tail -1)

if [ -z "$LATEST" ]; then
  echo "No video found in ~/Downloads"
  exit 1
fi

echo "=== Using: $LATEST ==="

# Get current duration
DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$LATEST" 2>/dev/null)
echo "Current duration: ${DURATION}s"

# Copy original to RAID0
cp "$LATEST" "$BASE/herjyi_original.mp4"
echo "Copied to: $BASE/herjyi_original.mp4"

# Calculate stretch factor for 50 seconds
FACTOR=$(python3 -c "print(50.0 / $DURATION)")
echo "Stretch factor: ${FACTOR}x"

# Stretch to 50 seconds
echo "=== Stretching to 50 seconds ==="
ffmpeg -y -i "$LATEST" \
  -filter:v "setpts=PTS*$FACTOR" \
  -an \
  -c:v libx264 -crf 18 -preset slow \
  -pix_fmt yuv420p \
  "$BASE/herjyi_50s_final.mp4"

echo ""
echo "=== DONE ==="
echo "Original: $BASE/herjyi_original.mp4(${DURATION}s)"
echo "Stretched: $BASE/herjyi_50s_final.mp4 (50s)"
ls -lh "$BASE/"
