#!/bin/bash
# HERJYI 40s Commercial — Setup on Mac Mini External Drive
# Drive: Raido - AI Video

set -e

BASE="/Volumes/Raido - AI Video/HERJYI-Video"

mkdir -p "$BASE/stills"
mkdir -p "$BASE/clips"
mkdir -p "$BASE/overlays"
mkdir -p "$BASE/final"
mkdir -p "$BASE/assets"

echo "=== HERJYI Video Project Structure ==="
echo "$BASE/"
echo "  stills/     <- Grok-generated hero images"
echo "  clips/      <- Hailuo 2.3 video clips (10s each)"
echo "  overlays/   <- Canva text overlay PNGs"
echo "  final/      <- Stitched + graded output"
echo "  assets/     <- Brand assets, logos, fonts"
echo ""
echo "Done. All heavy files stay on Raido drive."
