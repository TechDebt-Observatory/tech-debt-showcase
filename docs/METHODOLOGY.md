# Technical Debt Analysis Methodology

## Prompt Engineering

This project uses a standardized prompt to ensure reproducible results across different code samples and AI models.

### Core Prompt
I have a C program (OpenSSL's apps/asn1parse.c) that I want you to analyze for technical debt and add comprehensive comments.

Please add good comments to the code. I'm an old school programmer who learned on System/370 assembly with punched cards.

The comments should include:

1. A comprehensive header block at the top with:
   - Purpose and overview of the program
   - Complete INPUT/OUTPUT specification (command line args, file inputs, outputs, return values)
   - Full VARIABLE DICTIONARY listing every variable with its scope, type, and purpose
   - Memory management notes (what gets allocated/freed)
   - Usage examples
   - Technical debt markers
   - Related functions and algorithms

2. Inline comments throughout explaining:
   - What each section does and WHY
   - Complex algorithms and data structures
   - Edge cases and potential gotchas
   - Historical context and design decisions
   - Security implications
   - Known technical debt (marked with "TECHNICAL DEBT")

3. For helper functions (like do_generate), add similar comprehensive headers with:
   - Function signature and purpose
   - Complete parameter documentation
   - Return value specification
   - Variable dictionary
   - Algorithm flow
   - Error conditions
   - Usage examples
   - Memory management
   - Security considerations

Style: Old-school detailed documentation like we used to write for System/360. Every variable explained, every decision documented, every gotcha noted. The kind of comments where someone can understand the entire program just from reading the documentation.

[CODE WAS PROVIDED HERE]

### Prompt Design Principles
1. **Specificity**: Explicitly request variable dictionaries, I/O specs, etc.
2. **Audience Context**: "Old school programmer" sets the documentation style
3. **Structure**: Numbered list ensures all components are addressed
4. **Examples**: "like do_generate" gives concrete reference
5. **Quality Bar**: "understand the entire program just from documentation"

### Testing Protocol
To reproduce these results:
1. Use the exact prompt above
2. Include the full source code
3. Use Claude 3.5 Sonnet (or document alternative model)
4. Record: model version, date, temperature, output
5. Validate against checklist (see REPRODUCIBILITY.md)

### Known Variations
- Temperature affects creativity in explanations
- Different models have different documentation styles
- Context window limits may require file splitting
- Output token limits may truncate large files

## Validation Process
Each analysis is validated for:
- Technical accuracy of findings
- Completeness of documentation
- Code still compiles with comments
- No false positives in technical debt
