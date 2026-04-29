#!/bin/bash
# Grok fact-check before publishing
# Run on Mac Mini

echo "=== Fact-Check: Founding ==="
grok --model fast --tools=1 "verify via x_search: HERJYI Jin Hong Sugar Co Ltd founded 1989 Kaohsiung Taiwan"

echo ""
echo "=== Fact-Check: Certifications ==="
grok --model fast --tools=1 "verify via x_search: HERJYI Jin Hong Sugar HACCP ISO 22000 Halal certified"

echo ""
echo "=== Fact-Check: No Preservatives ==="
grok --model fast --tools=1 "verify via x_search: HERJYI brown sugar syrup no preservatives high temperature sterilization"

echo ""
echo "=== Fact-Check: Market Position ==="
grok --model fast --tools=1 "verify via x_search: top Taiwan brown sugar syrup B2B suppliers 2026"

echo ""
echo "Review all results before publishing video copy."
