#!/bin/bash
# HERJYI — ONE COMMAND
# Mac Mini + RAID0. Higgsfield all the way.

set -e

if [ -z "$HF_API_KEY" ] || [ -z "$HF_SECRET" ]; then
  echo "export HF_API_KEY=your-key"
  echo "export HF_SECRET=your-secret"
  exit 1
fi

export HF_KEY="${HF_API_KEY}:${HF_SECRET}"

pip3 install higgsfield-client 2>/dev/null || true

bash herjyi-video/higgsfield-generate.sh
bash herjyi-video/stitch.sh

echo ""
echo "DONE. Final video: /Volumes/RAID0/HERJYI-Video/final/herjyi_40s_raw.mp4"
