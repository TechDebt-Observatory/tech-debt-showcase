# Quick Start: Validation Script v2.0

## One-Line Test

```bash
cd ~/Projects/tech-debt-showcase/test-results/dictionary-fix-validation && ./validate_results_v2.sh
```

## What It Checks

✅ **Symbol Dictionary Completeness**
- Counts symbols in grouped OR flat structures
- Extracts checkpoint proof if present
- Parses category breakdown

✅ **Validation Proof**
- Comment preservation evidence
- Confidence statements
- Self-check results

✅ **Baseline Comparison**
- vs. Phase 1 v6.0 original
- Improvement delta
- Quality indicators

## Reading the Output

### Success Indicators

```
✅ CHECKPOINT VERIFIED: Dictionary complete
   All 96 symbols documented with proof
```
**Meaning:** Prompt v6.1 working perfectly. Documentation is research-ready.

```
✅ SUFFICIENT: 85 entries (≥80 minimum)
   ⚠️  No checkpoint proof - consider this a partial success
```
**Meaning:** Acceptable for testing, but prompt could be improved.

### Warning Indicators

```
⚠️  INCOMPLETE: 45 entries (<80 expected)
   Recommend: Review dictionary section manually
```
**Meaning:** Significant issue. Check if prompt was followed correctly.

```
⚠️  REGRESSION: -15 entries
```
**Meaning:** Fewer symbols than baseline. May indicate grouped structure (check checkpoint proof).

## Decision Matrix

| Checkpoint | Pattern Count | Verdict |
|------------|---------------|---------|
| YES + 96 = 96 | Any | ✅ **Use for research** |
| YES + Mismatch | Any | ⚠️ **Review manually** |
| No proof | ≥80 | ✅ **Acceptable** |
| No proof | <80 | ❌ **Retry documentation** |

## What Gets Extracted

After running, check:

```
dictionary_section_TEST.txt     # Your SYMBOL_DICTIONARY section
dictionary_section_BASELINE.txt # Comparison target
```

## Common Scenarios

### Scenario 1: Perfect Run
```
Checkpoint: YES (96 = 96)
Pattern count: 31 (grouped structure)
Verdict: ✅ SUCCESS - Use checkpoint count
```

### Scenario 2: No Checkpoint
```
Checkpoint: none
Pattern count: 87
Verdict: ✅ SUFFICIENT - Acceptable without proof
```

### Scenario 3: Mismatch
```
Checkpoint: Scanned 96, Documented 82
Pattern count: 82
Verdict: ⚠️ INCOMPLETE - 14 symbols missing
```

## Next Steps After Validation

### If ✅ SUCCESS
1. Proceed to CVE analysis testing
2. Use documentation for AI comprehension tests
3. Archive as reference example

### If ⚠️ PARTIAL
1. Review dictionary section manually
2. Check if categories are logically organized
3. Consider re-running with Opus 4

### If ❌ INCOMPLETE
1. Check prompt was copied correctly
2. Verify pre-flight checklist was completed
3. Review AI output for errors/truncation

## Troubleshooting

**Script says "No such file"**
```bash
# Check filename matches:
ls -la dh_check_TEST_v6.1_fixed.c
# Script expects exact name with v6.1
```

**Pattern count = 0**
```bash
# Check section name:
grep "@section.*DICTIONARY" dh_check_TEST_v6.1_fixed.c
# Should find SYMBOL_DICTIONARY or VARIABLE_DICTIONARY
```

**Baseline not found**
```bash
# Baseline should be:
ls -la dh_check_BASELINE_v6_original.c
# If missing, comparison will be skipped (not fatal)
```

## For Your Research

When validating documentation for CVE analysis:

**Required Quality Gates:**
- ✅ Checkpoint proof present
- ✅ All categories documented (11+)
- ✅ Completeness = YES
- ✅ No original comments modified

**Why This Matters:**
- Incomplete dictionaries → Poor AI context
- Missing categories → Blind spots in vulnerability detection
- Modified comments → Loss of historical context

**Research Validity:**
Your hypothesis is "comprehensive documentation improves AI vulnerability detection."

A dictionary that passes v2.0 validation provides:
- **Complete semantic context** (all symbols)
- **Organized knowledge** (grouped categories)
- **Verifiable coverage** (checkpoint proof)

This creates a **fair test condition** for comparing AI performance on documented vs. undocumented code.

---

**Last Updated:** 2024-11-28  
**Script Version:** 2.0  
**Compatible With:** Phase 1 Prompt v6.1
