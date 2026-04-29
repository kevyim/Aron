#!/bin/bash
# HERJYI — Grok Fact-Check Commands
# Run before finalizing any marketing copy
# Cost: ~$0.03 per call

echo "=== Fact-Check 1: Founding Year ==="
grok --model fast --tools=1 "verify via x_search: HERJYI Jin Hong Sugar Co Ltd founded 1989 Kaohsiung Taiwan. Check if this founding year and location are accurate."

echo ""
echo "=== Fact-Check 2: Certifications ==="
grok --model fast --tools=1 "verify via x_search: HERJYI Jin Hong Sugar HACCP ISO 22000 Halal certified. Confirm these certifications are current and valid."

echo ""
echo "=== Fact-Check 3: No Preservatives Claim ==="
grok --model fast --tools=1 "verify via x_search: HERJYI brown sugar syrup made through high temperature sterilization no preservatives added. Is this claim substantiated?"

echo ""
echo "=== Fact-Check 4: Market Position ==="
grok --model fast --tools=1 "verify via x_search: top Taiwan brown sugar syrup B2B suppliers 2026. Where does HERJYI Jin Hong rank among competitors?"

echo ""
echo "✅ Review all results before using claims in video copy"
