# Session Notes: CVE Case Study Planning
**Date:** 2025-11-29  
**Session Topic:** 5-CVE Case Study Structure & Script Documentation Plan

---

## WHERE WE LEFT OFF

We were planning the 5-CVE case study series for testing the 6D documentation framework.

### DECISIONS MADE

**4 Additional CVEs Selected:**
1. **CVE-2023-3817** - DH q parameter DoS (follow-up to CVE-2023-3446)
2. **CVE-2024-4603** - DSA parameter validation DoS (similar pattern, different algorithm)
3. **CVE-2024-0727** - PKCS12 NULL pointer dereference (memory safety)
4. **CVE-2024-4741** - SSL_free_buffers use-after-free (resource lifecycle)

**Directory Structure Finalized:**
- Each CVE follows standardized structure
- Test results in `test-results/control-group/` and `test-results/experimental-group/`
- Documented code versioned as `{file}_6D_v6.2.c`
- Metadata in markdown + CSV format

**Shared Tools Approach:**
- Generic templates in `/tools/`
- CVE-specific configs in each `case-studies/CVE-*/scripts/`
- Hybrid approach: shared logic, local customization

**Testing Structure:**
- 12 tests per CVE (6 control, 6 experimental)
- 2 AI models (GPT-4, Kimi K2)
- 3 standardized queries per model
- Scoring rubrics: Detection (binary), Root Cause (0-100), Fix Correctness (0-100)

---

## NEXT ACTIONS

### IMMEDIATE: Script Documentation (New Chat)
Create 4D documentation standard for all bash/python scripts:
- Style guide: `/methodology/script-documentation-standard.md`
- Template: `/tools/templates/script_template.sh`
- Document critical scripts with full 4D (purpose, workflow, dependencies, gotchas)
- Leave simple scripts with minimal documentation

### AFTER SCRIPT DOCUMENTATION: Return to This Chat
1. Create shared tools (`forensics_template.sh`, `create_cve_case_study.sh`)
2. Set up all 5 CVE case study directories
3. Run forensic extraction for each CVE
4. Create 6D documentation for each vulnerable file
5. Execute testing protocol
6. Analyze and report findings

---

## KEY FILES TO REFERENCE

**CVE Investigation Framework:**
- `/methodology/cve-investigation-framework/README.md`
- `/methodology/cve-investigation-framework/test_methodology.md`

**Existing Case Study:**
- `/case-studies/CVE-2023-3446-dhtest/` (template structure)
- `/case-studies/CVE-2023-3446-dhtest/README.md` (detailed methodology)

**6D Prompt:**
- `/methodology/prompt-engineering/Phase1v6.2.txt` (current version)

**Existing Forensics Script:**
- `/tools/cve_2023_3446_forensics.sh` (to be used as template)

---

## CHAT LINKS

**Current Chat:** [This conversation about CVE selection and structure planning]  
**Next Chat:** Script documentation with 4D framework

---

## NOTES

- All 4 CVEs have clear git commits and documented fixes
- Testing order recommended: CVE-2023-3817 → CVE-2024-4603 → CVE-2024-0727 → CVE-2024-4741
- Prompt version (v6.2) embedded in documented filenames for reproducibility
- Statistical analysis will aggregate across all 5 CVEs for meta-findings
