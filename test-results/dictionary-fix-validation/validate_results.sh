#!/bin/bash
# Validation Script - Extract Metrics from Test Output
# Run after completing documentation test

TEST_DIR="/Users/basiladdington/Projects/tech-debt-showcase/test-results/dictionary-fix-validation"

echo "════════════════════════════════════════════════════════════"
echo "    Dictionary Fix Validation - Metrics Extraction"
echo "════════════════════════════════════════════════════════════"
echo ""

# Check if test output exists
if [ ! -f "$TEST_DIR/dh_check_TEST_v6_fixed.c" ]; then
    echo "❌ ERROR: Test output not found at:"
    echo "   $TEST_DIR/dh_check_TEST_v6_fixed.c"
    echo ""
    echo "Please run the test first and save output to this location."
    exit 1
fi

echo "✅ Test output found"
echo ""

# Extract VARIABLE_DICTIONARY section
echo "═══ EXTRACTING VARIABLE_DICTIONARY SECTION ═══"
echo ""

# Find start and end of dictionary section
DICT_START=$(grep -n "@section VARIABLE_DICTIONARY" "$TEST_DIR/dh_check_TEST_v6_fixed.c" | head -1 | cut -d: -f1)
DICT_END=$(grep -n "@section" "$TEST_DIR/dh_check_TEST_v6_fixed.c" | grep -A1 "VARIABLE_DICTIONARY" | tail -1 | cut -d: -f1)

if [ -z "$DICT_START" ]; then
    echo "⚠️  WARNING: VARIABLE_DICTIONARY section not found in output"
else
    echo "📍 Dictionary section: lines $DICT_START-$DICT_END"
    
    # Extract just the dictionary section
    sed -n "${DICT_START},${DICT_END}p" "$TEST_DIR/dh_check_TEST_v6_fixed.c" > "$TEST_DIR/dictionary_section_TEST.txt"
    
    # Count entries (lines with " - " or ":" that look like definitions)
    DICT_ENTRIES=$(grep -E "(: |^ \* - )" "$TEST_DIR/dictionary_section_TEST.txt" | wc -l | tr -d ' ')
    
    echo "📊 Dictionary entries found: $DICT_ENTRIES"
fi

echo ""

# Extract validation proof
echo "═══ EXTRACTING VALIDATION PROOF ═══"
echo ""

if grep -q "VALIDATION COMPLETE" "$TEST_DIR/dh_check_TEST_v6_fixed.c"; then
    echo "✅ Validation proof found"
    grep -A 10 "VALIDATION COMPLETE" "$TEST_DIR/dh_check_TEST_v6_fixed.c" | head -10
else
    echo "⚠️  WARNING: No validation proof found in output"
fi

echo ""

# Check for checkpoint acknowledgment
echo "═══ CHECKING CHECKPOINT ACKNOWLEDGMENT ═══"
echo ""

if grep -q "CHECKPOINT" "$TEST_DIR/dh_check_TEST_v6_fixed.c" || \
   grep -q "checkpoint" "$TEST_DIR/dh_check_TEST_v6_fixed.c" || \
   grep -q "variable dictionary" "$TEST_DIR/dh_check_TEST_v6_fixed.c"; then
    echo "✅ Checkpoint/dictionary reference found in output"
else
    echo "⚠️  No explicit checkpoint acknowledgment found"
fi

echo ""

# Compare to baseline
echo "═══ BASELINE COMPARISON ═══"
echo ""

if [ -f "$TEST_DIR/dh_check_BASELINE_v6_original.c" ]; then
    echo "Comparing to baseline..."
    
    # Extract baseline dictionary
    BASELINE_START=$(grep -n "@section VARIABLE_DICTIONARY" "$TEST_DIR/dh_check_BASELINE_v6_original.c" | head -1 | cut -d: -f1)
    BASELINE_END=$(grep -n "@section" "$TEST_DIR/dh_check_BASELINE_v6_original.c" | grep -A1 "VARIABLE_DICTIONARY" | tail -1 | cut -d: -f1)
    
    if [ -n "$BASELINE_START" ]; then
        sed -n "${BASELINE_START},${BASELINE_END}p" "$TEST_DIR/dh_check_BASELINE_v6_original.c" > "$TEST_DIR/dictionary_section_BASELINE.txt"
        
        BASELINE_ENTRIES=$(grep -E "(: |^ \* - )" "$TEST_DIR/dictionary_section_BASELINE.txt" | wc -l | tr -d ' ')
        
        echo "📊 Baseline entries: $BASELINE_ENTRIES"
        echo "📊 Test entries:     $DICT_ENTRIES"
        
        DELTA=$((DICT_ENTRIES - BASELINE_ENTRIES))
        if [ $DELTA -gt 0 ]; then
            echo "✅ IMPROVEMENT: +$DELTA entries"
        elif [ $DELTA -lt 0 ]; then
            echo "⚠️  REGRESSION: $DELTA entries"
        else
            echo "➡️  SAME: No change in entry count"
        fi
    fi
else
    echo "⚠️  Baseline file not found - skipping comparison"
fi

echo ""

# File size comparison
echo "═══ FILE SIZE METRICS ═══"
echo ""

TEST_SIZE=$(wc -c < "$TEST_DIR/dh_check_TEST_v6_fixed.c" | tr -d ' ')
TEST_LINES=$(wc -l < "$TEST_DIR/dh_check_TEST_v6_fixed.c" | tr -d ' ')

echo "📄 Test output:"
echo "   Size:  $(numfmt --to=iec-i --suffix=B $TEST_SIZE)"
echo "   Lines: $TEST_LINES"

if [ -f "$TEST_DIR/dh_check_BASELINE_v6_original.c" ]; then
    BASELINE_SIZE=$(wc -c < "$TEST_DIR/dh_check_BASELINE_v6_original.c" | tr -d ' ')
    BASELINE_LINES=$(wc -l < "$TEST_DIR/dh_check_BASELINE_v6_original.c" | tr -d ' ')
    
    echo ""
    echo "📄 Baseline:"
    echo "   Size:  $(numfmt --to=iec-i --suffix=B $BASELINE_SIZE)"
    echo "   Lines: $BASELINE_LINES"
    
    SIZE_DELTA=$((TEST_SIZE - BASELINE_SIZE))
    LINE_DELTA=$((TEST_LINES - BASELINE_LINES))
    
    echo ""
    echo "📊 Delta:"
    echo "   Size:  $SIZE_DELTA bytes"
    echo "   Lines: $LINE_DELTA"
fi

echo ""

# Summary
echo "════════════════════════════════════════════════════════════"
echo "    SUMMARY"
echo "════════════════════════════════════════════════════════════"
echo ""

if [ -n "$DICT_ENTRIES" ] && [ -n "$BASELINE_ENTRIES" ]; then
    COMPLETENESS_BASELINE=$((BASELINE_ENTRIES * 100 / 35))  # 35 = expected total
    COMPLETENESS_TEST=$((DICT_ENTRIES * 100 / 35))
    
    echo "Dictionary Completeness (estimated):"
    echo "  Baseline: $COMPLETENESS_BASELINE% ($BASELINE_ENTRIES/35 entries)"
    echo "  Test:     $COMPLETENESS_TEST% ($DICT_ENTRIES/35 entries)"
    echo ""
    
    if [ $COMPLETENESS_TEST -ge 95 ]; then
        echo "✅ SUCCESS: Dictionary completeness ≥95%"
        echo "   Prompt fix appears to be working!"
    elif [ $COMPLETENESS_TEST -gt $COMPLETENESS_BASELINE ]; then
        echo "➡️  IMPROVEMENT: Better than baseline but <95%"
        echo "   Consider testing with Opus 4.5"
    else
        echo "⚠️  NO IMPROVEMENT: Same or worse than baseline"
        echo "   Prompt fix may not be sufficient"
    fi
fi

echo ""
echo "📁 Extracted sections saved to:"
echo "   $TEST_DIR/dictionary_section_TEST.txt"
echo "   $TEST_DIR/dictionary_section_BASELINE.txt"
echo ""
echo "Next: Review the dictionary sections manually for quality assessment"
echo ""
