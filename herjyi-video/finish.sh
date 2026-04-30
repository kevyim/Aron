#!/bin/bash
set -e
BASE="/Volumes/RAID0/HERJYI-Video/final"
mkdir -p "$BASE"

echo "Searching for Grok videos..."

# Search everywhere in Downloads and Desktop
FILES=$(find "$HOME/Downloads" "$HOME/Desktop" -type f -name "grok-*.mp4" 2>/dev/null | sort)

# If not found, try broader search
if [ -z "$FILES" ]; then
  echo "Not in Downloads/Desktop. Searching home folder..."
  FILES=$(find "$HOME" -maxdepth 5 -type f -name "grok-*.mp4" 2>/dev/null | sort)
fi

# If still not found, search /Volumes/RAID0 too
if [ -z "$FILES" ]; then
  echo "Searching RAID0..."
  FILES=$(find /Volumes/RAID0 -type f -name "grok-*.mp4" 2>/dev/null | sort)
fi

# Last resort - any mp4 with grok in the name anywhere
if [ -z "$FILES" ]; then
  echo "Broad search..."
  FILES=$(find "$HOME" /Volumes/RAID0 -maxdepth 6 -type f -name "*grok*" 2>/dev/null | sort)
fi

if [ -z "$FILES" ]; then
  echo "ERROR: No grok videos found anywhere."
  echo "Listing all mp4 files in Downloads:"
  find "$HOME/Downloads" -type f -name "*.mp4" 2>/dev/null
  echo ""
  echo "Listing all folders in Downloads:"
  ls -la "$HOME/Downloads/"
  exit 1
fi

COUNT=$(echo "$FILES" | wc -l | xargs)
echo "Found $COUNT clips:"
echo "$FILES"
echo ""

# Build concat file
> /tmp/grok_concat.txt
while IFS= read -r f; do
  echo "file '$f'" >> /tmp/grok_concat.txt
  DUR=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$f" 2>/dev/null || echo "unknown")
  echo "  -> ${DUR}s"
done <<< "$FILES"

echo ""
echo "Stitching $COUNT clips..."
ffmpeg -y -f concat -safe 0 -i /tmp/grok_concat.txt -c:v libx264 -crf 18 -preset slow -pix_fmt yuv420p "$BASE/herjyi_stitched.mp4" 2>/dev/null

DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$BASE/herjyi_stitched.mp4")
echo "Stitched: ${DURATION}s"

FACTOR=$(python3 -c "print(round(50.0 / $DURATION, 4))")
echo "Stretching to 50s (${FACTOR}x)..."
ffmpeg -y -i "$BASE/herjyi_stitched.mp4" -filter:v "setpts=PTS*$FACTOR" -an -c:v libx264 -crf 18 -preset slow -pix_fmt yuv420p "$BASE/herjyi_50s_final.mp4" 2>/dev/null

echo ""
echo "DONE"
ls -lh "$BASE/"*.mp4
echo ""
echo "Final: $BASE/herjyi_50s_final.mp4 (50s)"
