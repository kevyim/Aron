#!/bin/bash
# HERJYI 40s Commercial — WORLD #1 PROMPTS
# Upgraded to D_studioproject / Apple / Nike quality tier
# Run on Mac Mini. Output to Raido.

set -e
BASE="/Volumes/Raido - AI Video/HERJYI-Video"
mkdir -p "$BASE/stills"

echo "========================================"
echo "  HERJYI — Grok Image Generation"
echo "  World #1 Quality Tier"
echo "========================================"

echo ""
echo "=== SCENE 1: THE ORIGIN ==="
grok --model grok-3 "
Generate a hyper-realistic product photograph:
Extreme macro close-up of raw Taiwanese brown sugar crystals scattered on a rough dark slate surface. Each crystal catches warm volumetric amber light from a single overhead source, creating sharp micro-shadows and brilliant caramel-colored highlights. Visible crystalline facets with traces of dark molasses pooled between crystals. One blurred sugarcane stalk leans diagonally in the far background. Shallow depth of field, f/1.4 bokeh. Dark negative space fills 60% of frame. Shot on Hasselblad H6D-400c, Phase One 120mm macro lens, premium ingredient advertisement for luxury brand. Hyper-realistic, photorealistic, 8K resolution, no text, no watermark.
" -o "$BASE/stills/scene1_origin.png"

echo ""
echo "=== SCENE 2: THE CRAFT ==="
grok --model grok-3 "
Generate a hyper-realistic beverage photograph:
Birds-eye overhead shot of a crystal-clear glass on soft beige seamless studio backdrop. Dark brown sugar syrup pools at the bottom like liquid amber. Fresh cold whole milk is being poured from above, the stream breaking the surface and creating organic marble-like swirl patterns as brown sugar tendrils curl upward through white milk. Micro-bubbles form at the contact point. Three perfectly clear ice cubes visible through the liquid with realistic light refraction. Tiny condensation droplets on the outer glass rim. Single soft diffused light source from upper left creating one clean shadow. Shot on Canon EOS R5 with 100mm macro, f/2.8, commercial beverage photography for Starbucks-tier brand. Photorealistic, hyper-detailed liquid physics, 8K, no text, no watermark.
" -o "$BASE/stills/scene2_craft.png"

echo ""
echo "=== SCENE 3: THE PEARLS ==="
grok --model grok-3 "
Generate a hyper-realistic food photograph:
Freeze-frame action shot of three glossy black tapioca boba pearls suspended mid-fall in the air above a glass of brown sugar milk tea. Each pearl is perfectly spherical, coated in a thin glossy layer of brown sugar syrup that catches light as a specular highlight. The pearls are at slightly different heights creating dynamic diagonal composition. Below them, the glass shows a smooth gradient from dark caramel brown at bottom to creamy white at top. Fine condensation droplets bead on the glass exterior. Soft warm beige studio background. Rembrandt lighting with key light from 45 degrees right. Shot on Sony A7R V with 90mm macro, f/2.0, high-speed freeze frame. Commercial food photography for premium Asian beverage brand. Hyper-realistic, 8K, no text, no watermark.
" -o "$BASE/stills/scene3_pearls.png"

echo ""
echo "=== SCENE 4: THE HERO SHOT ==="
grok --model grok-3 "
Generate a hyper-realistic hero product photograph:
Perfectly centered tall transparent glass filled with iced brown sugar bubble milk tea against clean beige seamless studio background. Inside the glass: dramatic tiger-stripe brown sugar syrup pattern streaked vertically along the inner wall. Glossy black tapioca pearls settled at the bottom in a neat pile. Rich creamy milk tea fills the middle, gradient from dark amber to soft cream. Three crystal-clear ice cubes near the top with sharp-edge refraction and internal light caustics. Realistic condensation droplets covering the entire glass exterior, some droplets mid-drip. Soft omnidirectional studio lighting creating a single clean diffused shadow beneath the glass on the seamless surface. Perfect symmetry. Shot on Hasselblad X2D, 80mm, f/4.0. Ultra-premium commercial hero shot for billion-dollar beverage brand launch. Apple-level minimalism. Hyper-realistic, photorealistic, 8K, no text, no watermark, no logo.
" -o "$BASE/stills/scene4_hero.png"

echo ""
echo "========================================"
echo "  All 4 hero stills generated"
echo "========================================"
ls -lh "$BASE/stills/"
echo ""
echo "Next: Feed each into Hailuo 2.3 or Higgsfield generate-video"
