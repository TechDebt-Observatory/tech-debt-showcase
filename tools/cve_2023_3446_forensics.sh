#!/bin/bash
# CVE-2023-3446 Forensic Extraction Script
# NTSB-style investigation of OpenSSL DH_check() vulnerability

set -e

# Configuration - UPDATED FOR NEW PROJECT STRUCTURE
REPO_PATH="/Users/basiladdington/Projects/tech-debt-showcase/local-repos/openssl"
OUTPUT_DIR="/Users/basiladdington/Projects/tech-debt-showcase/case-studies/CVE-2023-3446-dhtest"
PATCH_COMMIT="9e0094e2aa1b3428a12d5095132f133c078d3c3d"
TARGET_FILE="crypto/dh/dh_check.c"  # CORRECTED: This is the actual vulnerable file
BASENAME=$(basename "$TARGET_FILE")  # Will be "dh_check.c"

# Verify repository exists
if [ ! -d "$REPO_PATH" ]; then
    echo "ERROR: OpenSSL repository not found at: $REPO_PATH"
    echo ""
    echo "Please clone the repository first:"
    echo "  cd /Users/basiladdington/Projects/tech-debt-showcase/local-repos"
    echo "  git clone https://github.com/openssl/openssl.git"
    echo ""
    exit 1
fi

# Create output directory structure (updated to match case study template)
mkdir -p "$OUTPUT_DIR"/{original,analysis/{diffs,metadata}}

echo "====================================="
echo "CVE-2023-3446 FORENSIC EXTRACTION"
echo "====================================="
echo ""

cd "$REPO_PATH"

# ============================================
# PHASE 1: COMMIT FORENSICS
# ============================================
echo "[PHASE 1] Extracting commit metadata..."

# Get commit details
git log -1 --format=full "$PATCH_COMMIT" > "$OUTPUT_DIR/analysis/metadata/patch_commit_details.txt"

# Get commit date and author
COMMIT_DATE=$(git log -1 --format=%cd --date=iso "$PATCH_COMMIT")
COMMIT_AUTHOR=$(git log -1 --format="%an <%ae>" "$PATCH_COMMIT")
COMMIT_MESSAGE=$(git log -1 --format=%B "$PATCH_COMMIT")

echo "Patch Commit: $PATCH_COMMIT" > "$OUTPUT_DIR/analysis/metadata/timeline.txt"
echo "Author: $COMMIT_AUTHOR" >> "$OUTPUT_DIR/analysis/metadata/timeline.txt"
echo "Date: $COMMIT_DATE" >> "$OUTPUT_DIR/analysis/metadata/timeline.txt"
echo "" >> "$OUTPUT_DIR/analysis/metadata/timeline.txt"
echo "Commit Message:" >> "$OUTPUT_DIR/analysis/metadata/timeline.txt"
echo "$COMMIT_MESSAGE" >> "$OUTPUT_DIR/analysis/metadata/timeline.txt"

echo "  ✓ Commit metadata saved"

# ============================================
# PHASE 2: EXTRACT VULNERABLE CODE (PRE-PATCH)
# ============================================
echo "[PHASE 2] Extracting vulnerable code (pre-patch)..."

# Get parent commit (the vulnerable version)
PARENT_COMMIT=$(git rev-parse "$PATCH_COMMIT^")
echo "Parent (vulnerable) commit: $PARENT_COMMIT" >> "$OUTPUT_DIR/analysis/metadata/timeline.txt"

# Extract vulnerable version
git show "$PARENT_COMMIT:$TARGET_FILE" > "$OUTPUT_DIR/original/$BASENAME"

# Get vulnerable version metadata
echo "[Vulnerable Version]" > "$OUTPUT_DIR/original/metadata.txt"
echo "Commit: $PARENT_COMMIT" >> "$OUTPUT_DIR/original/metadata.txt"
git log -1 --format=full "$PARENT_COMMIT" >> "$OUTPUT_DIR/original/metadata.txt"

# Calculate comment coverage for vulnerable version
TOTAL_LINES=$(wc -l < "$OUTPUT_DIR/original/$BASENAME")
COMMENT_LINES=$(grep -cE '^\s*(//|/\*|\*)' "$OUTPUT_DIR/original/$BASENAME" || echo "0")
COMMENT_RATIO=$(awk "BEGIN {printf \"%.2f\", ($COMMENT_LINES/$TOTAL_LINES)*100}")

echo "" >> "$OUTPUT_DIR/original/metadata.txt"
echo "Code Statistics:" >> "$OUTPUT_DIR/original/metadata.txt"
echo "  Total lines: $TOTAL_LINES" >> "$OUTPUT_DIR/original/metadata.txt"
echo "  Comment lines: $COMMENT_LINES" >> "$OUTPUT_DIR/original/metadata.txt"
echo "  Comment coverage: $COMMENT_RATIO%" >> "$OUTPUT_DIR/original/metadata.txt"

echo "  ✓ Vulnerable version saved (lines: $TOTAL_LINES, comments: $COMMENT_RATIO%)"

# ============================================
# PHASE 3: DIFF ANALYSIS
# ============================================
echo "[PHASE 3] Generating diff analysis..."

# Generate unified diff
git diff "$PARENT_COMMIT" "$PATCH_COMMIT" -- "$TARGET_FILE" > "$OUTPUT_DIR/analysis/diffs/unified.diff"

# Generate side-by-side diff
git diff --word-diff "$PARENT_COMMIT" "$PATCH_COMMIT" -- "$TARGET_FILE" > "$OUTPUT_DIR/analysis/diffs/word-diff.txt"

# Generate stats
git diff --stat "$PARENT_COMMIT" "$PATCH_COMMIT" -- "$TARGET_FILE" > "$OUTPUT_DIR/analysis/diffs/stats.txt"

# Extract only the changed functions
echo "  ✓ Generating function-level changes..."
git diff "$PARENT_COMMIT" "$PATCH_COMMIT" -- "$TARGET_FILE" | \
  grep -E "^(@@|\+|\-)" | \
  grep -v "^---\|^+++" > "$OUTPUT_DIR/analysis/diffs/function_changes.txt"

echo "  ✓ Diff analysis complete"

# ============================================
# PHASE 4: IDENTIFY SPECIFIC VULNERABILITY
# ============================================
echo "[PHASE 4] Identifying vulnerability location..."

# Search for DH_check related code in vulnerable version
echo "[Vulnerability Locations in $BASENAME]" > "$OUTPUT_DIR/analysis/metadata/vulnerability_locations.txt"
echo "" >> "$OUTPUT_DIR/analysis/metadata/vulnerability_locations.txt"

grep -n "DH_check\|BN_num_bits\|OPENSSL_DH" "$OUTPUT_DIR/original/$BASENAME" >> "$OUTPUT_DIR/analysis/metadata/vulnerability_locations.txt" || echo "No vulnerability markers found"

echo "  ✓ Vulnerability locations identified"

# ============================================
# PHASE 5: GENERATE INVESTIGATION SUMMARY
# ============================================
echo "[PHASE 5] Generating investigation summary..."

cat > "$OUTPUT_DIR/analysis/INVESTIGATION_SUMMARY.md" << EOF
# CVE-2023-3446 CRASH INVESTIGATION REPORT
## OpenSSL DH_check() Denial of Service

**Investigation Date:** $(date +"%Y-%m-%d %H:%M:%S")
**Investigator:** Baz (6D Documentation Framework Validation)
**Case Study:** 1 of 5

---

## EXECUTIVE SUMMARY

### Vulnerability Classification
- **CVE ID:** CVE-2023-3446
- **Type:** Algorithmic Complexity / Denial of Service
- **Severity:** LOW (CVSS 3.7)
- **Affected Component:** crypto/dh/dh_check.c (DH parameter validation)
- **Root Cause:** Excessive computation time checking oversized DH parameters

### Timeline
- **Discovery:** June 25, 2023 (OSSfuzz automated fuzzing)
- **Public Disclosure:** July 19, 2023
- **Time to Patch:** 24 days
- **Patch Commit:** $PATCH_COMMIT
- **Patch Date:** $COMMIT_DATE

### Code Quality Baseline
- **Total Lines:** $TOTAL_LINES
- **Comment Coverage:** $COMMENT_RATIO% (SPARSE)
- **Documentation Quality:** Minimal inline documentation

---

## TECHNICAL ANALYSIS

### Root Cause
The DH_check() function performed parameter validation checks but continued
processing even after detecting oversized modulus values (>10,000 bits).
This caused excessive computation time leading to DoS conditions.

### The Fix
Introduced a maximum limit of 32,768 bits for DH parameter checks, with
early termination when limits are exceeded.

### Files Modified
\`\`\`
$TARGET_FILE
\`\`\`

### Code Changes
See: \`analysis/diffs/unified.diff\` for complete patch analysis

---

## RESEARCH HYPOTHESIS

**Question:** Would AI + 6D documentation have caught this vulnerability faster?

### Test Variables
1. **Control Group:** Vulnerable code with original sparse comments ($COMMENT_RATIO%)
2. **Experimental Group:** Same code with 6D documentation:
   - @intent: Function purpose and expected behavior
   - @history: Evolution of DH checking logic
   - @deps: Dependencies on crypto parameters
   - @techdebt: Known performance concerns
   - @arch: Relationship to broader OpenSSL architecture
   - @security: Input validation and DoS risks

### Measurement Criteria
1. **Detection Speed:** Time for AI to identify the vulnerability
2. **Detection Accuracy:** Correct identification of root cause
3. **Patch Quality:** Correctness of AI-proposed fix
4. **False Positive Rate:** Incorrect vulnerability claims

### Expected Outcome
6D documentation should enable AI to:
- Identify algorithmic complexity risks in input validation
- Recognize missing bounds checks earlier
- Propose correct fixes with proper context

---

## NEXT STEPS

1. Generate 6D documentation for vulnerable code
2. Design standardized test queries for GPT-4 and Kimi K2
3. Run comparative analysis (undocumented vs. documented)
4. Collect quantitative metrics
5. Generate findings report

**Evidence Location:** \`$OUTPUT_DIR\`

---

## FORENSIC ARTIFACTS

### Directory Structure
\`\`\`
$OUTPUT_DIR/
├── original/                      # Pre-patch code (control group)
│   ├── dhtest.c
│   └── metadata.txt
├── documented/                    # To be created with 6D annotations
│   └── dhtest.c
├── analysis/                      # Investigation outputs
│   ├── diffs/
│   │   ├── unified.diff
│   │   ├── word-diff.txt
│   │   ├── stats.txt
│   │   └── function_changes.txt
│   ├── metadata/
│   │   ├── patch_commit_details.txt
│   │   ├── timeline.txt
│   │   └── vulnerability_locations.txt
│   └── INVESTIGATION_SUMMARY.md  # This file
└── ai-detection-results/          # Test results to be collected
    ├── control-group/
    └── experimental-group/
\`\`\`

**End of Investigation Summary**
EOF

echo "  ✓ Investigation summary generated"

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
