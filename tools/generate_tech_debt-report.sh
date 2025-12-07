#!/usr/bin/env bash
# =========================================================
# OpenSSL Tech Debt Observatory - Tech Debt Reporter
# Author: Basil Addington
# Purpose: Run clang-tidy across OpenSSL repo, focusing on
#          high-priority tech debt, and generate a summarized
#          report for analysis.
# Notes:
#   - Can be run from tools/ directory.
#   - Reads compile_commands.json from OpenSSL root.
#   - Prints screen output and saves report to OPENSSL_REPORT.txt
#   - AI Generated chatgpt
# =========================================================

set -e
set -o pipefail

# -----------------------------
# CONFIGURATION
# -----------------------------

# Absolute path to OpenSSL repo
OPENSSL_DIR="/Users/basiladdington/Projects/tech-debt-showcase/local-repos/openssl"

# Path to clang-tidy (adjust if installed elsewhere)
CLANG_TIDY=$(which clang-tidy)

# Output report file
# The location of the file inside the main openSSL directory keeps it out of github
#   changes. This will be rather large file. Once the output is worthy of being
#   saved, then moving it to the research/ folder for public use would be needed.
REPORT_FILE="$OPENSSL_DIR/OPENSSL_TECH_DEBT_REPORT.txt"

# -----------------------------
# START SCRIPT
# -----------------------------
echo "=================================================="
echo "[INFO] OpenSSL Tech Debt Observatory - Tech Debt Reporter"
echo "[INFO] OpenSSL repo: $OPENSSL_DIR"
echo "[INFO] Using clang-tidy: $CLANG_TIDY"
echo "=================================================="

# -----------------------------
# Verify OpenSSL directory exists
# -----------------------------
if [[ ! -d "$OPENSSL_DIR" ]]; then
    echo "[ERROR] OpenSSL directory not found: $OPENSSL_DIR"
    exit 1
fi

# -----------------------------
# Move into OpenSSL directory
# -----------------------------
cd "$OPENSSL_DIR"
echo "[INFO] Entered OpenSSL directory: $(pwd)"

# -----------------------------
# Verify compile_commands.json exists
# -----------------------------
if [[ ! -f compile_commands.json ]]; then
    echo "[ERROR] compile_commands.json not found! Run build_compile_db.sh first."
    exit 1
fi

# -----------------------------
# Clear previous report
# -----------------------------
rm -f "$REPORT_FILE"
echo "[INFO] Generating new tech debt report..."
echo "OpenSSL Tech Debt Observatory Report" >> "$REPORT_FILE"
echo "Generated: $(date)" >> "$REPORT_FILE"
echo "==================================================" >> "$REPORT_FILE"

# -----------------------------
# Find all .c files in apps/, crypto/, providers/
# -----------------------------
FILES=$(find apps crypto providers -type f -name "*.c")

TOTAL_FILES=$(echo "$FILES" | wc -l)
echo "[INFO] Found $TOTAL_FILES C source files to analyze"

# -----------------------------
# Run clang-tidy on each file
# -----------------------------
COUNTER=0
for FILE in $FILES; do
    COUNTER=$((COUNTER+1))
    echo "[INFO] [$COUNTER/$TOTAL_FILES] Analyzing $FILE ..."
    
    # Run clang-tidy with compile_commands.json, high-priority checks only
    "$CLANG_TIDY" -p="$OPENSSL_DIR" "$FILE" \
        -checks='bugprone-*,clang-analyzer-*,performance-*,readability-*,cppcoreguidelines-*' \
        -quiet >> "$REPORT_FILE" 2>&1 || true
done

# -----------------------------
# Summarize results
# -----------------------------
echo "==================================================" >> "$REPORT_FILE"
echo "[INFO] Tech debt scan complete." >> "$REPORT_FILE"
echo "[INFO] Report saved to $REPORT_FILE"
echo "=================================================="
echo "[INFO] Sample output (first 20 lines):"
head -n 20 "$REPORT_FILE"

echo "=================================================="
echo "[INFO] OpenSSL Tech Debt Observatory report generation complete."
echo " Don't forget to same the output file in the Showcase repo if ready"
echo " to publish and document findings."
echo "=================================================="
