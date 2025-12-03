# Dictionary Fix Validation Test - Quick Start

## 🎯 Goal
Test whether Phase 1 v6 prompt fixes (dictionary-first ordering + checkpoint gates) improve VARIABLE_DICTIONARY completeness.

---

## 📦 What's in This Package

```
dictionary-fix-validation/
├── README.md                           ← You are here
├── RUN_TEST.md                         ← Complete test instructions
├── TEST_PLAN.md                        ← Detailed test methodology
├── validate_results.sh                 ← Metrics extraction script (executable)
├── dh_check_BASELINE_v6_original.c     ← Already documented (before fix)
└── dh_check_TEST_v6_fixed.c            ← Will be created by you
```

---

## ⚡ Quick Start (5 Minutes)

### Step 1: Run the Test
1. Open **NEW Claude Desktop conversation** (fresh context)
2. Open `RUN_TEST.md` in this directory
3. Copy these THREE sections into Claude:
   - SECTION 1: Context framing
   - SECTION 2: Full Phase 1 v6 prompt (from `methodology/prompt-engineering/Phase1v6.txt`)
   - SECTION 3: Source file (from `case-studies/CVE-2023-3446-dhtest/original/dh_check.c`)
4. Wait for Claude to complete documentation
5. Save output as: `dh_check_TEST_v6_fixed.c` in this directory

### Step 2: Extract Metrics
```bash
cd tech-debt-showcase/test-results/dictionary-fix-validation
./validate_results.sh
```

### Step 3: Review Results
The script will show:
- ✅ Dictionary entry count (test vs baseline)
- ✅ Completeness percentage
- ✅ Improvement delta
- ✅ Success/failure assessment

---

## 📊 Success Criteria

**Target:** Dictionary completeness ≥95% (33+ entries out of 35 expected)

**Decision Tree:**
```
IF test ≥95% completeness:
  → ✅ SUCCESS: Prompt fix works!
  → Ship Phase 1 v6 (fixed version)
  
ELIF test 80-94% (improved over baseline):
  → ➡️  PARTIAL: Better but not sufficient
  → Test same file with Opus 4.5 (model upgrade)
  
ELSE test <80% (same or worse):
  → ⚠️  FAILURE: Prompt fix insufficient
  → Consider architecture changes
```

---

## 📝 Test Conditions

**Model:** Claude Sonnet 4.5  
**Prompt:** Phase 1 v6 (with dictionary fixes applied)  
**File:** dh_check.c (333 lines, ~3,300 tokens)  
**Memory:** Enabled (standard chat, mitigated with fresh conversation)  
**Baseline:** Phase 1 v6 (before dictionary fixes)

---

## 🔬 What We're Testing

**Hypothesis:** Reordering documentation sequence to put VARIABLE_DICTIONARY FIRST (before 40 minutes of function documentation) will prevent attention fatigue and improve dictionary completeness.

**Changes Made:**
1. ✅ Moved VARIABLE_DICTIONARY to STEP 1 (document during initial scan)
2. ✅ Added checkpoint gate (must validate before proceeding)
3. ✅ Added completeness metric to validation proof

**Expected Impact:** Dictionary completeness improves from ~60% to 95%+

---

## 📖 Detailed Documentation

See `TEST_PLAN.md` for:
- Complete test methodology
- Ground truth analysis (actual variable counts)
- Baseline analysis
- Success criteria details

---

## ⏱️ Time Estimate

- **Test execution:** 2-3 minutes (Claude generation time)
- **Metrics extraction:** 10 seconds (automated script)
- **Manual review:** 5-10 minutes (quality assessment)
- **Total:** ~10-15 minutes

---

## 🚀 After Testing

### If Successful (≥95%):
1. Document results in `TEST_PLAN.md` (fill in Results section)
2. Update `CHANGES_Phase1v6_Dictionary_Fix.md` with test data
3. Consider this validation complete
4. Proceed with CVE research using fixed prompt

### If Partial Success (80-94%):
1. Document results in `TEST_PLAN.md`
2. Prepare Opus 4.5 test (same protocol, different model)
3. Compare Sonnet vs Opus performance

### If Failure (<80%):
1. Document results and analyze failure mode
2. Consider multi-pass architecture or additional prompt changes
3. Review extracted dictionary sections for patterns

---

## 📞 Questions?

Refer to:
- `RUN_TEST.md` - Step-by-step test execution
- `TEST_PLAN.md` - Detailed methodology and rationale
- `../openssl_file_analysis.md` - Why we're focusing on this

---

**Status:** READY TO RUN ✅

Run the test whenever you're ready. The validation script will tell you immediately if the prompt fix worked!
