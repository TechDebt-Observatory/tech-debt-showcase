# READY-TO-RUN TEST PACKAGE
# Dictionary Fix Validation - Phase 1 v6
# Run this in a NEW Claude Desktop conversation

═══════════════════════════════════════════════════════════════════════
                    TEST INSTRUCTIONS - READ FIRST
═══════════════════════════════════════════════════════════════════════

## Setup
1. Open NEW conversation in Claude Desktop (fresh context)
2. Copy SECTION 1 (Context) + SECTION 2 (Prompt) + SECTION 3 (Source)
3. Paste into Claude Desktop
4. Wait for completion
5. Save output to: test-results/dictionary-fix-validation/dh_check_TEST_v6_fixed.c
6. Run SECTION 4 (Validation Script) to extract metrics

## Memory Mitigation
- Using fresh conversation minimizes memory impact
- Both baseline and test run under same conditions (fair comparison)
- Document as: "Memory enabled (standard chat conditions)"

═══════════════════════════════════════════════════════════════════════
                    SECTION 1: CONTEXT FRAMING
═══════════════════════════════════════════════════════════════════════

IMPORTANT: This is a standalone documentation task. Treat this source file as if you've never seen it before. Ignore any previous context about DH, OpenSSL, or CVE-2023-3446. Your task is to document this file according to the prompt below, with special attention to the VARIABLE_DICTIONARY section.

═══════════════════════════════════════════════════════════════════════
                    SECTION 2: PROMPT (Phase 1 v6 - Fixed)
═══════════════════════════════════════════════════════════════════════

[PASTE ENTIRE CONTENTS OF: methodology/prompt-engineering/Phase1v6.txt]

NOTE: The prompt is 712 lines. Make sure you copy the ENTIRE file from:
  "Version 6 of phase 1 prompt" 
through to:
  "END OF PROMPT"

═══════════════════════════════════════════════════════════════════════
                    SECTION 3: SOURCE FILE TO DOCUMENT
═══════════════════════════════════════════════════════════════════════

File: dh_check.c
Lines: 333
Purpose: DH parameter validation (CVE-2023-3446 case study)

---BEGIN SOURCE---

[PASTE ENTIRE CONTENTS OF: case-studies/CVE-2023-3446-dhtest/original/dh_check.c]

---END SOURCE---

═══════════════════════════════════════════════════════════════════════
                    WAIT FOR CLAUDE TO COMPLETE
═══════════════════════════════════════════════════════════════════════

Expected output:
- Fully documented dh_check.c with Doxygen comments
- VARIABLE_DICTIONARY section should appear EARLY in output
- Validation proof at the end with dictionary completeness metric

═══════════════════════════════════════════════════════════════════════
                    SECTION 4: SAVE AND VALIDATE
═══════════════════════════════════════════════════════════════════════

1. Save Claude's output to:
   tech-debt-showcase/test-results/dictionary-fix-validation/dh_check_TEST_v6_fixed.c

2. Run validation script (below) to extract metrics

3. Compare to baseline

═══════════════════════════════════════════════════════════════════════
                    END OF TEST PACKAGE
═══════════════════════════════════════════════════════════════════════
