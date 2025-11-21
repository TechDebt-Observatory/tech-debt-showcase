#!/bin/bash

# organize-files.sh - Organize Technical Debt Observatory files (Git-Aware)
# Usage: bash organize-files.sh

set -e  # Exit on error

echo "🗂️  Technical Debt Observatory - File Organization Script (Git-Aware)"
echo "=================================================================="
echo ""

# Verify we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Error: Not in a git repository"
    echo "This script requires an existing git repository."
    exit 1
fi

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "Working directory: $SCRIPT_DIR"
echo "Git repository: ✅ Detected"
echo ""

# Show current status
echo "📊 Current git status:"
git status --short
echo ""

read -p "⚠️  This will reorganize files using 'git mv'. Continue? (y/n): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Aborted by user"
    exit 1
fi

# Create directory structure
echo "📁 Creating directory structure..."
mkdir -p docs
mkdir -p site/{assets/{css,images,js},examples/openssl}
mkdir -p analysis/{prompts,results/openssl/asn1parse,validation/checklists}
mkdir -p tools/{api,utilities}
mkdir -p research/{papers,industry-reports,notes}
mkdir -p project/feedback
mkdir -p deploy

echo "✅ Directory structure created"
echo ""

# Move documentation files using git mv (preserves history)
echo "📄 Moving documentation files..."
for file in ETHICS.md LIMITATIONS.md VALIDATION.md EDUCATION.md METHODOLOGY.md REPRODUCTION.md FAQ.md goals.md; do
    if [ -f "$file" ]; then
        git mv "$file" docs/
        echo "  ✓ Moved $file → docs/ (history preserved)"
    elif [ -f "docs/$file" ]; then
        echo "  ℹ️  $file already in docs/"
    fi
done

# Move HTML files to site using git mv
echo "🌐 Moving website files..."
for file in index.html goals.html analysis.html commented.html raw-code.html scale.html mandatory-review.html; do
    if [ -f "$file" ]; then
        git mv "$file" site/
        echo "  ✓ Moved $file → site/ (history preserved)"
    elif [ -f "site/$file" ]; then
        echo "  ℹ️  $file already in site/"
    fi
done

# Keep README.md and LICENSE.md in root
echo "📋 Root files..."
for file in README.md LICENSE.md; do
    if [ -f "$file" ]; then
        echo "  ✓ $file stays in root"
    fi
done

# Create or update .gitignore
echo "🚫 Creating .gitignore..."
if [ -f ".gitignore" ]; then
    echo "  ℹ️  .gitignore exists, creating .gitignore.new"
    cat > .gitignore.new << 'EOF'
# API keys and secrets
tools/api/.env
tools/api/*_key.txt
*.key
.anthropic_api_key

# Analysis working files
analysis/results/**/draft-*.md
analysis/results/**/temp-*.json
analysis/results/**/working-*.txt

# Personal notes (keep these private)
research/notes/personal/
project/feedback/private/

# macOS
.DS_Store
.AppleDouble
.LSOverride
._*

# Thumbnails
Thumbs.db

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# Temporary files
*.tmp
*.bak
~$*
*.log

# Python
__pycache__/
*.py[cod]
*$py.class
.venv/
venv/

# Node (if you add any JavaScript tools)
node_modules/
npm-debug.log

# Build outputs
site/build/
site/dist/

# Environment files
.env
.env.local
EOF
    echo "  ⚠️  Review .gitignore.new and merge manually"
else
    cat > .gitignore << 'EOF'
# API keys and secrets
tools/api/.env
tools/api/*_key.txt
*.key
.anthropic_api_key

# Analysis working files
analysis/results/**/draft-*.md
analysis/results/**/temp-*.json
analysis/results/**/working-*.txt

# Personal notes (keep these private)
research/notes/personal/
project/feedback/private/

# macOS
.DS_Store
.AppleDouble
.LSOverride
._*

# Thumbnails
Thumbs.db

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# Temporary files
*.tmp
*.bak
~$*
*.log

# Python
__pycache__/
*.py[cod]
*$py.class
.venv/
venv/

# Node (if you add any JavaScript tools)
node_modules/
npm-debug.log

# Build outputs
site/build/
site/dist/

# Environment files
.env
.env.local
EOF
    echo "✅ .gitignore created"
fi
echo ""

# Create placeholder README files for empty directories
echo "📝 Creating placeholder README files..."

cat > analysis/README.md << 'EOF'
# Analysis Directory

This directory contains:
- `prompts/` - Prompt templates used for AI analysis
- `results/` - Analysis outputs organized by project
- `validation/` - Validation checklists and processes

See METHODOLOGY.md in the docs folder for details.
EOF

cat > tools/README.md << 'EOF'
# Tools Directory

Scripts and utilities for:
- API interactions with Claude
- Batch analysis automation
- Report generation

See REPRODUCTION.md in the docs folder for usage instructions.
EOF

cat > research/README.md << 'EOF'
# Research Directory

Reference materials including:
- Academic papers on code quality and technical debt
- Industry reports and studies
- Personal research notes

Supporting evidence for the project's claims.
EOF

cat > project/README.md << 'EOF'
# Project Management

Project planning and tracking:
- `roadmap.md` - Future features and milestones
- `changelog.md` - Version history
- `todo.md` - Current tasks
- `feedback/` - User feedback and suggestions
EOF

echo "✅ Placeholder READMEs created"
echo ""

# Create initial project files
echo "📝 Creating project management files..."

if [ ! -f "project/roadmap.md" ]; then
cat > project/roadmap.md << 'EOF'
# Technical Debt Observatory Roadmap

## Phase 1: Proof of Concept ✅
- [x] Analyze single OpenSSL file
- [x] Create website showcase
- [x] Document methodology

## Phase 2: Validation (Current)
- [ ] Test with multiple AI models
- [ ] Gather community feedback
- [ ] Refine false positive detection

## Phase 3: Expansion
- [ ] Analyze full OpenSSL codebase
- [ ] Add 4-5 more critical projects
- [ ] Build automation scripts

## Phase 4: Public Dashboard
- [ ] Create interactive dashboard
- [ ] Weekly automated updates
- [ ] API access for security tools

## Phase 5: Community
- [ ] Contribution matching system
- [ ] Integration with OSS projects
- [ ] Education partnerships
EOF
fi

if [ ! -f "project/todo.md" ]; then
cat > project/todo.md << 'EOF'
# Current Tasks

## High Priority
- [x] Organize project structure
- [ ] Deploy website to GitHub Pages
- [ ] Create contribution guidelines

## Medium Priority
- [ ] Test analysis with GPT-4
- [ ] Document API usage patterns
- [ ] Create analysis template

## Low Priority
- [ ] Add syntax highlighting to code samples
- [ ] Create logo/branding
- [ ] Set up analytics (anonymous)

## Backlog
- [ ] Automate multi-file analysis
- [ ] Create CI/CD pipeline
- [ ] Build comparison tools
EOF
fi

if [ ! -f "project/changelog.md" ]; then
cat > project/changelog.md << 'EOF'
# Changelog

## [1.0.0] - 2025-01-XX

### Added
- Initial website with OpenSSL asn1parse.c analysis
- Comprehensive documentation system
- Methodology and validation process
- Educational curriculum proposal
- Vision for scaling to full codebases

### Changed
- Reorganized project structure for better maintainability
- Separated docs, site, and analysis directories

### Documentation
- ETHICS.md - Ethical guidelines
- LIMITATIONS.md - Known limitations
- VALIDATION.md - Validation process
- EDUCATION.md - CS curriculum proposal
- METHODOLOGY.md - Analysis methodology
- REPRODUCTION.md - How to reproduce
- FAQ.md - Frequently asked questions
EOF
fi

echo "✅ Project files created"
echo ""

# Create example prompt files
echo "📝 Creating example prompts..."

if [ ! -f "analysis/prompts/technical-debt-analysis.txt" ]; then
cat > analysis/prompts/technical-debt-analysis.txt << 'EOF'
Analyze this C code for technical debt. Focus on:

1. Security vulnerabilities (buffer overflows, integer overflows, unchecked inputs)
2. Memory safety issues (leaks, use-after-free, uninitialized variables)
3. Error handling gaps
4. Type safety problems
5. Code maintainability issues
6. Complexity and readability concerns

For each issue found:
- Specify exact line numbers
- Explain the problem clearly
- Assess severity (Critical/High/Medium/Low)
- Suggest specific remediation

[CODE HERE]
EOF
fi

if [ ! -f "analysis/prompts/code-documentation.txt" ]; then
cat > analysis/prompts/code-documentation.txt << 'EOF'
Add comprehensive comments to this C code in old-school System/370 style.

Include:
1. File header with purpose, I/O spec, variable dictionary
2. Function headers with complete documentation
3. Inline comments explaining WHY, not just WHAT
4. Technical debt markers
5. Security implications
6. Usage examples

[CODE HERE]
EOF
fi

echo "✅ Example prompts created"
echo ""

# Show what changed
echo "=================================================="
echo "✅ Organization Complete!"
echo ""
echo "📊 Git status:"
git status --short
echo ""
echo "🎯 Next steps:"
echo "  1. Review the changes: git status"
echo "  2. Review the differences: git diff --staged"
echo "  3. If happy, commit: bash commit-and-push.sh"
echo "  4. Or commit manually:"
echo "     git add ."
echo "     git commit -m 'Reorganize project structure'"
echo "     git push origin main"
echo ""
