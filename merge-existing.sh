#!/bin/bash

echo "Merging existing repo content into new structure..."

# Checkout existing files to temp location
mkdir -p .temp-merge
git --work-tree=.temp-merge checkout origin/main -- .

# Move website to showcase/
echo "Moving website files to showcase/..."
cp -r .temp-merge/site/* showcase/

# Keep existing documentation (might be useful)
echo "Preserving existing documentation..."
mkdir -p docs-archive
cp -r .temp-merge/docs/* docs-archive/

# Keep project management
echo "Preserving project files..."
mkdir -p project
cp -r .temp-merge/project/* project/ 2>/dev/null || true

# Keep existing analysis prompts
echo "Preserving existing prompts..."
mkdir -p methodology/existing-prompts
cp -r .temp-merge/analysis/prompts/* methodology/existing-prompts/ 2>/dev/null || true

# Keep useful scripts
echo "Copying utility scripts..."
cp .temp-merge/*.sh tools/ 2>/dev/null || true

# Save the existing README for reference
echo "Saving existing README..."
cp .temp-merge/README.md README-from-existing.md

# Cleanup
rm -rf .temp-merge

echo ""
echo "Merge complete! Check:"
echo "  - showcase/ for website"
echo "  - docs-archive/ for existing docs"
echo "  - methodology/existing-prompts/ for old prompts"
echo "  - README-from-existing.md vs README.md"
