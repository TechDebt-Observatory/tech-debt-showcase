#!/bin/bash

# commit-and-push.sh - Commit reorganization and push to GitHub
# Usage: bash commit-and-push.sh

set -e  # Exit on error

echo "🚀 Technical Debt Observatory - Commit & Push Script"
echo "=================================================="
echo ""

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Error: Not a git repository"
    exit 1
fi

# Show current status
echo "📊 Current status:"
git status --short
echo ""

# Check if there are staged changes
if git diff --cached --quiet; then
    echo "ℹ️  No staged changes detected"
    echo ""
    read -p "Stage all changes? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git add .
        echo "✅ All changes staged"
    else
        echo "❌ No changes to commit"
        exit 0
    fi
fi

# Show what will be committed
echo ""
echo "📋 Changes to be committed:"
git diff --cached --stat
echo ""

# Prompt for confirmation
read -p "🤔 Commit and push these changes? (y/n): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Aborted by user"
    exit 1
fi

# Get commit message
echo ""
echo "💬 Commit message options:"
echo "  1. Use default: 'Reorganize project structure'"
echo "  2. Enter custom message"
read -p "Choose (1/2): " -n 1 -r
echo ""

if [[ $REPLY == "1" ]]; then
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
    echo "Enter your commit message (press Ctrl+D when done):"
    COMMIT_MSG=$(cat)
fi

# Commit
echo ""
echo "💾 Committing changes..."
git commit -m "$COMMIT_MSG"
echo "✅ Changes committed"
echo ""

# Get current branch
BRANCH=$(git branch --show-current)
echo "🌿 Current branch: $BRANCH"
echo ""

# Check for uncommitted changes before pushing
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

# Push
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
REPO_URL=$(git remote get-url origin | sed 's/\.git$//')
echo "🔗 Repository: $REPO_URL"
echo ""

# Optional: Open GitHub
read -p "🌐 Open GitHub repository in browser? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        open "$REPO_URL"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        xdg-open "$REPO_URL"
    else
        echo "Repository URL: $REPO_URL"
    fi
fi
