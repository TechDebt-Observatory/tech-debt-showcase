# Doxygen Template for 6D Documentation

## File Header Template

```c
/**
 * @file dhtest.c
 * @brief DH parameter testing and validation utility
 * 
 * INTENT (Dimension 3):
 * Validates Diffie-Hellman parameters against cryptographic safety requirements.
 * Critical for preventing weak DH attacks (CVE-2016-0701, CVE-2016-0705).
 * 
 * ARCHITECTURE (Dimension 5):
 * - Part of OpenSSL test suite (crypto/dh/)
 * - Uses: BN library for bignum math, EVP for parameter parsing
 * - Called by: Test harness, may be used standalone
 * 
 * HISTORY (Dimension 4):
 * - Created: 2002 (original DH implementation)
 * - Modified: 2016 - Added small subgroup checks (CVE-2016-0701)
 * - Modified: 2018 - Added safe prime verification
 * 
 * TECHNICAL DEBT (Dimension 6):
 * - TODO: Add timing attack mitigation (see Issue #1234)
 * - WORKAROUND: Manual p-1 factorization (lines 145-167)
 *   Reason: BN_is_prime() insufficient for DH security
 *   Fix: Need BN_is_safe_prime() from OpenSSL 3.0+
 * 
 * @author OpenSSL Team
 * @copyright Apache License 2.0
 */
```

## Function Template

```c
/**
 * @brief [One-line description - SYNTAX]
 * 
 * [Detailed description - STRUCTURE]
 * 
 * INTENT: [Why this function exists, design decisions]
 * 
 * ALGORITHM: [How it works internally]
 * 1. Step one
 * 2. Step two
 * 3. Step three
 * 
 * @param param1 [Description, valid values, constraints]
 * @param param2 [Description]
 * 
 * @return [What it returns]
 * @retval 0 [Specific meaning]
 * @retval 1 [Specific meaning]
 * @retval -1 [Error condition]
 * 
 * @pre [Preconditions]
 * @post [Postconditions]
 * 
 * @warning [Security warnings, edge cases]
 * @see [Related functions]
 * 
 * HISTORY:
 * - 2016-01: Added CVE-2016-0701 mitigation
 * - 2018-03: Refactored for OpenSSL 1.1.1
 * 
 * TECH DEBT:
 * - Known limitation: [Description]
 * - Workaround: [What and why]
 * - TODO: [Future improvement]
 */
int function_name(param1, param2) {
    // Implementation
}
```

## Inline Comment Template

```c
// STRUCTURE: This loop iterates over all primes < sqrt(p)
// INTENT: Verify p is not composite (CVE-2016-0701 requirement)
// TECH DEBT: O(n^2) complexity, see Issue #1234 for optimization
for (i = 0; i < prime_count; i++) {
    // ...
}
```
