#!/bin/bash
################################################################################
# quickstart.sh - DEPRECATED - Redirect to prepare-worst-cve.sh
################################################################################
#
# @purpose: Backwards compatibility wrapper for prepare-worst-cve.sh
#   - This script has been superseded by prepare-worst-cve.sh
#   - Redirects all calls to the canonical version
#   - Maintains backwards compatibility for existing workflows
#   - Provides deprecation notice to users
#
# @status: DEPRECATED (use prepare-worst-cve.sh instead)
#
# @history:
#   - Originally: Duplicate copy of prepare-worst-cve.sh
#   - 2024-12-07: Replaced with redirect wrapper
#   - Reason: Consolidate functionality in single well-documented script
#
# @workflow: Simple redirect
#   1. Display deprecation notice
#   2. Forward all arguments to prepare-worst-cve.sh
#   3. Exit with same exit code
#
# @dependencies:
#   - prepare-worst-cve.sh must exist in same directory
#
# @gotchas:
#   - Script name misleading (not actually a "quick start")
#   - Historical artifact from early development
#   - May be referenced in old documentation or scripts
#
# USAGE:
#   ./quickstart.sh <csv_results_file> [file_index]
#   
#   This will automatically redirect to:
#   ./prepare-worst-cve.sh <csv_results_file> [file_index]
#
# MIGRATION:
#   Update your scripts to call prepare-worst-cve.sh directly:
#   
#   OLD: ./quickstart.sh results.csv 1
#   NEW: ./prepare-worst-cve.sh results.csv 1
#
# RELATED SCRIPTS:
#   - prepare-worst-cve.sh - The canonical version (USE THIS)
#   - analyze-comments.sh - Generates CSV input for prepare-worst-cve.sh
#
################################################################################

# Get the directory where this script is located
# WHY: Ensures we can find prepare-worst-cve.sh regardless of where script is called from
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_SCRIPT="$SCRIPT_DIR/prepare-worst-cve.sh"

# Display deprecation notice
# WHY: Educate users to migrate to canonical script
echo "═══════════════════════════════════════════════════════════════"
echo "  ⚠️  DEPRECATION NOTICE"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "The script 'quickstart.sh' has been deprecated."
echo ""
echo "Please use 'prepare-worst-cve.sh' instead:"
echo "  $TARGET_SCRIPT"
echo ""
echo "This redirect will forward your request automatically..."
echo ""

# Wait briefly for user to see notice
# WHY: Gives user time to read deprecation message
sleep 2

# Verify target script exists
# WHY: Provide helpful error if prepare-worst-cve.sh is missing
if [[ ! -f "$TARGET_SCRIPT" ]]; then
    echo "ERROR: prepare-worst-cve.sh not found at: $TARGET_SCRIPT"
    echo ""
    echo "Please ensure prepare-worst-cve.sh exists in the same directory."
    echo ""
    exit 1
fi

# Verify target script is executable
# WHY: Common issue after git clone or file copy
if [[ ! -x "$TARGET_SCRIPT" ]]; then
    echo "WARNING: prepare-worst-cve.sh is not executable"
    echo "Fixing permissions..."
    chmod +x "$TARGET_SCRIPT"
fi

# Forward all arguments to canonical script
# WHY: Maintains backwards compatibility while encouraging migration
echo "Redirecting to: prepare-worst-cve.sh $*"
echo ""

# Execute the canonical script with all original arguments
# WHY: "$@" preserves argument quoting and spaces
exec "$TARGET_SCRIPT" "$@"

# Note: exec replaces current process, so script ends here
# Exit code will be whatever prepare-worst-cve.sh returns
