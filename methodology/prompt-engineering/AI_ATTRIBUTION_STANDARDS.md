# AI Attribution Standards

## Context: Open Source AI Contribution Guidelines

As of 2025, major open source projects (Linux kernel, Fedora, Red Hat) are establishing guidelines for AI-assisted contributions. Phase 1 v6 aligns with these emerging standards.

---

## Our Approach: Minimal but Transparent

Following the Linux kernel philosophy:
- **Human responsibility**: Developer signing off takes full responsibility
- **No special status**: AI-assisted code isn't treated differently
- **Minimal bureaucracy**: Don't create AI-specific processes
- **Trust but verify**: Same review standards apply

---

## Attribution Tags in Phase 1 v6

### File-Level Attribution (Required)
Added to file header template:

```c
/**
@file filename.c
@brief One-sentence purpose

@details [comprehensive documentation]

@section AI_ATTRIBUTION
Documentation generated with assistance from Claude (Anthropic AI)
Analysis date: [YYYY-MM-DD]
Prompt version: 6.0
Validated by: [to be filled during validation]

[rest of documentation sections]
*/
```

**Why this placement**:
- After brief/details (human-readable priority)
- Before technical sections
- Non-intrusive but discoverable
- Clear without being bureaucratic

### Technical Debt Markers (Required)
Added to `@technical_debt` blocks:

```c
/**
@technical_debt
@category BUFFER_OVERFLOW
@severity CRITICAL
@confidence HIGH
@ai_detected              ← NEW
@validated pending         ← NEW
@lines 45-47
@issue strcpy() with no size validation
@impact Remote code execution possible
@recommendation Use strncpy with bounds check
@see CERT STR31-C, CWE-120
*/
```

**Why these tags**:
- `@ai_detected`: Makes clear this wasn't human-found
- `@validated`: Tracks human review status (pending/confirmed/rejected)
- Standard Doxygen format (tooling compatible)
- Minimal addition (2 tags, not overwhelming)

### Optional: Uncertain Analysis
For low-confidence findings:

```c
/**
 * @note SPECULATION (AI-generated, low confidence):
 * This custom memory pool may exist for VMS performance (historical).
 * Modern systems may not need it, but kept for ABI stability.
 * 
 * @ai_confidence low
 * @validation_needed Verify with maintainer or VMS expert
 */
```

**When to use**:
- Historical context you're inferring
- Design rationale that's not documented
- Edge case behavior you're uncertain about
- Performance characteristics without benchmarks

**When NOT to use**:
- Facts you can verify in code
- Standard patterns (no speculation needed)
- Well-documented behavior

---

## What We Don't Include

### ❌ Not Using Verbose Tags
We chose NOT to adopt:
```c
@ai-model-version claude-3.5-sonnet-20241022
@ai-training-cutoff 2024-04
@ai-temperature 0.3
@ai-token-count 15243
@ai-cost-usd 0.08
@ai-inference-time-ms 45000
```

**Why**: Too much noise. Doesn't help maintainers. Focus on content, not process.

### ❌ Not Marking Every Comment
We chose NOT to do:
```c
/* @ai-generated This loop iterates over buffer */ ← No
/* Buffer iteration for null termination check */  ← Yes, no tag
```

**Why**: If file header says "AI-documented", all NEW comments are implicitly AI-generated. No need to tag each one.

### ❌ Not Disclaiming Constantly
We chose NOT to do:
```c
/** 
 * @brief Performs RSA decryption
 * @ai-disclaimer This may be incorrect, verify independently
 * @ai-disclaimer Not reviewed by maintainer
 * @ai-disclaimer Use at your own risk
 */
```

**Why**: One disclaimer at file level is sufficient. Repetition creates noise and implies unreliability.

---

## Comparison with Linux Kernel Guidelines

### Linux Kernel Approach
```c
/*
 * This code was generated with assistance from GitHub Copilot
 * Reviewed and validated by [developer name]
 */
```

**Characteristics**:
- Minimal (2 lines)
- States tool used
- States human validator
- No metadata spam
- Doesn't disrupt code flow

### Our Approach (Phase 1 v6)
```c
/**
@section AI_ATTRIBUTION
Documentation generated with assistance from Claude (Anthropic AI)
Analysis date: 2025-11-20
Prompt version: 6.0
Validated by: [human validator]
*/
```

**Characteristics**:
- Slightly more verbose (4 fields)
- Includes date (for tracking evolution)
- Includes prompt version (for reproducibility)
- Uses Doxygen sections (tooling compatible)
- Still maintains minimal philosophy

**Rationale for differences**:
- **Date**: Useful for "was this recent?" questions
- **Prompt version**: Essential for methodology reproducibility
- **Doxygen format**: Generates documentation automatically
- **Section vs inline**: Groups related metadata

---

## Tooling Implications

### Doxygen Output
The `@section AI_ATTRIBUTION` generates a subsection in HTML/PDF documentation:
- Appears in table of contents
- Searchable by string "AI_ATTRIBUTION"
- Can be filtered/extracted by scripts
- Doesn't clutter main documentation flow

### Grep/Search
```bash
# Find all AI-documented files
grep -r "@section AI_ATTRIBUTION" src/

# Find specific prompt version
grep -r "Prompt version: 6.0" src/

# Find unvalidated AI findings
grep -r "@validated pending" src/

# Find AI-detected technical debt
grep -r "@ai_detected" src/
```

### Validation Scripts
Our validation script can now check:
```bash
# Ensure all documented files have attribution
if ! grep -q "@section AI_ATTRIBUTION" "$file"; then
    echo "ERROR: Missing AI attribution in $file"
fi

# Ensure prompt version matches expected
if ! grep -q "Prompt version: 6.0" "$file"; then
    echo "WARNING: Unexpected prompt version in $file"
fi
```

---

## Evolution Path

### Current State (v6.0)
- File-level attribution (required)
- Technical debt tags (required)
- Uncertainty tags (optional)

### Future Considerations (v7.0+)

**If standards evolve, we might add**:
```c
@ai_model_family claude-sonnet
@ai_provider anthropic
@review_status pending  
@confidence_distribution high:12,medium:4,low:1
```

**Triggers for adding more tags**:
1. Industry standards converge on specific format
2. Tooling emerges that requires specific tags
3. Legal/compliance requirements appear
4. Research needs demand more metadata

**Triggers for removing tags**:
1. Community feedback says "too verbose"
2. Maintainers ignore/skip documentation
3. Tooling doesn't use the data
4. Standards shift to simpler approach

---

## Guidelines for Validators

### When Filling Validation Field

**Good validation entries**:
```c
Validated by: J. Smith (OpenSSL core maintainer)
Validated by: Security team (2025-11-20)
Validated by: Anonymous reviewer (external audit)
Validated by: Automated testing + manual spot-check
```

**Bad validation entries**:
```c
Validated by: AI ← No, defeats the purpose
Validated by: N/A ← Then don't use this documentation
Validated by: Maybe? ← Not validated, mark as pending
Validated by: [empty] ← Fill this in or don't merge
```

### Validation Status Lifecycle

```
@validated pending     → AI just documented, not reviewed yet
           ↓
@validated in_review   → Human actively checking
           ↓
@validated confirmed   → Human verified accuracy
           ↓
@validated rejected    → Human found errors, needs redo
```

**For Technical Debt**:
- `pending`: AI detected, not confirmed
- `confirmed`: Human verified it's real
- `false_positive`: Human determined it's not an issue
- `wont_fix`: Real issue, but accepted (document why)

---

## FAQ

### Q: Do we need to tag AI-generated inline comments?
**A**: No. File header attribution covers all new content. Only tag uncertainty.

### Q: What if original code already has AI-generated content?
**A**: Phase 1 focuses on documentation only. Preserve all original comments exactly, regardless of their origin.

### Q: Should we credit specific AI models?
**A**: Yes, at file level. Helps with reproducibility and tracking model improvements over time.

### Q: What if multiple AIs were used?
**A**: Document all:
```c
@section AI_ATTRIBUTION
Documentation generated with assistance from:
- Claude 3.5 Sonnet (initial analysis)
- GPT-4 (validation review)
Prompt version: 6.0
Validated by: [human]
```

### Q: Do these tags affect compilation?
**A**: No. They're comments. Zero impact on compiled code.

### Q: Can we auto-generate these tags?
**A**: Partially. The script can fill:
- `Analysis date`: current date
- `Prompt version`: from version control
- `@ai_detected`: automatically added

Humans must fill:
- `Validated by`: who reviewed
- `@validated`: status after review

---

## Compliance Checklist

For Phase 1 v6 documentation to be compliant:

File-Level Attribution:
- [ ] `@section AI_ATTRIBUTION` present
- [ ] AI model identified
- [ ] Analysis date included
- [ ] Prompt version specified
- [ ] Validation field present (can be "pending")

Technical Debt:
- [ ] All issues have `@ai_detected` tag
- [ ] All issues have `@validated` status
- [ ] Severity and confidence included
- [ ] Recommendation provided

Comment Preservation:
- [ ] All original comments preserved exactly
- [ ] No original content modified
- [ ] Validation proof provided

If any box unchecked → Documentation incomplete → Do not merge

---

## Summary

Phase 1 v6 attribution approach:
- **Minimal**: Only essential tags
- **Transparent**: Clear about AI involvement
- **Tooling-friendly**: Doxygen compatible
- **Human-centric**: Focus on content, not process
- **Evolution-ready**: Can add tags if standards emerge

This balances:
- Transparency (community knows AI was used)
- Practicality (doesn't burden maintainers)
- Standards (aligns with Linux kernel philosophy)
- Reproducibility (can recreate analysis)

**Core principle**: If it doesn't help maintainers understand code, don't add it.

---

**Version**: 6.0  
**Status**: Aligned with Linux kernel AI contribution guidelines (2025)  
**Review date**: Update if OSS standards change significantly
