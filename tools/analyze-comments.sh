#!/bin/bash
################################################################################
# analyze-comments.sh - CVE-Patched File Comment Ratio Analyzer
################################################################################
#
# @purpose: Identify least-documented security-critical code in OpenSSL
#   - Analyzes OpenSSL files patched for CVEs in last 2 years
#   - Calculates comment ratio (comment lines vs code lines)
#   - Ranks files by documentation quality (lowest ratio = worst documented)
#   - Identifies specific CVEs that affected each file
#   - Generates CSV for further analysis (input for prepare-worst-cve.sh)
#   - Enables systematic targeting of high-risk, low-documentation code
#
# @workflow: Three-phase analysis process
#   Phase 1: Analyze Known CVE Commits
#     └─> Process hardcoded CVE_COMMITS array, extract files, calculate ratios
#   Phase 2: Search Git History for Additional CVEs
#     └─> Scan git log for CVE_PATTERNS, find additional commits, deduplicate
#   Phase 3: Generate Results and Statistics
#     └─> Sort by ratio, write CSV, display summary, show worst offenders
#
# @dependencies: External requirements
#   System requirements:
#     - OS: macOS/Linux with bash 4.0+ (associative arrays required)
#     - Shell: bash (set -euo pipefail used for safety)
#     - Required commands: git, awk, grep, sort, wc, head, tail, basename
#   File structure:
#     - $OPENSSL_REPO: OpenSSL git repository (default: ~/Shared/analysis/repos/openssl)
#     - $OUTPUT_DIR: Analysis workspace (default: ~/Shared/cve_comment_analysis)
#   Permissions:
#     - Read access to OpenSSL repository
#     - Write access to output directory
#   Network:
#     - None required (works offline with cloned repo)
#
# @gotchas: Known issues and edge cases
#   Bash Version Requirement:
#     - Requires bash 4.0+ for associative arrays (declare -A)
#     - macOS ships with bash 3.2 by default
#     - Error: "declare: -A: invalid option" → Install bash via Homebrew
#     - Workaround: brew install bash && /usr/local/bin/bash analyze-comments.sh
#   Nested Comment Detection:
#     - Multiline comment detection may fail on nested /* */ patterns
#     - Rare in C but can cause undercounting of comment lines
#     - Impact: Comment ratios may be slightly lower than actual
#   CVE Pattern Maintenance:
#     - CVE_PATTERNS array must be manually updated for new CVEs
#     - Check OpenSSL security advisories quarterly
#     - Add new patterns to keep analysis current
#   File Deduplication:
#     - Files may appear in multiple CVE commits
#     - Associative array prevents reanalysis but accumulates CVE list
#     - CVE list concatenation uses comma separator (may need parsing)
#   Deleted Files:
#     - Git history may reference files deleted in later commits
#     - Script silently skips non-existent files (no error)
#     - Some CVE fixes may not be captured if files were removed
#   Comment Style Variations:
#     - Only counts C-style comments (// and /* */)
#     - Doesn't detect documentation comments (/** */) separately
#     - Preprocessor directives (#if 0) used as comments not counted
#
# USAGE:
#   ./analyze-comments.sh [openssl_repo_path]
#   
#   Arguments:
#     openssl_repo_path - Path to OpenSSL git repository (optional)
#                        Default: ~/Shared/analysis/repos/openssl
#
#   Examples:
#     ./analyze-comments.sh
#     ./analyze-comments.sh ~/repos/openssl
#     ./analyze-comments.sh /custom/path/to/openssl
#
# OUTPUT:
#   $OUTPUT_DIR/cve_files_by_comment_ratio.csv
#     Format: file_path,total_lines,comment_lines,code_lines,comment_ratio_pct,cve_numbers
#     Sorted: Ascending by comment ratio (worst documented first)
#     Used by: prepare-worst-cve.sh for selecting analysis targets
#
# RELATED SCRIPTS:
#   - prepare-worst-cve.sh - Uses CSV output to prepare worst file for analysis
#   - cve_2023_3446_forensics.sh - Forensic extraction for specific CVE
#   - setup-pipeline.sh - Full environment setup if dependencies missing
#
################################################################################

# Error handling - Exit on error, undefined variables, and pipe failures
set -euo pipefail

# ===========================================
# CONFIGURATION SECTION
# @purpose: Define paths, CVE patterns, and analysis parameters
# @why: Centralized configuration enables easy customization and updates
# @gotcha: CVE_PATTERNS must be manually maintained - check OpenSSL advisories quarterly
# ===========================================

# OpenSSL repository location (can override via command line argument)
# WHY: Allows flexibility in repository location without editing script
OPENSSL_REPO="${1:-$HOME/Shared/analysis/repos/openssl}"

# Output directory for analysis results
# WHY: Centralized location for all CVE analysis outputs
OUTPUT_DIR="$HOME/Shared/cve_comment_analysis"

# Main results file (sorted by comment ratio)
# WHY: CSV format enables easy consumption by prepare-worst-cve.sh and spreadsheet tools
RESULTS_FILE="$OUTPUT_DIR/cve_files_by_comment_ratio.csv"

# Temporary directory for intermediate processing
# WHY: Separate temp space keeps output directory clean
TEMP_DIR="$OUTPUT_DIR/temp"

# ===========================================
# CVE COMMIT DATABASE
# @purpose: Hardcoded list of known CVE commits for fast analysis
# @why: Avoids expensive git log searches for well-known CVEs
# @format: "commit_hash|CVE_number|description"
# @maintenance: Add new entries when major CVEs are discovered
# ===========================================

# Known CVE commits from 2023-2025
# WHY: Starting with known commits is faster than searching entire git history
declare -a CVE_COMMITS=(
    "738d4f9fdeaad57660dcba50a619fafced3fd5e9|CVE-2024-12797|RPK authentication failure"
    "87ebd203feffcf92ad5889df92f90bb0ee10a699|CVE-2024-12797|RPK authentication test"
    "798779dff4fb70d7c0c7b7db1e013e245d880026|CVE-2024-12797|RPK authentication 3.2"
)

# ===========================================
# CVE SEARCH PATTERNS
# @purpose: List of CVE identifiers to search in git history
# @why: Comprehensive pattern list ensures we find all security-related commits
# @maintenance: UPDATE THIS QUARTERLY - Check https://www.openssl.org/news/secadv.html
# @gotcha: Missing patterns = missing analysis = incomplete results
# ===========================================

# CVE patterns from 2023-2024 OpenSSL security advisories
# WHY: Covers critical vulnerabilities from last 2 years
# MAINTENANCE: Add new CVEs as they are disclosed
declare -a CVE_PATTERNS=(
    "CVE-2024-12797"  # RPK authentication failure (Dec 2024)
    "CVE-2024-4741"   # Use-after-free in SSL_free_buffers (May 2024)
    "CVE-2024-4603"   # Excessive time in DH check (Apr 2024)
    "CVE-2023-3446"   # DH_check() excessive time (Jul 2023)
    "CVE-2023-3817"   # Excessive time in DH verify (Aug 2023)
    "CVE-2023-5678"   # Improper null pointer check (Nov 2023)
    "CVE-2023-0286"   # X.400 address type confusion (Feb 2023)
    "CVE-2023-0464"   # Policy constraints not checked (Mar 2023)
    "CVE-2023-0465"   # Invalid certificate policy (Mar 2023)
    "CVE-2023-0466"   # Policy verification omission (Mar 2023)
)

# ===========================================
# VALIDATION SECTION
# @purpose: Verify prerequisites before analysis
# @why: Early failure prevents wasted processing time
# ===========================================

echo "═══════════════════════════════════════════════════════════════"
echo "  CVE-Patched File Comment Ratio Analyzer"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Check: Bash version supports associative arrays
# WHY: Script uses declare -A which requires bash 4.0+
if ((BASH_VERSINFO[0] < 4)); then
    echo "ERROR: This script requires bash 4.0 or higher"
    echo "Current version: $BASH_VERSION"
    echo ""
    echo "macOS users:"
    echo "  brew install bash"
    echo "  /usr/local/bin/bash analyze-comments.sh"
    echo ""
    exit 1
fi

# Check: OpenSSL repository exists and is valid git repo
# WHY: Cannot analyze without source repository
if [[ ! -d "$OPENSSL_REPO/.git" ]]; then
    echo "ERROR: OpenSSL repository not found at: $OPENSSL_REPO"
    echo ""
    echo "Please clone OpenSSL repository:"
    echo "  mkdir -p $(dirname "$OPENSSL_REPO")"
    echo "  cd $(dirname "$OPENSSL_REPO")"
    echo "  git clone https://github.com/openssl/openssl.git"
    echo ""
    echo "Or specify custom path:"
    echo "  $0 /path/to/your/openssl"
    echo ""
    exit 1
fi

echo "✓ Found OpenSSL repository at: $OPENSSL_REPO"
echo "✓ Bash version: $BASH_VERSION"
echo ""

# Create output directories
# WHY: mkdir -p is safe for existing directories
mkdir -p "$OUTPUT_DIR"
mkdir -p "$TEMP_DIR"

################################################################################
# FUNCTION: calculate_comment_ratio
#
# @purpose: Calculate comment coverage ratio for a C source file
#
# @params:
#   $1 - Full path to C file to analyze
#
# @output:
#   Echoes: "total_lines|comment_lines|code_lines|ratio"
#   Returns: 0 on success, 1 if file not found
#
# @algorithm:
#   1. Count total lines in file
#   2. Count blank lines (whitespace only)
#   3. Count single-line comments (// and /* ... */)
#   4. Count multi-line comment blocks (/* ... */)
#   5. Calculate code_lines = total - blank - comments
#   6. Calculate ratio = (comments / code) * 100
#   7. Format as pipe-delimited string
#
# @gotchas:
#   - Nested comments: /* /* nested */ */ may be miscounted
#     Impact: Rare in C, minimal effect on ratio accuracy
#   - String literals: Code like printf("/* not a comment */") counted as comment
#     Impact: Very rare, typically <1% effect on ratio
#   - Preprocessor: #if 0 ... #endif blocks used as comments not detected
#     Impact: Undercounts documentation in files using this pattern
#   - Multi-line detection: State machine tracks /* */ boundaries
#     Limitation: Assumes comments don't span /* ... /* ... */ patterns
#
# @example:
#   result=$(calculate_comment_ratio "/path/to/file.c")
#   IFS='|' read total comments code ratio <<< "$result"
################################################################################
calculate_comment_ratio() {
    local file="$1"
    
    # Validate: File must exist
    # WHY: Avoid errors on deleted or moved files
    if [[ ! -f "$file" ]]; then
        echo "0|0|0|0.00"
        return 1
    fi
    
    # Count total lines
    # WHY: Baseline for all calculations
    local total_lines
    total_lines=$(wc -l < "$file")
    
    # Count blank lines (whitespace only)
    # WHY: Need to exclude from both comment and code counts
    local blank_lines
    blank_lines=$(grep -c "^[[:space:]]*$" "$file" || true)
    
    # Count single-line comments
    # WHY: Catches // comments and single-line /* */ comments
    # PATTERN: Lines starting with optional whitespace then // or /* ... */
    local single_comments
    single_comments=$(grep -c "^[[:space:]]*//\|^[[:space:]]*/\*.*\*/" "$file" || true)
    
    # Count multi-line comment blocks using state machine
    # WHY: /* ... */ blocks can span many lines, need line-by-line tracking
    local multiline_comments=0
    local in_comment=0
    
    while IFS= read -r line; do
        # State machine for multi-line comment detection
        # WHY: Tracks whether we're inside a /* */ block
        
        # Check if line starts a multi-line comment
        # GOTCHA: Assumes /* on its own line (common C style)
        if [[ "$line" =~ /\* ]] && [[ ! "$line" =~ \*/ ]]; then
            in_comment=1
            ((multiline_comments++))
        # Check if we're inside a comment
        elif [[ $in_comment -eq 1 ]]; then
            ((multiline_comments++))
            # Check if comment ends on this line
            if [[ "$line" =~ \*/ ]]; then
                in_comment=0
            fi
        fi
    done < "$file"
    
    # Calculate total comment lines
    # WHY: Combines single-line and multi-line counts
    local comment_lines=$((single_comments + multiline_comments))
    
    # Calculate code lines (total minus blank minus comments)
    # WHY: Actual executable/declarative code lines
    local code_lines=$((total_lines - blank_lines - comment_lines))
    
    # Prevent negative numbers from counting errors
    # WHY: Edge case where comment detection overcounts
    # GOTCHA: Can happen with nested comments or strings containing comment syntax
    if [[ $code_lines -lt 0 ]]; then
        code_lines=0
    fi
    
    # Calculate comment ratio as percentage
    # WHY: Ratio (comments/code * 100) is standard metric for documentation coverage
    local ratio="0.00"
    if [[ $code_lines -gt 0 ]]; then
        ratio=$(awk "BEGIN {printf \"%.2f\", ($comment_lines / $code_lines) * 100}")
    fi
    
    # Return pipe-delimited result
    # WHY: Easy parsing with IFS='|' read in calling code
    echo "$total_lines|$comment_lines|$code_lines|$ratio"
}

################################################################################
# FUNCTION: get_files_from_commit
#
# @purpose: Extract list of C/H files changed in a specific git commit
#
# @params:
#   $1 - Git commit hash
#
# @output:
#   List of file paths (one per line), relative to repository root
#   Only C and H files (filters out other file types)
#
# @algorithm:
#   1. Change to OpenSSL repository directory
#   2. Run git show with --name-only to get changed files
#   3. Filter for .c and .h extensions using grep
#   4. Return file list to stdout
#
# @gotchas:
#   - Deleted files: May return paths to files that no longer exist
#     Workaround: Caller should check file existence before processing
#   - Renamed files: Git shows both old and new paths
#     Impact: Minimal, both paths will be checked and only existing one analyzed
#
# @example:
#   files=$(get_files_from_commit "abc123def456")
################################################################################
get_files_from_commit() {
    local commit="$1"
    
    # Change to repository for git commands
    # WHY: Git commands must run from within repository
    cd "$OPENSSL_REPO"
    
    # Extract C/H files from commit
    # WHY: Only interested in source files, not build scripts or docs
    # --name-only: Just filenames, no diff content
    # --pretty="": No commit message in output
    # || true: Don't fail if no C/H files in commit
    git show --name-only --pretty="" "$commit" | grep -E '\.(c|h)$' || true
}

################################################################################
# FUNCTION: find_cve_commits
#
# @purpose: Search git history for commits mentioning CVE patterns
#
# @output:
#   List of "commit_hash|CVE_number" pairs (one per line)
#   Deduplicated with sort -u
#
# @algorithm:
#   1. Change to OpenSSL repository
#   2. For each CVE pattern in CVE_PATTERNS array:
#      a. Search git log since 2023-01-01
#      b. Look for CVE in commit messages (--grep)
#      c. Format as "hash|CVE" pairs
#   3. Deduplicate results
#
# @gotchas:
#   - Date range: Only searches since 2023-01-01
#     WHY: Focuses on recent vulnerabilities (last 2 years)
#     Impact: Older CVEs won't be found
#   - Commit message format: Assumes CVE mentioned in commit message
#     Impact: Some CVEs might be referenced only in PR descriptions
#   - Multiple CVEs per commit: Each CVE gets separate entry
#     WHY: Enables tracking which CVEs affected which files
#
# @example:
#   while IFS='|' read -r hash cve; do
#       echo "Found $cve in commit $hash"
#   done < <(find_cve_commits)
################################################################################
find_cve_commits() {
    cd "$OPENSSL_REPO"
    
    # Date range for CVE search
    # WHY: Last 2 years captures recent security fixes
    local since_date="2023-01-01"
    
    # Search for each CVE pattern
    # WHY: Comprehensive search across all known CVE identifiers
    for cve in "${CVE_PATTERNS[@]}"; do
        # Git log search:
        # --since: Limit to recent commits (performance optimization)
        # --grep: Search commit messages for CVE identifier
        # --pretty=format: Custom output format (hash|CVE)
        # || true: Don't fail if pattern not found
        git log --since="$since_date" --grep="$cve" --pretty=format:"%H|$cve" || true
    done | sort -u  # Deduplicate results
}

# ===========================================
# MAIN EXECUTION
# ===========================================

# Initialize results CSV with header
# WHY: Standard CSV format with descriptive column names
echo "file_path,total_lines,comment_lines,code_lines,comment_ratio_pct,cve_numbers" > "$RESULTS_FILE"

echo "Analyzing files changed in CVE commits..."
echo ""

# Initialize file tracking
# WHY: Associative array prevents duplicate analysis and accumulates CVE lists
# BASH 4.0+ REQUIRED: declare -A creates associative array (hash map)
declare -A analyzed_files

# ============================================
# PHASE 1: Analyze Known CVE Commits
# @purpose: Process hardcoded CVE_COMMITS array for fast analysis
# @why: Known commits avoid expensive git log searches
# @method: Iterate CVE_COMMITS, extract files, calculate ratios, store in array
# @output: Populates analyzed_files associative array with ratios and CVE lists
# @gotcha: Files may be deleted between commit and now (silently skipped)
# ============================================

echo "[PHASE 1] Analyzing known CVE commits..."

# Process each hardcoded CVE commit
# WHY: Starting with known commits is faster than searching entire git history
for entry in "${CVE_COMMITS[@]}"; do
    # Parse pipe-delimited entry
    # WHY: IFS='|' read splits on pipe separator
    IFS='|' read -r commit cve description <<< "$entry"
    
    echo "  → $cve ($commit): $description"
    
    # Get all C/H files modified in this commit
    while IFS= read -r file; do
        # Skip empty lines from grep
        if [[ -z "$file" ]]; then
            continue
        fi
        
        # Construct full path to file
        full_path="$OPENSSL_REPO/$file"
        
        # Check if file already analyzed
        # WHY: Files may appear in multiple CVE commits
        if [[ -n "${analyzed_files[$file]:-}" ]]; then
            # File already processed - append this CVE to list
            # WHY: Tracks all CVEs that affected this file
            analyzed_files[$file]="${analyzed_files[$file]},$cve"
            continue
        fi
        
        # Analyze file if it exists in current repository state
        # WHY: Some files may have been deleted since the CVE commit
        if [[ -f "$full_path" ]]; then
            echo "    Analyzing: $file"
            
            # Calculate comment ratio
            IFS='|' read -r total comments code ratio <<< "$(calculate_comment_ratio "$full_path")"
            
            # Store in associative array
            # KEY: File path (relative to repo)
            # VALUE: total|comments|code|ratio|CVE_list
            analyzed_files[$file]="$total|$comments|$code|$ratio|$cve"
        fi
    done < <(get_files_from_commit "$commit")
done

echo ""

# ============================================
# PHASE 2: Search Git History for Additional CVEs
# @purpose: Find CVE commits not in hardcoded list
# @why: Comprehensive analysis requires searching entire git history
# @method: Scan git log for CVE_PATTERNS, extract files, deduplicate
# @output: Adds newly found files to analyzed_files array, appends CVEs to existing files
# @gotcha: Expensive operation (searches entire git history), may take 1-2 minutes
# ============================================

echo "[PHASE 2] Searching git history for additional CVE commits..."

# Search for additional CVE commits using find_cve_commits function
# WHY: Hardcoded list may miss recently disclosed CVEs
while IFS='|' read -r commit cve; do
    # Skip empty results
    if [[ -z "$commit" ]]; then
        continue
    fi
    
    echo "  → Found $cve in commit $commit"
    
    # Get files from this commit
    while IFS= read -r file; do
        if [[ -z "$file" ]]; then
            continue
        fi
        
        full_path="$OPENSSL_REPO/$file"
        
        # Check if file already analyzed
        if [[ -n "${analyzed_files[$file]:-}" ]]; then
            # Append CVE if not already in list
            # WHY: Avoid duplicate CVE entries like "CVE-2023-3446,CVE-2023-3446"
            if [[ ! "${analyzed_files[$file]}" =~ $cve ]]; then
                analyzed_files[$file]="${analyzed_files[$file]},$cve"
            fi
            continue
        fi
        
        # Analyze new file
        if [[ -f "$full_path" ]]; then
            IFS='|' read -r total comments code ratio <<< "$(calculate_comment_ratio "$full_path")"
            analyzed_files[$file]="$total|$comments|$code|$ratio|$cve"
        fi
    done < <(get_files_from_commit "$commit")
done < <(find_cve_commits)

echo ""

# ============================================
# PHASE 3: Generate Results and Statistics
# @purpose: Write CSV, sort by ratio, display summary, show worst offenders
# @why: Provides actionable results for documentation targeting
# @method: Write all files to CSV, sort ascending by ratio, display statistics
# @output: Final CSV file sorted by comment ratio + console summary
# @gotcha: CSV uses comma separator, which requires escaping commas in data
# ============================================

echo "[PHASE 3] Writing results..."

# Write all analyzed files to CSV
# WHY: CSV format enables consumption by prepare-worst-cve.sh and spreadsheet tools
for file in "${!analyzed_files[@]}"; do
    # Parse stored data
    IFS='|' read -r total comments code ratio cves <<< "${analyzed_files[$file]}"
    
    # Escape commas in file path and CVE list
    # WHY: CSV format uses commas as delimiters
    # GOTCHA: Replace commas with semicolons in paths (rare but possible)
    file_escaped="${file//,/;}"
    
    # Convert comma-separated CVE list to space-separated
    # WHY: Easier to read in final output, avoids CSV parsing issues
    cves_escaped="${cves//,/ }"
    
    # Write CSV row
    echo "$file_escaped,$total,$comments,$code,$ratio,$cves_escaped" >> "$RESULTS_FILE"
done

# Sort results by comment ratio (ascending - lowest first)
# WHY: Lowest ratios = worst documented = highest priority for analysis
{
    head -n 1 "$RESULTS_FILE"  # Keep CSV header
    tail -n +2 "$RESULTS_FILE" | sort -t',' -k5 -n  # Sort by column 5 (ratio) numerically
} > "$TEMP_DIR/sorted.csv"

# Replace original with sorted version
# WHY: In-place sort would lose data on error
mv "$TEMP_DIR/sorted.csv" "$RESULTS_FILE"

echo "✓ Analysis complete!"
echo ""

# Display results summary
echo "═══════════════════════════════════════════════════════════════"
echo "  RESULTS"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Files analyzed: ${#analyzed_files[@]}"
echo ""
echo "Top 10 files with LOWEST comment ratios (most under-documented):"
echo ""

# Print formatted table header
printf "%-50s %8s %8s %8s %8s %s\n" "FILE" "TOTAL" "COMMENTS" "CODE" "RATIO%" "CVEs"
printf "%-50s %8s %8s %8s %8s %s\n" "=====" "=====" "========" "====" "======" "===="

# Display top 10 worst-documented files
# WHY: Provides immediate visibility into priority targets
tail -n +2 "$RESULTS_FILE" | head -n 10 | while IFS=',' read -r file total comments code ratio cves; do
    printf "%-50s %8s %8s %8s %7s%% %s\n" \
        "$(basename "$file")" "$total" "$comments" "$code" "$ratio" "$cves"
done

echo ""
echo "Full results saved to: $RESULTS_FILE"
echo ""
echo "═══════════════════════════════════════════════════════════════"

# Generate summary statistics
echo ""
echo "Summary Statistics:"
echo "-------------------"

# Calculate aggregate metrics
# WHY: Provides context for individual file ratios
total_files=${#analyzed_files[@]}

# Declare variables before command substitution
# WHY: Prevents masking of command failures
avg_ratio=""
avg_ratio=$(awk -F',' 'NR>1 {sum+=$5; count++} END {if(count>0) printf "%.2f", sum/count; else print "0.00"}' "$RESULTS_FILE")

min_ratio=""
min_ratio=$(awk -F',' 'NR>1 {print $5}' "$RESULTS_FILE" | sort -n | head -n1)

max_ratio=""
max_ratio=$(awk -F',' 'NR>1 {print $5}' "$RESULTS_FILE" | sort -n | tail -n1)

echo "Total CVE-patched files analyzed: $total_files"
echo "Average comment ratio: ${avg_ratio}%"
echo "Lowest comment ratio: ${min_ratio}% (worst documented)"
echo "Highest comment ratio: ${max_ratio}% (best documented)"
echo ""

# List unique CVEs and file counts
# WHY: Shows which CVEs affected most files (broader impact)
echo "CVEs found in analysis:"

# Separate declaration and assignment to avoid masking return values
unique_cves=""
unique_cves=$(awk -F',' 'NR>1 {print $6}' "$RESULTS_FILE" | tr ' ' '\n' | sort -u | grep -v '^$')

echo "$unique_cves" | while read -r cve; do
    count=""
    count=$(grep -c "$cve" "$RESULTS_FILE" || true)
    printf "  - %-20s %3d files\n" "$cve:" "$count"
done

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  NEXT STEPS"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "1. Review worst-documented files:"
echo "     head -20 $RESULTS_FILE"
echo ""
echo "2. Prepare worst file for analysis:"
echo "     ./prepare-worst-cve.sh $RESULTS_FILE 1"
echo ""
echo "3. Compare to baseline (asn1parse.c: 348 lines, ~5% comments)"
echo ""
echo "4. Update CVE_PATTERNS array quarterly:"
echo "     Check: https://www.openssl.org/news/secadv.html"
echo "     Edit: Lines 118-131 in this script"
echo ""
echo "═══════════════════════════════════════════════════════════════"
