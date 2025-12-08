#!/bin/bash
################################################################################
# commit-and-push.sh - Interactive Git Commit and Push Workflow
################################################################################
#
# @purpose: Guide users through safe commit and push process
#   - Validate git repository state before operations
#   - Show changes before committing (prevent surprises)
#   - Provide default or custom commit message options
#   - Push to correct branch with confirmation
#   - Open GitHub repository for verification
#
# @workflow: Five-phase interactive workflow
#   Phase 1: Validation
#     └─> Check git repository exists
#     └─> Display current git status
#     └─> Prompt to stage changes if needed
#
#   Phase 2: Review
#     └─> Show what will be committed (--stat)
#     └─> Prompt for confirmation before commit
#     └─> Allow user to abort safely
#
#   Phase 3: Commit Message
#     └─> Offer default message (reorganization template)
#     └─> Allow custom message input
#     └─> Create commit with chosen message
#
#   Phase 4: Pre-Push Validation
#     └─> Display current branch name
#     └─> Check for uncommitted changes
#     └─> Warn if working tree is dirty
#
#   Phase 5: Push and Next Steps
#     └─> Push to origin/BRANCH
#     └─> Display GitHub Pages setup instructions
#     └─> Optionally open repository in browser
#
# @dependencies: Git repository with origin remote
#   System requirements:
#     - Bash 3.0+ (read -p with -r flag)
#     - git command available
#     - set -e for error propagation
#
#   Repository state:
#     - Must be git repository (.git directory exists)
#     - Origin remote must be configured
#     - At least one commit exists (for branch detection)
#
#   Browser support:
#     - macOS: open command
#     - Linux: xdg-open command
#     - Windows: Manual URL copy
#
# @gotchas: Interactive input and git state handling
#   Git Repository Check:
#     - Only checks for .git directory in current directory
#     - Will not detect if you're in a subdirectory of git repo
#     - Consider using 'git rev-parse --git-dir' for robustness
#     - Script must be run from repository root
#
#   Staged vs. Unstaged:
#     - If nothing staged, prompts to stage all changes
#     - 'git add .' stages everything including new files
#     - Respects .gitignore rules
#     - No granular staging (all-or-nothing)
#
#   Commit Message Input:
#     - Default message is project reorganization template
#     - Custom message uses cat (reads until Ctrl+D)
#     - Multi-line messages supported
#     - No validation of message format
#
#   Uncommitted Changes Warning:
#     - Checks for dirty working tree after commit
#     - Can happen if new changes made during script execution
#     - User can choose to abort push and fix
#     - Prevents pushing incomplete work
#
#   Branch Handling:
#     - Pushes to current branch only
#     - No branch creation or switching
#     - Assumes branch already exists on remote
#     - First push may require --set-upstream
#
#   GitHub Pages Instructions:
#     - Hardcoded instructions for /site folder
#     - Assumes specific directory structure
#     - May need adjustment for different setups
#     - Instructions shown every time (no persistence)
#
# USAGE:
#   ./commit-and-push.sh
#   # Interactive prompts guide you through:
#   #   1. Staging changes (if needed)
#   #   2. Reviewing changes to commit
#   #   3. Choosing commit message
#   #   4. Confirming push
#   #   5. Opening repository in browser
#
# OUTPUT:
#   Git operations:
#     - Staged changes (if prompted)
#     - Commit created with message
#     - Push to origin/BRANCH
#
#   Terminal display:
#     - Status summary with file counts
#     - Changes to be committed (--stat)
#     - Confirmation prompts
#     - GitHub Pages setup instructions
#     - Repository URL
#
# RELATED SCRIPTS:
#   - check-status.sh - Run first to see current state
#   - organize-files.sh - Reorganize before committing
#
################################################################################

set -e  # Exit on error

echo "🚀 Technical Debt Observatory - Commit & Push Script"
echo "=================================================="
echo ""

# ============================================
# PHASE 1: Validation
# WHY: Ensure we're in a git repository before operations
# ============================================

# Check if we're in a git repository
# WHY: .git directory check is fast but only works from repo root
# GOTCHA: Won't detect if in subdirectory of git repo
if [ ! -d ".git" ]; then
    echo "❌ Error: Not a git repository"
    exit 1
fi

# Show current status
# WHY: --short provides compact view of current state
echo "📊 Current status:"
git status --short
echo ""

# Check if there are staged changes
# WHY: --cached checks index, --quiet returns exit code only
if git diff --cached --quiet; then
    echo "ℹ️  No staged changes detected"
    echo ""
    
    # WHY: -n 1 reads single character, -r prevents backslash escaping
    read -p "Stage all changes? (y/n): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # WHY: git add . stages all changes in current directory
        # GOTCHA: Respects .gitignore but stages everything else
        git add .
        echo "✅ All changes staged"
    else
        echo "❌ No changes to commit"
        exit 0
    fi
fi

# ============================================
# PHASE 2: Review Changes
# WHY: Always show what's about to be committed
# ============================================

echo ""
echo "📋 Changes to be committed:"
# WHY: --cached shows staged changes, --stat shows file summary
git diff --cached --stat
echo ""

# Prompt for confirmation
# WHY: Prevent accidental commits
read -p "🤔 Commit and push these changes? (y/n): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Aborted by user"
    exit 1
fi

# ============================================
# PHASE 3: Commit Message
# WHY: Provide helpful default or allow customization
# ============================================

# Get commit message
echo ""
echo "💬 Commit message options:"
echo "  1. Use default: 'Reorganize project structure'"
echo "  2. Enter custom message"
read -p "Choose (1/2): " -n 1 -r
echo ""

if [[ $REPLY == "1" ]]; then
    # WHY: Default message template for common reorganization commits
    # GOTCHA: Hardcoded for specific use case (project reorganization)
    COMMIT_MSG="Reorganize project structure

- Separate docs/, site/, analysis/, tools/, research/, and project/ directories
- Move documentation to docs/
- Move HTML files to site/ for GitHub Pages
- Add .gitignore for better security
- Create project management files (roadmap, todo, changelog)
- Add analysis prompt templates
- Preserve git history with 'git mv'
- Improve organization for scalability"
else
    # WHY: cat reads multi-line input until Ctrl+D (EOF)
    # GOTCHA: No validation of commit message format
    echo "Enter your commit message (press Ctrl+D when done):"
    COMMIT_MSG=$(cat)
fi

# ============================================
# Commit Changes
# WHY: -m flag uses message from variable
# ============================================

echo ""
echo "💾 Committing changes..."
git commit -m "$COMMIT_MSG"
echo "✅ Changes committed"
echo ""

# ============================================
# PHASE 4: Pre-Push Validation
# WHY: Verify state before pushing to remote
# ============================================

# Get current branch
# WHY: --show-current returns just the branch name
BRANCH=$(git branch --show-current)
echo "🌿 Current branch: $BRANCH"
echo ""

# Check for uncommitted changes before pushing
# WHY: --quiet returns exit code, -- separates options from paths
# GOTCHA: Can happen if changes made during script execution
if ! git diff-index --quiet HEAD --; then
    echo "⚠️  Warning: You have uncommitted changes"
    git status --short
    echo ""
    
    read -p "Continue with push? (y/n): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Push cancelled"
        exit 1
    fi
fi

# ============================================
# PHASE 5: Push and Next Steps
# WHY: Push to remote and provide follow-up guidance
# ============================================

# Push
# WHY: Explicit origin and branch name for clarity
# GOTCHA: May require --set-upstream on first push
echo "📤 Pushing to origin/$BRANCH..."
git push origin "$BRANCH"

echo ""
echo "=================================================="
echo "✅ Successfully pushed to GitHub!"
echo ""
echo "🌐 Next steps:"
echo "  1. Visit your GitHub repository"
echo "  2. Verify the file structure looks correct"
echo "  3. Set up GitHub Pages:"
echo ""
echo "     GitHub Pages Setup:"
echo "     - Go to: Settings → Pages"
echo "     - Source: Deploy from a branch"
echo "     - Branch: $BRANCH"
echo "     - Folder: /site"
echo "     - Click Save"
echo ""
echo "  4. Your site will be live at:"
echo "     https://YOUR-USERNAME.github.io/YOUR-REPO-NAME/"
echo ""

# Get repo URL
# WHY: sed removes .git suffix for clean browser URL
REPO_URL=$(git remote get-url origin | sed 's/\.git$//')
echo "🔗 Repository: $REPO_URL"
echo ""

# Optional: Open GitHub
# WHY: Convenient for immediate verification
read -p "🌐 Open GitHub repository in browser? (y/n): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    # WHY: OS-specific commands for opening URLs
    # GOTCHA: $OSTYPE not available on all systems
    if [[ "$OSTYPE" == "darwin"* ]]; then
        open "$REPO_URL"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        xdg-open "$REPO_URL"
    else
        # WHY: Fallback for Windows or unknown OS
        echo "Repository URL: $REPO_URL"
    fi
fi
