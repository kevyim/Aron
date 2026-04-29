#!/bin/bash
# HERJYI — Full Higgsfield Generation (Stills + Video)
# Mac Mini + RAID0 drive.

set -e

if [ -z "$HF_KEY" ]; then
  if [ -n "$HF_API_KEY" ] && [ -n "$HF_SECRET" ]; then
    export HF_KEY="${HF_API_KEY}:${HF_SECRET}"
  else
    echo "Set credentials first"
    exit 1
  fi
fi

# Activate venv if not already
if [ -d "/tmp/hf-venv" ]; then
  source /tmp/hf-venv/bin/activate
fi

BASE="/Volumes/RAID0/HERJYI-Video"
mkdir -p "$BASE"/{stills,clips,overlays,final}

python3 << 'PYEOF'
import os, urllib.request, json, time
from higgsfield_client import subscribe, submit

BASE = "/Volumes/RAID0/HERJYI-Video"

scenes = [
    {
        "name": "scene1_origin",
        "img": "Extreme macro close-up of raw Taiwanese brown sugar crystals on rough dark slate. Warm volumetric amber light, crystalline facets with molasses pooled between. One blurred sugarcane stalk in background. f/1.4 bokeh, Hasselblad H6D, 8K, hyper-realistic, no text.",
        "vid": "Ultra-slow dolly-in macro. Brown sugar crystals melting on dark slate, caramel pooling. Warm volumetric amber light shifting. Steam wisps. Ridley Scott lighting, 24fps cinematic, 8K."
    },
    {
        "name": "scene2_craft",
        "img": "Birds-eye overhead of crystal glass on beige backdrop. Brown sugar syrup at bottom, milk being poured creating marble swirl patterns. Ice cubes with refraction. Condensation droplets. Canon EOS R5 100mm macro, commercial beverage photo, 8K, no text.",
        "vid": "Overhead top-down, slow zoom. Milk pours into glass hitting brown sugar syrup. Caramel swirls bloom. Ice cubes drop with micro-splash. Diffused cafe lighting, beige bg. Hyper-realistic liquid, 24fps, 8K."
    },
    {
        "name": "scene3_pearls",
        "img": "Three glossy black tapioca pearls suspended mid-fall above brown sugar milk tea glass. Coated in brown sugar syrup, specular highlights. Glass shows brown-to-cream gradient. Condensation. Rembrandt lighting 45 degrees. Sony A7R V 90mm macro, 8K, no text.",
        "vid": "Slow-motion tracking. Three tapioca pearls fall staggered into milk tea. Crown splash, ripples, pearls sink through cream. Camera tracks last pearl downward. Condensation slides on glass. Rembrandt light, 120fps at 24fps, 8K."
    },
    {
        "name": "scene4_hero",
        "img": "Centered tall glass of iced brown sugar bubble milk tea on beige seamless. Tiger-stripe syrup pattern, tapioca pearls at bottom, creamy milk tea, ice cubes with caustics. Full condensation. Hasselblad X2D 80mm, Apple-level minimalism, hero product shot, 8K, no text.",
        "vid": "Slow 180-degree orbit around hero glass. Camera rises base to eye level. Tiger-stripe rotates into view. Condensation droplet slides down. Light shifts creating ice caustics. Settles front-center symmetrical. Apple product reveal energy, 24fps, 8K."
    }
]

def download(url, path):
    urllib.request.urlretrieve(url, path)
    size_mb = os.path.getsize(path) / (1024*1024)
    print(f"  Downloaded: {path} ({size_mb:.1f} MB)")

def extract_url(result):
    if isinstance(result, str):
        return result
    if isinstance(result, dict):
        for key in ["url", "image_url", "video_url", "output_url"]:
            if key in result:
                return result[key]
        if "output" in result and isinstance(result["output"], dict):
            return result["output"].get("url")
        if "data" in result and isinstance(result["data"], dict):
            return result["data"].get("url")
    return None

results = {}

for scene in scenes:
    name = scene["name"]
    print(f"\n{'='*50}")
    print(f"  {name.upper()}")
    print(f"{'='*50}")

    print("  [IMG] Generating...")
    try:
        img_result = subscribe("generate-image", {"prompt": scene["img"], "resolution": "1080p"})
        print(f"  [IMG] Result: {json.dumps(img_result, default=str)[:200]}")
        img_url = extract_url(img_result)
        if img_url:
            download(img_url, f"{BASE}/stills/{name}.png")
            results[f"{name}_img"] = img_url

            print("  [VID] Generating...")
            try:
                vid_result = subscribe("generate-video", {
                    "image_url": img_url,
                    "prompt": scene["vid"]
                })
                print(f"  [VID] Result: {json.dumps(vid_result, default=str)[:200]}")
                vid_url = extract_url(vid_result)
                if vid_url:
                    download(vid_url, f"{BASE}/clips/{name}.mp4")
                    results[f"{name}_vid"] = vid_url
                else:
                    print("  [VID] No URL found in result")
            except Exception as e:
                print(f"  [VID] Error: {e}")
        else:
            print("  [IMG] No URL found in result")
    except Exception as e:
        print(f"  [IMG] Error: {e}")

print(f"\n{'='*50}")
print("  GENERATION SUMMARY")
print(f"{'='*50}")
for k, v in results.items():
    print(f"  {k}: {v[:80]}...")
print(f"\nStills: {BASE}/stills/")
print(f"Clips:  {BASE}/clips/")
PYEOF

echo ""
echo "Next: bash herjyi-video/stitch.sh"
