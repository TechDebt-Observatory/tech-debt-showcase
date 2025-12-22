# Phase 1 Prompt v7 - Complete Package (7D Framework)

## What This Package Contains

This directory contains the complete Phase 1 v7 documentation prompt aligned with the **7D Documentation Framework v4.0**, supporting IEEE 1012-2024 V&V compliance for safety-critical systems.

---

## Core Files

### The 7D Framework

This prompt implements the **7D Documentation Framework v4.0**, which captures:
- **D1: Syntax** - What code accepts/returns
- **D2: Structure** - How code works internally  
- **D3: Intent** - Why code exists
- **D4: History** - How code evolved
- **D5: Relationships** - Where code fits in system
- **D6: Quality & Telemetry** - What's wrong + how to observe it
- **D7: Verification** - Proof of compliance (V&V)

### 1. Phase1v7.0.txt
**The actual prompt to use with AI**

**Location**: `/methodology/prompt-engineering/Phase1v7.0.txt`

**What it is**: 
- Production-ready prompt for AI-assisted code documentation
- Aligned with 7D Documentation Framework v4.0
- Includes all 7 dimensions (D1-D7)
- Supports IEEE 1012-2024 V&V Level 4 compliance
- Includes three-persona attestation model

**How to use**:
1. Copy entire file
2. Paste into Claude (or other AI)
3. Provide source code file to document
4. AI will follow 7D structured process with validation
   - WARNING: will have problems with code containing >3000 lines or >50 functions. Claude Pro has 200,000 token output limit. Currently not tested on other AI token limits. Working on a chunking version or mulit-pass for larger files.
5. For Level 3+: Complete three-persona attestation

**Key features**:
- 7 documentation dimensions (Syntax, Structure, Intent, History, Relationships, Quality/Telemetry, Verification)
- 3 Tier policy on comment preservation: (1 Must keep unchanged, 2 Modify, 3 remove non professional comments)
- Visual examples (WRONG vs RIGHT patterns)
- D7 verification checkpoint with attestation block
- Three-persona model (Builder, Auditor, Economist)
- V&V level scaling (Level 1-4 rigor options)

---

### 2. Phase1v5_to_v6_CHANGES.md (Historical)
**Summary of v5→v6 changes (comment preservation focus)**

**What it covers**:
- What problem v6 solved (comment modification in v5)
- 7 major structural changes
- Psychological/cognitive design improvements
- Expected outcomes (95-99% compliance)

**Note**: v6→v7 changes are framework-focused (7D alignment), not error correction.

### 2b. v6→v7 Changes Summary
**What changed from v6 to v7**:
- Upgraded from 6 dimensions to 7D Framework v4.0
- Added D7: Verification & Compliance (IEEE 1012-2024 V&V)
- Consolidated telemetry into D6: Quality & Telemetry
- Added three-persona attestation model (Builder, Auditor, Economist)
- Added V&V level scaling (Level 1-4)
- Added functional safety standard mapping (ISO 26262, IEC 61508)

---

### 3. AI_ATTRIBUTION_STANDARDS.md
**How AI contribution attribution works**

**What it covers**:
- Linux kernel / Fedora / Red Hat guidelines
- Our minimal approach (file-level + technical debt tags)
- What we include vs what we don't
- Tooling implications (Doxygen, grep, validation)
- Validator guidelines
- FAQ and compliance checklist

**Use this to**:
- Understand why certain tags exist
- Know how to fill validation fields
- Align with open source standards
- Explain approach to external reviewers

---

## Supporting Analysis (v5→v6 Error Study)

Note: The v5→v6 analysis remains valid for comment preservation lessons.
The v6→v7 changes focus on 7D framework alignment, not error correction.

### Directory: `/phase-1-prompts/Phase 1 v5 to v6 Error Analysis/`

**Key documents**:

1. **MASTER_SUMMARY.md** (16KB)
   - Executive summary of what went wrong
   - Complete overview of all analysis documents
   - What you have now and how to use it
   - Immediate next steps

2. **prompt_improvements.md** (17KB)
   - Root cause analysis (why instructions were ignored)
   - 8 specific prompt changes with rationale
   - Testing methodology
   - Expected outcomes

3. **prompt_revision_concrete.md** (15KB)
   - Ready-to-use text sections (used to build v6)
   - Exact additions to make
   - Before/after structural comparison
   - Quick implementation guide

4. **prompt_v6_psychology.md** (12KB)
   - Cognitive science explanation
   - Why v6 prevents errors v5 didn't
   - 4 cognitive barriers in v5
   - 8 cognitive enhancements in v6

5. **prevention_checklist.md** (6.4KB)
   - Process to follow before/during/after documentation
   - Pre-documentation mandatory steps
   - Post-documentation validation
   - Workflow changes

6. **validate_comment_preservation.sh** (4.2KB)
   - Executable validation script
   - Automatically detects comment modifications
   - Usage: `./validate_comment_preservation.sh original.c documented.c`
   - Clear PASS/FAIL output

7. **corrected_examples.txt** (8.8KB)
   - Three complete functions showing proper pattern
   - Visual examples of correct documentation
   - Validation checklist for each

---

## Quick Start Guide

### For First-Time Use

1. **Read Phase1v7.0.txt** (5 minutes)
   - Understand 7D structure and requirements
   - Note the pre-flight checklist
   - Review visual examples
   - Understand three-persona attestation (Level 3+)

2. **Test on sample file** (10 minutes)
   - Use a file with known comments
   - Verify AI completes pre-flight
   - Check validation proof provided
   - Run validation script

3. **Review output** (5 minutes)
   - Confirm all Tier 1 original comments preserved
   - Verify documentation quality
   - Check AI attribution present

**Total time**: ~20 minutes to validate v7 works

---

### For Understanding Why v6 Exists

1. **Read MASTER_SUMMARY.md** (10 minutes)
   - What went wrong with v5
   - Overview of all fixes
   - Big picture understanding

2. **Read Phase1v5_to_v6_CHANGES.md** (5 minutes)
   - Specific changes made
   - Expected improvements
   - Testing guidelines

3. **Skim prompt_v6_psychology.md** (5 minutes, optional)
   - Cognitive science behind changes
   - Why structural enforcement works
   - Design principles

**Total time**: 15-20 minutes to understand rationale

---

### For Implementing in Your Workflow

1. **Use Phase1v7.0.txt** as your standard prompt

2. **Use validate_comment_preservation.sh** on all outputs
   ```bash
   ./validate_comment_preservation.sh original.c documented.c
   ```

3. **Follow prevention_checklist.md** process:
   - Pre-documentation analysis
   - Documentation rules
   - Post-documentation validation

4. **Track metrics** over time:
   - % passing validation
   - % requiring rework
   - Time saved vs manual review

---

## Integration with Technical Debt Observatory

### How This Fits Into the Larger Project

**Phase 1 (this prompt)**:
- 7D comprehensive documentation generation (D1-D7)
- Technical debt identification with telemetry (D6)
- Comment preservation (unchanged)
- AI attribution (unchanged)
- V&V checkpoint generation (D7)
- Three-persona attestation support

**Phase 2** (separate prompt):
- 7D validation and refinement
- False positive filtering
- Severity calibration
- Cross-file relationship analysis (D5)
- Economist review for HIGH/MEDIUM debt items

**Phase 3** (automation):
- Batch processing scripts
- CI/CD integration with GPG signing
- Automated validation
- Metrics dashboard
- V&V artifact generation

---

## Version History

### v5.0 (Previous)
- Comprehensive documentation requirements
- Comment preservation instruction at line 227
- Quality standards well-defined
- **Problem**: Instructions ignored, comments modified

### v6.0 (Previous)
- Critical requirements at top (impossible to miss)
- Mandatory pre-flight checklist (forced awareness)
- Enhanced visual examples (concrete guidance)
- Required validation proof (cannot skip)
- Self-check questionnaire (metacognitive gate)
- AI attribution standards (OSS compliance)
- **Problem**: Limited to 6 dimensions, no V&V compliance support

### v7.0 (Current)
- 7D Documentation Framework alignment (D1-D7)
- D7: Verification & Compliance (IEEE 1012-2024 V&V support)
- D6: Quality & Telemetry (consolidated runtime instrumentation)
- Three-persona attestation model (Builder, Auditor, Economist)
- V&V level scaling (Level 1-4 rigor options)
- GPG signing workflow for Level 3+ compliance
- ISO 26262 / IEC 61508 functional safety mapping
- **Result**: Full regulatory compliance support + 95-99% documentation compliance

### v8.0 (Future?)
Potential additions based on real-world usage:
- Phase 2 integration hooks for 7D validation
- Automated three-persona workflow tooling
- CI/CD GPG signing integration
- Multi-file cross-reference analysis

---

## Validation Script Usage

### Basic Usage
```bash
# Make script executable (first time only)
chmod +x validate_comment_preservation.sh

# Run validation
./validate_comment_preservation.sh original.c documented.c

# Expected output if PASSED:
✓ Comment count: 42 → 67 (added 25, preserved all)
✓ No comments removed (diff check clean)
✓ Sample verification: 3/3 preserved
✓ VALIDATION PASSED

# Expected output if FAILED:
✗ Comment count decreased: 42 → 40 (2 MISSING)
✗ Found removed comments:
  Line 145: /* Original comment text */
  Line 287: /* Another original comment */
✗ VALIDATION FAILED - Comments were modified
```

### Automated Pipeline Integration
```bash
#!/bin/bash
# In your CI/CD pipeline

for file in src/*.c; do
    # Run AI documentation
    ai_document "$file" > "documented/$file"
    
    # Validate
    if ./validate_comment_preservation.sh "$file" "documented/$file"; then
        echo "✓ $file passed validation"
        git add "documented/$file"
    else
        echo "✗ $file FAILED - rejecting"
        rm "documented/$file"
        exit 1
    fi
done
```

---

## Common Issues and Solutions

### Issue: AI skips pre-flight checklist
**Solution**: The checklist is in the prompt. If AI skips it:
1. Verify you're using Phase1v6.txt (not v5)
2. Check if CRITICAL REQUIREMENTS section is at top
3. Try explicitly asking: "Start with pre-flight checklist"
4. If persistent, file bug report

### Issue: AI provides validation but it's wrong
**Solution**: Don't trust AI validation alone
1. ALWAYS run validation script
2. Spot-check 3-5 functions manually
3. If script fails, reject AI output
4. AI validation is self-check, script is ground truth

### Issue: Original comments modified despite v6
**Solution**: This means v6 needs refinement
1. Document which comments were modified
2. Analyze why they were missed
3. Consider adding to visual examples
4. Update v6.1 with additional patterns

### Issue: Too verbose, too much validation
**Solution**: Validation only happens once per file
1. Initial overhead is necessary for quality
2. Time saved on preventing rework >> validation time
3. Can automate validation script in pipeline
4. Alternative: Accept lower quality / higher risk

---

## Metrics to Track

### Primary Metrics (Quality Gates)
- **Comment Preservation Rate**: Must be 100%
- **Validation Script Pass Rate**: Must be 100%
- **Pre-flight Completion Rate**: Must be 100%

### Secondary Metrics (Performance)
- Documentation time per file
- Rework rate (% requiring corrections)
- False positive rate (technical debt)
- Human validation time required

### Long-term Metrics (Value)
- New contributor onboarding time (before/after)
- Bug rate in documented vs undocumented code
- Maintainer satisfaction (survey)
- Technical debt reduction over time

---

## When to Update This Prompt

### Update triggers:
1. **Standards evolve**: Linux kernel changes AI guidelines
2. **Consistent failures**: >5% fail validation despite v6
3. **New requirements**: Legal/compliance needs emerge
4. **Tool limitations**: AI models change behavior
5. **Feedback**: Maintainers request changes

### Update process:
1. Document problem in new directory (like v5→v6 analysis)
2. Analyze root cause
3. Test potential fixes
4. Create v7.0 with changes
5. Document in version history
6. Update this README

---

## Support and Questions

### If you find issues:
1. Document the failure case
2. Run validation script
3. Check if issue is in documentation
4. File bug report with:
   - Input file
   - AI output
   - Validation results
   - Expected vs actual behavior

### If you need help:
1. Start with MASTER_SUMMARY.md
2. Check relevant specific document
3. Review visual examples
4. Test with validation script

### If you want to contribute:
1. Propose changes with rationale
2. Test on multiple files
3. Provide before/after comparison
4. Update relevant documentation

---

## File Organization

```
methodology/prompt-engineering/
├── Phase1v7.0.txt                        ← Use this
├── Phase1v6_to_v7_CHANGES.md             ← Read this (if exists)
├── AI_ATTRIBUTION_STANDARDS.md           ← Reference this
├── README_v7.md                          ← You are here
│
├── phase-1-prompts/
│   ├── Phase 1 v5 to v6 Error Analysis/
│   │   ├── MASTER_SUMMARY.md            ← Start here
│   │   ├── prompt_improvements.md       ← Deep dive
│   │   ├── prompt_revision_concrete.md  ← Implementation
│   │   ├── prompt_v6_psychology.md      ← Theory
│   │   ├── prevention_checklist.md      ← Process
│   │   ├── validate_comment_preservation.sh  ← Tool
│   │   └── corrected_examples.txt       ← Examples
│
└── [other methodology files...]
```

---

## Success Criteria

### You'll know v6 is working when:
1. ✅ AI consistently completes pre-flight checklist
2. ✅ Validation script passes on first try
3. ✅ Zero comments modified across multiple files
4. ✅ AI provides validation proof proactively
5. ✅ Documentation quality meets standards
6. ✅ Human validation time decreases
7. ✅ Maintainer complaints about AI docs drop to zero

### You'll know v6 needs refinement when:
1. ❌ Validation script fails >5% of time
2. ❌ AI skips validation steps
3. ❌ Maintainers reject AI documentation
4. ❌ Comments still getting modified
5. ❌ False positive rate on technical debt >20%
6. ❌ Rework time exceeds initial documentation time

---

## Next Steps

### Immediate (Today)
1. [ ] Test Phase1v6.txt on 2-3 sample files
2. [ ] Verify validation script works in your environment
3. [ ] Review one complete example from corrected_examples.txt
4. [ ] Confirm you understand pre-flight requirements

### Short-term (This Week)
1. [ ] Document 10+ files using v6
2. [ ] Track metrics (pass rate, rework needed)
3. [ ] Gather feedback from team
4. [ ] Refine workflow based on results

### Long-term (This Month)
1. [ ] Integrate into standard documentation process
2. [ ] Train team on v6 requirements
3. [ ] Automate validation in CI/CD
4. [ ] Establish quality baselines
5. [ ] Plan Phase 2 integration

---

## Questions?

Check the FAQ sections in:
- AI_ATTRIBUTION_STANDARDS.md
- MASTER_SUMMARY.md
- prompt_v6_psychology.md

If still unclear, document your question and test case.

---

**Version**: 7.0  
**Status**: Production Ready  
**Last Updated**: 2025-12-13  
**Maintainer**: Technical Debt Observatory Team
**Framework**: 7D Documentation Framework v4.0
