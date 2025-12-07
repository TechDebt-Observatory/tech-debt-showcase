# Quick Start Guide: 4D Documentation Framework
## Tech Debt Observatory

**Time to read:** 5 minutes  
**Time to document first script:** 15-45 minutes (depending on complexity)

---

## The 10-Minute Version

### What is 4D Documentation?

A **lightweight framework** for documenting shell scripts and Python utilities with four key dimensions:

1. **@purpose** - What problem does this solve?
2. **@workflow** - How does it work?
3. **@dependencies** - What does it need?
4. **@gotchas** - What can go wrong?

### Why Use It?

- **Faster onboarding** - New contributors understand scripts in minutes
- **Fewer errors** - @gotchas prevent common mistakes
- **Easier maintenance** - Future you (or others) won't need to reverse-engineer
- **Better quality** - Forces you to think through edge cases

### How to Start?

**1. Pick your template:**
```bash
# For shell scripts
cp /tools/docs/templates/script_template.sh /tools/my-script.sh

# For Python
cp /tools/docs/templates/python_template.py /tools/my-script.py
```

**2. Fill in the 4D header:**
- What problem am I solving? (@purpose)
- What are the major steps? (@workflow)
- What do I need to run this? (@dependencies)
- What can go wrong? (@gotchas)

**3. Write your script with:**
- Phase headers for major sections
- Inline comments for complex logic
- Helpful error messages
- Completion message with next steps

**Done!** You now have a self-documenting script.

---

## First Script Walkthrough

Let's document a real script step by step.

### Example: `check-git-status.sh`

**What it does:** Shows git status, branch, and change counts

**Step 1: Add 4D header** (5 minutes)

```bash
#!/bin/bash
# check-git-status.sh - Quick git repository status overview
#
# @purpose: Display comprehensive git status at a glance
#   - Shows current branch and remote
#   - Counts unstaged, staged, and untracked files
#   - Displays directory tree for context
#
# @workflow:
#   1. Display git status (short format)
#   2. Show branch and remote info
#   3. Count changes by type
#   4. Display directory tree (2 levels)
#
# @dependencies:
#   - git (any version)
#   - tree command (optional - fallback to find)
#   - Must run from within git repository
#
# @gotchas:
#   - Fails if not in git repository (by design)
#   - Tree display limited to 2 levels for readability
#   - Untracked files can make output very long
#
# Usage: bash check-git-status.sh

set -e
```

**Step 2: Add validation** (3 minutes)

```bash
# Validate we're in a git repository
if [ ! -d ".git" ]; then
    echo "ERROR: Not in a git repository"
    echo "Please run from root of git repository"
    exit 1
fi
```

**Step 3: Implement with progress indicators** (5 minutes)

```bash
echo "📊 Git Status Overview"
echo "=" * 50

# Show status
echo "🔍 Changes:"
git status --short

# Show branch
echo ""
echo "🌿 Branch: $(git branch --show-current)"

# Count changes
UNSTAGED=$(git diff --name-only | wc -l | tr -d ' ')
STAGED=$(git diff --cached --name-only | wc -l | tr -d ' ')

echo ""
echo "📝 Summary:"
echo "  Unstaged: $UNSTAGED files"
echo "  Staged: $STAGED files"
```

**Step 4: Add helpful completion** (2 minutes)

```bash
echo ""
echo "Next steps:"
echo "  - Stage changes: git add <file>"
echo "  - Commit: git commit -m 'message'"
echo "  - Push: git push"
```

**Total time:** ~15 minutes for a simple script

---

## The Three Levels

Choose your documentation level based on script complexity:

### Level 1: Simple (<50 lines)

**Time:** 15 minutes  
**What:** Header-only 4D  
**Example:** `check-status.sh`

```bash
#!/bin/bash
# Brief description
# @purpose: [2-3 lines]
# @workflow: [3-5 steps]
# @dependencies: [key requirements]
# @gotchas: [main issues or "None known"]

# Minimal inline comments
```

### Level 2: Important (50-200 lines)

**Time:** 30-45 minutes  
**What:** Full 4D + phase headers  
**Example:** `analyze-comments.sh`

```bash
#!/bin/bash
# Full 4D header

# Configuration section

# ============================================
# PHASE 1: Phase Name
# @purpose: What this does
# @why: Why necessary
# @method: How it works
# @output: What it produces
# @gotcha: Issues specific to this phase
# ============================================

# Implementation
```

### Level 3: Critical (200+ lines)

**Time:** 45-90 minutes  
**What:** Comprehensive documentation  
**Reference:** `cve_2023_3446_forensics.sh`

```bash
#!/bin/bash
# Comprehensive 4D header

# Configuration with inline docs

# Phase headers with full @purpose/@why/@method/@output/@gotcha

# Function documentation blocks

# "WHY" comments for complex logic

# Error handling with recovery guidance

# Completion message with next steps
```

---

## Common Patterns

### Configuration Variables

```bash
# Configuration
REPO_PATH="/path/to/repo"  # Local git clone location
OUTPUT_DIR="/path/to/output"  # Where results go
TIMEOUT=30  # Maximum seconds to wait
```

### Phase Headers

```bash
# ============================================
# PHASE 1: VALIDATION
# @purpose: Check prerequisites before processing
# @why: Early failure prevents wasted time
# @method: Test each requirement, fail on first error
# @output: None (raises error or continues)
# @gotcha: Creates directories if missing (by design)
# ============================================
```

### Progress Indicators

```bash
echo "[PHASE 1] Validating inputs..."
# ... work happens ...
echo "  ✓ Validation complete"
```

### Error Messages

```bash
if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: Configuration not found: $CONFIG_FILE"
    echo ""
    echo "Create it with: cp config.example $CONFIG_FILE"
    exit 1
fi
```

### Completion Messages

```bash
echo ""
echo "====================================="
echo "PROCESSING COMPLETE"
echo "====================================="
echo ""
echo "Output: $OUTPUT_FILE"
echo ""
echo "Next steps:"
echo "  1. Review: cat $OUTPUT_FILE"
echo "  2. Validate: ./validate.sh"
echo "  3. Deploy: ./deploy.sh"
```

---

## Gotchas Cheatsheet

**Good gotchas explain:**
- What breaks (common failure modes)
- How to fix it (workaround or solution)
- Performance limits (scale constraints)
- Compatibility issues (OS/version-specific)
- Maintenance warnings (future developer notes)

**Examples of good @gotchas:**

```bash
# @gotchas:
#   Issue 1: Script fails if repo has uncommitted changes
#     Workaround: Run 'git stash' before executing
#   Issue 2: Large files (>10MB) cause timeout
#     Mitigation: Increase TIMEOUT_SECONDS variable
#   Issue 3: Requires bash 4.0+ for associative arrays
#     Fix: Update bash on macOS (ships with bash 3.2)
#   Performance: Processing 1000+ files takes ~5 minutes
#   Compatibility: Needs GNU grep (not BSD grep)
```

**Bad gotchas to avoid:**

```bash
# @gotchas: None  ❌ (Every script has edge cases!)
# @gotchas: May have issues  ❌ (Too vague!)
# @gotchas: Sometimes breaks  ❌ (No solution!)
```

---

## Documentation Workflow

### For New Scripts

1. **Start with template** - Copy appropriate template
2. **Fill header first** - Complete all 4D dimensions
3. **Write implementation** - Add phase headers as you go
4. **Test and update** - Find gotchas, update documentation
5. **Add to tracker** - Update DOCUMENTATION_STATUS.md

### For Existing Scripts

1. **Review complexity** - Determine Level 1/2/3
2. **Add header** - Start with @purpose and @dependencies
3. **Document phases** - Add phase headers if Level 2+
4. **Capture gotchas** - Document known issues
5. **Update tracker** - Mark in progress or complete

---

## Quality Checklist

**Before committing a script, verify:**

**Header:**
- [ ] All 4D dimensions present
- [ ] Purpose explains WHAT and WHY
- [ ] Dependencies list ALL requirements
- [ ] Gotchas document known issues
- [ ] Usage examples provided

**Body:**
- [ ] Configuration variables explained
- [ ] Major sections have phase headers (if Level 2+)
- [ ] Complex logic has "WHY" comments
- [ ] Error messages help user recover

**Completion:**
- [ ] Lists output locations
- [ ] Summarizes results
- [ ] Provides next steps

---

## When You Get Stuck

### "I don't know what can go wrong!"

**Run the script and watch for:**
- Error messages you get
- Assumptions about file paths
- Commands that might not exist
- Edge cases in inputs

**Add these to @gotchas!**

### "The workflow is obvious!"

**Good sign!** But still document it.

Future you (or others) may not find it obvious. Think:
- What are the major phases?
- Are there any decision points?
- What order must things happen in?

### "I don't have time for this!"

**Start small:**
- Just add @purpose and @dependencies (5 min)
- Mark as "In Progress" in tracker
- Come back later for full documentation

**Partial documentation > no documentation**

---

## Resources

### Documentation
- **Full Standard:** `/methodology/script-documentation-standard.md`
- **Progress Tracker:** `/tools/DOCUMENTATION_STATUS.md`
- **Implementation Summary:** `/IMPLEMENTATION_SUMMARY.md`

### Templates
- **Shell Scripts:** `/tools/docs/templates/script_template.sh`
- **Python:** `/tools/docs/templates/python_template.py`

### Examples
- **Gold Standard:** `/tools/cve_2023_3446_forensics.sh`
- **Good Foundation:** `/tools/analyze-comments.sh`

---

## Next Steps

1. **Read this guide** (you're here! ✅)

2. **Pick one script to document:**
   - Start with high-priority if you're confident
   - Or pick a simple script to practice

3. **Copy template and fill in:**
   ```bash
   cp /tools/docs/templates/script_template.sh /tools/my-script.sh
   ```

4. **Follow examples:**
   - Look at `cve_2023_3446_forensics.sh` for reference
   - Check documentation standard for details

5. **Update tracker:**
   - Mark script as "In Progress"
   - Update when complete

6. **Iterate:**
   - Add gotchas as you discover issues
   - Improve based on feedback

---

## FAQ

**Q: How long does documentation take?**  
A: 15 min (simple) to 90 min (complex). Average ~30 min.

**Q: Should I document helper scripts?**  
A: Yes! Use Level 1 (header-only). Takes ~15 min.

**Q: What if script changes?**  
A: Update documentation at same time. Keep in sync.

**Q: Can I skip gotchas if nothing goes wrong?**  
A: No! Even simple scripts have edge cases. Document them.

**Q: Do I need all 4D dimensions?**  
A: Yes. Even if brief (2-3 lines), all 4 add value.

**Q: What about one-liners?**  
A: If it's in version control, document it. Header only.

---

## Success Story

**Before 4D:**
```bash
#!/bin/bash
# Extract CVE data

REPO=/path/to/repo
git log --grep CVE > output.txt
```

**User tries to run it:**
- Where's /path/to/repo?
- What if repo doesn't exist?
- What format is output.txt?
- Now what?

**After 4D:**
```bash
#!/bin/bash
# extract-cve-data.sh - Extract CVE commits from repository
#
# @purpose: Generate list of CVE-related commits for analysis
# @workflow: Search git history, format results, save to file
# @dependencies: git 2.0+, write access to current directory
# @gotchas: Fails if REPO_PATH doesn't exist - create first

REPO_PATH="/path/to/openssl"  # Must be git repository
OUTPUT_FILE="cve_commits_$(date +%Y%m%d).txt"

# Validation
if [ ! -d "$REPO_PATH/.git" ]; then
    echo "ERROR: Git repository not found: $REPO_PATH"
    echo "Clone first: git clone URL $REPO_PATH"
    exit 1
fi

cd "$REPO_PATH"
git log --grep="CVE-" --format="%H|%ai|%s" > "$OUTPUT_FILE"

echo "✓ Saved to: $OUTPUT_FILE"
echo "Next: Review file and run analysis"
```

**Result:**
- User knows exactly what to do
- Script validates prerequisites
- Helpful error messages guide recovery
- Clear next steps provided

**That's the power of 4D documentation!** 🎉

---

**Now go document your first script!**

Track your progress in `/tools/DOCUMENTATION_STATUS.md`

Questions? See the full documentation standard.

---

**File:** `/QUICK_START.md`  
**Version:** 1.0  
**Updated:** 2024-11-29
