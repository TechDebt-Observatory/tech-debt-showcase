#!/bin/bash

################################################################################
# Detailed CVE File Documentation Assistant
################################################################################
#
# PURPOSE:
#   Takes the file with the lowest comment ratio from CVE analysis and:
#   1. Extracts comprehensive statistics
#   2. Identifies the specific CVE(s) that patched it
#   3. Generates the exact prompt for Claude API analysis
#   4. Prepares the file for your documentation methodology
#
# USAGE:
#   ./prepare_worst_cve_file.sh <csv_results_file> [file_index]
#
# DEPENDENCIES:
#   - analyze_cve_comments.sh must be run first
#
################################################################################

set -euo pipefail

# Configuration
OPENSSL_REPO="${OPENSSL_REPO:-$HOME/Shared/analysis/repos/openssl}"
RESULTS_FILE="${1:-$HOME/Shared/cve_comment_analysis/cve_files_by_comment_ratio.csv}"
FILE_INDEX="${2:-1}"  # Default to worst file (index 1 after header)
OUTPUT_DIR="$HOME/Shared/cve_comment_analysis/worst_file_analysis"

################################################################################
# Validate inputs
################################################################################

if [[ ! -f "$RESULTS_FILE" ]]; then
    echo "ERROR: Results file not found: $RESULTS_FILE"
    echo "Please run analyze_cve_comments.sh first"
    exit 1
fi

if [[ ! -d "$OPENSSL_REPO/.git" ]]; then
    echo "ERROR: OpenSSL repository not found at: $OPENSSL_REPO"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

################################################################################
# Extract the target file
################################################################################

echo "═══════════════════════════════════════════════════════════════"
echo "  Worst CVE-Patched File Analysis"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Get the Nth worst file (after header)
TARGET_LINE=$((FILE_INDEX + 1))
FILE_DATA=$(sed -n "${TARGET_LINE}p" "$RESULTS_FILE")

if [[ -z "$FILE_DATA" ]]; then
    echo "ERROR: No file found at index $FILE_INDEX"
    exit 1
fi

# Parse CSV data
IFS=',' read -r FILE_PATH TOTAL_LINES COMMENT_LINES CODE_LINES COMMENT_RATIO CVES <<< "$FILE_DATA"

echo "File #${FILE_INDEX} with lowest comment ratio:"
echo "  File: $FILE_PATH"
echo "  Total lines: $TOTAL_LINES"
echo "  Comment lines: $COMMENT_LINES"
echo "  Code lines: $CODE_LINES"
echo "  Comment ratio: ${COMMENT_RATIO}%"
echo "  CVEs: $CVES"
echo ""

FULL_PATH="$OPENSSL_REPO/$FILE_PATH"

if [[ ! -f "$FULL_PATH" ]]; then
    echo "ERROR: File not found: $FULL_PATH"
    exit 1
fi

################################################################################
# Extract CVE information from git history
################################################################################

echo "Extracting CVE patch information..."
echo ""

cd "$OPENSSL_REPO"

# Find commits that modified this file and mention CVEs
CVE_COMMITS_FILE="$OUTPUT_DIR/cve_commits.txt"
> "$CVE_COMMITS_FILE"

for cve in $CVES; do
    echo "  Searching for commits mentioning $cve..."
    
    git log --all --since="2023-01-01" --grep="$cve" --pretty=format:"%H|%ai|%s" -- "$FILE_PATH" >> "$CVE_COMMITS_FILE" || true
done

if [[ -s "$CVE_COMMITS_FILE" ]]; then
    echo ""
    echo "Found CVE commits:"
    cat "$CVE_COMMITS_FILE" | while IFS='|' read -r hash date subject; do
        echo "    $hash - $date - $subject"
    done
else
    echo "  (No specific commits found - may be inherited from parent file)"
fi

echo ""

################################################################################
# Generate analysis files
################################################################################

echo "Generating analysis files..."
echo ""

# 1. Copy the source file
cp "$FULL_PATH" "$OUTPUT_DIR/source_file.c"
echo "  ✓ Source file copied to: $OUTPUT_DIR/source_file.c"

# 2. Generate statistics file
STATS_FILE="$OUTPUT_DIR/statistics.txt"
cat > "$STATS_FILE" <<EOF
═══════════════════════════════════════════════════════════════
FILE STATISTICS
═══════════════════════════════════════════════════════════════

File: $FILE_PATH
Location: $FULL_PATH

CODE METRICS:
  Total lines:        $TOTAL_LINES
  Comment lines:      $COMMENT_LINES
  Code lines:         $CODE_LINES
  Blank lines:        $((TOTAL_LINES - COMMENT_LINES - CODE_LINES))
  Comment ratio:      ${COMMENT_RATIO}%

SECURITY CONTEXT:
  CVEs that patched this file: $CVES
  Last modified: $(git log -1 --format="%ai" -- "$FILE_PATH")
  Total commits: $(git log --oneline -- "$FILE_PATH" | wc -l)

COMPARISON TO BASELINE:
  Your asn1parse.c analysis:   ~5% comment ratio (348 lines)
  This file:                    ${COMMENT_RATIO}% comment ratio ($TOTAL_LINES lines)
  
STATUS: $(if (( $(echo "$COMMENT_RATIO < 5" | bc -l) )); then echo "WORSE than asn1parse.c"; else echo "Better than asn1parse.c but still under-documented"; fi)

═══════════════════════════════════════════════════════════════
EOF

echo "  ✓ Statistics saved to: $STATS_FILE"

# 3. Generate Claude API prompt
PROMPT_FILE="$OUTPUT_DIR/claude_prompt.txt"
cat > "$PROMPT_FILE" <<'PROMPTEOF'
I have a C file from OpenSSL that was recently patched for security vulnerabilities (CVEs) and has extremely low documentation.

This file needs comprehensive comments added. I'm an old school programmer who learned on System/370 assembly with punched cards.

CONTEXT:
PROMPTEOF

# Add file-specific context
cat >> "$PROMPT_FILE" <<EOF
- File: $FILE_PATH
- CVEs: $CVES
- Current comment ratio: ${COMMENT_RATIO}% (very low)
- Total lines: $TOTAL_LINES
- This is security-critical code that was patched for vulnerabilities

EOF

# Add standard methodology
cat >> "$PROMPT_FILE" <<'PROMPTEOF2'
The comments should include:

1. A comprehensive header block at the top with:
   - Purpose and overview of the code
   - Complete INPUT/OUTPUT specification
   - Full VARIABLE DICTIONARY listing every variable with its scope, type, and purpose
   - Memory management notes (what gets allocated/freed)
   - Security considerations
   - CVE context (what vulnerabilities were patched and why)
   - Technical debt markers
   - Related functions and algorithms

2. Inline comments throughout explaining:
   - What each section does and WHY
   - Complex algorithms and data structures
   - Edge cases and potential gotchas
   - Historical context and design decisions
   - Security implications (especially related to CVE patches)
   - Known technical debt (marked with "TECHNICAL DEBT")
   - Why certain approaches were chosen for security

3. For each function, add comprehensive headers with:
   - Function signature and purpose
   - Complete parameter documentation
   - Return value specification
   - Variable dictionary
   - Algorithm flow
   - Error conditions
   - Security considerations
   - CVE-related changes

Style: Old-school detailed documentation like we used to write for System/360. Every variable explained, every decision documented, every security consideration noted, every gotcha flagged. The kind of comments where someone can understand the entire code and its security implications just from reading the documentation.

[PASTE SOURCE CODE HERE]
PROMPTEOF2

echo "  ✓ Claude prompt template saved to: $PROMPT_FILE"

# 4. Generate the complete API call script
API_SCRIPT="$OUTPUT_DIR/run_claude_api.sh"
cat > "$API_SCRIPT" <<'EOF'
#!/bin/bash

################################################################################
# Claude API Analysis Script
################################################################################

set -euo pipefail

if [[ -z "${ANTHROPIC_API_KEY:-}" ]]; then
    echo "ERROR: ANTHROPIC_API_KEY environment variable not set"
    echo "Export your API key: export ANTHROPIC_API_KEY='your-key-here'"
    exit 1
fi

SOURCE_FILE="source_file.c"
PROMPT_FILE="claude_prompt.txt"
OUTPUT_FILE="claude_response.json"
COMMENTED_FILE="source_file_commented.c"

if [[ ! -f "$SOURCE_FILE" ]] || [[ ! -f "$PROMPT_FILE" ]]; then
    echo "ERROR: Required files not found"
    exit 1
fi

echo "Reading source file and prompt..."

# Read the source code
SOURCE_CODE=$(cat "$SOURCE_FILE")

# Read the prompt template
PROMPT_TEMPLATE=$(cat "$PROMPT_FILE")

# Combine prompt and source code
FULL_PROMPT="${PROMPT_TEMPLATE}

${SOURCE_CODE}"

echo "Calling Claude API..."
echo "  Model: claude-sonnet-4-20250514"
echo "  Max tokens: 16000"
echo "  Temperature: 0.3"
echo ""

# Make API call
curl https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d "{
    \"model\": \"claude-sonnet-4-20250514\",
    \"max_tokens\": 16000,
    \"temperature\": 0.3,
    \"messages\": [
      {
        \"role\": \"user\",
        \"content\": $(echo "$FULL_PROMPT" | jq -Rs .)
      }
    ]
  }" > "$OUTPUT_FILE"

if [[ $? -eq 0 ]]; then
    echo "✓ API call successful"
    echo ""
    
    # Extract the commented code from response
    jq -r '.content[0].text' "$OUTPUT_FILE" > "$COMMENTED_FILE"
    
    echo "Results:"
    echo "  Raw API response: $OUTPUT_FILE"
    echo "  Commented code: $COMMENTED_FILE"
    echo ""
    
    # Calculate new statistics
    ORIGINAL_LINES=$(wc -l < "$SOURCE_FILE")
    COMMENTED_LINES=$(wc -l < "$COMMENTED_FILE")
    
    echo "Statistics:"
    echo "  Original file: $ORIGINAL_LINES lines"
    echo "  Commented file: $COMMENTED_LINES lines"
    echo "  Added: $((COMMENTED_LINES - ORIGINAL_LINES)) lines of documentation"
    echo ""
    
    # Estimate cost (rough calculation)
    INPUT_TOKENS=$(echo "$FULL_PROMPT" | wc -w)
    OUTPUT_TOKENS=$(jq -r '.usage.output_tokens' "$OUTPUT_FILE" 2>/dev/null || echo "unknown")
    
    if [[ "$OUTPUT_TOKENS" != "unknown" ]]; then
        # Claude 3.5 Sonnet pricing: $3/MTok input, $15/MTok output
        COST=$(awk "BEGIN {printf \"%.4f\", ($INPUT_TOKENS * 3 / 1000000) + ($OUTPUT_TOKENS * 15 / 1000000)}")
        echo "Estimated cost: \$$COST"
    fi
else
    echo "✗ API call failed"
    exit 1
fi
EOF

chmod +x "$API_SCRIPT"
echo "  ✓ API execution script saved to: $API_SCRIPT"

# 5. Generate comparison template
COMPARISON_FILE="$OUTPUT_DIR/validation_checklist.md"
cat > "$COMPARISON_FILE" <<EOF
# Validation Checklist for CVE File Documentation

## File Information
- **File**: $FILE_PATH
- **CVEs**: $CVES
- **Original Comment Ratio**: ${COMMENT_RATIO}%
- **Analysis Date**: $(date +%Y-%m-%d)

## Pre-Analysis Checklist

- [ ] Source file copied and backed up
- [ ] CVE commit history extracted
- [ ] Claude prompt prepared
- [ ] API key configured

## Post-Analysis Validation

### Accuracy (Does it match the code?)
- [ ] All variables documented correctly
- [ ] Function signatures accurate
- [ ] Algorithm descriptions match implementation
- [ ] CVE-related changes properly identified
- [ ] No hallucinations or invented details

### Completeness (Did it document everything?)
- [ ] Every function has a header
- [ ] Every variable explained
- [ ] All CVE patches identified with context
- [ ] Security implications documented
- [ ] Edge cases noted
- [ ] Error conditions explained

### Security Context
- [ ] CVE vulnerabilities clearly explained
- [ ] Why patches fixed the issues documented
- [ ] Remaining technical debt identified
- [ ] Security best practices noted
- [ ] Potential attack vectors documented

### "Why" Factor (Explains reasoning, not just facts?)
- [ ] Design decisions explained
- [ ] Trade-offs documented
- [ ] Historical context provided
- [ ] Why CVE vulnerabilities existed
- [ ] Why specific fixes were chosen

### Quality
- [ ] Comments are clear and readable
- [ ] Old-school documentation style maintained
- [ ] Appropriate level of detail
- [ ] Useful for new contributors
- [ ] Would help prevent future CVEs

## Comparison to Baseline

Your asn1parse.c analysis found:
- 12 critical issues
- 8 high priority
- 5 medium priority
- 0% false positives
- Time: 75 seconds, Cost: ~\$0.05

This file ($FILE_PATH):
- Total findings: ___ (to be filled after analysis)
- False positives: ___ (to be validated)
- Time: ___ seconds
- Cost: \$___

## Next Steps

- [ ] Run API analysis: cd $OUTPUT_DIR && ./run_claude_api.sh
- [ ] Validate all findings manually
- [ ] Compare to asn1parse.c methodology
- [ ] Document false positive rate
- [ ] Add to website showcase
- [ ] Share results with OpenSSL maintainers (if 0% false positives)

## Notes

EOF

echo "  ✓ Validation checklist saved to: $COMPARISON_FILE"

################################################################################
# Final summary
################################################################################

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  PREPARATION COMPLETE"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "File prepared for analysis: $(basename "$FILE_PATH")"
echo "Comment ratio: ${COMMENT_RATIO}% ($(if (( $(echo "$COMMENT_RATIO < 5" | bc -l) )); then echo "WORSE"; else echo "Better"; fi) than your asn1parse.c baseline)"
echo "CVEs: $CVES"
echo ""
echo "Output directory: $OUTPUT_DIR"
echo ""
echo "Next steps:"
echo ""
echo "  1. Review the file:"
echo "     cat $OUTPUT_DIR/source_file.c"
echo ""
echo "  2. Review statistics:"
echo "     cat $OUTPUT_DIR/statistics.txt"
echo ""
echo "  3. Run Claude API analysis:"
echo "     export ANTHROPIC_API_KEY='your-key-here'"
echo "     cd $OUTPUT_DIR"
echo "     ./run_claude_api.sh"
echo ""
echo "  4. Validate results:"
echo "     vi $OUTPUT_DIR/validation_checklist.md"
echo ""
echo "  5. Compare to asn1parse.c analysis"
echo ""
echo "═══════════════════════════════════════════════════════════════"

# Display the file content preview
echo ""
echo "File preview (first 30 lines):"
echo "-------------------------------------------------------------------"
head -n 30 "$FULL_PATH"
echo "-------------------------------------------------------------------"
echo "(Full file has $TOTAL_LINES lines)"
echo ""