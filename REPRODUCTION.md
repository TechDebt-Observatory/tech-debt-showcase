# Using Claude API
```
curl https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d '{
    "model": "claude-sonnet-4-20250514",
    "max_tokens": 16000,
    "temperature": 0.3,
    "messages": [
      {
        "role": "user",
        "content": "I have a C program (OpenSSL'\''s apps/asn1parse.c) that I want you to analyze for technical debt and add comprehensive comments.\n\nPlease add good comments to the code. I'\''m an old school programmer who learned on System/370 assembly with punched cards.\n\nThe comments should include:\n\n1. A comprehensive header block at the top with:\n   - Purpose and overview of the program\n   - Complete INPUT/OUTPUT specification (command line args, file inputs, outputs, return values)\n   - Full VARIABLE DICTIONARY listing every variable with its scope, type, and purpose\n   - Memory management notes (what gets allocated/freed)\n   - Usage examples\n   - Technical debt markers\n   - Related functions and algorithms\n\n2. Inline comments throughout explaining:\n   - What each section does and WHY\n   - Complex algorithms and data structures\n   - Edge cases and potential gotchas\n   - Historical context and design decisions\n   - Security implications\n   - Known technical debt (marked with \"TECHNICAL DEBT\")\n\n3. For helper functions (like do_generate), add similar comprehensive headers with:\n   - Function signature and purpose\n   - Complete parameter documentation\n   - Return value specification\n   - Variable dictionary\n   - Algorithm flow\n   - Error conditions\n   - Usage examples\n   - Memory management\n   - Security considerations\n\nStyle: Old-school detailed documentation like we used to write for System/360. Every variable explained, every decision documented, every gotcha noted. The kind of comments where someone can understand the entire program just from reading the documentation.\n\n[PASTE CODE HERE]"
      }
    ]
  }'
```

---

## 📊 **TESTING PROTOCOL FOR REPEATABILITY**

### **Test Matrix:**

| AI Model           | Version     | Temperature | Date Tested | Pass/Fail |
|--------------------|-------------|-------------|-------------|-----------|
| Claude 3.5 Sonnet  | 20241022    | 0.3         | 2025-01-XX  |      PASS |
| GPT-4              | gpt-4-turbo | 0.3         | TBD         |         - |
| GPT-4o             | gpt-4o      | 0.3         | TBD         |         - |
| Gemini Pro         | 1.5         | 0.3         | TBD         |         - |
| Llama 3            | 70B         | 0.3         | TBD         |         - |

### **Evaluation Criteria:**

**Quantitative Metrics:**
- [ ] Variable dictionary completeness (% of variables documented)
- [ ] I/O specification present (Y/N)
- [ ] Function header present (Y/N)
- [ ] Usage examples included (count)
- [ ] Technical debt markers present (count)
- [ ] Comment-to-code ratio
- [ ] Time to generate (seconds)
- [ ] Cost per analysis (USD)

**Qualitative Metrics:**
- [ ] Accuracy of technical analysis
- [ ] Clarity of explanations
- [ ] Usefulness for onboarding
- [ ] Security insight quality
- [ ] "Old school" style adherence

---

## 📝 **STANDARDIZED PROMPT TEMPLATE**

For testing across different codebases:
```
TASK: Add comprehensive technical documentation to the provided C code.

TARGET AUDIENCE: Experienced systems programmers who value detailed documentation (System/370 era style).

REQUIRED DOCUMENTATION:

1. FILE HEADER (at top of file):
   • Purpose and overview
   • Complete I/O specification
   • Variable dictionary (all variables)
   • Memory management notes
   • Usage examples
   • Technical debt markers
   • Algorithm descriptions

2. FUNCTION HEADERS (before each function):
   • Function signature and purpose
   • Parameter documentation (in/out/inout)
   • Return value specification
   • Local variable dictionary
   • Algorithm flow
   • Error conditions
   • Usage examples
   • Memory management
   • Security considerations

3. INLINE COMMENTS (throughout code):
   • What each section does
   • WHY design decisions were made
   • Edge cases and gotchas
   • Security implications
   • Known technical debt (marked "TECHNICAL DEBT")

STYLE: Comprehensive, old-school documentation where the comments could serve as a complete manual for the code. Every variable explained, every decision documented, every risk noted.

CODE:
[PASTE CODE HERE]
