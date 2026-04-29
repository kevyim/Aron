#!/bin/bash
# HERJYI 40s Commercial — FULL PIPELINE
# Mac Mini + Raido drive. One command.
# Usage: bash run-all.sh

set -e

BASE="/Volumes/Raido - AI Video/HERJYI-Video"

if [ -z "$HF_API_KEY" ] || [ -z "$HF_SECRET" ]; then
  echo "ERROR: Set HF_API_KEY and HF_SECRET first"
  echo "  export HF_API_KEY=your-api-key"
  echo "  export HF_SECRET=your-secret"
  exit 1
fi

export HF_KEY="${HF_API_KEY}:${HF_SECRET}"

echo "========================================"
echo "  HERJYI 40s Commercial — Full Pipeline"
echo "========================================"

# --- STEP 0: Setup folders on Raido ---
echo "[0/5] Creating project on Raido..."
mkdir -p "$BASE"/{stills,clips,overlays,final,assets}

# --- STEP 1: Install deps ---
echo "[1/5] Installing dependencies..."
pip3 install higgsfield-client 2>/dev/null || true
brew list ffmpeg &>/dev/null || brew install ffmpeg 2>/dev/null || true

# --- STEP 2: Generate 4 stills + 4 videos ---
echo "[2/5] Generating stills and video clips via Higgsfield..."

python3 << 'PYEOF'
import os, time, json, urllib.request

from higgsfield_client import subscribe, submit

BASE = "/Volumes/Raido - AI Video/HERJYI-Video"

scenes = [
    {
        "name": "scene1_origin",
        "img_prompt": "Macro close-up of raw Taiwanese brown sugar crystals on a dark slate surface. Warm amber glow illuminates the irregular crystalline texture. Traces of molasses glisten. Single sugarcane stalk blurred in background. Dark moody studio lighting. Premium ingredient photography, 8K, shallow depth of field.",
        "vid_prompt": "Slow dolly-in macro shot. Golden brown sugar crystals on dark slate begin to melt, thick glossy caramel slowly pooling. Warm volumetric amber lighting from above. Wisps of steam rise. Dark background, premium commercial photography style. Ultra-slow motion, cinematic depth of field, 8K hyper-realistic."
    },
    {
        "name": "scene2_craft",
        "img_prompt": "A transparent glass viewed from above showing dark brown sugar syrup pooled at the bottom with fresh white milk being poured from top. The moment of first contact, brown sugar tendrils swirling upward into milk creating marble patterns. Soft warm beige seamless background. Overhead angle. Premium beverage advertisement, DSLR macro, hyper-realistic, 8K.",
        "vid_prompt": "Top-down overhead shot, slow zoom in. Creamy milk pours into glass, colliding with dark brown sugar syrup below. Caramel marble swirls bloom upward in slow motion. Three clear ice cubes drop in sequence with realistic splash and refraction. Soft diffused cafe lighting, warm beige background. Hyper-realistic liquid physics, ultra-slow motion, premium commercial, 8K."
    },
    {
        "name": "scene3_pearls",
        "img_prompt": "Extreme macro of glossy black tapioca pearls mid-fall, three pearls suspended in air above a glass of brown sugar milk tea. Each pearl coated in glistening brown sugar syrup. Glass shows perfect brown-to-cream gradient. Condensation droplets on glass. Soft beige studio background. Rembrandt lighting. Commercial food photography, 8K.",
        "vid_prompt": "Slow-motion tracking shot. Glossy black tapioca pearls fall one by one into brown sugar milk tea. Each pearl breaks the surface with micro-splash and sinks through cream layer. Camera follows the last pearl downward through liquid. Condensation forms on glass exterior. Warm Rembrandt studio lighting, beige background. Hyper-realistic, premium beverage ad, ultra-slow motion, 8K."
    },
    {
        "name": "scene4_hero",
        "img_prompt": "Center-frame hero product shot of a tall transparent glass filled with iced brown sugar bubble milk tea. Tiger-stripe brown sugar pattern on inside of glass. Tapioca pearls settled at bottom. Creamy milk tea with ice cubes. Visible condensation droplets. Clean beige seamless studio background. Soft natural lighting, clean shadow beneath glass. Ultra-sharp, DSLR macro, premium advertisement, 8K.",
        "vid_prompt": "Slow crane shot rising from glass base to top. Finished brown sugar bubble milk tea centered in frame. Camera slowly orbits 15 degrees. Condensation droplet slides down glass surface. Subtle light shift catches ice cube refraction. Everything calm and still. Soft diffused studio lighting, warm beige background. Ultra-premium commercial, Apple product-shot aesthetic, hyper-realistic, 8K."
    }
]

def download(url, path):
    urllib.request.urlretrieve(url, path)
    print(f"  Saved: {path}")

for scene in scenes:
    name = scene["name"]
    print(f"\n=== {name.upper()} ===")

    # Generate image
    print(f"  Generating image...")
    try:
        img_result = subscribe("generate-image", {
            "prompt": scene["img_prompt"],
            "resolution": "1080p"
        })
        print(f"  Image result: {img_result}")

        # Extract image URL
        img_url = None
        if isinstance(img_result, dict):
            img_url = img_result.get("url") or img_result.get("image_url") or img_result.get("output", {}).get("url")
        elif isinstance(img_result, str):
            img_url = img_result

        if img_url:
            download(img_url, f"{BASE}/stills/{name}.png")

            # Generate video from image
            print(f"  Generating video...")
            vid_result = subscribe("generate-video", {
                "image_url": img_url,
                "prompt": scene["vid_prompt"]
            })
            print(f"  Video result: {vid_result}")

            vid_url = None
            if isinstance(vid_result, dict):
                vid_url = vid_result.get("url") or vid_result.get("video_url") or vid_result.get("output", {}).get("url")
            elif isinstance(vid_result, str):
                vid_url = vid_result

            if vid_url:
                download(vid_url, f"{BASE}/clips/{name}.mp4")
        else:
            print(f"  WARNING: No image URL in result")
    except Exception as e:
        print(f"  ERROR: {type(e).__name__}: {e}")

print("\n=== All generation complete ===")
print(f"Stills: {BASE}/stills/")
print(f"Clips:  {BASE}/clips/")
PYEOF

echo "[2/5] Generation done."

# --- STEP 3: Rename clips for concat ---
echo "[3/5] Preparing clips..."
cd "$BASE/clips"
for f in scene1_origin.mp4 scene2_craft.mp4 scene3_pearls.mp4 scene4_hero.mp4; do
  NUM=$(echo "$f" | grep -o '[0-9]')
  [ -f "$f" ] && cp "$f" "scene${NUM}.mp4"
done

# --- STEP 4: Stitch ---
echo "[4/5] Stitching 4 clips into 40s video..."

MISSING=0
for i in 1 2 3 4; do
  [ ! -f "$BASE/clips/scene${i}.mp4" ] && echo "  Missing scene${i}.mp4" && MISSING=1
done

if [ "$MISSING" -eq 0 ]; then
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

  echo "  Raw video: $BASE/final/herjyi_40s_raw.mp4"
else
  echo "  Skipping stitch — missing clips."
fi

# --- STEP 5: Summary ---
echo ""
echo "========================================"
echo "  PIPELINE COMPLETE"
echo "========================================"
echo ""
echo "Output on Raido:"
echo "  Stills:  $BASE/stills/"
echo "  Clips:   $BASE/clips/"
echo "  Final:   $BASE/final/"
echo ""
[ -f "$BASE/final/herjyi_40s_raw.mp4" ] && echo "Final video: $BASE/final/herjyi_40s_raw.mp4" && ls -lh "$BASE/final/herjyi_40s_raw.mp4"
echo ""
echo "Next: Add Canva overlays in CapCut/DaVinci"
echo "  Endcard:    https://www.canva.com/d/Xu-Lq4y2bLBRxrl"
echo "  Scene 1:    https://www.canva.com/d/w3-ClQDtFWVw4vx"
echo "  Scene 2:    https://www.canva.com/d/QWPYJH22PoU_Ep8"
echo "  Scene 3:    https://www.canva.com/d/KNOBSsEgquIRpC0"
echo "  Scene 4:    https://www.canva.com/d/G_IJXA8rBHVlZqv"
