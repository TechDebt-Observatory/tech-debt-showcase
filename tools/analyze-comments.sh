#!/bin/bash

################################################################################
# CVE-Patched File Comment Ratio Analyzer for OpenSSL
################################################################################
#
# PURPOSE:
#   Analyzes OpenSSL files that were patched for CVEs in the last 2 years,
#   calculates their comment ratios, and identifies the least-documented
#   security-critical code.
#
# USAGE:
#   ./analyze_cve_comments.sh [openssl_repo_path]
#
# OUTPUT:
#   CSV file with: filename, total_lines, comment_lines, code_lines, 
#                  comment_ratio, cve_numbers
#
################################################################################

set -euo pipefail

# Configuration
OPENSSL_REPO="${1:-$HOME/Shared/analysis/repos/openssl}"
OUTPUT_DIR="$HOME/Shared/cve_comment_analysis"
RESULTS_FILE="$OUTPUT_DIR/cve_files_by_comment_ratio.csv"
TEMP_DIR="$OUTPUT_DIR/temp"

# CVE commits from last 2 years (2023-2025)
# Format: "commit_hash|CVE_number|description"
declare -a CVE_COMMITS=(
    "738d4f9fdeaad57660dcba50a619fafced3fd5e9|CVE-2024-12797|RPK authentication failure"
    "87ebd203feffcf92ad5889df92f90bb0ee10a699|CVE-2024-12797|RPK authentication test"
    "798779dff4fb70d7c0c7b7db1e013e245d880026|CVE-2024-12797|RPK authentication 3.2"
)

# Add more CVEs from 2023-2024 that we can look up
declare -a CVE_PATTERNS=(
    "CVE-2024-12797"
    "CVE-2024-4741"
    "CVE-2024-4603"
    "CVE-2023-3446"
    "CVE-2023-3817"
    "CVE-2023-5678"
    "CVE-2023-0286"
    "CVE-2023-0464"
    "CVE-2023-0465"
    "CVE-2023-0466"
)

################################################################################
# FUNCTION: calculate_comment_ratio
#
# Calculates the comment ratio for a C source file.
#
# PARAMETERS:
#   $1 - Full path to the C file
#
# OUTPUTS:
#   Echoes: "total_lines|comment_lines|code_lines|ratio"
#
# ALGORITHM:
#   - Counts total lines
#   - Counts single-line comments (// and /*)
#   - Counts multi-line comment blocks (/* ... */)
#   - Calculates code lines = total - blank - comments
#   - Returns ratio as percentage
################################################################################
calculate_comment_ratio() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        echo "0|0|0|0.00"
        return
    fi
    
    # Total lines
    local total_lines=$(wc -l < "$file")
    
    # Blank lines
    local blank_lines=$(grep -c "^[[:space:]]*$" "$file" || true)
    
    # Single-line comments (// style and single-line /* */ )
    local single_comments=$(grep -c "^[[:space:]]*//\|^[[:space:]]*/\*.*\*/" "$file" || true)
    
    # Multi-line comment blocks - count lines between /* and */
    local multiline_comments=0
    local in_comment=0
    
    while IFS= read -r line; do
        # Check if line starts a comment
        if [[ "$line" =~ /\* ]] && [[ ! "$line" =~ \*/ ]]; then
            in_comment=1
            ((multiline_comments++))
        # Check if we're in a comment
        elif [[ $in_comment -eq 1 ]]; then
            ((multiline_comments++))
            # Check if comment ends
            if [[ "$line" =~ \*/ ]]; then
                in_comment=0
            fi
        fi
    done < "$file"
    
    # Total comment lines
    local comment_lines=$((single_comments + multiline_comments))
    
    # Code lines (non-blank, non-comment)
    local code_lines=$((total_lines - blank_lines - comment_lines))
    
    # Prevent negative numbers
    if [[ $code_lines -lt 0 ]]; then
        code_lines=0
    fi
    
    # Calculate ratio (avoid division by zero)
    local ratio="0.00"
    if [[ $code_lines -gt 0 ]]; then
        ratio=$(awk "BEGIN {printf \"%.2f\", ($comment_lines / $code_lines) * 100}")
    fi
    
    echo "$total_lines|$comment_lines|$code_lines|$ratio"
}

################################################################################
# FUNCTION: get_files_from_commit
#
# Extracts list of C files changed in a specific commit.
#
# PARAMETERS:
#   $1 - Commit hash
#
# OUTPUTS:
#   List of file paths (one per line)
################################################################################
get_files_from_commit() {
    local commit="$1"
    cd "$OPENSSL_REPO"
    
    # Get list of files changed in this commit (C and H files only)
    git show --name-only --pretty="" "$commit" | grep -E '\.(c|h)$' || true
}

################################################################################
# FUNCTION: find_cve_commits
#
# Searches git log for commits mentioning CVEs in last 2 years.
#
# OUTPUTS:
#   List of "commit_hash|CVE_number" pairs
################################################################################
find_cve_commits() {
    cd "$OPENSSL_REPO"
    
    local since_date="2023-01-01"
    
    for cve in "${CVE_PATTERNS[@]}"; do
        # Search commit messages for CVE references
        git log --since="$since_date" --grep="$cve" --pretty=format:"%H|$cve" || true
    done | sort -u
}

################################################################################
# MAIN EXECUTION
################################################################################

echo "═══════════════════════════════════════════════════════════════"
echo "  CVE-Patched File Comment Ratio Analyzer"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Validate repository exists
if [[ ! -d "$OPENSSL_REPO/.git" ]]; then
    echo "ERROR: OpenSSL repository not found at: $OPENSSL_REPO"
    echo "Usage: $0 [path_to_openssl_repo]"
    exit 1
fi

echo "✓ Found OpenSSL repository at: $OPENSSL_REPO"
echo ""

# Create output directory
mkdir -p "$OUTPUT_DIR"
mkdir -p "$TEMP_DIR"

# Initialize results file
echo "file_path,total_lines,comment_lines,code_lines,comment_ratio_pct,cve_numbers" > "$RESULTS_FILE"

echo "Analyzing files changed in CVE commits..."
echo ""

# Track files we've already analyzed (to avoid duplicates)
declare -A analyzed_files

# First, analyze known CVE commits
echo "Phase 1: Analyzing known CVE commits..."
for entry in "${CVE_COMMITS[@]}"; do
    IFS='|' read -r commit cve description <<< "$entry"
    
    echo "  → $cve ($commit): $description"
    
    # Get files from this commit
    while IFS= read -r file; do
        if [[ -z "$file" ]]; then
            continue
        fi
        
        # Full path to file
        full_path="$OPENSSL_REPO/$file"
        
        # Skip if already analyzed
        if [[ -n "${analyzed_files[$file]:-}" ]]; then
            # Add this CVE to existing entry
            analyzed_files[$file]="${analyzed_files[$file]},$cve"
            continue
        fi
        
        # Analyze file if it exists
        if [[ -f "$full_path" ]]; then
            echo "    Analyzing: $file"
            
            # Calculate comment ratio
            IFS='|' read -r total comments code ratio <<< "$(calculate_comment_ratio "$full_path")"
            
            # Store in associative array
            analyzed_files[$file]="$total|$comments|$code|$ratio|$cve"
        fi
    done < <(get_files_from_commit "$commit")
done

echo ""
echo "Phase 2: Searching git history for additional CVE commits..."

# Search for additional CVE commits
while IFS='|' read -r commit cve; do
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
        
        # Skip if already analyzed
        if [[ -n "${analyzed_files[$file]:-}" ]]; then
            # Add this CVE to existing entry
            if [[ ! "${analyzed_files[$file]}" =~ $cve ]]; then
                analyzed_files[$file]="${analyzed_files[$file]},$cve"
            fi
            continue
        fi
        
        # Analyze file if it exists
        if [[ -f "$full_path" ]]; then
            IFS='|' read -r total comments code ratio <<< "$(calculate_comment_ratio "$full_path")"
            analyzed_files[$file]="$total|$comments|$code|$ratio|$cve"
        fi
    done < <(get_files_from_commit "$commit")
done < <(find_cve_commits)

echo ""
echo "Phase 3: Writing results..."

# Write all results to CSV
for file in "${!analyzed_files[@]}"; do
    IFS='|' read -r total comments code ratio cves <<< "${analyzed_files[$file]}"
    
    # Escape commas in file path and CVE list
    file_escaped="${file//,/;}"
    cves_escaped="${cves//,/ }"
    
    echo "$file_escaped,$total,$comments,$code,$ratio,$cves_escaped" >> "$RESULTS_FILE"
done

# Sort by comment ratio (ascending - lowest first)
{
    head -n 1 "$RESULTS_FILE"  # Keep header
    tail -n +2 "$RESULTS_FILE" | sort -t',' -k5 -n
} > "$TEMP_DIR/sorted.csv"

mv "$TEMP_DIR/sorted.csv" "$RESULTS_FILE"

echo "✓ Analysis complete!"
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  RESULTS"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Files analyzed: ${#analyzed_files[@]}"
echo ""
echo "Top 10 files with LOWEST comment ratios (most under-documented):"
echo ""
printf "%-50s %8s %8s %8s %8s %s\n" "FILE" "TOTAL" "COMMENTS" "CODE" "RATIO%" "CVEs"
printf "%-50s %8s %8s %8s %8s %s\n" "=====" "=====" "========" "====" "======" "===="

# Display top 10 lowest comment ratios
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

total_files=${#analyzed_files[@]}
avg_ratio=$(awk -F',' 'NR>1 {sum+=$5; count++} END {if(count>0) printf "%.2f", sum/count; else print "0.00"}' "$RESULTS_FILE")
min_ratio=$(awk -F',' 'NR>1 {print $5}' "$RESULTS_FILE" | sort -n | head -n1)
max_ratio=$(awk -F',' 'NR>1 {print $5}' "$RESULTS_FILE" | sort -n | tail -n1)

echo "Total CVE-patched files analyzed: $total_files"
echo "Average comment ratio: ${avg_ratio}%"
echo "Lowest comment ratio: ${min_ratio}%"
echo "Highest comment ratio: ${max_ratio}%"
echo ""

# List unique CVEs found
echo "CVEs found in analysis:"
unique_cves=$(awk -F',' 'NR>1 {print $6}' "$RESULTS_FILE" | tr ' ' '\n' | sort -u | grep -v '^$')
echo "$unique_cves" | while read -r cve; do
    count=$(grep -c "$cve" "$RESULTS_FILE" || true)
    echo "  - $cve: $count files"
done

echo ""
echo "Next steps:"
echo "  1. Review the lowest-ratio files in: $RESULTS_FILE"
echo "  2. Use your existing methodology to document the worst offenders"
echo "  3. Cross-reference with your asn1parse.c analysis (348 lines, ~5% comments)"
echo ""
echo "═══════════════════════════════════════════════════════════════"