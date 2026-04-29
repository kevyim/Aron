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

# Install in virtual env to avoid PEP 668 error
if [ ! -d "/tmp/hf-venv" ]; then
  python3 -m venv /tmp/hf-venv
fi
source /tmp/hf-venv/bin/activate
pip install higgsfield-client 2>/dev/null || pip install higgsfield-client

bash herjyi-video/higgsfield-generate.sh
bash herjyi-video/stitch.sh

echo ""
echo "DONE. Final video: /Volumes/RAID0/HERJYI-Video/final/herjyi_40s_raw.mp4"
