# Shell Script 4D Documentation Standard
## Tech Debt Observatory Project

**Version:** 1.0  
**Date:** 2025-11-29  
**Author:** Basil Addington  
**Purpose:** Lightweight documentation framework for shell scripts in the Tech Debt Observatory project

---

## Table of Contents

1. [Overview](#overview)
2. [The 4D Framework](#the-4d-framework)
3. [Documentation Levels](#documentation-levels)
4. [Header Block Structure](#header-block-structure)
5. [Phase Documentation](#phase-documentation)
6. [Inline Comment Standards](#inline-comment-standards)
7. [Configuration Documentation](#configuration-documentation)
8. [Error Handling Documentation](#error-handling-documentation)
9. [Completion Messages](#completion-messages)
10. [Python Adaptation](#python-adaptation)
11. [Examples](#examples)
12. [Quick Reference](#quick-reference)

---

## Overview

### Philosophy

This 4D documentation standard is a **lightweight adaptation** of the 6D framework used for C/C++ codebases. While C code requires comprehensive documentation covering architecture, security, and deep technical debt, **shell scripts need focused, practical documentation** that helps maintainers understand:

- **What problem does this solve?** (@purpose)
- **How does it work?** (@workflow)
- **What does it need?** (@dependencies)
- **What can go wrong?** (@gotchas)

### Relationship to 6D Framework

**6D Framework (C/C++ code):**
1. @intent - Function purpose and expected behavior
2. @history - Evolution of implementation
3. @deps - External dependencies and relationships
4. @techdebt - Known issues and modernization barriers
5. @arch - Architectural context and design patterns
6. @security - Security implications and attack vectors

**4D Framework (Shell scripts):**
1. @purpose - Problem being solved *(maps to @intent)*
2. @workflow - High-level execution steps *(maps to @intent + @arch)*
3. @dependencies - Requirements and environment *(maps to @deps)*
4. @gotchas - Known issues and edge cases *(maps to @techdebt + @security)*

The 4D framework **consolidates** rather than reduces - it combines related concerns into practical categories for scripts.

---

## The 4D Framework

### 1. @purpose

**What problem does this script solve?**

This dimension captures the script's reason for existence and the specific use case it addresses.

**Components:**
- **Problem statement** - What pain point does this solve?
- **Intended use case** - When should this script be used?
- **Output/deliverables** - What does it produce?
- **Context** - Where does this fit in the larger project?

**Example:**
```bash
# @purpose: Extract forensic evidence from CVE-patched OpenSSL files
#   Problem: Manually collecting git commits, diffs, and metadata is time-consuming
#   Use case: NTSB-style investigation of historical vulnerabilities
#   Output: Complete evidence package in structured directory format
#   Context: Phase 1 of Tech Debt Observatory CVE validation methodology
```

### 2. @workflow

**How does this script accomplish its goal?**

This dimension provides a high-level execution roadmap without implementation details.

**Components:**
- **Major phases** - Sequential steps in the process
- **Branching logic** - Decision points and conditional flows
- **Data transformations** - How inputs become outputs
- **Integration points** - Where this connects to other scripts/tools

**Example:**
```bash
# @workflow: Five-phase forensic extraction process
#   Phase 1: Extract commit metadata from git history
#   Phase 2: Checkout vulnerable version (pre-patch)
#   Phase 3: Generate diff analysis (unified, word-diff, stats)
#   Phase 4: Identify vulnerability locations via pattern matching
#   Phase 5: Generate investigation summary report
#   └─> Each phase validates previous outputs before proceeding
```

### 3. @dependencies

**What does this script need to run?**

This dimension catalogs all external requirements and environmental assumptions.

**Components:**
- **System requirements** - OS, shell version, utilities
- **External tools** - Required commands and versions
- **File paths** - Expected directory structure
- **Environment variables** - Required/optional env vars
- **Permissions** - File/directory access needs
- **Network access** - External resources or APIs

**Example:**
```bash
# @dependencies: macOS/Linux environment with git
#   Required tools:
#     - bash 4.0+ (for associative arrays)
#     - git 2.0+ (for forensic commands)
#     - awk, grep, wc (standard POSIX utilities)
#   File structure:
#     - /local-repos/openssl (git clone required first)
#     - /case-studies/CVE-* (created by script)
#   Permissions:
#     - Read access to OpenSSL repository
#     - Write access to case-studies directory
#   Network: None (operates on local git repository)
```

### 4. @gotchas

**What can go wrong and how to handle it?**

This dimension captures **known issues, edge cases, and maintenance warnings** - the tribal knowledge that prevents future headaches.

**Components:**
- **Common failure modes** - Typical ways the script breaks
- **Edge cases** - Unusual inputs or conditions
- **Performance limitations** - Scale constraints
- **Compatibility issues** - Known incompatibilities
- **Maintenance warnings** - Things future maintainers should know
- **Recovery procedures** - How to fix common problems

**Example:**
```bash
# @gotchas: Known issues and edge cases
#   Issue 1: Script fails if OpenSSL repo has uncommitted changes
#     Workaround: Add 'git stash' before checkout operations
#   Issue 2: Large diffs (>10MB) can hang diff generation
#     Mitigation: Add timeout to git diff commands
#   Issue 3: CVE format changes break grep patterns
#     Fix: Update regex in find_cve_commits() function
#   Issue 4: Duplicate CVE numbers create directory conflicts
#     Behavior: Script appends "-N" suffix to directory names
#   Performance: Analysis of 1000+ commits takes ~5 minutes
#   Compatibility: Requires GNU grep (not BSD grep on old macOS)
```

---

## Documentation Levels

The 4D framework applies to scripts at **three complexity levels**:

### Level 1: Simple Scripts (<50 lines)

**Documentation: Header-only 4D**

Simple utility scripts get a **concise header block** with all four dimensions, but minimal inline comments.

**Criteria:**
- Single responsibility
- Linear execution (no complex branching)
- Few or no configuration variables
- Obvious code flow

**Example scripts:**
- `check-status.sh` - Git status display
- `commit-and-push.sh` - Automated git commit/push

**Documentation pattern:**
```bash
#!/bin/bash
# Script name - Brief one-line description
#
# @purpose: [2-3 lines max]
# @workflow: [3-5 step list]
# @dependencies: [Key requirements only]
# @gotchas: [Top 2-3 issues if any, or "None known"]
#
# Usage: ./script.sh [args]

set -e  # Standard error handling

# Minimal inline comments for non-obvious sections only
```

### Level 2: Important Scripts (50-200 lines)

**Documentation: Basic 4D + phase headers**

Medium-complexity scripts get **full 4D headers** plus **phase documentation blocks** for major sections.

**Criteria:**
- Multiple distinct phases
- Configuration variables
- Some error handling
- Moderate branching logic

**Example scripts:**
- `analyze-comments.sh` - Comment coverage analysis
- `quickstart.sh` - Quick start helper
- `organize-files.sh` - File organization

**Documentation pattern:**
```bash
#!/bin/bash
# Full header with detailed 4D documentation

# ============================================
# PHASE N: Phase Name
# @purpose: What this phase does
# @why: Why this phase is necessary
# @method: How it accomplishes the goal
# @output: What it produces
# @gotcha: Known issues specific to this phase
# ============================================

[Phase code with targeted inline comments]
```

### Level 3: Critical Scripts (200+ lines)

**Documentation: Full 4D + comprehensive inline**

Complex, critical scripts get **complete documentation** at all levels - headers, phases, functions, and complex logic blocks.

**Criteria:**
- Mission-critical functionality
- Complex algorithms or data flows
- Multiple configuration sections
- Extensive error handling
- Integration with external systems

**Example scripts:**
- `cve_2023_3446_forensics.sh` - CVE forensic extraction
- `prepare-worst-cve.sh` - CVE preparation
- `setup-pipeline.sh` - Pipeline setup

**Documentation pattern:**
```bash
#!/bin/bash
# Comprehensive file-level 4D header

# ===========================================
# CONFIGURATION SECTION
# Document each variable with inline comment
# ===========================================

# Phase headers with full @purpose/@why/@method/@output/@gotcha

# Function documentation blocks (for complex functions)

# "WHY" comments for non-obvious logic

# Error handling with explanatory comments

# Completion messages with next steps
```

---

## Header Block Structure

Every script starts with a **comprehensive header block** following this template:

```bash
#!/bin/bash
################################################################################
# Script Title - Brief Description (One Line)
################################################################################
#
# @purpose: What problem does this solve?
#   - Primary use case
#   - Expected output/deliverables
#   - Context in larger project
#
# @workflow: High-level execution flow
#   Phase 1: First major step
#   Phase 2: Second major step
#   Phase 3: Third major step
#   [etc.]
#
# @dependencies: External requirements
#   System requirements:
#     - OS version, shell version
#     - Required command-line tools
#   File structure:
#     - Expected directories and files
#   Environment variables:
#     - Required env vars (if any)
#   Permissions:
#     - Access requirements
#   Network:
#     - External connectivity needs (if any)
#
# @gotchas: Known issues and edge cases
#   Issue 1: [Description]
#     Workaround: [Solution]
#   Issue 2: [Description]
#     Mitigation: [Solution]
#   [Performance notes]
#   [Compatibility warnings]
#
# USAGE:
#   ./script-name.sh [arguments]
#   
#   Examples:
#     ./script-name.sh input.txt
#     ./script-name.sh --flag value
#
# RELATED SCRIPTS:
#   - other-script.sh - What it does
#   - another-script.sh - What it does
#
################################################################################

set -e  # Exit on error (or set -euo pipefail for stricter mode)
```

**Header sections:**

1. **Shebang + Title Block**
   - `#!/bin/bash` - Interpreter
   - Title and brief description
   - Clear separation with `####`

2. **4D Dimensions**
   - Each dimension clearly labeled
   - Structured, scannable format
   - Concrete, actionable information

3. **Usage Section**
   - Command-line syntax
   - Parameter descriptions
   - Concrete examples

4. **Related Scripts**
   - Links to other relevant scripts
   - Brief context for each

5. **Error Handling Declaration**
   - `set -e` or `set -euo pipefail`
   - Documents script's error policy

---

## Phase Documentation

For **Level 2 and Level 3 scripts**, major phases get dedicated documentation blocks:

```bash
# ============================================
# PHASE N: Phase Name
# @purpose: Specific goal of this phase
# @why: Why this phase is necessary
# @method: Algorithm or approach used
# @output: What this phase produces
# @gotcha: Known issues specific to this phase
# ============================================

echo "[PHASE N] Starting phase name..."

[Phase implementation]

echo "  ✓ Phase N complete"
```

**Phase header guidelines:**

- **Clear boundaries:** Use visual separators (`====`)
- **Numbered phases:** Sequential numbering for readability
- **Descriptive names:** Phase name indicates what it does
- **Five attributes:** @purpose, @why, @method, @output, @gotcha
- **Progress indicators:** Echo statements for user feedback

**When to use phase headers:**

- Script has 3+ distinct logical sections
- Each section has different inputs/outputs
- Sections could theoretically be separate scripts
- Sequential execution with dependencies between phases

**Example:**

```bash
# ============================================
# PHASE 3: DIFF ANALYSIS
# @purpose: Generate comprehensive diff analysis between vulnerable and patched versions
# @why: Multiple diff formats reveal different aspects of the vulnerability fix
# @method: Use git diff with various flags (unified, word-diff, stats)
# @output: Three diff files in analysis/diffs/ directory
# @gotcha: Large diffs can hang - consider adding timeout for files >10MB
# ============================================

echo "[PHASE 3] Generating diff analysis..."

# Generate unified diff
git diff "$PARENT_COMMIT" "$PATCH_COMMIT" -- "$TARGET_FILE" > "$OUTPUT_DIR/analysis/diffs/unified.diff"

# Generate word-level diff
git diff --word-diff "$PARENT_COMMIT" "$PATCH_COMMIT" -- "$TARGET_FILE" > "$OUTPUT_DIR/analysis/diffs/word-diff.txt"

# Generate statistics
git diff --stat "$PARENT_COMMIT" "$PATCH_COMMIT" -- "$TARGET_FILE" > "$OUTPUT_DIR/analysis/diffs/stats.txt"

echo "  ✓ Diff analysis complete"
```

---

## Inline Comment Standards

### Configuration Variables

Every configuration variable gets an **inline explanation**:

```bash
# Configuration - UPDATED FOR NEW PROJECT STRUCTURE
REPO_PATH="/Users/basiladdington/Projects/tech-debt-showcase/local-repos/openssl"  # Local git clone location
OUTPUT_DIR="/Users/basiladdington/Projects/tech-debt-showcase/case-studies/CVE-2023-3446-dhtest"  # Evidence output directory
PATCH_COMMIT="9e0094e2aa1b3428a12d5095132f133c078d3d3d"  # Git commit hash that fixed the vulnerability
TARGET_FILE="crypto/dh/dh_check.c"  # Vulnerable file within OpenSSL codebase
BASENAME=$(basename "$TARGET_FILE")  # Extract filename for output naming
```

**Variable comment format:**
- Placed on same line as variable (for short comments)
- Explains **purpose** not **type** (type is obvious from value)
- Includes **context** when path or value is non-obvious

### Complex Logic

For non-obvious logic, use **"WHY" comments** that explain reasoning:

```bash
# WHY: We need the parent commit (one before the patch) because that contains
# the vulnerable code. The patch commit itself has the fix already applied.
PARENT_COMMIT=$(git rev-parse "$PATCH_COMMIT^")

# WHY: Multiple comment line counting methods because:
#   - Single-line comments: // and single-line /* */
#   - Multi-line blocks: /* ... */ spanning multiple lines
#   - Need to count each separately to avoid double-counting
local single_comments=$(grep -c "^[[:space:]]*//\|^[[:space:]]*/\*.*\*/" "$file" || true)
```

**"WHY" comment guidelines:**
- Start with "WHY:" to make it scannable
- Explain **decision rationale** not **implementation details**
- Useful for future maintainers who might question the approach
- Include when:
  - Logic is counterintuitive
  - Alternative approaches exist but were rejected
  - Edge cases require special handling
  - Historical context matters

### Function Documentation

For complex functions in scripts, use **function documentation blocks**:

```bash
################################################################################
# FUNCTION: calculate_comment_ratio
#
# @purpose: Calculate comment-to-code ratio for a C source file
#
# @params:
#   $1 - Full path to the C file to analyze
#
# @output:
#   Echoes: "total_lines|comment_lines|code_lines|ratio"
#   Example: "348|17|280|6.07"
#
# @algorithm:
#   1. Count total lines with wc
#   2. Count single-line comments (// and single-line /* */)
#   3. Count multi-line comment blocks (/* ... */)
#   4. Calculate code lines = total - blank - comments
#   5. Calculate ratio = (comments / code) * 100
#
# @gotchas:
#   - Returns "0|0|0|0.00" if file doesn't exist
#   - Prevents negative code line counts
#   - Handles division by zero
################################################################################
calculate_comment_ratio() {
    local file="$1"
    
    # Validation: Check file exists
    if [[ ! -f "$file" ]]; then
        echo "0|0|0|0.00"
        return
    fi
    
    # [Implementation]
}
```

**When to document functions:**
- Function is >20 lines
- Function has complex algorithm
- Function is called from multiple places
- Function has non-obvious parameters or return values

---

## Configuration Documentation

Configuration sections deserve **dedicated documentation blocks**:

```bash
# ===========================================
# CONFIGURATION SECTION
# @purpose: Define paths and settings for CVE forensic extraction
# @gotcha: All paths must be absolute - script does not use relative paths
# ===========================================

# Repository paths (must be git clones)
REPO_PATH="/Users/basiladdington/Projects/tech-debt-showcase/local-repos/openssl"
OUTPUT_DIR="/Users/basiladdington/Projects/tech-debt-showcase/case-studies/CVE-2023-3446-dhtest"

# CVE-specific metadata
PATCH_COMMIT="9e0094e2aa1b3428a12d5095132f133c078d3d3d"  # Commit that fixed CVE-2023-3446
TARGET_FILE="crypto/dh/dh_check.c"  # File that was vulnerable

# Derived variables (calculated from above)
BASENAME=$(basename "$TARGET_FILE")  # Used for output file naming
```

**Configuration documentation includes:**
- **Section header** with @purpose and @gotcha
- **Grouped variables** by related functionality
- **Inline comments** for each variable
- **Separation** between configured and derived variables

---

## Error Handling Documentation

Error handling deserves **explanatory comments**:

```bash
# Validation: Verify repository exists before proceeding
# WHY: Early failure is better than cryptic git errors later
if [ ! -d "$REPO_PATH" ]; then
    echo "ERROR: OpenSSL repository not found at: $REPO_PATH"
    echo ""
    echo "Please clone the repository first:"
    echo "  cd /Users/basiladdington/Projects/tech-debt-showcase/local-repos"
    echo "  git clone https://github.com/openssl/openssl.git"
    echo ""
    exit 1
fi

# Validation: Check write permissions on output directory
# WHY: Better to fail early than after 5 minutes of processing
if [ ! -w "$(dirname "$OUTPUT_DIR")" ]; then
    echo "ERROR: No write permission for output directory"
    exit 1
fi
```

**Error handling documentation:**
- **Validation comments** explain what is being checked
- **"WHY" comments** explain why the check matters
- **Helpful error messages** guide user toward solution
- **Exit codes** should be consistent (1 for user errors, 2 for system errors)

---

## Completion Messages

Scripts should end with **helpful completion messages**:

```bash
# ============================================
# COMPLETION
# ============================================
echo ""
echo "====================================="
echo "EXTRACTION COMPLETE"
echo "====================================="
echo ""
echo "Output directory: $OUTPUT_DIR"
echo ""
echo "Key files:"
echo "  • analysis/INVESTIGATION_SUMMARY.md - Full crash report"
echo "  • original/$BASENAME - Vulnerable code (control group baseline)"
echo "  • analysis/diffs/unified.diff - Exact changes from patch"
echo ""
echo "Next steps:"
echo "  1. Create 6D documentation: documented/$BASENAME"
echo "  2. Run AI tests using methodology/cve-investigation-framework/"
echo "  3. Collect results in ai-detection-results/"
echo ""
```

**Completion message guidelines:**
- **Clear visual separator** to indicate completion
- **Output location** - where results were written
- **Key files** - most important outputs with brief descriptions
- **Next steps** - what user should do next
- **Use bullet points** (•) for readability

---

## Python Adaptation

For Python scripts in the project, adapt the 4D framework to **Python docstrings**:

```python
#!/usr/bin/env python3
"""
Module Title - Brief Description

@purpose: What problem does this solve?
    - Primary use case
    - Expected output/deliverables
    - Context in larger project

@workflow: High-level execution flow
    Phase 1: First major step
    Phase 2: Second major step
    Phase 3: Third major step

@dependencies: External requirements
    System requirements:
        - Python version
        - Required packages (requirements.txt)
    File structure:
        - Expected directories and files
    Environment variables:
        - Required env vars (if any)

@gotchas: Known issues and edge cases
    Issue 1: [Description]
        Workaround: [Solution]
    Issue 2: [Description]
        Mitigation: [Solution]

Usage:
    python script.py [arguments]
    
    Examples:
        python script.py input.txt
        python script.py --flag value

Related modules:
    - other_module.py - What it does
"""

import os
import sys
import json

# Configuration section
BASE_DIR = os.path.expanduser("~/Shared/analysis")  # Analysis workspace root
REPO_NAME = sys.argv[1] if len(sys.argv) > 1 else None  # Target repository name

def main():
    """
    Main execution function.
    
    @purpose: Orchestrate the analysis pipeline
    @workflow:
        1. Validate inputs
        2. Load bundle data
        3. Process analysis results
        4. Write output
    @returns: None (writes to disk)
    @raises: ValueError if inputs are invalid
    """
    # [Implementation]
    pass

if __name__ == "__main__":
    main()
```

**Python-specific conventions:**

1. **Module docstring** at file top (triple-quoted)
2. **4D framework** adapted to Python docstring style
3. **Function docstrings** with @purpose, @workflow, @returns, @raises
4. **Inline comments** for complex logic (same as shell scripts)
5. **Type hints** encouraged but not required

---

## Examples

### Example 1: Simple Script (Level 1)

**File:** `check-status.sh`

```bash
#!/bin/bash
# check-status.sh - Quick git repository status check
#
# @purpose: Display comprehensive git status at a glance
#   - Show branch, uncommitted changes, and remote info
#   - Help users understand repository state before commits
#
# @workflow:
#   1. Display git status (short format)
#   2. Show current branch and remote
#   3. Count unstaged, staged, and untracked files
#   4. Display directory tree
#
# @dependencies:
#   - git (any version)
#   - tree command (optional - fallback to find)
#
# @gotchas:
#   - Requires being run from within a git repository
#   - Tree display limited to 2 levels for readability
#
# Usage: bash check-status.sh

set -e

echo "📊 Technical Debt Observatory - Status Check"
echo "=================================================="
echo ""

# Git status
echo "🔍 Git Status:"
git status --short
echo ""

# [Rest of implementation with minimal inline comments]
```

### Example 2: Important Script (Level 2)

**File:** `analyze-comments.sh`

```bash
#!/bin/bash
################################################################################
# CVE-Patched File Comment Ratio Analyzer for OpenSSL
################################################################################
#
# @purpose: Identify least-documented security-critical OpenSSL files
#   - Analyzes files that were patched for CVEs in the last 2 years
#   - Calculates comment-to-code ratios for each file
#   - Produces CSV ranked by documentation quality
#   - Enables targeted documentation efforts on high-risk, low-doc files
#
# @workflow: Three-phase analysis process
#   Phase 1: Analyze known CVE commits from hardcoded list
#   Phase 2: Search git history for additional CVE commits
#   Phase 3: Generate sorted CSV and summary statistics
#   └─> Each file analyzed once (deduplication via associative array)
#
# @dependencies:
#   System requirements:
#     - bash 4.0+ (for associative arrays)
#     - git 2.0+ (for commit searching)
#     - awk, grep, bc (standard POSIX utilities)
#   File structure:
#     - $HOME/Shared/analysis/repos/openssl (cloned git repository)
#     - $HOME/Shared/cve_comment_analysis (output directory, created by script)
#   Permissions:
#     - Read access to OpenSSL repository
#     - Write access to output directory
#   Network: None (operates on local git clone)
#
# @gotchas:
#   Issue 1: Requires bash 4.0+ for associative arrays
#     Workaround: Update bash on macOS (ships with ancient bash 3.2)
#   Issue 2: Multi-line comment detection can miss nested comments
#     Impact: Comment ratios may be slightly underestimated
#   Issue 3: Large repos (10k+ files) take 5-10 minutes
#     Performance: Script optimized to analyze only CVE-touched files
#   Issue 4: CVE_PATTERNS list may need updates for new CVEs
#     Maintenance: Update array when analyzing newer date ranges
#
# USAGE:
#   ./analyze_cve_comments.sh [openssl_repo_path]
#   
#   Examples:
#     ./analyze_cve_comments.sh
#     ./analyze_cve_comments.sh /custom/path/to/openssl
#
# OUTPUT:
#   CSV file: $HOME/Shared/cve_comment_analysis/cve_files_by_comment_ratio.csv
#   Format: file_path,total_lines,comment_lines,code_lines,comment_ratio_pct,cve_numbers
#
# RELATED SCRIPTS:
#   - prepare-worst-cve.sh - Takes output CSV and prepares worst file for analysis
#
################################################################################

set -euo pipefail

# ===========================================
# CONFIGURATION
# ===========================================

# Input/Output Paths
OPENSSL_REPO="${1:-$HOME/Shared/analysis/repos/openssl}"  # OpenSSL git clone location
OUTPUT_DIR="$HOME/Shared/cve_comment_analysis"  # Analysis output directory
RESULTS_FILE="$OUTPUT_DIR/cve_files_by_comment_ratio.csv"  # Final CSV output
TEMP_DIR="$OUTPUT_DIR/temp"  # Temporary working directory

# CVE Data - Known commits from 2023-2025 (manually curated)
# Format: "commit_hash|CVE_number|description"
declare -a CVE_COMMITS=(
    "738d4f9fdeaad57660dcba50a619fafced3fd5e9|CVE-2024-12797|RPK authentication failure"
    # [More entries...]
)

# CVE Patterns - Additional CVEs to search for via git log
declare -a CVE_PATTERNS=(
    "CVE-2024-12797"
    "CVE-2023-3446"
    # [More entries...]
)

# ============================================
# FUNCTION: calculate_comment_ratio
# @purpose: Calculate comment-to-code ratio for a C source file
# [Full function documentation as shown earlier]
# ============================================
calculate_comment_ratio() {
    # [Implementation]
}

# ============================================
# PHASE 1: KNOWN CVE COMMITS
# @purpose: Analyze files from manually curated CVE list
# @why: Ensures critical CVEs are covered even if git grep fails
# @method: Iterate through CVE_COMMITS array, analyze each modified file
# @output: Populates analyzed_files associative array
# @gotcha: Duplicate files across CVEs are deduplicated
# ============================================

echo "Phase 1: Analyzing known CVE commits..."

# [Implementation]

# ============================================
# PHASE 2: GIT HISTORY SEARCH
# [Similar phase documentation]
# ============================================

# [Implementation]

# ============================================
# PHASE 3: RESULTS GENERATION
# [Similar phase documentation]
# ============================================

# [Implementation]
```

### Example 3: Critical Script (Level 3)

**File:** `cve_2023_3446_forensics.sh` (already well-documented - see reference file)

This script demonstrates:
- ✅ Complete 4D header
- ✅ Configuration section with inline variable docs
- ✅ Phase headers with @purpose/@why/@method/@output/@gotcha
- ✅ Validation with helpful error messages
- ✅ Progress indicators throughout
- ✅ Comprehensive completion message with next steps

---

## Quick Reference

### Checklist for New Scripts

**Before writing a script:**
- [ ] Determine documentation level (1, 2, or 3)
- [ ] Review appropriate template
- [ ] Identify all 4D dimensions

**While writing:**
- [ ] Add 4D header block at top
- [ ] Document configuration variables inline
- [ ] Add phase headers for major sections
- [ ] Use "WHY" comments for complex logic
- [ ] Add validation with helpful error messages

**Before committing:**
- [ ] Review @gotchas - did you find new edge cases?
- [ ] Test completion message - are next steps clear?
- [ ] Check that a newcomer could understand the workflow
- [ ] Verify all dependencies are documented

### Common Patterns

**Error checking:**
```bash
# Validation: Check required file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: Configuration file not found: $CONFIG_FILE"
    echo "Please create it with: cp config.example config.txt"
    exit 1
fi
```

**Progress indicators:**
```bash
echo "[PHASE 1] Starting data extraction..."
# [Work happens]
echo "  ✓ Extracted 47 records"
```

**Next steps:**
```bash
echo "Next steps:"
echo "  1. Review output: cat $OUTPUT_FILE"
echo "  2. Run analysis: ./analyze-results.sh"
echo "  3. Generate report: ./make-report.sh"
```

### Anti-Patterns (What NOT to Do)

❌ **Don't over-comment obvious code:**
```bash
# BAD: Stating the obvious
echo "Hello"  # Prints "Hello" to the screen
```

❌ **Don't skip @gotchas:**
```bash
# BAD: No gotchas documented
# @gotchas: None
```
Every script has edge cases - document them!

❌ **Don't use vague @purpose statements:**
```bash
# BAD: Too vague
# @purpose: Process files
```
Be specific about WHAT problem and WHY.

❌ **Don't omit next steps:**
```bash
# BAD: No guidance
echo "Done."
```
Always tell users what to do next.

---

## Maintenance Notes

This standard is **version 1.0** and should evolve based on:

1. **Feedback from script users** - Are the docs actually helpful?
2. **New edge cases discovered** - Update @gotchas sections
3. **Pattern emergence** - Document common patterns as templates
4. **Tool changes** - Update @dependencies as tools evolve

**To propose changes:**
1. Open an issue describing the problem
2. Provide example of current vs. proposed documentation
3. Explain benefit to future maintainers

---

## Conclusion

The 4D documentation framework makes shell scripts **self-documenting** without adding excessive overhead. By focusing on four critical dimensions - purpose, workflow, dependencies, and gotchas - we enable:

- **Faster onboarding** for new contributors
- **Reduced maintenance burden** through clear documentation
- **Better error handling** with helpful guidance
- **Tribal knowledge preservation** via @gotchas
- **Easier debugging** when things go wrong

Use this standard for **all new scripts** in the Tech Debt Observatory project, and gradually migrate existing scripts during normal maintenance.

**Remember:** The goal is not perfection, but **comprehension**. Document enough that your future self (or a new contributor) can understand and modify the script without reverse-engineering it.

---

**Document Version:** 1.0  
**Last Updated:** 2024-11-29  
**Author:** Baz  
**License:** Same as Tech Debt Observatory project
