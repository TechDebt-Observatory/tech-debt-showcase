#!/bin/bash
# validate_comment_preservation.sh
# Validates that all original comments are preserved in documented version

set -e

ORIGINAL=$1
DOCUMENTED=$2

if [ ! -f "$ORIGINAL" ] || [ ! -f "$DOCUMENTED" ]; then
    echo "Usage: $0 original.c documented.c"
    echo ""
    echo "Example: $0 dhtest_original.c dhtest_documented.c"
    exit 1
fi

echo "=========================================="
echo "COMMENT PRESERVATION VALIDATION"
echo "=========================================="
echo ""
echo "Original file: $ORIGINAL"
echo "Documented file: $DOCUMENTED"
echo ""

# Count total lines
ORIG_LINES=$(wc -l < "$ORIGINAL")
DOC_LINES=$(wc -l < "$DOCUMENTED")
echo "Original lines: $ORIG_LINES"
echo "Documented lines: $DOC_LINES"
echo "Added lines: $((DOC_LINES - ORIG_LINES))"
echo ""

# Extract just the comment text (remove line numbers and whitespace)
echo "Extracting original comments..."
grep -oh "/\*[^*]*\*/" "$ORIGINAL" 2>/dev/null | sort | uniq > /tmp/orig_comments.txt || true
grep -oh "/\*[^*]*\*\+/" "$ORIGINAL" 2>/dev/null | sort | uniq >> /tmp/orig_comments.txt || true

echo "Extracting documented comments..."
grep -oh "/\*[^*]*\*/" "$DOCUMENTED" 2>/dev/null | sort | uniq > /tmp/doc_comments.txt || true
grep -oh "/\*[^*]*\*\+/" "$DOCUMENTED" 2>/dev/null | sort | uniq >> /tmp/doc_comments.txt || true

ORIG_COMMENT_COUNT=$(wc -l < /tmp/orig_comments.txt)
DOC_COMMENT_COUNT=$(wc -l < /tmp/doc_comments.txt)

echo "Original unique comments: $ORIG_COMMENT_COUNT"
echo "Documented unique comments: $DOC_COMMENT_COUNT"
echo ""

# Check if all original comments exist in documented version
echo "Checking if all original comments are preserved..."
MISSING=0
while IFS= read -r comment; do
    if ! grep -qF "$comment" /tmp/doc_comments.txt; then
        echo "ERROR: Original comment missing or modified:"
        echo "  $comment"
        MISSING=$((MISSING + 1))
    fi
done < /tmp/orig_comments.txt

if [ $MISSING -gt 0 ]; then
    echo ""
    echo "❌ VALIDATION FAILED: $MISSING original comments missing or modified"
    exit 1
fi

echo "✓ All original comments found in documented version"
echo ""

# Check for removed comment lines using diff
echo "Checking for removed comment lines..."
REMOVED_LINES=$(diff -u "$ORIGINAL" "$DOCUMENTED" 2>/dev/null | grep "^-" | grep -c "/\*" || true)

if [ "$REMOVED_LINES" -gt 0 ]; then
    echo "ERROR: $REMOVED_LINES comment lines were removed:"
    diff -u "$ORIGINAL" "$DOCUMENTED" | grep "^-" | grep "/\*" | head -10
    echo ""
    echo "❌ VALIDATION FAILED: Original comments were removed"
    exit 1
fi

echo "✓ No comment lines were removed"
echo ""

# Check for modified comment lines
echo "Checking for modified inline comments..."
# Extract inline comments (/* ... */ on same line as code)
grep -n "/\*.*\*/" "$ORIGINAL" | grep -v "^[[:space:]]*\*/\?$" > /tmp/orig_inline.txt || true
ORIG_INLINE_COUNT=$(wc -l < /tmp/orig_inline.txt)

if [ "$ORIG_INLINE_COUNT" -gt 0 ]; then
    MODIFIED_INLINE=0
    while IFS=: read -r linenum comment; do
        # Get same line from documented version
        doc_line=$(sed -n "${linenum}p" "$DOCUMENTED" 2>/dev/null || true)
        if ! echo "$doc_line" | grep -qF "${comment#*:}"; then
            echo "WARNING: Inline comment may be modified at line $linenum"
            echo "  Original: $comment"
            echo "  Documented: $doc_line"
            MODIFIED_INLINE=$((MODIFIED_INLINE + 1))
        fi
    done < /tmp/orig_inline.txt
    
    if [ "$MODIFIED_INLINE" -gt 0 ]; then
        echo ""
        echo "⚠️  WARNING: $MODIFIED_INLINE inline comments may have been modified"
        echo "    Manual review recommended"
    else
        echo "✓ Inline comments appear preserved"
    fi
fi

echo ""
echo "=========================================="
echo "✅ VALIDATION PASSED"
echo "=========================================="
echo ""
echo "Summary:"
echo "  - All $ORIG_COMMENT_COUNT unique original comments preserved"
echo "  - No comment lines removed"
echo "  - Documentation added: $((DOC_LINES - ORIG_LINES)) lines"
echo ""
echo "NOTE: This automated check validates comment preservation."
echo "      Manual review is still recommended for accuracy and quality."
