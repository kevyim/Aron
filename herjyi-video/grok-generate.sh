#!/bin/bash
# HERJYI 40s Commercial — Grok Image Generation
# Run on Mac Mini. Output to Raido external drive.

set -e

BASE="/Volumes/Raido - AI Video/HERJYI-Video"
mkdir -p "$BASE/stills"

echo "=== SCENE 1: THE ORIGIN ==="
grok --model grok-3 \
  "Generate an image: Macro close-up of raw Taiwanese brown sugar crystals on a dark slate surface. Warm amber glow illuminates the irregular crystalline texture. Traces of molasses glisten. Single sugarcane stalk blurred in background. Dark moody studio lighting. Premium ingredient photography, 8K, shallow depth of field." \
  -o "$BASE/stills/scene1_origin.png"

echo "=== SCENE 2: THE CRAFT ==="
grok --model grok-3 \
  "Generate an image: A transparent glass viewed from above showing dark brown sugar syrup pooled at the bottom with fresh white milk being poured from top. The moment of first contact — brown sugar tendrils swirling upward into milk creating marble patterns. Soft warm beige seamless background. Overhead angle. Premium beverage advertisement, DSLR macro, hyper-realistic, 8K." \
  -o "$BASE/stills/scene2_craft.png"

echo "=== SCENE 3: THE PEARLS ==="
grok --model grok-3 \
  "Generate an image: Extreme macro of glossy black tapioca pearls mid-fall, three pearls suspended in air above a glass of brown sugar milk tea. Each pearl coated in glistening brown sugar syrup. Glass shows perfect brown-to-cream gradient. Condensation droplets on glass. Soft beige studio background. Rembrandt lighting. Commercial food photography, 8K." \
  -o "$BASE/stills/scene3_pearls.png"

echo "=== SCENE 4: THE HERO SHOT ==="
grok --model grok-3 \
  "Generate an image: Center-frame hero product shot of a tall transparent glass filled with iced brown sugar bubble milk tea. Tiger-stripe brown sugar pattern on inside of glass. Tapioca pearls settled at bottom. Creamy milk tea with ice cubes. Visible condensation droplets. Clean beige seamless studio background. Soft natural lighting, clean shadow beneath glass. Ultra-sharp, DSLR macro, premium advertisement, 8K." \
  -o "$BASE/stills/scene4_hero.png"

echo ""
echo "All 4 hero stills saved to: $BASE/stills/"
echo "Next: Upload each to Hailuo 2.3 with prompts from hailuo-prompts.md"
