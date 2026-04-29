#!/bin/bash
# HERJYI 40s Commercial — FULL AUTOMATED PIPELINE
# One command. Mac Mini + Raido drive. Higgsfield MCP.
# Usage: bash run-all.sh

set -e

BASE="/Volumes/Raido - AI Video/HERJYI-Video"

echo "========================================"
echo "  HERJYI 40s Commercial — Full Pipeline"
echo "========================================"
echo ""

# --- STEP 0: Setup ---
echo "[0/6] Setting up project on Raido drive..."
mkdir -p "$BASE"/{stills,clips,overlays,final,assets}

# --- STEP 1: Install Higgsfield MCP ---
echo "[1/6] Installing Higgsfield MCP..."
pip install higgsfield-mcp 2>/dev/null || pip3 install higgsfield-mcp 2>/dev/null

# Add to Claude Code if not already added
claude mcp add higgsfield -- python3 -m higgsfield_mcp.server 2>/dev/null || true

echo ""
echo "[1/6] Higgsfield MCP installed."
echo "       Make sure HF_API_KEY and HF_SECRET are set:"
echo "       export HF_API_KEY=your-key"
echo "       export HF_SECRET=your-secret"
echo ""

# --- STEP 2: Generate stills via Claude + Higgsfield ---
echo "[2/6] Launching Claude Code to generate stills via Higgsfield MCP..."

claude --print "You have Higgsfield MCP connected. Do this exactly:

1. Call generate_image with prompt: 'Macro close-up of raw Taiwanese brown sugar crystals on a dark slate surface. Warm amber glow illuminates irregular crystalline texture. Traces of molasses glisten. Single sugarcane stalk blurred in background. Dark moody studio lighting. Premium ingredient photography, 8K, shallow depth of field.' Save the URL.

2. Call generate_image with prompt: 'A transparent glass from above showing dark brown sugar syrup pooled at bottom with fresh white milk poured from top. Brown sugar tendrils swirling upward into milk creating marble patterns. Soft warm beige seamless background. Overhead angle. Premium beverage ad, DSLR macro, hyper-realistic, 8K.' Save the URL.

3. Call generate_image with prompt: 'Extreme macro of glossy black tapioca pearls mid-fall, three pearls suspended above brown sugar milk tea glass. Each pearl coated in glistening brown sugar syrup. Brown-to-cream gradient in glass. Condensation droplets. Soft beige studio background. Rembrandt lighting. Commercial food photography, 8K.' Save the URL.

4. Call generate_image with prompt: 'Center-frame hero product shot of tall transparent glass filled with iced brown sugar bubble milk tea. Tiger-stripe brown sugar pattern inside glass. Tapioca pearls at bottom. Creamy milk tea with ice cubes. Condensation droplets. Clean beige seamless studio background. Soft natural lighting, clean shadow beneath. Ultra-sharp, DSLR macro, premium ad, 8K.' Save the URL.

5. For EACH image URL, call generate_video with cinematic slow-motion motion preset.

6. Poll get_generation_status for each job until completed.

7. Print all final URLs as a list.

Output ONLY the final image and video URLs, one per line, labeled scene1_img, scene1_vid, scene2_img, scene2_vid, scene3_img, scene3_vid, scene4_img, scene4_vid." > "$BASE/generation_urls.txt"

echo "[2/6] Generation URLs saved to $BASE/generation_urls.txt"

# --- STEP 3: Download all generated files ---
echo "[3/6] Downloading stills and clips to Raido..."

while IFS= read -r line; do
  if [[ "$line" == *"scene"*"_img"* ]]; then
    NAME=$(echo "$line" | cut -d: -f1 | xargs)
    URL=$(echo "$line" | cut -d' ' -f2-)
    SCENE_NUM=$(echo "$NAME" | grep -o '[0-9]')
    curl -sL "$URL" -o "$BASE/stills/scene${SCENE_NUM}.png" && echo "  Downloaded $NAME"
  elif [[ "$line" == *"scene"*"_vid"* ]]; then
    NAME=$(echo "$line" | cut -d: -f1 | xargs)
    URL=$(echo "$line" | cut -d' ' -f2-)
    SCENE_NUM=$(echo "$NAME" | grep -o '[0-9]')
    curl -sL "$URL" -o "$BASE/clips/scene${SCENE_NUM}.mp4" && echo "  Downloaded $NAME"
  fi
done < "$BASE/generation_urls.txt"

echo "[3/6] All files downloaded."

# --- STEP 4: Download Canva overlays ---
echo "[4/6] Download these Canva overlay PNGs manually:"
echo "  Endcard:    https://www.canva.com/d/Xu-Lq4y2bLBRxrl -> $BASE/overlays/endcard.png"
echo "  Scene 1:    https://www.canva.com/d/w3-ClQDtFWVw4vx -> $BASE/overlays/scene1_title.png"
echo "  Scene 2:    https://www.canva.com/d/QWPYJH22PoU_Ep8 -> $BASE/overlays/scene2_overlay.png"
echo "  Scene 3:    https://www.canva.com/d/KNOBSsEgquIRpC0 -> $BASE/overlays/scene3_overlay.png"
echo "  Scene 4:    https://www.canva.com/d/G_IJXA8rBHVlZqv -> $BASE/overlays/scene4_closing.png"
echo ""

# --- STEP 5: Stitch with ffmpeg ---
echo "[5/6] Stitching 4 clips into 40s video..."

for i in 1 2 3 4; do
  if [ ! -f "$BASE/clips/scene${i}.mp4" ]; then
    echo "ERROR: Missing $BASE/clips/scene${i}.mp4"
    exit 1
  fi
done

cat > "$BASE/clips/concat.txt" << 'CLIPLIST'
file 'scene1.mp4'
file 'scene2.mp4'
file 'scene3.mp4'
file 'scene4.mp4'
CLIPLIST

ffmpeg -y -f concat -safe 0 \
  -i "$BASE/clips/concat.txt" \
  -c:v libx264 -crf 18 -preset slow \
  -vf "fps=24,scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2" \
  -pix_fmt yuv420p \
  "$BASE/final/herjyi_40s_raw.mp4"

echo "[5/6] Raw video: $BASE/final/herjyi_40s_raw.mp4"

# --- STEP 6: Add overlays with ffmpeg ---
echo "[6/6] Adding text overlays..."

if [ -f "$BASE/overlays/scene1_title.png" ]; then
  ffmpeg -y \
    -i "$BASE/final/herjyi_40s_raw.mp4" \
    -i "$BASE/overlays/scene1_title.png" \
    -i "$BASE/overlays/scene2_overlay.png" \
    -i "$BASE/overlays/scene3_overlay.png" \
    -i "$BASE/overlays/scene4_closing.png" \
    -i "$BASE/overlays/endcard.png" \
    -filter_complex "
      [1:v]format=rgba,fade=t=in:st=6.5:d=0.5:alpha=1,fade=t=out:st=9:d=0.5:alpha=1[ov1];
      [2:v]format=rgba,fade=t=in:st=16.5:d=0.5:alpha=1,fade=t=out:st=19:d=0.5:alpha=1[ov2];
      [3:v]format=rgba,fade=t=in:st=26.5:d=0.5:alpha=1,fade=t=out:st=29:d=0.5:alpha=1[ov3];
      [4:v]format=rgba,fade=t=in:st=32.5:d=0.5:alpha=1,fade=t=out:st=36:d=0.5:alpha=1[ov4];
      [5:v]format=rgba,fade=t=in:st=36.5:d=0.5:alpha=1[ov5];
      [0:v][ov1]overlay=0:0[tmp1];
      [tmp1][ov2]overlay=0:0[tmp2];
      [tmp2][ov3]overlay=0:0[tmp3];
      [tmp3][ov4]overlay=0:0[tmp4];
      [tmp4][ov5]overlay=0:0[final]" \
    -map "[final]" \
    -c:v libx264 -crf 18 -preset slow -pix_fmt yuv420p \
    "$BASE/final/herjyi_40s_with_overlays.mp4"
  echo "[6/6] Final with overlays: $BASE/final/herjyi_40s_with_overlays.mp4"
else
  echo "[6/6] Skipped overlays (PNGs not found). Use raw video."
fi

echo ""
echo "========================================"
echo "  DONE"
echo "========================================"
echo ""
echo "Files on Raido:"
ls -lh "$BASE/stills/" 2>/dev/null
ls -lh "$BASE/clips/" 2>/dev/null
ls -lh "$BASE/final/" 2>/dev/null
echo ""
echo "Final video: $BASE/final/herjyi_40s_with_overlays.mp4"
echo "Raw video:   $BASE/final/herjyi_40s_raw.mp4"
