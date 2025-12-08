#!/bin/bash
################################################################################
# check-status.sh - Repository Quick Status Overview
################################################################################
#
# @purpose: Display comprehensive git and directory status at a glance
#   - Show git repository state (branch, remote, last commit)
#   - Count uncommitted changes (unstaged, staged, untracked)
#   - Display directory structure for project overview
#   - Provide quick health check before commits
#
# @workflow: Single-phase status collection
#   Phase 1: Status Display
#     └─> Git status summary with --short format
#     └─> Current branch and remote information
#     └─> Last commit message for context
#     └─> Change counts (unstaged, staged, untracked)
#     └─> Directory tree visualization (2 levels deep)
#
# @dependencies: Git repository with standard tools
#   System requirements:
#     - Bash 3.0+ (basic shell features)
#     - git command available
#     - tree command (optional, falls back to find)
#
#   File structure:
#     - Must run from git repository root or subdirectory
#     - No specific file requirements
#
#   Repository state:
#     - Git repository must be initialized
#     - Remote optional (will show if configured)
#
# @gotchas: Git and tree command availability
#   Git Repository:
#     - Must be run inside a git repository
#     - Will fail with "not a git repository" if outside
#     - Works from any subdirectory (git auto-detects root)
#
#   Tree Command:
#     - tree command not available on all systems
#     - Automatically falls back to find if tree missing
#     - find output less visual but functionally equivalent
#     - Install tree: brew install tree (macOS), apt install tree (Linux)
#
#   Output Formatting:
#     - Emojis may not render in all terminals
#     - ASCII tree uses --charset ascii for compatibility
#     - Directory depth limited to 2 levels (avoid clutter)
#
#   Change Counts:
#     - wc -l output includes leading spaces (tr removes them)
#     - Counts are file counts, not line counts
#     - Untracked respects .gitignore rules
#
# USAGE:
#   ./check-status.sh
#   # No arguments required
#   # Run from anywhere in git repository
#
# OUTPUT:
#   Terminal display with 6 sections:
#     1. Git Status - Short format file status
#     2. Branch - Current branch name
#     3. Remote - Configured remote URL
#     4. Last Commit - Most recent commit message
#     5. Changes - File counts by category
#     6. Directory Structure - Tree view (2 levels)
#
# RELATED SCRIPTS:
#   - commit-and-push.sh - Next step after checking status
#   - organize-files.sh - Reorganizes project structure
#
################################################################################

echo "📊 Technical Debt Observatory - Status Check"
echo "=================================================="
echo ""

# ============================================
# Git Status Summary
# WHY: --short provides compact, scannable format
# ============================================
echo "🔍 Git Status:"
git status --short
echo ""

# ============================================
# Branch Information
# WHY: Important to know which branch before committing
# ============================================
echo "🌿 Branch: $(git branch --show-current)"
echo ""

# ============================================
# Remote Information
# WHY: Verify correct remote before pushing
# WHY: head -n 1 shows only fetch URL (not both fetch/push)
# ============================================
echo "🔗 Remote:"
git remote -v | head -n 1
echo ""

# ============================================
# Last Commit Context
# WHY: --oneline provides hash and message for context
# ============================================
echo "💾 Last Commit:"
git log -1 --oneline
echo ""

# ============================================
# Change Counts
# WHY: Numerical summary helps assess scope
# WHY: tr -d ' ' removes leading spaces from wc
# ============================================
UNSTAGED=$(git diff --name-only | wc -l | tr -d ' ')
STAGED=$(git diff --cached --name-only | wc -l | tr -d ' ')
UNTRACKED=$(git ls-files --others --exclude-standard | wc -l | tr -d ' ')

echo "📝 Changes:"
echo "  Unstaged: $UNSTAGED files"
echo "  Staged: $STAGED files"
echo "  Untracked: $UNTRACKED files"
echo ""

# ============================================
# Directory Structure
# WHY: Visual overview helps navigate project
# WHY: -L 2 limits depth to avoid overwhelming output
# WHY: -d shows directories only (not files)
# WHY: --charset ascii for terminal compatibility
# WHY: -I excludes common noise (node_modules, .git)
# WHY: Falls back to find if tree not installed
# ============================================
echo "📁 Directory Structure:"
tree -L 2 -d --charset ascii -I 'node_modules|.git' 2>/dev/null || find . -type d -maxdepth 2 -not -path '*/\.*' | sort
echo ""
