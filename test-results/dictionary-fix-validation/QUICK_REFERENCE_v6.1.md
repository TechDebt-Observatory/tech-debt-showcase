# Phase 1 v6.0 → v6.1 Quick Reference

## One-Line Summary
**v6.1 expands VARIABLE_DICTIONARY to SYMBOL_DICTIONARY with 7 explicit categories**

## What Changed

### Before (v6.0)
```
@section VARIABLE_DICTIONARY
Document all globals, file-scoped statics, and non-trivial function parameters
```
- Ambiguous scope
- No category structure
- Optional checkpoint (before writing code)
- Validation proof in conversation, not output

### After (v6.1)
```
@section SYMBOL_DICTIONARY

1. CONSTANTS AND MACROS
2. ERROR CODES / STATUS FLAGS
3. SPECIAL VALUES / SENTINEL VALUES
4. STRUCTURE FIELDS
5. GLOBAL VARIABLES
6. FUNCTION PARAMETERS
7. LOCAL/TEMPORARY VARIABLES
```
- Explicit 7-category structure
- Examples for each category
- Mandatory checkpoint proof IN OUTPUT
- Detailed breakdown by category

## The 7 Categories Explained

| # | Category | Example | Count Rule |
|---|----------|---------|------------|
| 1 | Constants/Macros | `DH_MIN_MODULUS_BITS: 512` | Each constant = 1 entry |
| 2 | Error Codes | `DH_CHECK_P_NOT_PRIME: 0x01` | Each code = 1 entry |
| 3 | Special Values | `NID_undef` (sentinel) | Each value = 1 entry |
| 4 | Structure Fields | `dh->params.p: BIGNUM*` | Each field = 1 entry |
| 5 | Globals | `static s_cache: ...` | Each global = 1 entry |
| 6 | Function Params | `const DH *dh` | Significant only, 1 each |
| 7 | Local Variables | `BIGNUM *tmp` | Significant only, can group |

## Critical New Requirements

### 1. Checkpoint Proof Must Be Embedded

**Location**: After `@section SYMBOL_DICTIONARY`, before content

**Format**:
```c
/**
 * @note CHECKPOINT PROOF - SYMBOL_DICTIONARY COMPLETENESS
 * Symbols scanned: 40
 * Dictionary entries created: 40
 * Completeness: YES
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
 * Status: COMPLETE - Proceeding to file header
 */
```

### 2. Individual Enumeration Required

**WRONG** (grouped):
```
Error flags (bitwise OR):
- DH_CHECK_P_NOT_PRIME, DH_CHECK_Q_NOT_PRIME, DH_NOT_SUITABLE_GENERATOR
```

**RIGHT** (individual):
```
Error Flag Constants:
1. DH_CHECK_P_NOT_PRIME: 0x01 - Modulus p failed primality test
2. DH_CHECK_Q_NOT_PRIME: 0x10 - Subgroup order q failed primality test
3. DH_NOT_SUITABLE_GENERATOR: 0x08 - Generator out of valid range
```

### 3. Explicit Category Headers

```
@section SYMBOL_DICTIONARY

Constants and Macros:
- DH_MIN_MODULUS_BITS: ...
- OPENSSL_DH_MAX_MODULUS_BITS: ...

Error Flag Constants:
- DH_CHECK_P_NOT_PRIME: ...
- DH_CHECK_P_NOT_SAFE_PRIME: ...

Special Values:
- NID_undef: ...

Structure Fields:
- dh->params.p: ...
- dh->params.g: ...

[etc for all 7 categories]
```

## Validation Changes

### CHECK 5 Updated

**Before**:
```
CHECK 5: Variable Dictionary Completeness
Total variables: [N]
```

**After**:
```
CHECK 5: Symbol Dictionary Completeness
Total symbols: [N]
  Breakdown by category (see 7 categories above)
```

### Self-Check Updated

**Added**:
```
[ ] Is SYMBOL_DICTIONARY complete with checkpoint proof?
[ ] Are all 7 categories documented (even if empty)?
[ ] Are error codes enumerated individually?
```

## Why This Matters for CVE Analysis

**CVE-2023-3446** is about a MISSING constant:
- `OPENSSL_DH_CHECK_MAX_MODULUS_BITS` didn't exist
- Code used `OPENSSL_DH_MAX_MODULUS_BITS` for validation (wrong!)
- Attacker could supply 100,000-bit modulus → DoS

**v6.0 Problem**: Wouldn't document constants, so wouldn't catch that one is MISSING

**v6.1 Solution**: Requires constants category, would document:
```
Constants and Macros:
- DH_MIN_MODULUS_BITS: 512 - Minimum size
- OPENSSL_DH_MAX_MODULUS_BITS: 10000 - Max for GENERATION
- OPENSSL_DH_CHECK_MAX_MODULUS_BITS: **MISSING** ← CVE-2023-3446
```

## Migration Checklist

- [ ] Replace Phase1v6.txt with Phase1v6.1.txt in workflows
- [ ] Update template files to use SYMBOL_DICTIONARY
- [ ] Retrain team on 7-category structure
- [ ] Update validation scripts to look for checkpoint proof
- [ ] Archive existing v6.0 documentation with note about limitations

## Quick Test

**File**: Any C file with constants and error codes  
**Expected**: 7 category headers, checkpoint proof, individual error code entries  
**Time**: 2-3 minutes  
**Pass**: ≥95% symbol coverage in dictionary

## Common Mistakes to Avoid

1. ❌ Grouping error codes together
2. ❌ Skipping constants category
3. ❌ No checkpoint proof in output
4. ❌ Using VARIABLE_DICTIONARY header (old name)
5. ❌ Missing special values like NID_undef

## Version Compatibility

- v6.1 output is valid Doxygen (compatible)
- v6.1 validation script won't accept v6.0 output (incompatible)
- v6.0 prompt can still be used for simple files (but not recommended)
- Mixed v6.0/v6.1 documentation OK in same project (but confusing)

## When to Use v6.1

**Always**, except:
- Simple scripts with no constants/error codes (but v6.1 still works)
- Prototypes/experiments where completeness doesn't matter
- When working with established v6.0 codebase (but consider upgrade)

## Getting Help

**Issue**: Checkpoint proof missing  
**Solution**: Model skipped it, re-run with emphasis on "MUST embed proof"

**Issue**: Still getting 80-90% completeness  
**Solution**: Check if constants/special values categories are present

**Issue**: Counting seems wrong  
**Solution**: Review counting rules - grouped items may be counted as 1

**Issue**: Don't know what constants to look for  
**Solution**: Grep for #define, check header includes, look for ALLCAPS names

---

**Quick Link**: Full changelog at `/CHANGES_Phase1v6.1_Symbol_Dictionary.md`
