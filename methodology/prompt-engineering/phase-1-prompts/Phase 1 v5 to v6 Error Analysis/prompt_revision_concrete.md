# PROMPT REVISION - CONCRETE CHANGES
## Ready-to-Use Sections for Phase 1 Version 6

This document provides the exact text to add/replace in your prompt.

---

## ADDITION 1: Insert at Very Top of Prompt (Before Everything)

```markdown
═══════════════════════════════════════════════════════════════════════
                    🛑 CRITICAL REQUIREMENTS 🛑
                         READ THIS FIRST
═══════════════════════════════════════════════════════════════════════

This prompt has ONE ABSOLUTE REQUIREMENT that supersedes all others:

                PRESERVE ALL ORIGINAL COMMENTS EXACTLY

Rules:
- ZERO characters changed in existing /* */ or /** */ blocks
- ZERO words added to existing comments  
- ZERO comments removed or relocated
- ZERO "improvements" to existing comment text

Violation = AUTOMATIC REJECTION + COMPLETE REDO

Priority: Comment preservation > Documentation quality > Speed

Before starting, complete the MANDATORY PRE-FLIGHT CHECKLIST below.

═══════════════════════════════════════════════════════════════════════

MANDATORY PRE-FLIGHT CHECKLIST
═══════════════════════════════════════════════════════════════════════

Complete these steps BEFORE writing any documentation:

STEP 1: Extract existing comments
  Command: grep -n "/\*" source_file.c > original_comments.txt
  Action: List first 10 comments you found
  Checkpoint: "I found [N] comment lines in original source"

STEP 2: Identify where you CAN add documentation
  Allowed: Before functions, before file, in blank lines
  Prohibited: Inside existing /* */ blocks
  Checkpoint: "I will add documentation in [locations] only"

STEP 3: Acknowledge understanding
  State: "I understand that modifying ANY existing comment = failure"

STEP 4: Proceed only after completing Steps 1-3

═══════════════════════════════════════════════════════════════════════
```

---

## REPLACEMENT 2: Replace Existing "EXISTING COMMENT HANDLING" Section

**FIND (around line 227):**
```
EXISTING COMMENT HANDLING
CRITICAL: PRESERVE EVERY SINGLE EXISTING COMMENT EXACTLY AS IT APPEARS.
Do NOT remove, alter, or reformat any original comments
[rest of section...]
```

**REPLACE WITH:**

```markdown
═══════════════════════════════════════════════════════════════════════
                   🛑 EXISTING COMMENT HANDLING 🛑
                        ZERO TOLERANCE POLICY
═══════════════════════════════════════════════════════════════════════

ABSOLUTE REQUIREMENT - NOT NEGOTIABLE

PRESERVE EVERY SINGLE EXISTING COMMENT EXACTLY AS IT APPEARS.

What "exactly" means:
- Byte-for-byte identical
- Same line numbers (or explicitly moved with annotation)
- Same whitespace, punctuation, spelling (even if wrong)
- Same capitalization, even if inconsistent

Especially critical:
- License headers (legal requirement)
- Copyright notices (legal requirement)
- Author attributions (professional courtesy)
- Historical context (maintainer knowledge)
- TODO/FIXME markers (technical debt tracking)

VISUAL EXAMPLES - MEMORIZE THESE PATTERNS
------------------------------------------

❌ WRONG - Modified Original:
```c
/* Run the test. Success means no SIGSEGV.
 * Added after CVE-2022-1234 for regression testing. */ ← AI expanded comment
```

✅ RIGHT - Original Preserved, New Added:
```c
/**
 * @brief Regression test for segfault bug
 * @details Added after CVE-2022-1234 to prevent regression.
 */
/* Run the test. Success is any time the test does not cause a SIGSEGV interrupt */ ← Exact original
```

---

❌ WRONG - Original Deleted:
```c
/**
 * @brief Sets DH parameters from named group
 * @details Transfers ownership of parameters to DH object.
 */
if (!TEST_true(DH_set0_pqg(dh2, pcpy, NULL, gcpy)))  ← Original comment missing
```

✅ RIGHT - Original Preserved:
```c
/**
 * @brief Sets DH parameters from named group  
 * @details Transfers ownership of parameters to DH object.
 */
/* Set new DH parameters manually using a existing named group's p & g */ ← Kept
if (!TEST_true(DH_set0_pqg(dh2, pcpy, NULL, gcpy)))
```

---

WHEN IN DOUBT
-------------

If you're unsure whether a comment is original:
  1. PRESERVE IT EXACTLY
  2. Add clarification as NEW comment with @note or @warning
  3. Flag it for human review

Example:
```c
/* This workaround is needed for OpenSSL 1.0.2 bug #1234 */ ← Original (maybe outdated?)

/**
 * @note ORIGINAL COMMENT ABOVE MAY BE OUTDATED:
 * Comment refers to OpenSSL 1.0.2 behavior. Current version is 3.0.
 * Verify if workaround still necessary. See GitHub issue #5678.
 */
```

PLACEMENT RULES
---------------

Where to add NEW documentation:
✅ BEFORE functions (Doxygen headers)
✅ BEFORE file (file header)
✅ In blank lines between code sections
✅ AFTER existing comments (with @note/@warning)

Where NOT to add:
❌ INSIDE existing /* */ blocks
❌ REPLACING existing comments
❌ MODIFYING existing comment text

CONSEQUENCES OF VIOLATION
--------------------------

If ANY original comment is modified:
- Documentation automatically REJECTED
- Complete redo required from scratch
- No partial credit for quality work
- Maintainer trust damaged

WHY THIS MATTERS
----------------

- Legal: License headers required for compliance
- Historical: Evolution of codebase preserved
- Professional: Respecting previous maintainers
- Technical: Version control integrity maintained
- Trust: Teams reject AI that destroys their work

═══════════════════════════════════════════════════════════════════════
```

---

## ADDITION 3: Insert After All Documentation Sections (Before Examples)

```markdown
═══════════════════════════════════════════════════════════════════════
              MANDATORY VALIDATION BEFORE SUBMISSION
═══════════════════════════════════════════════════════════════════════

Your documentation is INCOMPLETE without validation proof.

You MUST perform these checks and include results:

CHECK 1: Comment Count Verification
------------------------------------
Original comment lines: [Your count from pre-flight]
Documented comment lines: [Your count from output]
Delta: [Difference - should be positive (additions) only]

Command used:
  grep -c "/\*" original.c    # Result: [N]
  grep -c "/\*" documented.c  # Result: [M]
  Expected: M >= N (only additions allowed)

CHECK 2: Diff Verification  
--------------------------
Run: diff -u original.c documented.c | grep "^-" | grep "/\*"

Expected result: EMPTY (no lines starting with "-" that contain "/*")
Your result: [paste output here, or state "EMPTY"]

If NOT empty: You removed original comments. STOP. Fix before submitting.

CHECK 3: Sample Verification
----------------------------
Pick 3 functions that had original comments.

Function 1: [name]
  Original comment at line [N]: [first 50 chars of comment]
  Preserved? [YES/NO]

Function 2: [name]
  Original comment at line [N]: [first 50 chars of comment]
  Preserved? [YES/NO]

Function 3: [name]
  Original comment at line [N]: [first 50 chars of comment]
  Preserved? [YES/NO]

All three must be YES.

CHECK 4: Confidence Statement
-----------------------------
Rate your confidence: [___]%

100% = "I verified every comment with diff/grep, all preserved exactly"
<100% = STOP. Do not submit. Run validation checks until 100%.

VALIDATION PROOF TEMPLATE
--------------------------
Include this statement with your submission:

"VALIDATION COMPLETE
- Original comments: [N]
- Documented comments: [M] (added [M-N] new)
- Diff check: EMPTY (no removals)
- Sample check: 3/3 preserved
- Confidence: 100%
- I verified every original comment is preserved exactly."

Without this statement and supporting data, documentation is REJECTED.

═══════════════════════════════════════════════════════════════════════
```

---

## ADDITION 4: Insert at End of Prompt (Final Section)

```markdown
═══════════════════════════════════════════════════════════════════════
                   SELF-CHECK BEFORE SUBMISSION
═══════════════════════════════════════════════════════════════════════

Answer YES or NO to each question. Submit only if ALL are YES.

DOCUMENTATION QUALITY
---------------------
[ ] Can a CS junior understand what each function does?
[ ] Are all WHY questions answered (not just WHAT)?
[ ] Are security implications documented?
[ ] Are maintainer traps explicitly flagged?
[ ] Is historical context provided where relevant?

COMMENT PRESERVATION (CRITICAL)
--------------------------------
[ ] Did I extract original comments before starting?
[ ] Did I count original comment lines (pre-flight)?
[ ] Did I preserve EVERY original comment exactly?
[ ] Can I prove preservation with diff output?
[ ] Did I run CHECK 1-4 from validation section?
[ ] Is my confidence level 100%?

DOXYGEN COMPLIANCE
------------------
[ ] Does every function have @brief?
[ ] Does every function have @details?
[ ] Are all @param tags present and documented?
[ ] Are @return values explained?
[ ] Is file header complete?

GO/NO-GO DECISION
-----------------

If ANY answer above is NO:
  → DO NOT SUBMIT
  → Fix the issues
  → Re-run checks
  → Try again

If ALL answers are YES:
  → Include validation proof (from CHECK 4)
  → Submit with confidence statement
  → Proceed

═══════════════════════════════════════════════════════════════════════

ACCEPTANCE CRITERIA - READ BEFORE SUBMITTING
═══════════════════════════════════════════════════════════════════════

Your documentation will be ACCEPTED if:
  ✅ All functions have comprehensive Doxygen headers
  ✅ File header includes design rationale and traps
  ✅ ALL original comments preserved exactly
  ✅ Validation proof provided
  ✅ Self-check shows all YES

Your documentation will be REJECTED if:
  ❌ ANY original comment modified/removed/relocated
  ❌ No validation proof provided
  ❌ Self-check incomplete or has NO answers
  ❌ Cannot prove comment preservation line-by-line

PRIORITY HIERARCHY
------------------
1. Comment preservation (absolute requirement)
2. Safety/security documentation (critical)
3. Documentation completeness (important)
4. Documentation quality (important)
5. Formatting/style (nice-to-have)

Translation: A perfectly documented file with ONE modified comment = REJECTED
            A basic documented file with all comments preserved = ACCEPTED

When in doubt, err on the side of preservation.

═══════════════════════════════════════════════════════════════════════
                          END OF PROMPT
═══════════════════════════════════════════════════════════════════════
```

---

## SUMMARY OF STRUCTURAL CHANGES

```
OLD STRUCTURE (V5):
-------------------
[Documentation Philosophy]
[Goal]
[Doxygen Structure]
[Various Sections]
[Existing Comment Handling] ← buried at line 227
[More sections]
[Examples]

NEW STRUCTURE (V6):
-------------------
🛑 CRITICAL REQUIREMENTS ← NEW, at top
   - Comment preservation priority
   
📋 MANDATORY PRE-FLIGHT CHECKLIST ← NEW
   - Extract comments
   - Identify allowed locations
   - Acknowledge understanding
   
[Documentation Philosophy]
[Goal]
[Doxygen Structure]

🛑 EXISTING COMMENT HANDLING ← ENHANCED
   - Visual examples
   - Zero tolerance language
   - When in doubt rules
   
[Various Sections]

✓ MANDATORY VALIDATION ← NEW
   - 4 validation checks
   - Confidence statement
   - Proof requirement
   
❓ SELF-CHECK ← NEW
   - Quality questions
   - Preservation questions
   - Go/no-go decision
   
✅ ACCEPTANCE CRITERIA ← NEW
   - What gets accepted
   - What gets rejected
   - Priority hierarchy
```

---

## QUICK IMPLEMENTATION GUIDE

To upgrade your prompt from V5 to V6:

1. **Add at top**: CRITICAL REQUIREMENTS + PRE-FLIGHT CHECKLIST
2. **Find & replace**: Existing "EXISTING COMMENT HANDLING" section
3. **Add before examples**: MANDATORY VALIDATION section
4. **Add at end**: SELF-CHECK + ACCEPTANCE CRITERIA

Time to implement: ~10 minutes of copy/paste
Expected improvement: 100% reduction in comment modification errors

---

## TESTING YOUR V6 PROMPT

Test on sample code with known comments:

```c
/* Original comment */
int test(void) {
    /* Another original */
    return 0;
}
```

Expected AI behavior with V6:
1. Stops at pre-flight, extracts 2 comments
2. Adds documentation BEFORE function
3. Preserves both comments exactly
4. Provides validation: "Found 2, preserved 2, diff=EMPTY"
5. States 100% confidence

If AI modifies comments or doesn't validate → prompt needs more work
If AI follows process and validates → V6 is working

---

END OF CONCRETE CHANGES DOCUMENT
