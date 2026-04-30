#!/bin/bash
# HERJYI 60s Commercial — FINAL BUILD
# Reorder + stretch + voiceover + merge
# Uses macOS built-in Chinese TTS (no API needed)
set -e

BASE="/Volumes/RAID0/HERJYI-Video/final"
mkdir -p "$BASE"

echo "========================================"
echo "  HERJYI — Final 60s Commercial Build"
echo "========================================"

# --- STEP 1: Reorder and stretch to 60s ---
echo "[1/4] Reordering clips and stretching to 60s..."

cat > /tmp/list.txt << 'EOF'
file '/Users/imu/Downloads/Grok Video/grok-8f2be06f-238c-4bd5-995a-9d7e9f62c6a0-720p.mp4'
file '/Users/imu/Downloads/Grok Video/grok-b1aa7526-db4d-4405-896d-0c93e9028722-720p.mp4'
file '/Users/imu/Downloads/Grok Video/grok-e851cdb3-341a-4e56-80d9-75d39106b93c-720p.mp4'
file '/Users/imu/Downloads/Grok Video/grok-464fd7ce-3010-449e-a054-a80805ed893c-720p.mp4'
EOF

FACTOR=$(for f in \
  "/Users/imu/Downloads/Grok Video/grok-8f2be06f"*mp4 \
  "/Users/imu/Downloads/Grok Video/grok-b1aa7526"*mp4 \
  "/Users/imu/Downloads/Grok Video/grok-e851cdb3"*mp4 \
  "/Users/imu/Downloads/Grok Video/grok-464fd7ce"*mp4; do \
  ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$f"; \
done | python3 -c "import sys; durs=[float(l) for l in sys.stdin]; print(round(60.0/sum(durs),4))")

ffmpeg -y -f concat -safe 0 -i /tmp/list.txt \
  -filter:v "setpts=PTS*$FACTOR" -an \
  -c:v libx264 -crf 18 -preset slow -pix_fmt yuv420p \
  "$BASE/herjyi_60s_video.mp4" 2>/dev/null

echo "  Video: $BASE/herjyi_60s_video.mp4"

# --- STEP 2: Generate voiceover with macOS TTS ---
echo "[2/4] Generating Mandarin voiceover..."

# Find best Chinese voice available
CN_VOICE=$(say -v '?' | grep -i 'zh_' | head -1 | awk '{print $1}')
if [ -z "$CN_VOICE" ]; then
  CN_VOICE="Ting-Ting"
fi
echo "  Using voice: $CN_VOICE"

# Generate each section as AIFF then convert
say -v "$CN_VOICE" -r 120 -o "$BASE/vo1.aiff" \
  "這個甜，不是加出來的。是從甘蔗開始，慢慢熬出來的。高雄，從1989年，一直做到現在。"

say -v "$CN_VOICE" -r 120 -o "$BASE/vo2.aiff" \
  "沒有多的東西，也不需要多的東西。純甘蔗，慢慢變成你看到的這一杯。"

say -v "$CN_VOICE" -r 120 -o "$BASE/vo3.aiff" \
  "熱的黑糖，遇到冰的牛奶。一圈一圈，這不是特效，是手藝。"

say -v "$CN_VOICE" -r 120 -o "$BASE/vo4.aiff" \
  "Q，是基本。但你會記得的，是那個香氣，跟最後那一口甜。"

say -v "$CN_VOICE" -r 120 -o "$BASE/vo5.aiff" \
  "簡單一杯，其實不簡單。不加防腐劑，只留下該有的味道。HERJYI。高雄做的，給全世界喝。純粹的能量，從台灣開始。"

echo "  Generated 5 voiceover segments"

# --- STEP 3: Combine voiceover segments with silence gaps ---
echo "[3/4] Combining voiceover with timed gaps..."

# Create silence padding
ffmpeg -y -f lavfi -i anullsrc=r=44100:cl=mono -t 1.5 -q:a 9 -acodec pcm_s16le "$BASE/silence.aiff" 2>/dev/null

# Concat all VO segments with silence gaps
cat > /tmp/vo_list.txt << VOEOF
file '$BASE/vo1.aiff'
file '$BASE/silence.aiff'
file '$BASE/vo2.aiff'
file '$BASE/silence.aiff'
file '$BASE/vo3.aiff'
file '$BASE/silence.aiff'
file '$BASE/vo4.aiff'
file '$BASE/silence.aiff'
file '$BASE/vo5.aiff'
VOEOF

ffmpeg -y -f concat -safe 0 -i /tmp/vo_list.txt \
  -c:a aac -b:a 192k \
  "$BASE/voiceover_full.m4a" 2>/dev/null

echo "  Voiceover: $BASE/voiceover_full.m4a"

# --- STEP 4: Merge video + voiceover ---
echo "[4/4] Merging video + voiceover..."

ffmpeg -y \
  -i "$BASE/herjyi_60s_video.mp4" \
  -i "$BASE/voiceover_full.m4a" \
  -c:v copy -c:a aac -b:a 192k \
  -shortest \
  "$BASE/herjyi_60s_final.mp4" 2>/dev/null

echo ""
echo "========================================"
echo "  DONE"
echo "========================================"
echo ""
ls -lh "$BASE/herjyi_60s_final.mp4"
echo ""
echo "Final: $BASE/herjyi_60s_final.mp4"
echo "Open it: open \"$BASE/herjyi_60s_final.mp4\""

# Auto-open
open "$BASE/herjyi_60s_final.mp4"
