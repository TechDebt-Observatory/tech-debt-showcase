#!/bin/bash
# Complete Test Workflow with v2.0 Validation
# This script guides you through testing Phase 1 v6.1 prompt

set -e  # Exit on error

TEST_DIR="/Users/basiladdington/Projects/tech-debt-showcase/test-results/dictionary-fix-validation"

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Phase 1 v6.1 Documentation Test - Complete Workflow      ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Step 1: Prerequisites check
echo "Step 1: Checking prerequisites..."
echo ""

if [ ! -f "$TEST_DIR/dh_check.c" ]; then
    echo "⚠️  Source file dh_check.c not found"
    echo "   Creating from OpenSSL repository..."
    echo ""
    echo "   Please paste the dh_check.c content, then press Ctrl+D:"
    cat > "$TEST_DIR/dh_check.c"
    echo ""
    echo "✅ Source file created"
else
    echo "✅ Source file found: dh_check.c"
fi

echo ""

# Step 2: Show prompt location
echo "Step 2: Locating Phase 1 v6.1 prompt..."
echo ""

PROMPT_FILE="$TEST_DIR/../../../framework/prompts/phase1-v6.1-prompt.txt"

if [ -f "$PROMPT_FILE" ]; then
    echo "✅ Prompt found at:"
    echo "   $PROMPT_FILE"
else
    echo "⚠️  Prompt file not found at expected location"
    echo "   Please ensure you have the Phase 1 v6.1 prompt available"
    echo ""
    echo "   Expected location: framework/prompts/phase1-v6.1-prompt.txt"
fi

echo ""

# Step 3: AI documentation step
echo "Step 3: Generate documentation with AI..."
echo ""
echo "   Choose your AI platform:"
echo "   1. Claude Sonnet 4.5 (Recommended)"
echo "   2. Claude Opus 4"
echo "   3. GPT-4"
echo "   4. Other"
echo ""
read -p "   Selection (1-4): " ai_choice

case $ai_choice in
    1) AI_NAME="Claude Sonnet 4.5" ;;
    2) AI_NAME="Claude Opus 4" ;;
    3) AI_NAME="GPT-4" ;;
    4) 
        read -p "   Enter AI name: " AI_NAME
        ;;
    *)
        echo "   Invalid selection, using Claude Sonnet 4.5"
        AI_NAME="Claude Sonnet 4.5"
        ;;
esac

echo ""
echo "   Instructions for $AI_NAME:"
echo "   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "   1. Open $AI_NAME interface"
echo "   2. Copy Phase 1 v6.1 prompt from:"
echo "      $PROMPT_FILE"
echo "   3. Paste the prompt into AI chat"
echo "   4. Follow with the source file content from:"
echo "      $TEST_DIR/dh_check.c"
echo "   5. Wait for complete output"
echo "   6. Save AI output to:"
echo "      $TEST_DIR/dh_check_TEST_v6.1_fixed.c"
echo "   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
read -p "   Press Enter when documentation is saved... "

# Verify output exists
if [ ! -f "$TEST_DIR/dh_check_TEST_v6.1_fixed.c" ]; then
    echo ""
    echo "❌ ERROR: Output file not found"
    echo "   Expected: $TEST_DIR/dh_check_TEST_v6.1_fixed.c"
    echo ""
    exit 1
fi

echo ""
echo "✅ Documentation file found"
echo ""

# Step 4: Run validation
echo "Step 4: Running validation script v2.0..."
echo ""

cd "$TEST_DIR"

if [ ! -f "./validate_results_v2.sh" ]; then
    echo "❌ ERROR: Validation script v2.0 not found"
    echo "   Expected: $TEST_DIR/validate_results_v2.sh"
    exit 1
fi

# Make executable if needed
chmod +x ./validate_results_v2.sh

# Run validation
./validate_results_v2.sh

echo ""
echo "════════════════════════════════════════════════════════════"
echo "    Test Complete"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "📁 Results saved to:"
echo "   Output: $TEST_DIR/dh_check_TEST_v6.1_fixed.c"
echo "   Dictionary: $TEST_DIR/dictionary_section_TEST.txt"
echo ""
echo "📊 Next steps:"
echo "   1. Review validation summary above"
echo "   2. Check dictionary section quality"
echo "   3. If validated, proceed to CVE analysis testing"
echo ""
echo "📖 Documentation:"
echo "   • Quick Start: $TEST_DIR/QUICK_START_V2.md"
echo "   • Full Guide: $TEST_DIR/VALIDATION_SCRIPT_V2_README.md"
echo "   • Comparison: $TEST_DIR/V1_VS_V2_COMPARISON.md"
echo ""
