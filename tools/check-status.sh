#!/bin/bash

# check-status.sh - Quick status check of repository
# Usage: bash check-status.sh

echo "📊 Technical Debt Observatory - Status Check"
echo "=================================================="
echo ""

# Git status
echo "🔍 Git Status:"
git status --short
echo ""

# Branch info
echo "🌿 Branch: $(git branch --show-current)"
echo ""

# Remote info
echo "🔗 Remote:"
git remote -v | head -n 1
echo ""

# Last commit
echo "💾 Last Commit:"
git log -1 --oneline
echo ""

# Uncommitted changes
UNSTAGED=$(git diff --name-only | wc -l | tr -d ' ')
STAGED=$(git diff --cached --name-only | wc -l | tr -d ' ')
UNTRACKED=$(git ls-files --others --exclude-standard | wc -l | tr -d ' ')

echo "📝 Changes:"
echo "  Unstaged: $UNSTAGED files"
echo "  Staged: $STAGED files"
echo "  Untracked: $UNTRACKED files"
echo ""

# Directory structure
echo "📁 Directory Structure:"
tree -L 2 -d --charset ascii -I 'node_modules|.git' 2>/dev/null || find . -type d -maxdepth 2 -not -path '*/\.*' | sort
echo ""
