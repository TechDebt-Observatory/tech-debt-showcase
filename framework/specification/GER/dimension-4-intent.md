# Dimension 4: Intent

## Purpose
Capture WHY the code exists and design decisions made.

## What to Document

### Design Rationale
- Why this approach was chosen
- What alternatives were considered
- Trade-offs made

### Assumptions
- Environmental assumptions
- Caller responsibilities
- Resource availability

### Business Logic
- Domain-specific rules
- Compliance requirements
- Security considerations

### Example

```c
/**
 * INTENT: DH parameter validation is cryptographically critical
 * 
 * We validate parameters BEFORE use because:
 * 1. Invalid DH parameters can leak private keys (CVE-2016-0701)
 * 2. Small subgroups enable backdoors (RFC 2631 Section 2.1.5)
 * 3. Weak parameters are computationally unsafe (NIST SP 800-56A)
 * 
 * DESIGN DECISION: Fail closed, not open
 * - Invalid parameters → immediate failure
 * - Missing parameters → no default fallback
 * - Rationale: Security over convenience
 * 
 * ASSUMPTION: Caller handles failure gracefully
 * - This function does NOT log errors (caller's responsibility)
 * - No state changes on failure (atomic operation)
 */
static int validate_dh_params(const DH *dh) {
    // Implementation...
}
```

## Key Questions to Answer

1. Why does this code exist?
2. What problem does it solve?
3. Why this solution over alternatives?
4. What assumptions does it make?
5. What are the security implications?
