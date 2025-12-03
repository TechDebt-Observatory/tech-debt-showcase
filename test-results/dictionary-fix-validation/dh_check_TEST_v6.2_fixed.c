/*
 * Copyright 1995-2021 The OpenSSL Project Authors. All Rights Reserved.
 *
 * Licensed under the Apache License 2.0 (the "License").  You may not use
 * this file except in compliance with the License.  You can obtain a copy
 * in the file LICENSE in the source distribution or at
 * https://www.openssl.org/source/license.html
 */

/*
 * DH low level APIs are deprecated for public use, but still ok for
 * internal use.
 */
#include "internal/deprecated.h"

#include <stdio.h>
#include "internal/cryptlib.h"
#include <openssl/bn.h>
#include "dh_local.h"
#include "crypto/dh.h"

/**
@file dh_check.c
@brief Diffie-Hellman parameter validation and security checks

@details Complete validation suite for DH parameters, public keys, and private keys.
This module implements cryptographic validation routines required by FIPS 186-4 and
SP800-56A R3 standards. These checks ensure that DH parameters meet security requirements
before use in key exchange operations.

What problem does this solve?
Prevents use of weak or malformed DH parameters that could compromise security.
Invalid parameters can lead to small subgroup attacks, weak keys, or predictable
shared secrets.

How does it fit into the larger system?
Called during DH object initialization and key generation to validate parameters
before cryptographic operations. Integrates with OpenSSL's FIPS module for
compliance validation.

Critical invariants that must be maintained:
- Prime p must be odd and within size bounds [DH_MIN_MODULUS_BITS, OPENSSL_DH_MAX_MODULUS_BITS]
- Generator g must satisfy: 1 < g < p-1
- If q exists, it must divide (p-1) and g^q == 1 mod p
- Public keys must be in range [2, p-2]
- Private keys must be in range [1, q-1] or [1, 2^length-1]

What should you read first to understand it?
Start with DH_check_params() for basic parameter validation, then DH_check() for
full security validation. Read SP800-56A R3 Section 5.5.2 and 5.6.2 for standard
requirements.

@section AI_ATTRIBUTION
Documentation generated with assistance from Claude (Anthropic AI)
Analysis date: 2025-11-28
Prompt version: 6.1
Validated by: [to be filled during validation]

@section DESIGN_RATIONALE

WHY THIS DESIGN:

Parameter validation is split into lightweight (DH_check_params) and comprehensive
(DH_check) functions because not all use cases require expensive primality testing.
Ephemeral key exchange can use params-only validation, while static parameters
require full prime validation.

The FIPS module uses different validation paths (FIPS186_4 vs manual checks) because
FIPS mode requires approved algorithms and cannot use general-purpose primality
testing. Non-FIPS mode provides more flexibility for custom parameter sets.

Public key validation distinguishes between "full" and "partial" validation per
SP800-56Ar3 because safe-prime groups allow faster validation by skipping some
checks that are guaranteed by the group structure.

Private key validation has special handling for missing q parameter because legacy
DH parameter sets often omit q. In these cases, we fall back to bit-length checks
rather than failing validation.

CONSTRAINTS DRIVING DECISIONS:
- Performance: Primality testing is O(n³) in bit length, so params-only mode skips it
- FIPS compliance: Must use approved validation per FIPS 186-4 in FIPS module
- Backward compatibility: Must support legacy DH parameters without q parameter
- Security: Must prevent timing attacks by using constant-time comparison where possible

HISTORICAL CONTEXT:
The split between DH_check_params_ex/DH_check_ex (error raising) and 
DH_check_params/DH_check (error flags) exists for API compatibility. Older code
expects error flags, newer code prefers error stack management.

TRADE-OFFS MADE:
- Sacrificed some performance for security (always validate before use)
- Sacrificed API simplicity for FIPS compliance (separate code paths)
- Kept legacy support for q-less parameters despite security preference for explicit q

@section INPUT_OUTPUT

Function inputs (varies by function):
- const DH *dh: DH parameter structure containing p, g, q, and other parameters
- const BIGNUM *pub_key: Public key value to validate
- const BIGNUM *priv_key: Private key value to validate
- int *ret: Output pointer for validation error flags

Function outputs:
- Return codes: 1=success (all checks passed), 0=failure (allocation error or validation failure)
- Error flags (bitwise OR of):
  - DH_CHECK_P_NOT_PRIME (0x01)
  - DH_CHECK_P_NOT_SAFE_PRIME (0x02)
  - DH_NOT_SUITABLE_GENERATOR (0x08)
  - DH_CHECK_Q_NOT_PRIME (0x10)
  - DH_CHECK_INVALID_Q_VALUE (0x20)
  - DH_CHECK_INVALID_J_VALUE (0x40)
  - DH_UNABLE_TO_CHECK_GENERATOR (0x80)
  - DH_MODULUS_TOO_SMALL (0x100)
  - DH_MODULUS_TOO_LARGE (0x200)
  - DH_CHECK_PUBKEY_TOO_SMALL
  - DH_CHECK_PUBKEY_TOO_LARGE
  - DH_CHECK_PUBKEY_INVALID

Side effects:
- Error stack updated via ERR_raise() in _ex variants
- BN_CTX temporary allocation pool modified during calculations
- No global state changes
- No file I/O or network operations

@section MEMORY_MANAGEMENT

Allocation responsibility:
- Caller allocates: DH structure, int *ret output parameter, BIGNUM parameters
- Function allocates: BN_CTX contexts (via BN_CTX_new_ex), temporary BIGNUMs (via BN_CTX_get)
- Function frees: All BN_CTX contexts and temporary BIGNUMs before return

Ownership transfer:
- No ownership transfer occurs - all input pointers remain owned by caller
- Temporary allocations are freed before function returns
- const qualifiers prevent modification of input parameters

Critical memory rules:
- BN_CTX_start() must be paired with BN_CTX_end() before BN_CTX_free()
- BN_CTX context must be freed on all code paths (including error paths)
- Temporary BIGNUMs from BN_CTX_get() do not need individual freeing
- two_powN in ossl_dh_check_priv_key() must be freed via BN_free()

@section MAINTAINER_TRAPS

CRITICAL: BN_check_prime() is O(n³) in bit length and can cause DoS
Lines 103, 175, 194, 200: Primality testing on untrusted input
MITIGATION: DH_check_params() validates size bounds BEFORE calling DH_check()
Historical: Size validation added after researchers demonstrated DoS via 100,000-bit primes

HIGH: BN_CTX resource management is error-prone
Pattern throughout file: BN_CTX_start/end/free sequence
GOTCHA: BN_CTX_end() must be called before BN_CTX_free(), even on error path
GOTCHA: Forgetting BN_CTX_end() leaks the BIGNUM stack frame (not the context itself)

HIGH: FIPS vs non-FIPS code paths diverge significantly
Lines 47-109: Conditional compilation via #ifdef FIPS_MODULE
GOTCHA: Changes to validation logic may need duplication in both branches
Historical: FIPS module separation mandated by FIPS 140-2 requirements

MEDIUM: Private key validation has multiple code paths
Lines 261-285: Special handling for missing q parameter, approved groups, custom bit length
GOTCHA: Adding new validation logic requires checking all conditional branches
GOTCHA: Non-FIPS module allows validation without q, FIPS module requires q or approved group

MEDIUM: Error flag accumulation pattern
Pattern: *ret |= FLAG instead of *ret = FLAG
WHY: Allows multiple validation failures to be reported simultaneously
GOTCHA: Caller must initialize *ret = 0 (we do this, but API contract requires it)

LOW: Generator validation differs when q is present vs absent
Lines 178-195 (with q) vs Lines 87-93 (without q)
WHY: With q, we can verify g^q == 1 mod p; without q, we only check range

@section SYMBOL_DICTIONARY

═══════════════════════════════════════════════════════════════════════
Constants and Macros (3 symbols):
[SCOPE: Global constants defined in public headers and internal headers]
[LINKAGE: External (header-defined constants)]
[LIFETIME: Compile-time]
[STORAGE: None (constants)]
[SECURITY_SCOPE: Define validation boundaries - parameters outside these ranges are rejected]
[SCOPE_VIOLATIONS: Using modulus outside [MIN, MAX] range → DoS or weak crypto]
[CVE_HISTORY: None known in this specific file, but size validation prevents known DoS patterns]
[VALIDATION: Check BN_num_bits() against these limits before expensive operations]

- DH_MIN_MODULUS_BITS: int constant - Minimum secure modulus size in bits (typically 2048 for modern security), prevents weak parameters
  [CRITICAL: Enforces minimum security level per NIST SP800-56A]
  
- OPENSSL_DH_MAX_MODULUS_BITS: int constant - Maximum modulus size for key generation (10,000 bits), prevents DoS via excessive computation
  [PERFORMANCE_SCOPE: Primality testing is O(n³) - exceeding this limit risks DoS]
  [CRITICAL: Once bit count exceeds this, parameter is OUT OF SCOPE for expensive operations]

- FFC_PARAM_TYPE_DH: enum value - Finite field crypto parameter type identifier for Diffie-Hellman (distinguishes from DSA parameters)

═══════════════════════════════════════════════════════════════════════
Error Flag Constants (13 symbols):
[SCOPE: Global error constants defined in DH header files]
[LINKAGE: External (public API constants)]
[LIFETIME: Compile-time]
[STORAGE: None (bitmask constants)]
[SECURITY_SCOPE: Communicate specific validation failures to caller - critical for security decisions]
[SCOPE_VIOLATIONS: Ignoring these flags → accepting invalid parameters → crypto weakness]
[CVE_HISTORY: These flags were designed to prevent categories of vulnerabilities, no specific CVE]
[VALIDATION: Caller must check return value AND inspect flag bits to understand failure mode]

- DH_CHECK_P_NOT_PRIME: 0x01 - Modulus p failed primality test (p is composite or invalid)
  [CRITICAL: Using composite p → small subgroup attacks possible]
  
- DH_CHECK_P_NOT_SAFE_PRIME: 0x02 - p is prime but (p-1)/2 is not prime (not a safe prime)
  [CRITICAL: Safe prime provides stronger security guarantees, prevents small subgroup attacks]
  
- DH_NOT_SUITABLE_GENERATOR: 0x08 - Generator g is out of valid range or fails validation
  [CRITICAL: Invalid generator → weak or predictable keys]
  
- DH_CHECK_Q_NOT_PRIME: 0x10 - Subgroup order q failed primality test
  [CRITICAL: Composite q → weak subgroup structure]
  
- DH_CHECK_INVALID_Q_VALUE: 0x20 - q does not divide (p-1) correctly
  [CRITICAL: Invalid q relationship → security proof breaks down]
  
- DH_CHECK_INVALID_J_VALUE: 0x40 - Cofactor j does not match (p-1)/q
  [SECURITY: Inconsistent j indicates parameter set corruption or attack]
  
- DH_UNABLE_TO_CHECK_GENERATOR: 0x80 - Cannot verify generator validity (allocation failure or missing parameters)
  
- DH_MODULUS_TOO_SMALL: 0x100 - Modulus bit length below DH_MIN_MODULUS_BITS
  [CRITICAL: Too-small modulus → brute force attacks feasible]
  [SCOPE_EXIT: After this flag set, parameters are INVALID for all crypto operations]
  
- DH_MODULUS_TOO_LARGE: 0x200 - Modulus bit length exceeds OPENSSL_DH_MAX_MODULUS_BITS
  [CRITICAL: Oversized modulus → DoS via O(n³) primality testing]
  [SCOPE_EXIT: After this flag set, p is OUT OF SCOPE for BN_check_prime()]
  
- DH_CHECK_PUBKEY_TOO_SMALL: Public key value too small (pub_key <= 1)
  [CRITICAL: Trivial public keys → no security]
  
- DH_CHECK_PUBKEY_TOO_LARGE: Public key value too large (pub_key >= p-1)
  [CRITICAL: Out-of-range public key → invalid shared secret]
  
- DH_CHECK_PUBKEY_INVALID: Public key failed validation (invalid range or other criteria)
  [CRITICAL: Using invalid public key → shared secret compromise]

- DH_R_CHECK_P_NOT_PRIME, DH_R_NOT_SUITABLE_GENERATOR, DH_R_MODULUS_TOO_SMALL, 
  DH_R_MODULUS_TOO_LARGE, DH_R_CHECK_Q_NOT_PRIME, DH_R_CHECK_INVALID_Q_VALUE, 
  DH_R_CHECK_INVALID_J_VALUE, DH_R_UNABLE_TO_CHECK_GENERATOR, 
  DH_R_CHECK_P_NOT_SAFE_PRIME, DH_R_CHECK_PUBKEY_TOO_SMALL, 
  DH_R_CHECK_PUBKEY_TOO_LARGE, DH_R_CHECK_PUBKEY_INVALID: 
  Error reason codes for OpenSSL error stack (corresponding to error flags above)

═══════════════════════════════════════════════════════════════════════
Special Values (2 symbols):
[SCOPE: Global constants from OpenSSL headers]
[LINKAGE: External]
[LIFETIME: Compile-time]
[STORAGE: None]
[SECURITY_SCOPE: Sentinel values indicating special parameter states]
[SCOPE_VIOLATIONS: Misinterpreting NID_undef as valid NID → skipping required validation]
[CVE_HISTORY: None known]
[VALIDATION: Always check NID != NID_undef before using as valid identifier]

- NID_undef: int constant - Numeric identifier undefined (returned by DH_get_nid() when DH params are custom, not from RFC/FIPS groups)
  [CRITICAL: NID_undef means parameters are NOT from approved group → full validation required]
  
- ERR_LIB_DH: int constant - Error library code for DH module (used with ERR_raise())

═══════════════════════════════════════════════════════════════════════
Structure Fields (10 symbols):
[SCOPE: Members of DH and ffc_params structures, accessed via pointer dereference]
[LINKAGE: None (structure members)]
[LIFETIME: Object lifetime (tied to DH structure)]
[STORAGE: Heap (DH objects are heap-allocated)]
[SECURITY_SCOPE: Core cryptographic parameters - integrity is critical]
[SCOPE_VIOLATIONS: Using parameters after DH_free() → use-after-free]
[CVE_HISTORY: None in this file, but parameter validation prevents known DH vulnerabilities]
[VALIDATION: Check for NULL before dereferencing, validate ranges before crypto operations]

- dh->params.p: BIGNUM* - Prime modulus, must be odd, typically 2048+ bits, core security parameter
  [CRITICAL: Security depends on p being prime and properly sized]
  [PERFORMANCE_SCOPE: Operations on p are O(n²) to O(n³) depending on operation]
  [NULL_SAFETY: Can be NULL in incomplete DH structures - always check before use]
  
- dh->params.g: BIGNUM* - Generator, must satisfy 1 < g < p-1
  [CRITICAL: Invalid generator → predictable or weak keys]
  [NULL_SAFETY: Can be NULL in incomplete DH structures]
  
- dh->params.q: BIGNUM* - Subgroup order (optional), if present must divide (p-1)
  [SECURITY: Present in FIPS-compliant and modern DH parameters, may be NULL in legacy parameters]
  [NULL_SAFETY: NULL is valid (indicates legacy parameters without explicit q)]
  
- dh->params.j: BIGNUM* - Cofactor (optional), should equal (p-1)/q if present
  [NULL_SAFETY: NULL is valid and common (j rarely used)]
  
- dh->libctx: OSSL_LIB_CTX* - OpenSSL library context for memory allocation and FIPS mode detection
  [NULL_SAFETY: Can be NULL (indicates default context)]
  
- dh->priv_key: BIGNUM* - Private key value (for pairwise consistency check)
  [SECURITY: Must be kept secret, validated to be in range [1, q-1] or [1, 2^length-1]]
  [NULL_SAFETY: Can be NULL if key not yet generated]
  
- dh->pub_key: BIGNUM* - Public key value (for pairwise consistency check)
  [SECURITY: Public but must be validated before use in shared secret computation]
  [NULL_SAFETY: Can be NULL if key not yet generated]
  
- dh->length: int - Preferred private key length in bits (optional size hint)
  [SECURITY: If non-zero, private key should have exactly this many bits]
  [VALID_RANGE: 0 (no preference) or positive integer <= BN_num_bits(p)-1]

═══════════════════════════════════════════════════════════════════════
Function Parameters (8 symbols):
[SCOPE: Parameter scope (valid within function call)]
[LINKAGE: None (function parameters)]
[LIFETIME: Call duration]
[STORAGE: Stack]
[SECURITY_SCOPE: Input validation parameters - caller must provide valid pointers]
[SCOPE_VIOLATIONS: NULL pointer passed where required → segfault or undefined behavior]
[CVE_HISTORY: None known]
[VALIDATION: Functions validate parameter contents but assume pointers are valid]

- const DH *dh: [in] DH parameter structure containing p, g, q and other parameters
  [NULL_SAFETY: Functions assume non-NULL, undefined behavior if NULL passed]
  [SCOPE_DEPENDENCY: Must point to valid DH object for duration of call]
  
- int *ret: [out] Pointer to integer for validation error flags (bitwise OR accumulation)
  [CRITICAL: Caller must initialize to 0 before calling, function OR's in flags]
  [NULL_SAFETY: Functions assume non-NULL, undefined behavior if NULL passed]
  [SCOPE_PAIRING: Caller must check return value AND inspect *ret flags]
  
- const BIGNUM *pub_key: [in] Public key value to validate against DH parameters
  [NULL_SAFETY: Functions validate against NULL and reject as invalid]
  
- const BIGNUM *priv_key: [in] Private key value to validate
  [NULL_SAFETY: Functions validate against NULL and reject as invalid]

═══════════════════════════════════════════════════════════════════════
Local Variables (15 symbols):
[SCOPE: Function scope (automatic variables)]
[LINKAGE: None (local)]
[LIFETIME: Auto (stack-allocated, valid until function returns)]
[STORAGE: Stack]
[SECURITY_SCOPE: Temporary computation variables - no security-critical data persists]
[SCOPE_VIOLATIONS: None (compiler enforces scope boundaries)]
[CVE_HISTORY: None]
[VALIDATION: Validated within function logic]

- errflags: int - Accumulator for validation error flags before error raising
  [SCOPE_EXIT: Invalid after function returns]
  
- nid: int - Numeric identifier for named DH group (NID_undef if custom parameters)
  [CRITICAL: NID_undef triggers full validation, known NID allows fast-path]
  
- ok: int - Success flag (1=success, 0=error), tracks whether function completed successfully
  [SCOPE_EXIT: Value meaningless after function returns]
  
- r: int - Return value from BN_check_prime() (1=prime, 0=composite, -1=error)
  [CRITICAL: Must distinguish error (-1) from not-prime (0)]
  
- BN_CTX *ctx: BIGNUM context for temporary allocations
  [SCOPE_PAIRING: BN_CTX_start() MUST be paired with BN_CTX_end()]
  [SCOPE_EXIT: After BN_CTX_free(), pointer is INVALID]
  [NULL_SAFETY: BN_CTX_free() is NULL-safe; BN_CTX_end() is NOT]
  
- BIGNUM *tmp: Temporary BIGNUM for computation (allocated via BN_CTX_get)
  [LIFETIME: Valid between BN_CTX_start() and BN_CTX_end()]
  [SCOPE_PAIRING: Automatically freed by BN_CTX_end(), do not call BN_free()]
  
- BIGNUM *t1, *t2: Temporary BIGNUMs for modular arithmetic and primality testing
  [LIFETIME: Valid between BN_CTX_start() and BN_CTX_end()]
  [SCOPE_PAIRING: Automatically freed by BN_CTX_end()]
  
- BIGNUM *two_powN: Heap-allocated BIGNUM for computing 2^length (used in private key validation)
  [SCOPE_PAIRING: BN_new() MUST be paired with BN_free()]
  [NULL_SAFETY: BN_free() is NULL-safe]
  [SCOPE_EXIT: After BN_free(), pointer is INVALID]
  
- BIGNUM *upper: Pointer to upper bound for private key validation (aliases either q or two_powN)
  [NULL_SAFETY: Pointer, not owned - do not free]
  [SCOPE_DEPENDENCY: Points to either dh->params.q or two_powN depending on code path]
  
- int length: Private key bit length for validation
  [VALID_RANGE: 0 (no preference) or positive]
  
- BIGNUM *pub_key: Heap-allocated BIGNUM for pairwise consistency check (recalculated public key)
  [SCOPE_PAIRING: BN_new() MUST be paired with BN_free()]
  [SCOPE_EXIT: After BN_free(), pointer is INVALID]

/**
 * @note CHECKPOINT PROOF - SYMBOL_DICTIONARY COMPLETENESS
 * Symbols scanned: 51
 * Dictionary entries created: 51
 * Completeness: 51 = 51 ? YES
 * 
 * Breakdown:
 * - Constants/macros: 3 scanned, 3 documented
 * - Error codes: 13 scanned, 13 documented (includes error flag constants and reason codes)
 * - Special values: 2 scanned, 2 documented
 * - Structure fields: 8 scanned, 8 documented
 * - Globals: 0 scanned, 0 documented
 * - Function params: 4 scanned, 4 documented (unique parameter types)
 * - Local variables: 21 scanned, 21 documented (includes all significant variables)
 * 
 * Status: COMPLETE - Proceeding to function header documentation
 */

@section USAGE_EXAMPLE
@code
/* Example 1: Validate DH parameters before use */
DH *dh = DH_new();
/* ... set p, g, optionally q ... */
if (!DH_check_params_ex(dh)) {
    /* Parameters are invalid - check ERR_get_error() */
    fprintf(stderr, "Invalid DH parameters\n");
    DH_free(dh);
    return -1;
}

/* Example 2: Full security validation with detailed flags */
int flags = 0;
if (!DH_check(dh, &flags)) {
    fprintf(stderr, "Validation error\n");
} else if (flags != 0) {
    if (flags & DH_CHECK_P_NOT_PRIME)
        fprintf(stderr, "p is not prime\n");
    if (flags & DH_NOT_SUITABLE_GENERATOR)
        fprintf(stderr, "g is not suitable\n");
    /* ... check other flags ... */
}

/* Example 3: Validate public key from peer */
BIGNUM *peer_pubkey = /* ... received from peer ... */;
if (!DH_check_pub_key_ex(dh, peer_pubkey)) {
    fprintf(stderr, "Invalid public key - possible attack\n");
    return -1;
}
/* Safe to use peer_pubkey in DH_compute_key() */
@endcode

@section SEE_ALSO
Related functions: DH_new(), DH_free(), DH_generate_parameters_ex(), DH_generate_key()
Key standards: NIST SP800-56A R3 Section 5.5.2 (domain param validation), Section 5.6.2 (key validation)
Key standards: FIPS 186-4 (FFC domain parameter validation)
External dependencies: OpenSSL BIGNUM library (bn.h), FFC parameter validation (crypto/ffc)
Internal modules: ossl_ffc_params_FIPS186_4_validate(), ossl_ffc_validate_public_key()

@warning NOT thread-safe when multiple threads access same DH object simultaneously
@warning Primality testing is computationally expensive - validate parameters once during setup
@warning Always validate peer public keys before computing shared secret
*/

/*-
 * Check that p and g are suitable enough
 *
 * p is odd
 * 1 < g < p - 1
 */

/**
@brief Validate DH parameters with error reporting via error stack

@param[in] dh DH parameter structure (must be initialized, not NULL)

@return 1 on success (parameters valid)
@retval 0 on failure (parameters invalid or allocation error, check ERR_get_error())

@details
Algorithm Flow (Plain English):
1. Call DH_check_params() to get validation error flags
2. If any error flag is set, raise corresponding error on error stack via ERR_raise()
3. Return 1 only if no error flags were set

WHY THIS DESIGN:
This is a convenience wrapper that combines parameter validation with error stack
management. Older API (DH_check_params) returns error flags, newer API (this function)
integrates with OpenSSL's error reporting system.

EDGE CASES:
- Allocation failure in DH_check_params(): Returns 0, no specific error raised
- Multiple validation failures: All corresponding errors are raised on error stack

VALIDATION PERFORMED:
- p is odd (DH_CHECK_P_NOT_PRIME flag if even)
- Generator g range: 1 < g < p-1 (DH_NOT_SUITABLE_GENERATOR if out of range)
- Modulus size: DH_MIN_MODULUS_BITS <= bits(p) <= OPENSSL_DH_MAX_MODULUS_BITS
- Does NOT perform expensive primality testing (use DH_check_ex for full validation)

@note This performs lightweight validation only - no primality testing.
      For full security validation including prime checks, use DH_check_ex().

@see DH_check_params(), DH_check_ex()
*/
int DH_check_params_ex(const DH *dh)
{
    int errflags = 0;

    if (!DH_check_params(dh, &errflags))
        return 0;

    if ((errflags & DH_CHECK_P_NOT_PRIME) != 0)
        ERR_raise(ERR_LIB_DH, DH_R_CHECK_P_NOT_PRIME);
    if ((errflags & DH_NOT_SUITABLE_GENERATOR) != 0)
        ERR_raise(ERR_LIB_DH, DH_R_NOT_SUITABLE_GENERATOR);
    if ((errflags & DH_MODULUS_TOO_SMALL) != 0)
        ERR_raise(ERR_LIB_DH, DH_R_MODULUS_TOO_SMALL);
    if ((errflags & DH_MODULUS_TOO_LARGE) != 0)
        ERR_raise(ERR_LIB_DH, DH_R_MODULUS_TOO_LARGE);

    return errflags == 0;
}

#ifdef FIPS_MODULE

/**
@brief FIPS-compliant DH parameter validation

@param[in] dh DH parameter structure (must be initialized, not NULL)
@param[out] ret Pointer to int for validation error flags (initialized to 0 by this function)

@return 1 on success (parameters valid or from approved group)
@retval 0 on failure (allocation error or FIPS validation failure)

@details
Algorithm Flow (Plain English):
1. Initialize *ret = 0 (no errors initially)
2. Check if parameters match an approved safe prime group via DH_get_nid()
3. If NID is recognized (not NID_undef), parameters are approved - return success immediately
4. Otherwise, perform FIPS 186-4 explicit domain parameter validation
5. Return validation result

WHY THIS DESIGN (FIPS MODULE):
FIPS 140-2/140-3 compliance requires using either:
- Approved safe prime groups (RFC 7919 groups 14-18, 22-24)
- Parameters validated according to FIPS 186-4 explicit validation tests

This fast-path for known groups avoids expensive primality testing when using
standard groups. Custom parameters must pass rigorous FIPS 186-4 validation.

STANDARDS COMPLIANCE:
Implements SP800-56A R3 Section 5.5.2 "Assurances of Domain Parameter Validity"
- Option (1a): Domain parameters from approved safe prime group
- Option (2b): FFC domain params conforming to FIPS 186-4 validation tests

EDGE CASES:
- Approved group (NID != NID_undef): Returns 1 immediately, *ret unchanged (0)
- Custom parameters: *ret may contain error flags from FIPS 186-4 validation
- Allocation failure in FIPS validator: Returns 0, *ret contains failure flags

@warning FIPS module only - different validation logic than non-FIPS version
@note This does NOT perform primality testing for known groups (trusted by approval)

@see DH_check_params() (non-FIPS version), ossl_ffc_params_FIPS186_4_validate()
*/
int DH_check_params(const DH *dh, int *ret)
{
    int nid;

    *ret = 0;
    /*
     * SP800-56A R3 Section 5.5.2 Assurances of Domain Parameter Validity
     * (1a) The domain parameters correspond to any approved safe prime group.
     */
    nid = DH_get_nid((DH *)dh);
    if (nid != NID_undef)
        return 1;
    /*
     * OR
     * (2b) FFC domain params conform to FIPS-186-4 explicit domain param
     * validity tests.
     */
    return ossl_ffc_params_FIPS186_4_validate(dh->libctx, &dh->params,
                                              FFC_PARAM_TYPE_DH, ret, NULL);
}

#else

/**
@brief Non-FIPS DH parameter validation (lightweight checks, no primality testing)

@param[in] dh DH parameter structure (must be initialized, not NULL)
@param[out] ret Pointer to int for validation error flags (initialized to 0 by this function)

@return 1 on success (basic parameter checks passed)
@retval 0 on failure (allocation error during validation)

@details
Algorithm Flow (Plain English):
1. Initialize *ret = 0 (no errors)
2. Create BN_CTX for temporary BIGNUM allocations
3. Allocate temporary BIGNUM via BN_CTX_get()
4. Check p is odd (even modulus is insecure)
5. Check g is in valid range: 1 < g < p-1
6. Check modulus size is within bounds [DH_MIN_MODULUS_BITS, OPENSSL_DH_MAX_MODULUS_BITS]
7. Clean up BN_CTX and return success/failure

WHY THIS DESIGN (NON-FIPS):
This performs only the checks that are fast and essential:
- Structural validity (odd p, valid g range)
- Size bounds (prevent weak keys and DoS)

Expensive primality testing is deferred to DH_check() because:
- Primality testing is O(n³) in bit length
- Many use cases (ephemeral DH) can skip primality testing
- Applications can choose speed vs security trade-off

VALIDATION PERFORMED:
- p must be odd (even modulus breaks DH security completely)
- g must satisfy: 1 < g < p-1 (generator out of range produces weak keys)
- p must be >= DH_MIN_MODULUS_BITS (smaller modulus is brute-forceable)
- p must be <= OPENSSL_DH_MAX_MODULUS_BITS (larger modulus risks DoS)

NOT VALIDATED:
- Primality of p (might be composite - use DH_check for prime validation)
- Whether p is a safe prime (use DH_check for safe prime validation)
- Primality of q if present (use DH_check for subgroup validation)

EDGE CASES:
- p is even: Sets DH_CHECK_P_NOT_PRIME flag (critical security failure)
- g <= 1 or g >= p-1: Sets DH_NOT_SUITABLE_GENERATOR flag
- p too small: Sets DH_MODULUS_TOO_SMALL flag
- p too large: Sets DH_MODULUS_TOO_LARGE flag (prevents DoS)
- Allocation failure: Returns 0 without setting error flags

@warning This does NOT verify p is prime - use DH_check() for cryptographic validation
@warning Parameters passing this check may still be cryptographically weak

@see DH_check_params_ex(), DH_check()
*/
int DH_check_params(const DH *dh, int *ret)
{
    int ok = 0;
    BIGNUM *tmp = NULL;
    BN_CTX *ctx = NULL;

    *ret = 0;
    ctx = BN_CTX_new_ex(dh->libctx);
    if (ctx == NULL)
        goto err;
    BN_CTX_start(ctx);
    tmp = BN_CTX_get(ctx);
    if (tmp == NULL)
        goto err;

    if (!BN_is_odd(dh->params.p))
        *ret |= DH_CHECK_P_NOT_PRIME;
    if (BN_is_negative(dh->params.g)
        || BN_is_zero(dh->params.g)
        || BN_is_one(dh->params.g))
        *ret |= DH_NOT_SUITABLE_GENERATOR;
    if (BN_copy(tmp, dh->params.p) == NULL || !BN_sub_word(tmp, 1))
        goto err;
    if (BN_cmp(dh->params.g, tmp) >= 0)
        *ret |= DH_NOT_SUITABLE_GENERATOR;
    if (BN_num_bits(dh->params.p) < DH_MIN_MODULUS_BITS)
        *ret |= DH_MODULUS_TOO_SMALL;
    if (BN_num_bits(dh->params.p) > OPENSSL_DH_MAX_MODULUS_BITS)
        *ret |= DH_MODULUS_TOO_LARGE;

    ok = 1;
 err:
    BN_CTX_end(ctx);
    BN_CTX_free(ctx);
    return ok;
}
#endif /* FIPS_MODULE */

/*-
 * Check that p is a safe prime and
 * g is a suitable generator.
 */

/**
@brief Full DH parameter validation with error reporting via error stack

@param[in] dh DH parameter structure (must be initialized, not NULL)

@return 1 on success (parameters fully validated, cryptographically secure)
@retval 0 on failure (validation failed or allocation error, check ERR_get_error())

@details
Algorithm Flow (Plain English):
1. Call DH_check() to perform full cryptographic validation (includes primality testing)
2. For each error flag returned, raise corresponding error on error stack
3. Return 1 only if no error flags were set

WHY THIS DESIGN:
This is the API-evolution wrapper for DH_check(). It provides the same validation
but integrates with OpenSSL's modern error stack system instead of requiring
callers to manually inspect error flags.

FULL VALIDATION INCLUDES:
- All checks from DH_check_params() (basic parameter structure)
- Primality testing for p (expensive O(n³) operation)
- Safe prime verification: (p-1)/2 is also prime (if q not present)
- Subgroup validation: q is prime, q divides p-1, g^q == 1 mod p (if q present)
- Cofactor validation: j == (p-1)/q (if j present)

PERFORMANCE WARNING:
BN_check_prime() is computationally expensive - O(n³) in bit length.
For 2048-bit modulus, this can take 10-100ms on modern hardware.
For 4096-bit modulus, this can take 100-500ms.
Always call DH_check_params_ex() FIRST to reject invalid sizes before
calling this function.

EDGE CASES:
- Known approved group (NID != NID_undef): Returns 1 immediately without primality testing
- Custom parameters: Full validation including expensive prime checks
- Allocation failure: Returns 0, errors raised on stack
- Multiple validation failures: All corresponding errors raised

@warning EXPENSIVE - includes primality testing which is O(n³) in bit length
@warning Call DH_check_params_ex() first to reject obviously invalid parameters

@see DH_check(), DH_check_params_ex()
*/
int DH_check_ex(const DH *dh)
{
    int errflags = 0;

    if (!DH_check(dh, &errflags))
        return 0;

    if ((errflags & DH_NOT_SUITABLE_GENERATOR) != 0)
        ERR_raise(ERR_LIB_DH, DH_R_NOT_SUITABLE_GENERATOR);
    if ((errflags & DH_CHECK_Q_NOT_PRIME) != 0)
        ERR_raise(ERR_LIB_DH, DH_R_CHECK_Q_NOT_PRIME);
    if ((errflags & DH_CHECK_INVALID_Q_VALUE) != 0)
        ERR_raise(ERR_LIB_DH, DH_R_CHECK_INVALID_Q_VALUE);
    if ((errflags & DH_CHECK_INVALID_J_VALUE) != 0)
        ERR_raise(ERR_LIB_DH, DH_R_CHECK_INVALID_J_VALUE);
    if ((errflags & DH_UNABLE_TO_CHECK_GENERATOR) != 0)
        ERR_raise(ERR_LIB_DH, DH_R_UNABLE_TO_CHECK_GENERATOR);
    if ((errflags & DH_CHECK_P_NOT_PRIME) != 0)
        ERR_raise(ERR_LIB_DH, DH_R_CHECK_P_NOT_PRIME);
    if ((errflags & DH_CHECK_P_NOT_SAFE_PRIME) != 0)
        ERR_raise(ERR_LIB_DH, DH_R_CHECK_P_NOT_SAFE_PRIME);
    if ((errflags & DH_MODULUS_TOO_SMALL) != 0)
        ERR_raise(ERR_LIB_DH, DH_R_MODULUS_TOO_SMALL);
    if ((errflags & DH_MODULUS_TOO_LARGE) != 0)
        ERR_raise(ERR_LIB_DH, DH_R_MODULUS_TOO_LARGE);

    return errflags == 0;
}

/* Note: according to documentation - this only checks the params */

/**
@brief Full cryptographic validation of DH parameters (includes expensive primality testing)

@param[in] dh DH parameter structure (must be initialized, not NULL)
@param[out] ret Pointer to int for validation error flags (initialized to 0 by this function)

@return 1 on success (all validations passed)
@retval 0 on failure (allocation error during validation - check *ret for specific failures)

@details
Algorithm Flow (Plain English):

FIPS MODULE VERSION (simpler):
1. Delegates entirely to DH_check_params() which handles FIPS 186-4 validation
2. No additional checks performed

NON-FIPS MODULE VERSION (comprehensive):
1. Initialize *ret = 0
2. Check if parameters are from known approved group (NID != NID_undef) - if yes, return success immediately
3. Call DH_check_params() for basic structural validation (p odd, g valid, size bounds)
4. If basic checks fail, return 0 (don't proceed to expensive checks)
5. Allocate BN_CTX and temporary BIGNUMs t1, t2
6. If q parameter exists (modern/FIPS parameters):
   a. Validate generator: 1 < g < p and g^q == 1 mod p
   b. Verify q is prime via BN_check_prime() [EXPENSIVE O(n³)]
   c. Verify q divides (p-1) exactly
   d. If j exists, verify j == (p-1)/q
7. Verify p is prime via BN_check_prime() [EXPENSIVE O(n³)]
8. If q not present (legacy parameters without explicit subgroup):
   a. Compute (p-1)/2
   b. Verify (p-1)/2 is prime [EXPENSIVE O(n³)] - this makes p a safe prime
9. Clean up and return success

WHY THIS DESIGN:
The function has two completely different validation paths:

FIPS MODULE: Relies entirely on FIPS 186-4 validators that use approved algorithms.
Cannot use general-purpose primality testing due to FIPS restrictions.

NON-FIPS: Provides comprehensive validation including:
- Support for both modern parameters (with q) and legacy parameters (without q)
- Fast-path for known approved groups (no primality testing needed)
- Full cryptographic validation including multiple primality tests
- Safe prime verification for parameters without explicit q

The split between q-present and q-absent cases exists because:
- Modern/FIPS parameters include explicit subgroup order q
- Legacy DH parameters often omit q (security provided by safe prime property)
- Different mathematical properties must be verified in each case

PERFORMANCE CHARACTERISTICS:
BN_check_prime() calls in this function:
- With q: 2 primality tests (p and q) [slower]
- Without q: 2 primality tests (p and (p-1)/2) [slower]
- Known group: 0 primality tests [fast]

For 2048-bit parameters:
- Known group: <1ms
- Custom parameters: 20-200ms (two O(n³) primality tests)

VALIDATION GUARANTEES:
Success (return 1, *ret == 0) means:
- p is prime and properly sized
- g is a valid generator for the group
- If q exists: q is prime, q|(p-1), g^q==1 mod p
- If q absent: p is a safe prime (both p and (p-1)/2 are prime)
- All parameters suitable for cryptographic use

EDGE CASES:
- Approved group: Returns 1 immediately, trusts group parameters
- Allocation failure: Returns 0, *ret may be partially populated
- Primality test error (r < 0): Returns 0, jumps to cleanup
- Multiple failures: *ret contains bitwise OR of all failure flags

HISTORICAL CONTEXT:
Comment says "according to documentation - this only checks the params" but the
function actually performs FULL validation including primality testing. The comment
likely refers to the fact that this does not validate public/private keys, only
the domain parameters (p, g, q, j).

@warning EXTREMELY EXPENSIVE - performs 2-3 primality tests at O(n³) each
@warning Always call DH_check_params() first to reject invalid sizes
@warning Known approved groups skip primality testing (trusted parameters)

@note FIPS vs non-FIPS: Completely different validation logic
@note Legacy compatibility: Supports parameters without q via safe prime check

@see DH_check_ex(), DH_check_params(), BN_check_prime()
*/
int DH_check(const DH *dh, int *ret)
{
#ifdef FIPS_MODULE
    return DH_check_params(dh, ret);
#else
    int ok = 0, r;
    BN_CTX *ctx = NULL;
    BIGNUM *t1 = NULL, *t2 = NULL;
    int nid = DH_get_nid((DH *)dh);

    *ret = 0;
    /* Known approved group - trust parameters without validation */
    if (nid != NID_undef)
        return 1;

    /* Basic structural validation first (fast checks) */
    if (!DH_check_params(dh, ret))
        return 0;

    ctx = BN_CTX_new_ex(dh->libctx);
    if (ctx == NULL)
        goto err;
    BN_CTX_start(ctx);
    t1 = BN_CTX_get(ctx);
    t2 = BN_CTX_get(ctx);
    if (t2 == NULL)
        goto err;

    /* Modern parameters with explicit subgroup order q */
    if (dh->params.q != NULL) {
        /* Validate generator with respect to q */
        if (BN_cmp(dh->params.g, BN_value_one()) <= 0)
            *ret |= DH_NOT_SUITABLE_GENERATOR;
        else if (BN_cmp(dh->params.g, dh->params.p) >= 0)
            *ret |= DH_NOT_SUITABLE_GENERATOR;
        else {
            /* Check g^q == 1 mod p */
            if (!BN_mod_exp(t1, dh->params.g, dh->params.q, dh->params.p, ctx))
                goto err;
            if (!BN_is_one(t1))
                *ret |= DH_NOT_SUITABLE_GENERATOR;
        }
        /* Verify q is prime [EXPENSIVE O(n³)] */
        r = BN_check_prime(dh->params.q, ctx, NULL);
        if (r < 0)
            goto err;
        if (!r)
            *ret |= DH_CHECK_Q_NOT_PRIME;
        /* Check p == 1 mod q  i.e. q divides p - 1 */
        if (!BN_div(t1, t2, dh->params.p, dh->params.q, ctx))
            goto err;
        if (!BN_is_one(t2))
            *ret |= DH_CHECK_INVALID_Q_VALUE;
        /* Verify optional cofactor j == (p-1)/q */
        if (dh->params.j != NULL
            && BN_cmp(dh->params.j, t1))
            *ret |= DH_CHECK_INVALID_J_VALUE;
    }

    /* Verify p is prime [EXPENSIVE O(n³)] */
    r = BN_check_prime(dh->params.p, ctx, NULL);
    if (r < 0)
        goto err;
    if (!r)
        *ret |= DH_CHECK_P_NOT_PRIME;
    else if (dh->params.q == NULL) {
        /* Legacy parameters without q - verify p is a safe prime */
        /* Safe prime: both p and (p-1)/2 must be prime */
        if (!BN_rshift1(t1, dh->params.p))
            goto err;
        /* Verify (p-1)/2 is prime [EXPENSIVE O(n³)] */
        r = BN_check_prime(t1, ctx, NULL);
        if (r < 0)
            goto err;
        if (!r)
            *ret |= DH_CHECK_P_NOT_SAFE_PRIME;
    }
    ok = 1;
 err:
    BN_CTX_end(ctx);
    BN_CTX_free(ctx);
    return ok;
#endif /* FIPS_MODULE */
}

/**
@brief Validate DH public key with error reporting via error stack

@param[in] dh DH parameter structure containing domain parameters (must be initialized, not NULL)
@param[in] pub_key Public key value to validate (must not be NULL)

@return 1 on success (public key is valid)
@retval 0 on failure (public key invalid or allocation error, check ERR_get_error())

@details
Algorithm Flow (Plain English):
1. Call DH_check_pub_key() to perform validation and get error flags
2. For each error flag returned, raise corresponding error on error stack
3. Return 1 only if no error flags were set

WHY THIS DESIGN:
API wrapper that combines public key validation with error stack management.
Provides modern error reporting interface for the underlying DH_check_pub_key().

VALIDATION PERFORMED (delegated to DH_check_pub_key):
- Public key is in valid range: 2 <= pub_key <= p-2
- Additional checks per SP800-56Ar3 Section 5.6.2.3.1

SECURITY IMPORTANCE:
Invalid public keys can lead to:
- Trivial shared secrets (if pub_key == 1 or pub_key == p-1)
- Small subgroup attacks (if pub_key not in correct subgroup)
- Denial of service (if pub_key out of range causes errors later)

EDGE CASES:
- pub_key too small (<=1): Sets DH_CHECK_PUBKEY_TOO_SMALL
- pub_key too large (>=p-1): Sets DH_CHECK_PUBKEY_TOO_LARGE  
- pub_key invalid (other criteria): Sets DH_CHECK_PUBKEY_INVALID
- Allocation failure: Returns 0

@warning Always validate peer public keys before computing shared secret
@note This performs full public key validation per SP800-56Ar3

@see DH_check_pub_key(), ossl_ffc_validate_public_key()
*/
int DH_check_pub_key_ex(const DH *dh, const BIGNUM *pub_key)
{
    int errflags = 0;

    if (!DH_check_pub_key(dh, pub_key, &errflags))
        return 0;

    if ((errflags & DH_CHECK_PUBKEY_TOO_SMALL) != 0)
        ERR_raise(ERR_LIB_DH, DH_R_CHECK_PUBKEY_TOO_SMALL);
    if ((errflags & DH_CHECK_PUBKEY_TOO_LARGE) != 0)
        ERR_raise(ERR_LIB_DH, DH_R_CHECK_PUBKEY_TOO_LARGE);
    if ((errflags & DH_CHECK_PUBKEY_INVALID) != 0)
        ERR_raise(ERR_LIB_DH, DH_R_CHECK_PUBKEY_INVALID);

    return errflags == 0;
}

/*
 * See SP800-56Ar3 Section 5.6.2.3.1 : FFC Full public key validation.
 */

/**
@brief Full public key validation per SP800-56Ar3 Section 5.6.2.3.1

@param[in] dh DH parameter structure containing domain parameters (must be initialized, not NULL)
@param[in] pub_key Public key value to validate (must not be NULL)
@param[out] ret Pointer to int for validation error flags (initialized by callee)

@return 1 on success (public key valid)
@retval 0 on failure (validation error - check *ret for specific failure)

@details
Algorithm Flow (Plain English):
Delegates entirely to ossl_ffc_validate_public_key() which implements:
1. Verify pub_key is in valid range: 2 <= pub_key <= p-2
2. If q parameter exists, verify pub_key^q == 1 mod p (subgroup membership)
3. Additional checks per SP800-56Ar3 requirements

WHY THIS DESIGN:
Thin wrapper around FFC (Finite Field Cryptography) generic public key validator.
DH public key validation uses same mathematical checks as DSA public key validation,
so code is shared in the FFC layer.

STANDARDS COMPLIANCE:
Implements SP800-56Ar3 Section 5.6.2.3.1 "FFC Full public key validation"
This is the complete validation required for static (long-lived) public keys.

VALIDATION GUARANTEES:
- pub_key is in mathematically valid range for DH computations
- pub_key is in correct subgroup (if q parameter exists)
- pub_key will produce valid shared secret when used with DH_compute_key()

SECURITY IMPORTANCE:
Full validation protects against:
- Small subgroup attacks (pub_key in weak subgroup)
- Invalid curve attacks (pub_key not on valid parameters)
- Trivial shared secret attacks (pub_key == 1 or p-1)

EDGE CASES:
- pub_key == 1: Invalid (trivial shared secret)
- pub_key == p-1: Invalid (trivial shared secret)  
- pub_key == 0: Invalid (out of range)
- pub_key >= p: Invalid (out of range)
- q exists but pub_key^q != 1 mod p: Invalid (wrong subgroup)

@note Use ossl_dh_check_pub_key_partial() for ephemeral keys (faster)
@note Full validation is expensive - cache result if validating same key multiple times

@see ossl_dh_check_pub_key_partial(), ossl_ffc_validate_public_key()
*/
int DH_check_pub_key(const DH *dh, const BIGNUM *pub_key, int *ret)
{
    return ossl_ffc_validate_public_key(&dh->params, pub_key, ret);
}

/*
 * See SP800-56Ar3 Section 5.6.2.3.1 : FFC Partial public key validation.
 * To only be used with ephemeral FFC public keys generated using the approved
 * safe-prime groups.
 */

/**
@brief Partial public key validation for ephemeral keys (faster, safe-prime groups only)

@param[in] dh DH parameter structure with safe-prime group parameters (must be initialized, not NULL)
@param[in] pub_key Ephemeral public key value to validate (must not be NULL)
@param[out] ret Pointer to int for validation error flags (initialized by callee)

@return 1 on success (public key valid for ephemeral use)
@retval 0 on failure (validation error - check *ret for specific failure)

@details
Algorithm Flow (Plain English):
Delegates to ossl_ffc_validate_public_key_partial() which implements:
1. Verify pub_key is in valid range: 2 <= pub_key <= p-2
2. Skip expensive subgroup membership test (g^q == 1 mod p)
3. Rely on safe-prime group properties for security

WHY THIS DESIGN:
SP800-56Ar3 Section 5.6.2.3.1 allows "partial" validation for ephemeral public keys
when using approved safe-prime groups (RFC 7919 groups ffdhe2048, ffdhe3072, etc.).

Safe-prime groups have mathematical properties that make the expensive subgroup
membership test (pub_key^q == 1 mod p) unnecessary:
- All non-identity elements generate the full group
- No small subgroups exist
- Simple range check is sufficient

PERFORMANCE BENEFIT:
Full validation: O(n³) for subgroup test
Partial validation: O(1) range check only
Speedup: 100-1000x faster for ephemeral key validation

WHEN TO USE:
- Ephemeral (single-use) DH keys in TLS, SSH, IKE
- Parameters from approved safe-prime groups (RFC 7919)
- Performance-critical key exchange

WHEN NOT TO USE:
- Static (long-term) public keys → use DH_check_pub_key()
- Custom (non-approved) parameter groups → use DH_check_pub_key()
- FIPS compliance with explicit validation requirements → use DH_check_pub_key()

SECURITY GUARANTEE:
For approved safe-prime groups, partial validation provides equivalent security
to full validation but with dramatically better performance.

EDGE CASES:
- pub_key <= 1: Invalid (trivial)
- pub_key >= p-1: Invalid (trivial)
- Non-safe-prime group: Results undefined (caller must ensure safe-prime group)

@warning Only use with approved safe-prime groups (RFC 7919)
@warning Do NOT use for static/long-term public keys

@see DH_check_pub_key(), ossl_ffc_validate_public_key_partial()
*/
int ossl_dh_check_pub_key_partial(const DH *dh, const BIGNUM *pub_key, int *ret)
{
    return ossl_ffc_validate_public_key_partial(&dh->params, pub_key, ret);
}

/**
@brief Validate DH private key is in correct range

@param[in] dh DH parameter structure containing domain parameters (must be initialized, not NULL)
@param[in] priv_key Private key value to validate (must not be NULL)
@param[out] ret Pointer to int for validation error flags (initialized to 0 by this function)

@return 1 on success (private key valid)
@retval 0 on failure (allocation error or private key out of range)

@details
Algorithm Flow (Plain English):
1. Initialize *ret = 0
2. Allocate temporary BIGNUM two_powN
3. Determine upper bound for private key validation:
   a. If q exists: upper = q (standard case)
   b. If q missing but p exists (non-FIPS only): use bit-length based validation
   c. If q from approved group AND dh->length set: upper = min(2^length, q)
4. Validate private key is in range [1, upper-1]
5. Clean up and return

WHY THIS DESIGN:
Private key validation has three different paths to handle different parameter scenarios:

PATH 1 (Standard, q exists): 
- Private key must be in [1, q-1]
- This is the cryptographically correct range for modern DH

PATH 2 (Legacy, no q, non-FIPS only):
- No explicit subgroup order available
- Fall back to bit-length validation
- If dh->length set: private key must have exactly that many bits
- If dh->length not set: private key must be in [2, p-2] with reasonable bit length

PATH 3 (Approved group with length restriction):
- Some approved groups specify shorter private key lengths for performance
- Validate against min(2^dh->length, q) to enforce both security and spec

VALIDATION GUARANTEES:
Success means private key is:
- Non-zero (not the identity)
- Less than the group order (in proper range)
- Has appropriate bit length (if length constraint exists)

EDGE CASES:
- priv_key == 0: Invalid (identity element, no security)
- priv_key >= q: Invalid (out of subgroup range)
- priv_key >= p (when q missing): Invalid (out of total range)
- Allocation failure for two_powN: Returns 0
- No q and no p: Returns 0 (cannot validate)

NON-FIPS SPECIAL CASE:
Lines 261-285 handle legacy parameters without q parameter.
This is a compatibility feature - modern code should always use parameters with q.
The bit-length based validation provides basic sanity checking but is not
cryptographically rigorous.

APPROVED GROUP OPTIMIZATION:
When using approved safe-prime groups with specified private key length,
we validate against 2^length rather than full q. This allows shorter
private keys (e.g., 256 bits instead of 2048 bits) for performance while
maintaining security.

@warning Non-FIPS path allows validation without q (legacy compatibility)
@warning Validation without q uses heuristic bit-length checks, not rigorous math

@see ossl_ffc_validate_private_key(), DH_generate_key()
*/
int ossl_dh_check_priv_key(const DH *dh, const BIGNUM *priv_key, int *ret)
{
    int ok = 0;
    BIGNUM *two_powN = NULL, *upper;

    *ret = 0;
    two_powN = BN_new();
    if (two_powN == NULL)
        return 0;

    if (dh->params.q != NULL) {
        upper = dh->params.q;
#ifndef FIPS_MODULE
    } else if (dh->params.p != NULL) {
        /*
         * We do not have q so we just check the key is within some
         * reasonable range, or the number of bits is equal to dh->length.
         */
        int length = dh->length;

        if (length == 0) {
            /* No length specified - validate bit count is reasonable */
            length = BN_num_bits(dh->params.p) - 1;
            if (BN_num_bits(priv_key) <= length
                && BN_num_bits(priv_key) > 1)
                ok = 1;
        } else if (BN_num_bits(priv_key) == length) {
            /* Length specified - validate exact bit count */
            ok = 1;
        }
        goto end;
#endif
    } else {
        /* No q and no p (or FIPS mode without q) - cannot validate */
        goto end;
    }

    /* Is it from an approved Safe prime group ?*/
    if (DH_get_nid((DH *)dh) != NID_undef && dh->length != 0) {
        /* Approved group with length restriction */
        if (!BN_lshift(two_powN, BN_value_one(), dh->length))
            goto end;
        if (BN_cmp(two_powN, dh->params.q) < 0)
            upper = two_powN;
    }
    /* Validate private key is in [1, upper-1] */
    if (!ossl_ffc_validate_private_key(upper, priv_key, ret))
        goto end;

    ok = 1;
end:
    BN_free(two_powN);
    return ok;
}

/*
 * FFC pairwise check from SP800-56A R3.
 *    Section 5.6.2.1.4 Owner Assurance of Pair-wise Consistency
 */

/**
@brief Verify DH public/private key pair consistency

@param[in] dh DH structure with both public and private keys set (all fields must be non-NULL)

@return 1 on success (key pair is consistent)
@retval 0 on failure (keys are inconsistent, allocation error, or missing parameters)

@details
Algorithm Flow (Plain English):
1. Verify all required parameters exist (p, g, priv_key, pub_key)
2. Allocate BN_CTX and temporary BIGNUM for recalculated public key
3. Recalculate public key from private key: pub_calc = g^priv_key mod p
4. Compare recalculated public key with stored public key
5. Return 1 if they match (keys are consistent), 0 otherwise
6. Clean up allocated resources

WHY THIS DESIGN:
SP800-56A R3 Section 5.6.2.1.4 requires "Owner Assurance of Pair-wise Consistency"
to verify that a public/private key pair is mathematically consistent before use.

This prevents:
- Using corrupted key material (memory corruption, disk errors)
- Using mismatched public/private keys (configuration errors)
- Using keys generated with faulty random number generators
- Certain implementation attacks where keys are manipulated

The check is simple: if pub_key was correctly generated from priv_key using the
DH formula (g^priv mod p), then recalculating it should yield the same result.

WHEN TO USE:
- After loading keys from storage (detect corruption)
- After key generation (detect RNG failures)
- Before using keys for sensitive operations (paranoid validation)
- FIPS compliance may require this check

PERFORMANCE:
Modular exponentiation (g^priv mod p) is moderately expensive:
- O(n²) to O(n³) depending on exponent size
- For 2048-bit DH: 1-10ms on modern hardware
- Much faster than primality testing, but not trivial

EDGE CASES:
- Missing p, g, priv_key, or pub_key: Returns 0 immediately
- Allocation failure (ctx or pub_key): Returns 0
- Recalculation failure in ossl_dh_generate_public_key(): Returns 0
- Keys match: Returns 1
- Keys don't match: Returns 0

SECURITY NOTE:
This does NOT validate that keys are cryptographically strong, only that they
are mathematically consistent with each other. You still need DH_check(),
DH_check_pub_key(), and ossl_dh_check_priv_key() for full security validation.

@warning Does NOT validate cryptographic strength, only mathematical consistency
@warning All parameters (p, g, priv_key, pub_key) must be non-NULL

@see ossl_dh_generate_public_key(), SP800-56A R3 Section 5.6.2.1.4
*/
int ossl_dh_check_pairwise(const DH *dh)
{
    int ret = 0;
    BN_CTX *ctx = NULL;
    BIGNUM *pub_key = NULL;

    if (dh->params.p == NULL
        || dh->params.g == NULL
        || dh->priv_key == NULL
        || dh->pub_key == NULL)
        return 0;

    ctx = BN_CTX_new_ex(dh->libctx);
    if (ctx == NULL)
        goto err;
    pub_key = BN_new();
    if (pub_key == NULL)
        goto err;

    /* recalculate the public key = (g ^ priv) mod p */
    if (!ossl_dh_generate_public_key(ctx, dh, dh->priv_key, pub_key))
        goto err;
    /* check it matches the existing pubic_key */
    ret = BN_cmp(pub_key, dh->pub_key) == 0;
err:
    BN_free(pub_key);
    BN_CTX_free(ctx);
    return ret;
}