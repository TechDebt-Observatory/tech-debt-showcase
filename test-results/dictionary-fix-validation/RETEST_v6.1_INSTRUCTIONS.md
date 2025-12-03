# Re-test Instructions - Phase 1 v6.1

## Quick Start

### Step 1: Complete Phase1v6.1.txt File

The Phase1v6.1.txt file has been partially created but needs completion. To finish it:

1. Open `/methodology/prompt-engineering/Phase1v6.1.txt` (currently has 196 lines)
2. It needs the content from line 195 of Phase1v6.txt onward to be appended
3. The key changes are already in the first 196 lines (expanded SYMBOL_DICTIONARY section)

**OR** use this workaround:
1. Copy Phase1v6.txt to Phase1v6.1.txt
2. Replace lines 154-180 (the VARIABLE_DICTIONARY section) with the new SYMBOL_DICTIONARY content from the partial Phase1v6.1.txt file
3. Update CHECK 5 in the validation section (around line 585) to reference SYMBOL_DICTIONARY instead of VARIABLE_DICTIONARY

### Step 2: Run the Test

1. Open **NEW** Claude Desktop conversation (fresh context)
2. Copy Phase1v6.1.txt content
3. Copy dh_check.c source (from document 2 in this conversation)
4. Wait for Claude to complete documentation
5. Save output as: `dh_check_TEST_v6.1_fixed.c` in `/test-results/dictionary-fix-validation/`

### Step 3: Validate

```bash
cd /Users/basiladdington/Projects/tech-debt-showcase/test-results/dictionary-fix-validation
./validate_results.sh
```

**Expected Results with v6.1**:
- Dictionary entries: 38-42 (vs v6.0's 31)
- Completeness: 95-100% (vs v6.0's 88%)
- Improvement: +7 to +11 entries
- Checkpoint proof embedded in output

### Step 4: Verify Improvements

Check that the output includes:

**In @section SYMBOL_DICTIONARY:**
- ✓ Constants and Macros subsection
- ✓ Error Codes subsection (12 individual entries)
- ✓ Special Values subsection (NID_undef)
- ✓ Structure Fields subsection
- ✓ Function Parameters subsection
- ✓ Local Variables subsection
- ✓ Checkpoint proof comment block with breakdown

**Checkpoint Proof Should Look Like:**
```c
/**
 * @note CHECKPOINT PROOF - SYMBOL_DICTIONARY COMPLETENESS
 * Symbols scanned: 40
 * Dictionary entries created: 40
 * Completeness: 40 = 40 ? YES
 * 
 * Breakdown:
 * - Constants/macros: 4 scanned, 4 documented
 * - Error codes: 12 scanned, 12 documented
 * - Special values: 1 scanned, 1 documented
 * - Structure fields: 8 scanned, 8 documented
 * - Globals: 0 scanned, 0 documented
 * - Function params: 4 scanned, 4 documented
 * - Local variables: 11 scanned, 11 documented
 * 
 * Status: COMPLETE - Proceeding to file header documentation
 */
```

## Success Criteria

**PRIMARY**: Symbol dictionary completeness ≥ 95% (38+ entries out of ~40 expected)

**SECONDARY CHECKS**:
1. Checkpoint proof present in output ✓
2. Constants section present ✓
3. Error codes enumerated individually ✓
4. NID_undef documented ✓
5. All original comments preserved ✓

## Decision Tree

```
IF v6.1 test ≥95% completeness:
  → ✅ SUCCESS: Scope fix works!
  → Adopt Phase 1 v6.1 as standard
  → Update all workflows
  → Begin CVE research with v6.1
  
ELIF v6.1 test 80-94% (improved but not sufficient):
  → ➡️ PARTIAL: Investigate remaining gaps
  → Check if missed categories or miscounted
  → Consider prompt refinement
  
ELSE v6.1 test <80% (no improvement):
  → ⚠️ FAILURE: Deeper issue than scope
  → Review checkpoint proof to see what was missed
  → Consider architectural changes
```

## Comparison Points

Create a side-by-side comparison:

| Metric | v6.0 Test | v6.1 Test | Baseline | Target |
|--------|-----------|-----------|----------|---------|
| Dictionary Entries | 31 | ??? | 40 | 38+ |
| Completeness % | 88% | ??? | 114% | 95%+ |
| Constants Section | ❌ | ??? | ✓ | ✓ |
| Error Codes | Grouped | ??? | Individual | Individual |
| Checkpoint Proof | ❌ | ??? | ❌ | ✓ |
| Special Values | ❌ | ??? | ✓ | ✓ |

## Files to Compare

1. **Baseline** (what we're trying to match):
   - `dh_check_BASELINE_v6_original.c`
   - Documented with v6.0, has 40 dictionary entries
   
2. **v6.0 Test** (what failed):
   - `dh_check_TEST_v6_fixed.c`
   - Has 31 dictionary entries, missing constants/special values
   
3. **v6.1 Test** (what we expect to succeed):
   - `dh_check_TEST_v6.1_fixed.c` ← CREATE THIS
   - Should have 38-42 dictionary entries, all categories present

## Troubleshooting

### If checkpoint proof is missing:
The model may have skipped embedding it. This is a v6.1 requirement. Reject and re-run.

### If constants section is missing:
Check if the prompt section explaining constants was included. The model needs clear examples.

### If error codes are still grouped:
The counting rules may not have been clear enough. The prompt should say "Individual error flags = separate entries".

### If completeness is still <95%:
1. Read the checkpoint proof to see what was counted
2. Compare to baseline dictionary manually
3. Identify specific missing elements
4. Determine if prompt needs further refinement

## Time Estimate

- Completing Phase1v6.1.txt: 5-10 minutes
- Running test: 2-3 minutes (Claude generation)
- Validation: 10 seconds (automated)
- Comparison analysis: 10 minutes
- **Total: ~20-25 minutes**

## After Testing

### If Successful
1. Document results in TEST_RESULTS_ANALYSIS.md
2. Update CHANGES_Phase1v6.1_Symbol_Dictionary.md with actual test data
3. Archive v6.0 as deprecated
4. Update main documentation workflow references

### If Unsuccessful
1. Document failure mode in TEST_RESULTS_ANALYSIS.md
2. Analyze what categories were still missed
3. Consider if examples in prompt are insufficient
4. May need to test with different model (Opus 4.5)

## Ready to Proceed?

- [ ] Phase1v6.1.txt file is complete
- [ ] Fresh Claude conversation ready
- [ ] Validation script tested and working
- [ ] Baseline comparison files ready
- [ ] Time allocated for analysis

When ready, execute Step 2 above.
