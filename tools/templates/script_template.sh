#!/bin/bash
################################################################################
# script-name.sh - Brief One-Line Description
################################################################################
#
# @purpose: What problem does this solve?
#   - Primary use case or problem being addressed
#   - Expected output/deliverables
#   - Context within the Tech Debt Observatory project
#
# @workflow: High-level execution flow
#   Phase 1: First major step
#   Phase 2: Second major step  
#   Phase 3: Third major step
#   [Add more phases as needed]
#   └─> Note any phase dependencies or branching logic
#
# @dependencies: External requirements
#   System requirements:
#     - OS: macOS/Linux
#     - Shell: bash 4.0+ (or specify version)
#     - Required commands: git, awk, grep, etc.
#   File structure:
#     - /path/to/required/directory (description)
#     - /path/to/input/files (description)
#   Environment variables:
#     - ENV_VAR_NAME: Description (required/optional)
#   Permissions:
#     - Read access to X
#     - Write access to Y
#   Network:
#     - None / Internet access required / Specific API access
#
# @gotchas: Known issues and edge cases
#   Issue 1: [Description of what can go wrong]
#     Workaround: [How to handle or fix it]
#   Issue 2: [Another potential problem]
#     Mitigation: [Prevention or solution]
#   Performance: [Any performance limitations or notes]
#   Compatibility: [OS-specific or version-specific issues]
#
# USAGE:
#   ./script-name.sh [arguments]
#   
#   Arguments:
#     arg1 - Description of first argument
#     arg2 - Description of second argument (optional)
#
#   Examples:
#     ./script-name.sh input.txt
#     ./script-name.sh --flag value
#
# OUTPUT:
#   - Primary output location and format
#   - Secondary outputs (if any)
#
# RELATED SCRIPTS:
#   - related-script.sh - What it does and when to use it
#   - another-script.sh - Relationship to this script
#
################################################################################

# Error handling - Exit on error, undefined variables, and pipe failures
set -euo pipefail

# ===========================================
# CONFIGURATION SECTION
# @purpose: Define paths, settings, and constants
# @gotcha: [Any configuration-specific warnings]
# ===========================================

# Project paths (absolute paths recommended)
PROJECT_ROOT="/Users/basiladdington/Projects/tech-debt-showcase"
INPUT_DIR="$PROJECT_ROOT/input"
OUTPUT_DIR="$PROJECT_ROOT/output"

# Script-specific configuration
VARIABLE_NAME="default_value"  # Description of what this controls
TIMEOUT_SECONDS=30  # Maximum time to wait for operation
DEBUG_MODE=false  # Set to true for verbose output

# Derived variables (calculated from configuration above)
TIMESTAMP=$(date +%Y%m%d_%H%M%S)  # Used for output file naming
OUTPUT_FILE="$OUTPUT_DIR/result_${TIMESTAMP}.txt"

# ===========================================
# VALIDATION SECTION
# @purpose: Verify prerequisites before proceeding
# @why: Early failure prevents wasted processing time
# ===========================================

echo "🔍 Validating prerequisites..."

# Check: Script arguments
if [ $# -lt 1 ]; then
    echo "ERROR: Missing required argument"
    echo ""
    echo "Usage: $0 <argument>"
    echo ""
    echo "Example: $0 input.txt"
    exit 1
fi

# Check: Required directories exist
if [ ! -d "$INPUT_DIR" ]; then
    echo "ERROR: Input directory not found: $INPUT_DIR"
    echo ""
    echo "Please create it with: mkdir -p $INPUT_DIR"
    exit 1
fi

# Check: Required commands available
for cmd in git awk grep; do
    if ! command -v $cmd &> /dev/null; then
        echo "ERROR: Required command not found: $cmd"
        echo "Please install $cmd and try again"
        exit 1
    fi
done

# Check: Write permissions
if [ ! -w "$OUTPUT_DIR" ]; then
    echo "ERROR: No write permission for output directory: $OUTPUT_DIR"
    exit 1
fi

echo "  ✓ All prerequisites validated"
echo ""

# ===========================================
# FUNCTION DEFINITIONS
# ===========================================

################################################################################
# FUNCTION: example_function
#
# @purpose: Brief description of what this function does
#
# @params:
#   $1 - First parameter description
#   $2 - Second parameter description (optional)
#
# @output:
#   Echoes: Description of what is output
#   Returns: 0 on success, 1 on failure
#
# @algorithm:
#   1. Step one of the process
#   2. Step two of the process
#   3. Final step
#
# @gotchas:
#   - [Any function-specific edge cases]
#   - [Performance notes if relevant]
################################################################################
example_function() {
    local input="$1"
    local optional="${2:-default}"  # Parameter with default value
    
    # Validation: Check input is not empty
    if [ -z "$input" ]; then
        echo "ERROR: example_function requires non-empty input"
        return 1
    fi
    
    # WHY: Explaining non-obvious logic here
    # [Your implementation]
    
    echo "Processed: $input"
    return 0
}

# ===========================================
# MAIN EXECUTION
# ===========================================

echo "====================================="
echo "SCRIPT NAME - Brief Description"
echo "====================================="
echo ""

# ============================================
# PHASE 1: Phase Name
# @purpose: What this phase accomplishes
# @why: Why this phase is necessary
# @method: How it accomplishes the goal
# @output: What files/data this produces
# @gotcha: Phase-specific issues to watch for
# ============================================

echo "[PHASE 1] Starting phase name..."

# Phase implementation goes here
# Use progress indicators for long operations

echo "  ✓ Phase 1 complete"
echo ""

# ============================================
# PHASE 2: Second Phase Name
# @purpose: [Description]
# @why: [Reasoning]
# @method: [Approach]
# @output: [Products]
# @gotcha: [Warnings]
# ============================================

echo "[PHASE 2] Starting second phase..."

# Phase implementation

echo "  ✓ Phase 2 complete"
echo ""

# ============================================
# PHASE 3: Final Phase Name  
# @purpose: [Description]
# @why: [Reasoning]
# @method: [Approach]
# @output: [Products]
# @gotcha: [Warnings]
# ============================================

echo "[PHASE 3] Starting final phase..."

# Phase implementation

echo "  ✓ Phase 3 complete"
echo ""

# ============================================
# COMPLETION
# ============================================

echo ""
echo "====================================="
echo "PROCESSING COMPLETE"
echo "====================================="
echo ""
echo "Output directory: $OUTPUT_DIR"
echo ""
echo "Key files:"
echo "  • $OUTPUT_FILE - Primary output"
echo "  • [Other important outputs]"
echo ""
echo "Summary statistics:"
echo "  - Records processed: [number]"
echo "  - Errors encountered: [number]"
echo "  - Processing time: [duration]"
echo ""
echo "Next steps:"
echo "  1. Review output: cat $OUTPUT_FILE"
echo "  2. Run validation: ./validate-results.sh"
echo "  3. Generate report: ./make-report.sh $OUTPUT_FILE"
echo ""

# Exit successfully
exit 0
