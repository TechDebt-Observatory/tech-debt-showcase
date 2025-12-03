# Methodology Directory
## Tech Debt Observatory

This directory contains the **methodological frameworks and documentation standards** for the Tech Debt Observatory project.

---

## Shell Script Documentation (4D Framework)

**NEW: Complete 4D documentation framework for shell scripts**

### Quick Access

- **📖 Complete Standard:** [`script-documentation-standard.md`](script-documentation-standard.md)
  - Full 4D framework guide (18KB)
  - All levels, patterns, and examples
  - Use as complete reference

- **🚀 Quick Start:** See `/QUICK_START.md` in project root
  - 10-minute introduction
  - First script walkthrough
  - Common patterns

- **📊 Visual Guide:** See `/VISUAL_GUIDE.md` in project root
  - Visual diagrams and flowcharts
  - Quick reference cards
  - Print for desk reference

- **📝 Templates:** See `/tools/templates/`
  - `script_template.sh` - Shell script template
  - `python_template.py` - Python template

- **✅ Status:** See `/tools/DOCUMENTATION_STATUS.md`
  - Progress tracking
  - Script inventory
  - Implementation roadmap

### The 4D Framework

**Four dimensions for self-documenting scripts:**

1. **@purpose** - What problem does this solve?
2. **@workflow** - How does it accomplish the goal?
3. **@dependencies** - What does it need to run?
4. **@gotchas** - What can go wrong and how to fix it?

**Three documentation levels:**
- **Level 1 (Simple):** < 50 lines, header-only, ~15 min
- **Level 2 (Important):** 50-200 lines, header + phases, ~30-45 min
- **Level 3 (Critical):** 200+ lines, comprehensive, ~45-90 min

**Reference example:** `/tools/cve_2023_3446_forensics.sh` (gold standard)

### Implementation Status

- ✅ 1/9 scripts complete
- 🔄 2/9 in progress (50-60% done)
- ⏳ 6/9 planned
- **Estimated completion:** ~4.5 hours total

---

## C/C++ Code Documentation (6D Framework)

**Original framework for legacy C/C++ codebases**

### Directories

- **`cve-investigation-framework/`** - NTSB-style CVE investigation methodology
- **`existing-prompts/`** - Prompt templates for code analysis
- **`prompt-engineering/`** - Prompt engineering best practices

### The 6D Framework

**Six dimensions for comprehensive code documentation:**

1. **@intent** - Function purpose and expected behavior
2. **@history** - Evolution of implementation
3. **@deps** - External dependencies and relationships
4. **@techdebt** - Known issues and modernization barriers
5. **@arch** - Architectural context and design patterns
6. **@security** - Security implications and attack vectors

### Relationship to 4D

The **4D framework is a lightweight adaptation** of 6D for shell scripts:

| 6D (C/C++) | → | 4D (Scripts) |
|-----------|---|--------------|
| @intent + @arch | → | @purpose + @workflow |
| @deps | → | @dependencies |
| @techdebt + @security + @history | → | @gotchas |

**Philosophy:** Scripts need practical, operational documentation; C code needs architectural, security-focused documentation.

---

## CVE Investigation Methodology

See [`readme_cve_analysis.md`](readme_cve_analysis.md) for:
- CVE forensic extraction process
- Analysis methodology
- AI detection experiments
- Validation procedures

---

## File Structure

```
methodology/
├── README.md                              (This file)
│
├── script-documentation-standard.md       (4D framework - COMPLETE)
│   └── Shell & Python documentation guide
│
├── readme_cve_analysis.md                 (CVE methodology)
│   └── Investigation framework
│
├── cve-investigation-framework/           (CVE analysis)
│   └── NTSB-style investigation templates
│
├── existing-prompts/                      (6D prompts)
│   └── Code analysis prompt templates
│
└── prompt-engineering/                    (6D techniques)
    └── Best practices for AI code analysis
```

---

## Quick Links

### For Shell Scripts

- Start here: `/QUICK_START.md`
- Complete guide: `script-documentation-standard.md`
- Templates: `/tools/templates/`
- Examples: `/tools/cve_2023_3446_forensics.sh`

### For C/C++ Code

- Investigation framework: `cve-investigation-framework/`
- Prompt templates: `existing-prompts/`
- Prompt engineering: `prompt-engineering/`

### Project Documentation

- Implementation summary: `/IMPLEMENTATION_SUMMARY.md`
- Visual guide: `/VISUAL_GUIDE.md`
- Complete deliverables: `/DELIVERABLES.md`

---

## Contributing

When adding new methodologies:

1. **Document the framework** - Create complete standard like 4D
2. **Provide templates** - Make it easy to apply
3. **Show examples** - Real-world reference implementations
4. **Track progress** - Status document for adoption
5. **Update this README** - Keep directory organized

---

## Version History

- **2024-11-29:** Added 4D framework for shell scripts
  - Complete documentation standard
  - Templates for shell and Python
  - Progress tracking system
  - Quick start and visual guides

- **2024-11-28:** Established CVE investigation methodology
  - NTSB-style forensic framework
  - Analysis prompts and procedures

- **Earlier:** 6D framework for C/C++ code
  - Comprehensive code documentation
  - Prompt engineering techniques

---

**Methodology Status:** Active development  
**Last Updated:** 2024-11-29  
**Maintainer:** Baz
