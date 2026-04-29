#!/bin/bash
# HERJYI — Full Higgsfield Generation (Stills + Video)
# Mac Mini + RAID0 drive.
# Correct model names from Higgsfield API docs.

set -e

if [ -z "$HF_KEY" ]; then
  if [ -n "$HF_API_KEY" ] && [ -n "$HF_SECRET" ]; then
    export HF_KEY="${HF_API_KEY}:${HF_SECRET}"
  else
    echo "Set credentials first"
    exit 1
  fi
fi

if [ -d "/tmp/hf-venv" ]; then
  source /tmp/hf-venv/bin/activate
fi

BASE="/Volumes/RAID0/HERJYI-Video"
mkdir -p "$BASE"/{stills,clips,overlays,final}

python3 << 'PYEOF'
import os, urllib.request, json
import higgsfield_client

BASE = "/Volumes/RAID0/HERJYI-Video"

# Correct Higgsfield application names:
# Image: bytedance/seedream/v4/text-to-image
# Video: bytedance/seedance/v1/pro/image-to-video

IMAGE_MODEL = "bytedance/seedream/v4/text-to-image"
VIDEO_MODEL = "bytedance/seedance/v1/pro/image-to-video"

scenes = [
    {
        "name": "scene1_origin",
        "img": "Extreme macro close-up of raw Taiwanese brown sugar crystals on rough dark slate. Warm volumetric amber light, crystalline facets with molasses pooled between. One blurred sugarcane stalk in background. f/1.4 bokeh, Hasselblad H6D, 8K, hyper-realistic, no text, no watermark.",
        "vid": "Ultra-slow dolly-in macro. Brown sugar crystals melting on dark slate, caramel pooling. Warm volumetric amber light shifting. Steam wisps. Ridley Scott lighting, 24fps cinematic, 8K."
    },
    {
        "name": "scene2_craft",
        "img": "Birds-eye overhead of crystal glass on beige backdrop. Brown sugar syrup at bottom, milk being poured creating marble swirl patterns. Ice cubes with refraction. Condensation droplets. Canon EOS R5 100mm macro, commercial beverage photo, 8K, no text, no watermark.",
        "vid": "Overhead top-down, slow zoom. Milk pours into glass hitting brown sugar syrup. Caramel swirls bloom. Ice cubes drop with micro-splash. Diffused cafe lighting, beige background. Hyper-realistic liquid, 24fps, 8K."
    },
    {
        "name": "scene3_pearls",
        "img": "Three glossy black tapioca pearls suspended mid-fall above brown sugar milk tea glass. Coated in brown sugar syrup, specular highlights. Glass shows brown-to-cream gradient. Condensation. Rembrandt lighting 45 degrees. Sony A7R V 90mm macro, 8K, no text, no watermark.",
        "vid": "Slow-motion tracking. Three tapioca pearls fall staggered into milk tea. Crown splash, ripples, pearls sink through cream. Camera tracks last pearl downward. Condensation slides on glass. Rembrandt light, 120fps at 24fps, 8K."
    },
    {
        "name": "scene4_hero",
        "img": "Centered tall glass of iced brown sugar bubble milk tea on beige seamless. Tiger-stripe syrup pattern, tapioca pearls at bottom, creamy milk tea, ice cubes with caustics. Full condensation. Hasselblad X2D 80mm, Apple-level minimalism, hero product shot, 8K, no text, no watermark.",
        "vid": "Slow 180-degree orbit around hero glass. Camera rises base to eye level. Tiger-stripe rotates into view. Condensation droplet slides down. Light shifts creating ice caustics. Settles front-center symmetrical. Apple product reveal energy, 24fps, 8K."
    }
]

def download(url, path):
    urllib.request.urlretrieve(url, path)
    size_mb = os.path.getsize(path) / (1024*1024)
    print(f"  Downloaded: {path} ({size_mb:.1f} MB)")

results = {}

for scene in scenes:
    name = scene["name"]
    print(f"\n{'='*50}")
    print(f"  {name.upper()}")
    print(f"{'='*50}")

    # Generate image
    print("  [IMG] Generating via Seedream v4...")
    try:
        img_result = higgsfield_client.subscribe(
            IMAGE_MODEL,
            arguments={
                "prompt": scene["img"],
                "resolution": "2K",
                "aspect_ratio": "9:16"
            }
        )
        print(f"  [IMG] Result keys: {list(img_result.keys()) if isinstance(img_result, dict) else type(img_result)}")

        img_url = None
        if isinstance(img_result, dict):
            if "images" in img_result and len(img_result["images"]) > 0:
                img_url = img_result["images"][0].get("url")
            elif "url" in img_result:
                img_url = img_result["url"]
            elif "image_url" in img_result:
                img_url = img_result["image_url"]

        if img_url:
            download(img_url, f"{BASE}/stills/{name}.png")
            results[f"{name}_img"] = img_url

            # Generate video from image
            print("  [VID] Generating via Seedance Pro...")
            try:
                # Upload the image to get a Higgsfield-hosted URL
                uploaded_url = higgsfield_client.upload_file(f"{BASE}/stills/{name}.png")
                print(f"  [VID] Uploaded image: {uploaded_url[:80]}...")

                vid_result = higgsfield_client.subscribe(
                    VIDEO_MODEL,
                    arguments={
                        "image_url": uploaded_url,
                        "prompt": scene["vid"]
                    }
                )
                print(f"  [VID] Result keys: {list(vid_result.keys()) if isinstance(vid_result, dict) else type(vid_result)}")

                vid_url = None
                if isinstance(vid_result, dict):
                    if "video" in vid_result:
                        vid_url = vid_result["video"].get("url") if isinstance(vid_result["video"], dict) else vid_result["video"]
                    elif "videos" in vid_result and len(vid_result["videos"]) > 0:
                        vid_url = vid_result["videos"][0].get("url")
                    elif "url" in vid_result:
                        vid_url = vid_result["url"]
                    elif "video_url" in vid_result:
                        vid_url = vid_result["video_url"]

                if vid_url:
                    download(vid_url, f"{BASE}/clips/{name}.mp4")
                    results[f"{name}_vid"] = vid_url
                else:
                    print(f"  [VID] No URL found. Full result: {json.dumps(vid_result, default=str)[:300]}")
            except Exception as e:
                print(f"  [VID] Error: {e}")
        else:
            print(f"  [IMG] No URL found. Full result: {json.dumps(img_result, default=str)[:300]}")
    except Exception as e:
        print(f"  [IMG] Error: {e}")

print(f"\n{'='*50}")
print("  GENERATION SUMMARY")
print(f"{'='*50}")
for k, v in results.items():
    print(f"  {k}: {v[:80]}...")
print(f"\nStills: {BASE}/stills/")
print(f"Clips:  {BASE}/clips/")

import subprocess
subprocess.run(["ls", "-lh", f"{BASE}/stills/"])
subprocess.run(["ls", "-lh", f"{BASE}/clips/"])
PYEOF

echo ""
echo "Next: bash herjyi-video/stitch.sh"
