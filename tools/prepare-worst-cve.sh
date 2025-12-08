#!/bin/bash
################################################################################
# prepare-worst-cve.sh - CVE File Documentation Preparation Assistant
################################################################################
#
# @purpose: Extract and prepare the worst-documented CVE-patched file for analysis
#   - Takes CSV output from analyze_cve_comments.sh
#   - Extracts file with lowest comment ratio
#   - Generates comprehensive context (git history, CVE commits, statistics)
#   - Prepares Claude API prompt and execution script
#   - Creates validation checklist for AI-generated documentation
#   - Enables systematic comparison to asn1parse.c baseline (~5% comment ratio)
#
# @workflow: Five-phase preparation process
#   Phase 1: Extract Target File from CSV
#     └─> Parse CSV, select file by index, validate existence
#   Phase 2: Extract CVE Information from Git History
#     └─> Search git log for CVE commits, generate timeline
#   Phase 3: Generate Analysis Files
#     ├─> Copy source file to output directory
#     ├─> Generate statistics file with metrics comparison
#     ├─> Create Claude API prompt with 6D methodology context
#     └─> Generate executable API script with cost estimation
#   Phase 4: Generate Validation Checklist
#     └─> Create markdown checklist for post-analysis validation
#   Phase 5: Display Summary and Next Steps
#     └─> Show file preview and execution instructions
#
# @dependencies: External requirements
#   System requirements:
#     - OS: macOS/Linux with bash 4.0+
#     - Shell: bash (set -euo pipefail used for safety)
#     - Required commands: git, bc, jq, curl, wc, head, sed, grep
#   File structure:
#     - $OPENSSL_REPO: OpenSSL git repository (default: ~/Shared/analysis/repos/openssl)
#     - $RESULTS_FILE: CSV from analyze_cve_comments.sh
#     - $OUTPUT_DIR: Analysis workspace (default: ~/Shared/cve_comment_analysis/worst_file_analysis)
#   Permissions:
#     - Read access to OpenSSL repository
#     - Write access to output directory
#   Network:
#     - None required for preparation
#     - Internet access required when running generated API script
#   Environment variables:
#     - ANTHROPIC_API_KEY: Required when executing generated API script (not needed for preparation)
#     - OPENSSL_REPO: Optional override for repository path
#
# @gotchas: Known issues and edge cases
#   CSV Parsing Issue:
#     - CVE field may contain spaces in rare cases (script splits on space)
#     - Workaround: Verify CVES variable contains expected values
#   bc Command Dependency:
#     - Required for float comparison in statistics generation
#     - Error: "bc: command not found" → Install: brew install bc (macOS) or apt-get install bc (Linux)
#   API Key Handling:
#     - Generated script requires ANTHROPIC_API_KEY at runtime
#     - Script validates presence before calling API
#     - Workaround: Export key before running: export ANTHROPIC_API_KEY='your-key'
#   Git Repository State:
#     - Assumes OpenSSL repo is up-to-date
#     - CVE commits searched since 2023-01-01 only
#     - Some CVEs may not have explicit commits (inherited from parent file)
#   File Index Out of Range:
#     - Requesting index beyond CSV length fails gracefully
#     - Error message shows how many files available
#   Existing Output Directory:
#     - mkdir -p used to avoid failure on existing directory
#     - Previous analysis files will be overwritten
#
# USAGE:
#   ./prepare-worst-cve.sh <csv_results_file> [file_index]
#   
#   Arguments:
#     csv_results_file - Path to CSV from analyze_cve_comments.sh
#     file_index - Which file to analyze (1=worst, 2=second-worst, etc.) [default: 1]
#
#   Examples:
#     ./prepare-worst-cve.sh ~/results/cve_files_by_comment_ratio.csv
#     ./prepare-worst-cve.sh ~/results/cve_files_by_comment_ratio.csv 3
#     OPENSSL_REPO=~/repos/openssl ./prepare-worst-cve.sh results.csv
#
# OUTPUT:
#   $OUTPUT_DIR/
#     ├── source_file.c              - Copy of target file for analysis
#     ├── statistics.txt              - Comprehensive metrics and comparison
#     ├── claude_prompt.txt           - Ready-to-use API prompt
#     ├── run_claude_api.sh           - Executable API call script
#     ├── cve_commits.txt             - Git history of CVE patches
#     └── validation_checklist.md     - Post-analysis validation guide
#
# RELATED SCRIPTS:
#   - analyze_cve_comments.sh - Must run first to generate CSV input
#   - cve_2023_3446_forensics.sh - Similar forensic extraction for specific CVE
#   - setup-pipeline.sh - Full environment setup if dependencies missing
#
################################################################################

# Error handling - Exit on error, undefined variables, and pipe failures
set -euo pipefail

# ===========================================
# CONFIGURATION SECTION
# @purpose: Define paths, settings, and constants
# @why: Centralized configuration enables easy customization
# @gotcha: OPENSSL_REPO must point to valid git repository with .git directory
# ===========================================

# OpenSSL repository location (customize via environment variable)
OPENSSL_REPO="${OPENSSL_REPO:-$HOME/Shared/analysis/repos/openssl}"

# Input: CSV file from analyze_cve_comments.sh (required argument)
# WHY: Script needs ranked list of files by comment ratio
RESULTS_FILE="${1:-$HOME/Shared/cve_comment_analysis/cve_files_by_comment_ratio.csv}"

# File selection: Which file to analyze (1=worst, 2=second-worst, etc.)
# WHY: Allows analyzing multiple files in ranked order
FILE_INDEX="${2:-1}"  # Default to worst file (index 1 after header)

# Output directory: Where all analysis files will be generated
# WHY: Isolated workspace for each file analysis
OUTPUT_DIR="$HOME/Shared/cve_comment_analysis/worst_file_analysis"

# ===========================================
# VALIDATION SECTION
# @purpose: Verify prerequisites before proceeding
# @why: Early failure prevents wasted processing and unclear errors
# @method: Check file existence, directory structure, and repository validity
# ===========================================

echo "🔍 Validating prerequisites..."

# Check: CSV results file exists
# WHY: Without input CSV, we can't identify which file to analyze
if [[ ! -f "$RESULTS_FILE" ]]; then
    echo "ERROR: Results file not found: $RESULTS_FILE"
    echo ""
    echo "Please run analyze_cve_comments.sh first to generate the CSV:"
    echo "  cd /path/to/tech-debt-showcase/tools"
    echo "  ./analyze_cve_comments.sh"
    echo ""
    exit 1
fi

# Check: OpenSSL repository exists and is valid git repo
# WHY: We need git history to extract CVE commit information
if [[ ! -d "$OPENSSL_REPO/.git" ]]; then
    echo "ERROR: OpenSSL repository not found at: $OPENSSL_REPO"
    echo ""
    echo "Please clone OpenSSL repository:"
    echo "  mkdir -p $(dirname "$OPENSSL_REPO")"
    echo "  cd $(dirname "$OPENSSL_REPO")"
    echo "  git clone https://github.com/openssl/openssl.git"
    echo ""
    echo "Or set OPENSSL_REPO environment variable:"
    echo "  export OPENSSL_REPO=/path/to/your/openssl"
    echo "  $0 $RESULTS_FILE $FILE_INDEX"
    echo ""
    exit 1
fi

# Check: bc command available for float comparisons
# WHY: Statistics generation uses bc for comment ratio comparisons
if ! command -v bc &> /dev/null; then
    echo "ERROR: bc command not found"
    echo ""
    echo "Please install bc for float arithmetic:"
    echo "  macOS: brew install bc"
    echo "  Ubuntu/Debian: sudo apt-get install bc"
    echo "  RHEL/CentOS: sudo yum install bc"
    echo ""
    exit 1
fi

# Create output directory (with -p to avoid error if exists)
# WHY: mkdir without -p fails if directory already exists
mkdir -p "$OUTPUT_DIR"

echo "  ✓ All prerequisites validated"
echo ""

# ============================================
# PHASE 1: Extract Target File from CSV
# @purpose: Parse CSV to identify and validate target file
# @why: Need to extract file path, metrics, and CVE list from ranked CSV
# @method: Use sed to extract specific line, then parse with IFS and read
# @output: FILE_PATH, TOTAL_LINES, COMMENT_LINES, CODE_LINES, COMMENT_RATIO, CVES
# @gotcha: CSV parsing assumes comma-separated format from analyze_cve_comments.sh
#          CVE list may contain spaces which complicates parsing
# ============================================

echo "═══════════════════════════════════════════════════════════════"
echo "  Worst CVE-Patched File Analysis Preparation"
echo "═══════════════════════════════════════════════════════════════"
echo ""

echo "[PHASE 1] Extracting target file from CSV..."

# Calculate line number: Add 1 to skip header row
# WHY: CSV has header row, so line 2 = index 1, line 3 = index 2, etc.
TARGET_LINE=$((FILE_INDEX + 1))
FILE_DATA=$(sed -n "${TARGET_LINE}p" "$RESULTS_FILE")

# Validate: File index exists in CSV
# WHY: User might request index beyond available files
if [[ -z "$FILE_DATA" ]]; then
    AVAILABLE_FILES=$(($(wc -l < "$RESULTS_FILE") - 1))  # Subtract header
    echo "ERROR: No file found at index $FILE_INDEX"
    echo ""
    echo "Available files in CSV: $AVAILABLE_FILES"
    echo "Please specify index between 1 and $AVAILABLE_FILES"
    echo ""
    echo "Example: $0 $RESULTS_FILE 1"
    exit 1
fi

# Parse CSV data into variables
# WHY: IFS=',' sets field separator for read to split on commas
IFS=',' read -r FILE_PATH TOTAL_LINES COMMENT_LINES CODE_LINES COMMENT_RATIO CVES <<< "$FILE_DATA"

echo "  ✓ File #${FILE_INDEX} selected (lowest comment ratio)"
echo ""
echo "File Information:"
echo "  Path:              $FILE_PATH"
echo "  Total lines:       $TOTAL_LINES"
echo "  Comment lines:     $COMMENT_LINES"
echo "  Code lines:        $CODE_LINES"
echo "  Comment ratio:     ${COMMENT_RATIO}%"
echo "  CVEs patched:      $CVES"
echo ""

# Construct full path by combining repository and file path
FULL_PATH="$OPENSSL_REPO/$FILE_PATH"

# Validate: File actually exists in repository
# WHY: CSV might be stale or file might have been deleted/moved
if [[ ! -f "$FULL_PATH" ]]; then
    echo "ERROR: File not found in repository: $FULL_PATH"
    echo ""
    echo "Possible causes:"
    echo "  1. CSV is out of date (run analyze_cve_comments.sh again)"
    echo "  2. File was deleted or moved in recent OpenSSL commits"
    echo "  3. Wrong OPENSSL_REPO path (current: $OPENSSL_REPO)"
    echo ""
    exit 1
fi

echo "  ✓ Phase 1 complete"
echo ""

# ============================================
# PHASE 2: Extract CVE Information from Git History
# @purpose: Search git log for commits that patched this file for CVEs
# @why: Provides security context and patch history for documentation
# @method: For each CVE, search git log with --grep, format as hash|date|subject
# @output: $OUTPUT_DIR/cve_commits.txt with commit details
# @gotcha: Only searches commits since 2023-01-01 (may miss older CVEs)
#          Some files inherit CVE context from parent files (no explicit commits)
# ============================================

echo "[PHASE 2] Extracting CVE patch information from git history..."

# Change to repository directory for git operations
# WHY: Git commands need to run from within repository
cd "$OPENSSL_REPO"

# Initialize CVE commits file (> creates/truncates file)
CVE_COMMITS_FILE="$OUTPUT_DIR/cve_commits.txt"
: > "$CVE_COMMITS_FILE"

# Search git history for each CVE mentioned in CSV
# WHY: Multiple CVEs might have patched this file
for cve in $CVES; do
    echo "  Searching for commits mentioning $cve..."
    
    # Git log search:
    # --all: Search all branches (not just current)
    # --since="2023-01-01": Limit to recent commits (performance optimization)
    # --grep="$cve": Match CVE in commit message
    # --pretty=format: Custom format (hash|date|subject)
    # -- "$FILE_PATH": Only commits touching this specific file
    # || true: Prevent script exit if no commits found (some CVEs are inherited)
    git log --all --since="2023-01-01" --grep="$cve" --pretty=format:"%H|%ai|%s" -- "$FILE_PATH" >> "$CVE_COMMITS_FILE" || true
done

# Display results or note absence
# WHY: User needs to understand if CVE context was found
if [[ -s "$CVE_COMMITS_FILE" ]]; then
    echo ""
    echo "  ✓ Found CVE commits:"
    # Parse and display each commit with indentation
    cat "$CVE_COMMITS_FILE" | while IFS='|' read -r hash date subject; do
        echo "      $hash - $date - $subject"
    done
else
    echo ""
    echo "  ⚠ No specific commits found"
    echo "      (CVE context may be inherited from parent file or pre-2023)"
fi

echo ""
echo "  ✓ Phase 2 complete"
echo ""

# ============================================
# PHASE 3: Generate Analysis Files
# @purpose: Create all files needed for Claude API analysis
# @why: Prepares complete workspace with source, context, and execution script
# @method: Generate 5 files - source copy, statistics, prompt, API script, validation checklist
# @output: source_file.c, statistics.txt, claude_prompt.txt, run_claude_api.sh, validation_checklist.md
# @gotcha: API script requires ANTHROPIC_API_KEY at runtime (not at preparation time)
# ============================================

echo "[PHASE 3] Generating analysis files..."
echo ""

# ─────────────────────────────────────────────
# File 1: Copy source file to output directory
# WHY: Isolated copy for analysis prevents accidental edits to repository
# ─────────────────────────────────────────────
cp "$FULL_PATH" "$OUTPUT_DIR/source_file.c"
echo "  ✓ Source file copied: $OUTPUT_DIR/source_file.c"

# ─────────────────────────────────────────────
# File 2: Generate comprehensive statistics file
# WHY: Provides context for evaluating AI documentation quality
# ─────────────────────────────────────────────
STATS_FILE="$OUTPUT_DIR/statistics.txt"
cat > "$STATS_FILE" <<EOF
═══════════════════════════════════════════════════════════════
CVE-PATCHED FILE STATISTICS
═══════════════════════════════════════════════════════════════

FILE INFORMATION:
  Path:              $FILE_PATH
  Full path:         $FULL_PATH
  Selected:          File #${FILE_INDEX} (ranked by comment ratio)

CODE METRICS:
  Total lines:       $TOTAL_LINES
  Comment lines:     $COMMENT_LINES
  Code lines:        $CODE_LINES
  Blank lines:       $((TOTAL_LINES - COMMENT_LINES - CODE_LINES))
  Comment ratio:     ${COMMENT_RATIO}%

SECURITY CONTEXT:
  CVEs patched:      $CVES
  Last modified:     $(git log -1 --format="%ai" -- "$FILE_PATH")
  Total commits:     $(git log --oneline -- "$FILE_PATH" | wc -l | tr -d ' ')
  File age:          $(git log --reverse --format="%ai" -- "$FILE_PATH" | head -1)

COMPARISON TO BASELINE:
  asn1parse.c baseline:     ~5% comment ratio (348 lines)
  This file:                ${COMMENT_RATIO}% comment ratio ($TOTAL_LINES lines)
  
STATUS: $(if (( $(echo "$COMMENT_RATIO < 5" | bc -l) )); then echo "WORSE than asn1parse.c - PRIORITY TARGET"; elif (( $(echo "$COMMENT_RATIO < 10" | bc -l) )); then echo "Better than asn1parse.c but still severely under-documented"; else echo "Better documented than baseline but still needs improvement"; fi)

ANALYSIS CONTEXT:
  This file was selected from CVE-patched files ranked by comment ratio.
  It represents security-critical code with insufficient documentation.
  Goal: Generate comprehensive 6D documentation and validate against baseline.

═══════════════════════════════════════════════════════════════
EOF

echo "  ✓ Statistics file created: $STATS_FILE"

# ─────────────────────────────────────────────
# File 3: Generate Claude API prompt template
# WHY: Standardized prompt ensures consistent 6D methodology application
# ─────────────────────────────────────────────
PROMPT_FILE="$OUTPUT_DIR/claude_prompt.txt"
cat > "$PROMPT_FILE" <<'PROMPTEOF'
I have a C file from OpenSSL that was recently patched for security vulnerabilities (CVEs) and has extremely low documentation.

This file needs comprehensive comments added. I'm an old school programmer who learned on System/370 assembly with punched cards.

CONTEXT:
PROMPTEOF

# Add file-specific context (using EOF without quotes to allow variable expansion)
cat >> "$PROMPT_FILE" <<EOF
- File: $FILE_PATH
- CVEs: $CVES
- Current comment ratio: ${COMMENT_RATIO}% (very low)
- Total lines: $TOTAL_LINES
- This is security-critical code that was patched for vulnerabilities

EOF

# Add standard methodology instructions
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

echo "  ✓ Claude prompt template created: $PROMPT_FILE"

# ─────────────────────────────────────────────
# File 4: Generate executable API call script
# WHY: Automates API interaction with error handling and cost estimation
# ─────────────────────────────────────────────
API_SCRIPT="$OUTPUT_DIR/run_claude_api.sh"
cat > "$API_SCRIPT" <<'EOF'
#!/bin/bash
################################################################################
# Claude API Analysis Script
# Auto-generated by prepare-worst-cve.sh
################################################################################

set -euo pipefail

# Validate: API key must be set
# WHY: API calls fail without authentication, better to check early
if [[ -z "${ANTHROPIC_API_KEY:-}" ]]; then
    echo "ERROR: ANTHROPIC_API_KEY environment variable not set"
    echo ""
    echo "Please export your API key:"
    echo "  export ANTHROPIC_API_KEY='your-key-here'"
    echo ""
    echo "To obtain a key:"
    echo "  1. Visit https://console.anthropic.com/"
    echo "  2. Create account or sign in"
    echo "  3. Go to API Keys section"
    echo "  4. Generate new key"
    echo ""
    exit 1
fi

# Input/output files
SOURCE_FILE="source_file.c"
PROMPT_FILE="claude_prompt.txt"
OUTPUT_FILE="claude_response.json"
COMMENTED_FILE="source_file_commented.c"

# Validate: Required files exist
# WHY: Missing files indicate script not run from correct directory
if [[ ! -f "$SOURCE_FILE" ]] || [[ ! -f "$PROMPT_FILE" ]]; then
    echo "ERROR: Required files not found in current directory"
    echo ""
    echo "Expected files:"
    echo "  - $SOURCE_FILE (source code to analyze)"
    echo "  - $PROMPT_FILE (API prompt template)"
    echo ""
    echo "Make sure you're running from the output directory:"
    echo "  cd \$(dirname \$0)"
    echo "  ./run_claude_api.sh"
    echo ""
    exit 1
fi

echo "═══════════════════════════════════════════════════════════════"
echo "  Claude API Analysis"
echo "═══════════════════════════════════════════════════════════════"
echo ""

echo "Reading source file and prompt template..."

# Read the source code
SOURCE_CODE=$(cat "$SOURCE_FILE")

# Read the prompt template
PROMPT_TEMPLATE=$(cat "$PROMPT_FILE")

# Combine prompt and source code
# WHY: API expects complete prompt with context and code
FULL_PROMPT="${PROMPT_TEMPLATE}

${SOURCE_CODE}"

echo "  ✓ Prompt assembled ($(echo "$FULL_PROMPT" | wc -w) words)"
echo ""

echo "Calling Claude API..."
echo "  Model: claude-sonnet-4-20250514"
echo "  Max tokens: 16000"
echo "  Temperature: 0.3 (balanced creativity)"
echo ""

# Make API call with curl
# WHY: curl is universally available and handles HTTPS natively
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

# Check API call success
# WHY: curl exit code indicates network/API errors
if [[ $? -eq 0 ]]; then
    echo ""
    echo "✓ API call successful"
    echo ""
    
    # Extract the commented code from JSON response
    # WHY: Response is JSON-wrapped, need to extract actual code
    jq -r '.content[0].text' "$OUTPUT_FILE" > "$COMMENTED_FILE"
    
    echo "Results:"
    echo "  Raw API response: $OUTPUT_FILE"
    echo "  Commented code:   $COMMENTED_FILE"
    echo ""
    
    # Calculate statistics
    ORIGINAL_LINES=$(wc -l < "$SOURCE_FILE")
    COMMENTED_LINES=$(wc -l < "$COMMENTED_FILE")
    ADDED_LINES=$((COMMENTED_LINES - ORIGINAL_LINES))
    
    echo "Documentation Statistics:"
    echo "  Original file:   $ORIGINAL_LINES lines"
    echo "  Commented file:  $COMMENTED_LINES lines"
    echo "  Added:           $ADDED_LINES lines of documentation (+$(awk "BEGIN {printf \"%.1f\", ($ADDED_LINES/$ORIGINAL_LINES)*100}")%)"
    echo ""
    
    # Estimate API cost
    # WHY: Users need to track spending for budget management
    INPUT_TOKENS=$(echo "$FULL_PROMPT" | wc -w)
    OUTPUT_TOKENS=$(jq -r '.usage.output_tokens' "$OUTPUT_FILE" 2>/dev/null || echo "unknown")
    
    if [[ "$OUTPUT_TOKENS" != "unknown" ]]; then
        # Claude 3.5 Sonnet pricing: $3/MTok input, $15/MTok output
        # WHY: Pricing from https://www.anthropic.com/pricing as of 2024
        COST=$(awk "BEGIN {printf \"%.4f\", ($INPUT_TOKENS * 3 / 1000000) + ($OUTPUT_TOKENS * 15 / 1000000)}")
        echo "Cost Estimation:"
        echo "  Input tokens:  $INPUT_TOKENS"
        echo "  Output tokens: $OUTPUT_TOKENS"
        echo "  Estimated:     \$$COST USD"
    fi
    echo ""
    
    echo "Next steps:"
    echo "  1. Review commented code: vi $COMMENTED_FILE"
    echo "  2. Validate against checklist: vi ../validation_checklist.md"
    echo "  3. Compare to original: diff $SOURCE_FILE $COMMENTED_FILE"
    echo ""
else
    echo "✗ API call failed"
    echo ""
    echo "Check:"
    echo "  1. API key is valid: echo \$ANTHROPIC_API_KEY"
    echo "  2. Network connection: curl https://api.anthropic.com"
    echo "  3. API response: cat $OUTPUT_FILE"
    echo ""
    exit 1
fi
EOF

# Make script executable
# WHY: Generated script needs execute permission to run
chmod +x "$API_SCRIPT"
echo "  ✓ API execution script created: $API_SCRIPT"

echo ""
echo "  ✓ Phase 3 complete"
echo ""

# ============================================
# PHASE 4: Generate Validation Checklist
# @purpose: Create structured validation guide for post-analysis review
# @why: Systematic validation ensures AI documentation quality and accuracy
# @method: Generate markdown checklist with categories and baseline comparison
# @output: $OUTPUT_DIR/validation_checklist.md
# @gotcha: Checklist is a template - analyst must fill in actual findings
# ============================================

echo "[PHASE 4] Generating validation checklist..."

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
- [ ] Baseline comparison criteria established

## Post-Analysis Validation

### Accuracy (Does it match the code?)
- [ ] All variables documented correctly
- [ ] Function signatures accurate
- [ ] Algorithm descriptions match implementation
- [ ] CVE-related changes properly identified
- [ ] No hallucinations or invented details
- [ ] Variable types and scopes correct
- [ ] Memory management accurately described

### Completeness (Did it document everything?)
- [ ] Every function has a header
- [ ] Every variable explained in dictionary
- [ ] All CVE patches identified with context
- [ ] Security implications documented
- [ ] Edge cases noted
- [ ] Error conditions explained
- [ ] Return values specified
- [ ] Parameter purposes documented

### Security Context
- [ ] CVE vulnerabilities clearly explained
- [ ] Why patches fixed the issues documented
- [ ] Remaining technical debt identified
- [ ] Security best practices noted
- [ ] Potential attack vectors documented
- [ ] Input validation patterns explained
- [ ] Buffer handling documented

### "Why" Factor (Explains reasoning, not just facts?)
- [ ] Design decisions explained
- [ ] Trade-offs documented
- [ ] Historical context provided
- [ ] Why CVE vulnerabilities existed
- [ ] Why specific fixes were chosen
- [ ] Why certain patterns used
- [ ] Why complexity exists in certain areas

### Quality Standards
- [ ] Comments are clear and readable
- [ ] Old-school documentation style maintained
- [ ] Appropriate level of detail
- [ ] Useful for new contributors
- [ ] Would help prevent future CVEs
- [ ] No unnecessary verbosity
- [ ] Technical terms explained

## Comparison to Baseline

Your asn1parse.c analysis found:
- 12 critical issues
- 8 high priority issues
- 5 medium priority issues
- 0% false positives
- Time: 75 seconds
- Cost: ~\$0.05

This file ($FILE_PATH):
- Total findings: ___ (to be filled after analysis)
- Critical: ___
- High: ___
- Medium: ___
- False positives: ___ (to be validated)
- Time: ___ seconds
- Cost: \$___

## Performance Metrics

### Speed
- [ ] Analysis completed in under 120 seconds
- [ ] Preparation took less than 30 seconds

### Accuracy
- [ ] False positive rate under 5%
- [ ] All CVE-related issues correctly identified
- [ ] No missed security-critical patterns

### Value
- [ ] Documentation adds clear understanding
- [ ] Would help in future code reviews
- [ ] Identifies technical debt actionably

## Next Steps

- [ ] Run API analysis: cd $OUTPUT_DIR && ./run_claude_api.sh
- [ ] Validate all findings manually
- [ ] Compare to asn1parse.c methodology
- [ ] Document false positive rate
- [ ] Calculate comment ratio improvement
- [ ] Test if documentation helps AI detect vulnerabilities faster
- [ ] Add to website showcase (if high quality)
- [ ] Share results with OpenSSL maintainers (if 0% false positives)

## Notes

_Use this space for observations, anomalies, or insights during validation:_

EOF

echo "  ✓ Validation checklist created: $COMPARISON_FILE"
echo ""
echo "  ✓ Phase 4 complete"
echo ""

# ============================================
# PHASE 5: Display Summary and Next Steps
# @purpose: Provide clear completion message with actionable next steps
# @why: Users need to understand what was generated and how to proceed
# @method: Display formatted summary with file preview
# @output: Console output only
# @gotcha: File preview limited to 30 lines to avoid overwhelming output
# ============================================

echo "[PHASE 5] Displaying summary..."
echo ""

echo "═══════════════════════════════════════════════════════════════"
echo "  PREPARATION COMPLETE"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "📄 Target File: $(basename "$FILE_PATH")"
echo "📊 Comment Ratio: ${COMMENT_RATIO}% ($(if (( $(echo "$COMMENT_RATIO < 5" | bc -l) )); then echo "⚠️  WORSE"; else echo "Better"; fi) than asn1parse.c baseline)"
echo "🔒 CVEs: $CVES"
echo ""
echo "📁 Output Directory: $OUTPUT_DIR"
echo ""
echo "Generated Files:"
echo "  ✓ source_file.c              - Copy of target file for analysis"
echo "  ✓ statistics.txt              - Comprehensive metrics and baseline comparison"
echo "  ✓ claude_prompt.txt           - Ready-to-use Claude API prompt"
echo "  ✓ run_claude_api.sh           - Executable API script with cost estimation"
echo "  ✓ cve_commits.txt             - Git history of CVE patches"
echo "  ✓ validation_checklist.md     - Post-analysis validation guide"
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  NEXT STEPS"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "1. Review the file and statistics:"
echo "     cat $OUTPUT_DIR/source_file.c"
echo "     cat $OUTPUT_DIR/statistics.txt"
echo ""
echo "2. Export your Claude API key (if not already set):"
echo "     export ANTHROPIC_API_KEY='your-api-key-here'"
echo ""
echo "3. Run Claude API analysis:"
echo "     cd $OUTPUT_DIR"
echo "     ./run_claude_api.sh"
echo ""
echo "4. Validate results against checklist:"
echo "     vi $OUTPUT_DIR/validation_checklist.md"
echo ""
echo "5. Compare to asn1parse.c baseline:"
echo "     - Check false positive rate"
echo "     - Verify CVE context accuracy"
echo "     - Measure documentation improvement"
echo ""
echo "═══════════════════════════════════════════════════════════════"

# Display file preview
# WHY: Gives analyst immediate context without opening file
echo ""
echo "File Preview (first 30 lines):"
echo "───────────────────────────────────────────────────────────────"
head -n 30 "$FULL_PATH"
echo "───────────────────────────────────────────────────────────────"
echo "(Full file has $TOTAL_LINES lines)"
echo ""

echo "  ✓ Phase 5 complete"
echo ""
echo "✅ All preparation steps completed successfully!"
echo ""

# Exit successfully
exit 0
