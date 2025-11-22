# Dimension 5: Relationships

## Purpose
Document HOW code relates to the larger system - dependencies, integration points, component interactions, and system-wide patterns.

## What to Document

### Component Relationships
- What this component depends on
- What depends on this component
- Interface contracts between components
- Data flow between components

### Dependencies
- Required libraries and versions
- System-level dependencies (OS, hardware)
- Build-time vs runtime dependencies
- Optional vs mandatory dependencies

### Integration Points
- Public APIs exposed
- External APIs consumed
- Configuration interfaces
- Callback mechanisms
- Plugin architectures

### System-Wide Patterns
- How this fits into broader architecture
- Design patterns used consistently
- Shared conventions and idioms
- Cross-cutting concerns (logging, error handling)

## Example Pattern

```c
/**
 * RELATIONSHIPS: asn1parse command-line tool integration
 * 
 * COMPONENT ROLE:
 * This is a command-line tool in the OpenSSL apps/ suite.
 * It's a thin wrapper around OpenSSL libcrypto ASN.1 parsing.
 * 
 * DEPENDS ON (Required):
 * - libcrypto (OpenSSL core library)
 *   ├── BIO subsystem (buffered I/O)
 *   │   ├── BIO_read, BIO_write (I/O operations)
 *   │   ├── BIO_new, BIO_free (lifetime management)
 *   │   └── BIO_f_base64 (format filters)
 *   ├── ASN.1 subsystem (parsing/encoding)
 *   │   ├── d2i_ASN1_TYPE (decode DER to internal)
 *   │   ├── i2d_ASN1_TYPE (encode internal to DER)
 *   │   ├── ASN1_parse_dump (generic display)
 *   │   ├── ASN1_item_d2i (typed parsing)
 *   │   └── ASN1_item_print (formatted output)
 *   ├── Error subsystem
 *   │   ├── ERR_print_errors (error display)
 *   │   └── ERR_get_error (error retrieval)
 *   ├── Memory subsystem
 *   │   ├── OPENSSL_malloc, OPENSSL_free
 *   │   └── BUF_MEM (dynamic buffer)
 *   └── PEM subsystem
 *       └── PEM_read_bio (PEM decode)
 * 
 * - apps/ framework (command-line infrastructure)
 *   ├── apps.h (common utilities)
 *   ├── opt_* functions (option parsing)
 *   └── bio_open_default (file opening)
 * 
 * DEPENDS ON (Optional):
 * - None (no optional features)
 * 
 * DEPENDED ON BY:
 * - Test suite: test/recipes/*asn1parse*
 * - Documentation: doc/man1/openssl-asn1parse.pod
 * - Scripts: util/mkdef.pl (for symbol extraction)
 * - Build system: Makefile, CMakeLists.txt
 * 
 * INTEGRATION POINTS:
 * 
 * 1. Command-line interface (apps.h framework):
 *    - Input: argc, argv (standard C)
 *    - Output: return 0 (success) or 1 (error)
 *    - Follows apps/ conventions:
 *      * opt_init() for option parsing
 *      * bio_out for stdout, bio_err for stderr
 *      * Common options: -help, -in, -out
 * 
 * 2. File I/O (BIO abstraction):
 *    - Reads from: Files, stdin, or generated data
 *    - Writes to: stdout or specified file
 *    - Formats: PEM, DER, Base64
 *    - BIO filters compose: base64 → buffered → file
 * 
 * 3. ASN.1 library (core functionality):
 *    - Generic parsing: d2i_ASN1_TYPE + ASN1_parse_dump
 *    - Typed parsing: ASN1_item_d2i + ASN1_item_print
 *    - Generation: ASN1_generate_nconf
 *    - All functions follow OpenSSL memory conventions
 * 
 * 4. Error reporting (ERR subsystem):
 *    - Errors pushed to error stack
 *    - ERR_print_errors displays them
 *    - Follows pattern: set error, goto cleanup
 * 
 * SHARED WITH OTHER APPS:
 * - Option parsing pattern (all apps/ tools)
 * - BIO usage pattern (all I/O tools)
 * - Error handling pattern (cleanup-on-goto)
 * - Memory management (OpenSSL allocators)
 * 
 * DIFFERS FROM OTHER APPS:
 * - Most apps process certificates/keys (high-level)
 * - This app processes raw ASN.1 (low-level)
 * - This app has -strparse (unique feature)
 * - This app can generate ASN.1 (unusual)
 * 
 * SYSTEM-WIDE IMPACT:
 * - Breaking BIO API → breaks this tool
 * - Breaking ASN.1 API → breaks this tool
 * - Changes to error reporting → needs update
 * - Changes to option parsing → needs update
 * 
 * DATA FLOW:
 *   User command line
 *   → argc/argv parsing
 *   → File/stdin via BIO
 *   → Optional format filter (base64)
 *   → Buffer accumulation
 *   → Optional strparse drilling
 *   → ASN.1 parsing
 *   → Display formatting
 *   → stdout/file via BIO
 * 
 * ARCHITECTURAL POSITION:
 *   ┌─────────────────┐
 *   │  Command Line   │ (User)
 *   └────────┬────────┘
 *            │
 *   ┌────────▼────────┐
 *   │  asn1parse.c    │ (This file)
 *   └────────┬────────┘
 *            │
 *   ┌────────▼────────┐
 *   │   libcrypto     │ (OpenSSL library)
 *   │  ┌───────────┐  │
 *   │  │ ASN.1 API │  │
 *   │  └───────────┘  │
 *   │  ┌───────────┐  │
 *   │  │  BIO API  │  │
 *   │  └───────────┘  │
 *   └─────────────────┘
 * 
 * TESTING RELATIONSHIPS:
 * - Unit tests: None (command-line tool)
 * - Integration tests: test/recipes/04-test_asn1parse.t
 * - Test vectors: test/asn1parse/
 * - Regression tests: test/recipes/04-test_asn1parse_overflow.t
 */
```

## Key Patterns to Document

### Library Dependencies
```c
/**
 * RELATIONSHIPS: BIO subsystem usage
 * 
 * DEPENDENCY: BIO (Basic I/O abstraction)
 * Location: crypto/bio/
 * Version: Stable since OpenSSL 0.9.x
 * 
 * WHY BIO:
 * - Abstracts file/memory/network I/O
 * - Supports filter chains (base64, encryption, compression)
 * - Consistent error handling
 * - Buffer management built-in
 * 
 * FUNCTIONS USED:
 * - BIO_new(BIO_s_file()) - File I/O
 * - BIO_new(BIO_f_base64()) - Base64 filter
 * - BIO_push() - Chain filters
 * - BIO_read() - Read data
 * - BIO_write() - Write data
 * - BIO_free() - Cleanup
 * 
 * USAGE PATTERN:
 * 1. Create source BIO (file, stdin)
 * 2. Optionally create filter BIO (base64)
 * 3. Push filter onto source (creates chain)
 * 4. Read/write through top of chain
 * 5. Free all BIOs (frees entire chain)
 * 
 * FILTER CHAIN EXAMPLE:
 *   [base64 filter BIO]
 *          ↓ (decodes)
 *   [file source BIO]
 *          ↓ (reads)
 *   [actual file]
 * 
 * Read from top BIO → automatically decoded
 * 
 * CONTRACT:
 * - BIOs must be freed in any order (reference counted)
 * - Source BIO freed → chain broken but filters still valid
 * - Filter BIO freed → source still usable
 * - Typical: free all, order doesn't matter
 * 
 * ERROR HANDLING:
 * - NULL return → allocation failed
 * - -1 return → I/O error
 * - 0 return → EOF (for reads)
 * - Check errno for system errors
 * 
 * THREAD SAFETY:
 * - BIOs are NOT thread-safe
 * - Each thread needs own BIO instances
 * - Sharing BIO between threads → undefined behavior
 * 
 * PERFORMANCE:
 * - BIOs add ~5% overhead vs raw I/O
 * - Filter chains: Each filter adds ~2-10% overhead
 * - Acceptable for OpenSSL use cases (not hot path)
 * 
 * ALTERNATIVES CONSIDERED:
 * - FILE* (not portable, no filter support)
 * - Direct read/write (no abstraction, hard to test)
 * - iostream (C++, not available in C)
 * 
 * RELATED PATTERNS:
 * - All OpenSSL apps use BIO for I/O
 * - SSL/TLS uses BIO for network I/O
 * - Consistent across entire codebase
 */
BIO *in = NULL, *b64 = NULL;

// Open file using apps framework (wraps BIO_new)
in = bio_open_default(infile, 'r', informat);

// If base64 input, insert filter
if (informat == FORMAT_BASE64) {
    b64 = BIO_new(BIO_f_base64());
    BIO_push(b64, in);  // Chain: base64 → file
    // Read from 'in' now goes through base64 decode
}

// Read data (automatically decoded if base64)
i = BIO_read(in, buffer, size);

// Cleanup (order doesn't matter)
BIO_free(b64);  // Frees filter (if exists)
BIO_free(in);   // Frees source
```

### Cross-Component Interactions
```c
/**
 * RELATIONSHIPS: ASN.1 subsystem interaction
 * 
 * COMPONENT: ASN.1 parsing and encoding
 * Location: crypto/asn1/
 * Interface: include/openssl/asn1.h
 * 
 * TWO MODES OF OPERATION:
 * 
 * 1. GENERIC PARSING (d2i_ASN1_TYPE):
 *    - Input: Raw DER bytes
 *    - Output: ASN1_TYPE* (generic structure)
 *    - Use case: When you don't know the type
 *    - Limitation: No field names, just tags
 * 
 * 2. TYPED PARSING (ASN1_item_d2i):
 *    - Input: Raw DER bytes + ASN1_ITEM* (type descriptor)
 *    - Output: Typed structure (e.g., X509*)
 *    - Use case: When you know what to expect
 *    - Benefit: Field names, validation
 * 
 * INTERACTION FLOW:
 * 
 * Generic path:
 *   DER bytes → d2i_ASN1_TYPE() → ASN1_TYPE*
 *                                      ↓
 *                              ASN1_parse_dump()
 *                                      ↓
 *                              stdout (tags/lengths)
 * 
 * Typed path:
 *   DER bytes + type → ASN1_item_d2i() → Typed struct
 *                                            ↓
 *                                    ASN1_item_print()
 *                                            ↓
 *                                    stdout (field names)
 * 
 * MEMORY OWNERSHIP:
 * - d2i_* functions allocate structures
 * - Caller must free with corresponding free function
 * - ASN1_TYPE_free() for generic
 * - ASN1_item_free() for typed
 * 
 * POINTER ADVANCEMENT:
 * - d2i functions advance input pointer
 * - Pass pointer-to-pointer: &p
 * - After call: p points past decoded data
 * - Allows chaining: decode, advance, decode next
 * 
 * ERROR REPORTING:
 * - NULL return → parse failed
 * - Error pushed to ERR stack
 * - Check ERR_get_error() for details
 * 
 * RELATIONSHIP WITH BIO:
 * - ASN.1 functions work on raw bytes
 * - BIO provides bytes from various sources
 * - Separation of concerns:
 *   * BIO: Get data from somewhere
 *   * ASN.1: Parse that data
 * 
 * CIRCULAR DEPENDENCY AVOIDANCE:
 * - BIO knows nothing about ASN.1
 * - ASN.1 knows nothing about BIO
 * - This file (asn1parse.c) bridges them
 * - Pattern: apps layer integrates libraries
 * 
 * VERSIONING:
 * - ASN.1 API stable since 0.9.x
 * - Major change in 3.0: deprecation warnings
 * - 4.0: Some old functions removed
 * - This file: Uses current API
 */

// Generic parsing (type unknown)
const unsigned char *p = data;
ASN1_TYPE *at = d2i_ASN1_TYPE(NULL, &p, length);
if (!at) {
    ERR_print_errors(bio_err);  // ASN.1 error details
    return -1;
}
ASN1_parse_dump(bio_out, data, length, indent, dump);
ASN1_TYPE_free(at);

// Typed parsing (type known)
const unsigned char *p = data;
const ASN1_ITEM *it = ASN1_ITEM_lookup("X509");
ASN1_VALUE *value = ASN1_item_d2i(NULL, &p, length, it);
if (!value) {
    ERR_print_errors(bio_err);  // Type-specific error
    return -1;
}
ASN1_item_print(bio_out, value, 0, it, NULL);
ASN1_item_free(value, it);
```

### Plugin Architecture / Extension Points
```c
/**
 * RELATIONSHIPS: ASN1_ITEM registry (extensibility)
 * 
 * EXTENSION MECHANISM: ASN1_ITEM registration
 * 
 * BUILT-IN TYPES:
 * - X509 (certificates)
 * - X509_CRL (revocation lists)
 * - PKCS7 (encrypted messages)
 * - RSAPublicKey, DSAPublicKey, etc.
 * - DHparams, ECParameters
 * 
 * HOW ITEMS ARE REGISTERED:
 * 1. Type definition in header (ASN1_SEQUENCE, etc.)
 * 2. Registration macro (IMPLEMENT_ASN1_FUNCTIONS)
 * 3. Automatic inclusion via libcrypto
 * 
 * LOOKUP MECHANISM:
 * - ASN1_ITEM_lookup(name) → finds registered type
 * - Returns ASN1_ITEM* descriptor
 * - NULL if type unknown
 * 
 * EXTENSIBILITY:
 * - Applications can register custom types
 * - Use IMPLEMENT_ASN1_FUNCTIONS in your code
 * - Link with libcrypto
 * - Type becomes available to all ASN.1 functions
 * 
 * USAGE IN THIS FILE:
 * - User specifies type with -item parameter
 * - We look up the type: ASN1_ITEM_lookup(opt_arg())
 * - If found: typed parsing
 * - If not found: list available types, error
 * 
 * DISCOVERY:
 * - ASN1_ITEM_get(index) → iterate all types
 * - Returns NULL when index exceeds count
 * - Used for -help (list supported types)
 * 
 * INTEGRATION EXAMPLE:
 * 
 * // User wants to parse as X509
 * it = ASN1_ITEM_lookup("X509");
 * if (it == NULL) {
 *     // Not found, show available options
 *     for (i = 0; ; i++) {
 *         const ASN1_ITEM *item = ASN1_ITEM_get(i);
 *         if (!item) break;
 *         printf("Available: %s\n", item->sname);
 *     }
 * }
 * 
 * DEPENDENCY:
 * - Depends on: ASN.1 type registry (libcrypto)
 * - Registry populated: At libcrypto initialization
 * - Registry is: Read-only at runtime (no dynamic registration)
 * 
 * THREAD SAFETY:
 * - Registry is read-only after init → thread-safe
 * - Lookup is thread-safe (no locks needed)
 * - Parsing is thread-safe (no shared state)
 * 
 * LIMITATIONS:
 * - Cannot register types at runtime (compile-time only)
 * - Cannot unregister types
 * - Type name must be unique
 * 
 * FUTURE:
 * - OpenSSL 4.0 may allow runtime registration
 * - Would enable plugin ASN.1 types
 * - Currently: static only
 */
```

### System-Wide Patterns
```c
/**
 * RELATIONSHIPS: OpenSSL error handling convention
 * 
 * PATTERN: Error stack + cleanup-on-goto
 * 
 * USED BY: All OpenSSL libraries and apps
 * 
 * COMPONENTS:
 * 1. Error stack (ERR_* functions)
 * 2. Goto-based cleanup (end: label)
 * 3. Return codes (0=success, -1=error for internal, 1=error for apps)
 * 
 * ERROR STACK PROTOCOL:
 * - Error occurs → Push to stack: ERR_put_error()
 * - Or use convenience: ERR_raise()
 * - Multiple errors → stack builds up
 * - Caller can: ERR_print_errors() to display all
 * - Caller can: ERR_get_error() to inspect programmatically
 * - Stack persists across calls until cleared
 * 
 * GOTO CLEANUP PROTOCOL:
 * - Initialize all resources to NULL/safe values
 * - On error: goto end
 * - At end label: Free all resources (NULL-safe)
 * - Return error code
 * 
 * WHY THIS PATTERN:
 * - C has no RAII (no destructors)
 * - C has no exceptions (no automatic unwinding)
 * - Manual cleanup would be error-prone
 * - Goto ensures all paths reach cleanup
 * 
 * CONSISTENCY ACROSS CODEBASE:
 * - libcrypto: Uses this pattern everywhere
 * - libssl: Uses this pattern everywhere
 * - apps: Uses this pattern everywhere
 * - tests: Expects this error reporting
 * 
 * EXAMPLE FROM THIS FILE:
 */
int asn1parse_main(int argc, char **argv)
{
    // Initialize to safe values
    BIO *in = NULL;
    BIO *b64 = NULL;
    ASN1_TYPE *at = NULL;
    int ret = 1;  // Pessimistic: assume error
    
    // Allocate resources
    if ((in = BIO_new(...)) == NULL) {
        ERR_raise(ERR_LIB_BIO, ERR_R_MALLOC_FAILURE);
        goto end;  // Skip to cleanup
    }
    
    // Do work
    if (some_operation() < 0) {
        ERR_raise(ERR_LIB_ASN1, ASN1_R_DECODE_ERROR);
        goto end;
    }
    
    // Success path
    ret = 0;
    
end:
    // Cleanup (safe even if NULL)
    BIO_free(in);
    BIO_free(b64);
    ASN1_TYPE_free(at);
    
    // Print errors if failed
    if (ret != 0)
        ERR_print_errors(bio_err);
    
    return ret;
}

/**
 * INTEGRATION WITH OTHER PATTERNS:
 * 
 * - Memory allocation: OPENSSL_malloc/free (not malloc/free)
 * - Thread safety: Error stack is per-thread
 * - Logging: Error stack is the log
 * - Debugging: Error stack provides trace
 * 
 * RELATIONSHIP WITH EXTERNAL CODE:
 * - Calling OpenSSL from other languages:
 *   * Must check error stack after each call
 *   * Must clear error stack before next call
 *   * Language bindings handle this automatically
 * 
 * TESTING IMPLICATIONS:
 * - Tests check error stack for expected errors
 * - Tests clear stack between test cases
 * - Tests verify cleanup by checking leaks
 */
```

### Data Flow Across Components
```c
/**
 * RELATIONSHIPS: Multi-component data flow
 * 
 * USER INPUT TO OUTPUT: Complete journey
 * 
 * 1. COMMAND LINE:
 *    User types: openssl asn1parse -in cert.pem -dump
 *    ↓
 * 
 * 2. OPTION PARSING (apps framework):
 *    - opt_init() → sets up parser
 *    - opt_next() → processes each option
 *    - opt_arg() → extracts argument values
 *    - Sets: infile="cert.pem", dump=1
 *    ↓
 * 
 * 3. FILE OPENING (BIO + apps):
 *    - bio_open_default(infile, 'r', FORMAT_PEM)
 *    - Opens: /path/to/cert.pem
 *    - Returns: BIO* pointing to file
 *    ↓
 * 
 * 4. PEM DECODE (PEM subsystem):
 *    - PEM_read_bio(in, &name, &header, &str, &num)
 *    - Reads: "-----BEGIN CERTIFICATE-----"
 *    - Base64 decodes: MIIDXTCCAkWgAwIB...
 *    - Returns: raw DER bytes in 'str'
 *    ↓
 * 
 * 5. OPTIONAL STRPARSE (ASN.1 subsystem):
 *    - If -strparse specified:
 *      * d2i_ASN1_TYPE() → parse structure
 *      * Navigate to nested offset
 *      * Point str at nested data
 *    - Allows "drilling down" into structure
 *    ↓
 * 
 * 6. PARSING (ASN.1 subsystem):
 *    - ASN1_parse_dump(bio_out, str, num, indent, dump)
 *    - Walks DER structure
 *    - Interprets tags, lengths, values
 *    ↓
 * 
 * 7. OUTPUT FORMATTING (BIO):
 *    - Writes to bio_out (stdout or file)
 *    - Format:
 *      0:d=0  hl=4 l= 467 cons: SEQUENCE
 *      4:d=1  hl=4 l= 316 cons:  SEQUENCE
 *      ...
 *      (hex dump if -dump specified)
 *    ↓
 * 
 * 8. USER SEES RESULT:
 *    Readable ASN.1 structure breakdown
 * 
 * DATA TRANSFORMATIONS:
 * - Command line → option structures (parsing)
 * - File path → BIO* (abstraction)
 * - PEM text → DER bytes (decoding)
 * - DER bytes → ASN1_TYPE* (parsing)
 * - ASN1_TYPE* → text output (formatting)
 * 
 * ERROR PATHS:
 * - Any step fails → goto end
 * - end label prints errors
 * - Cleanup frees all resources
 * - Exit with code 1
 * 
 * COMPONENT BOUNDARIES:
 * - apps framework: Option parsing, file opening
 * - PEM subsystem: PEM decoding
 * - ASN.1 subsystem: Structure parsing
 * - BIO subsystem: I/O abstraction
 * - Each is replaceable/testable independently
 * 
 * TESTING EACH BOUNDARY:
 * - Mock BIO → test parsing logic
 * - Mock ASN.1 → test I/O logic
 * - Mock options → test main flow
 * - Integration test → test everything together
 */
```

## Integration with Other Dimensions

Relationships dimension complements:

- **D1 (Syntax)**: Syntax documents function interface, Relationships documents component interface
- **D2 (Structure)**: Structure explains internal algorithm, Relationships explains external interactions
- **D3 (Intent)**: Intent explains why component exists, Relationships explains how it fits
- **D4 (History)**: History documents dependency evolution, Relationships documents current dependencies
- **D6 (Quality)**: Quality flags coupling issues, Relationships explains coupling rationale

## Checklist for Complete Relationships Documentation

- [ ] All dependencies identified (libraries, components)
- [ ] Dependency versions noted
- [ ] Integration points documented
- [ ] Data flow mapped
- [ ] Component role explained
- [ ] Shared patterns identified
- [ ] Cross-cutting concerns noted
- [ ] Thread safety implications documented
- [ ] Testing relationships explained
- [ ] Build/deployment dependencies noted

## Common Mistakes to Avoid

❌ **Don't**: List dependencies without explaining why needed
✅ **Do**: Explain what each dependency provides

❌ **Don't**: Forget to document optional vs required dependencies
✅ **Do**: Clearly mark what's mandatory vs nice-to-have

❌ **Don't**: Ignore system-wide patterns
✅ **Do**: Show how this follows/breaks conventions

❌ **Don't**: Omit data flow between components
✅ **Do**: Map the complete journey from input to output

❌ **Don't**: Forget about transitive dependencies
✅ **Do**: Document the whole dependency tree

## When Relationships Documentation is Most Critical

1. **Integration code**: Where multiple components meet
2. **Plugin architectures**: Extension points and protocols
3. **Shared libraries**: APIs used by many components
4. **System boundaries**: Interaction with OS, network, filesystem
5. **Complex dependency graphs**: Where understanding the web matters
6. **Refactoring candidates**: Need to understand impact radius

## Example: Complete Relationships Documentation

```c
/**
 * RELATIONSHIPS: Complete dependency and integration map
 * 
 * ========================
 * COMPONENT IDENTITY
 * ========================
 * Name: asn1parse command-line tool
 * Location: apps/asn1parse.c
 * Role: User-facing ASN.1 structure inspector
 * Layer: Application (highest level)
 * 
 * ========================
 * ARCHITECTURE POSITION
 * ========================
 *   ┌──────────────────────────────────┐
 *   │         End User                 │
 *   └─────────────┬────────────────────┘
 *                 │ (command line)
 *   ┌─────────────▼────────────────────┐
 *   │   asn1parse.c (THIS FILE)        │ ← Application Layer
 *   └─────────────┬────────────────────┘
 *                 │
 *   ┌─────────────▼────────────────────┐
 *   │   apps/ framework                │ ← App Framework Layer
 *   │   - Option parsing               │
 *   │   - File helpers                 │
 *   └─────────────┬────────────────────┘
 *                 │
 *   ┌─────────────▼────────────────────┐
 *   │   libcrypto (OpenSSL)           │ ← Library Layer
 *   │   ┌──────────────────────────┐  │
 *   │   │ BIO      │ ASN.1  │ PEM  │  │
 *   │   └──────────────────────────┘  │
 *   │   ┌──────────────────────────┐  │
 *   │   │ Memory   │ Error  │ OBJ  │  │
 *   │   └──────────────────────────┘  │
 *   └─────────────┬────────────────────┘
 *                 │
 *   ┌─────────────▼────────────────────┐
 *   │   Operating System               │ ← System Layer
 *   │   - File I/O                     │
 *   │   - Memory allocation            │
 *   └──────────────────────────────────┘
 * 
 * ========================
 * REQUIRED DEPENDENCIES
 * ========================
 * 
 * libcrypto (OpenSSL core):
 * - Version: 3.0+
 * - Why: All core cryptographic and parsing functionality
 * - Subsystems used:
 *   ├── BIO: I/O abstraction
 *   ├── ASN.1: Parsing and encoding
 *   ├── PEM: Base64 + headers
 *   ├── Memory: OPENSSL_malloc/free
 *   ├── Error: ERR_* functions
 *   └── OBJ: OID database
 * 
 * apps framework:
 * - Version: Same as OpenSSL (part of source tree)
 * - Why: Common command-line utilities
 * - Functions used:
 *   ├── opt_* Option parsing
 *   ├── bio_open_default() File opening
 *   └── Standard variables: bio_out, bio_err
 * 
 * Standard C library:
 * - stdio.h: printf, fprintf
 * - stdlib.h: strtol, memory functions
 * - string.h: string operations
 * 
 * ========================
 * OPTIONAL DEPENDENCIES
 * ========================
 * None. All features are mandatory.
 * 
 * ========================
 * DEPENDED ON BY
 * ========================
 * 
 * Test suite:
 * - test/recipes/04-test_asn1parse.t
 * - test/recipes/04-test_asn1parse_overflow.t
 * - test/asn1parse/* (test vectors)
 * 
 * Documentation:
 * - doc/man1/openssl-asn1parse.pod
 * - doc/man1/openssl.pod (mentions asn1parse)
 * 
 * Build system:
 * - Makefile (Unix)
 * - CMakeLists.txt (CMake)
 * - crypto/build.info (OpenSSL build)
 * 
 * Scripts:
 * - util/mkdef.pl (exports symbols)
 * - Some user scripts may wrap asn1parse
 * 
 * ========================
 * INTEGRATION POINTS
 * ========================
 * 
 * 1. Command-line interface:
 *    Protocol: Standard C main(argc, argv)
 *    Input: Command-line arguments
 *    Output: Return code (0=success, 1=error)
 *    Errors: Printed to stderr
 *    Results: Printed to stdout or file
 * 
 * 2. File I/O:
 *    Abstraction: BIO
 *    Sources: Files, stdin, or memory
 *    Sinks: stdout or files
 *    Formats: PEM, DER, Base64
 * 
 * 3. ASN.1 processing:
 *    API: libcrypto ASN.1 subsystem
 *    Methods:
 *    - Generic: d2i_ASN1_TYPE
 *    - Typed: ASN1_item_d2i
 *    - Display: ASN1_parse_dump, ASN1_item_print
 * 
 * 4. Error reporting:
 *    Mechanism: OpenSSL error stack
 *    Functions: ERR_print_errors, ERR_raise
 *    Thread-safe: Yes (per-thread stack)
 * 
 * ========================
 * DATA FLOW
 * ========================
 * 
 * Input sources:
 * ┌─────────┐     ┌─────────┐     ┌─────────┐
 * │  File   │ OR  │  stdin  │ OR  │Generate │
 * └────┬────┘     └────┬────┘     └────┬────┘
 *      └────────────────┴────────────────┘
 *                       │
 *              ┌────────▼────────┐
 *              │  BIO (buffered) │
 *              └────────┬────────┘
 *                       │
 *        ┌──────────────▼─────────────┐
 *        │  Optional: Base64 filter   │
 *        └──────────────┬─────────────┘
 *                       │
 *        ┌──────────────▼─────────────┐
 *        │  Read into memory buffer   │
 *        └──────────────┬─────────────┘
 *                       │
 *        ┌──────────────▼─────────────┐
 *        │  Optional: strparse drill  │
 *        └──────────────┬─────────────┘
 *                       │
 *        ┌──────────────▼─────────────┐
 *        │  ASN.1 parse (generic or   │
 *        │  typed)                    │
 *        └──────────────┬─────────────┘
 *                       │
 *        ┌──────────────▼─────────────┐
 *        │  Format output             │
 *        └──────────────┬─────────────┘
 *                       │
 *        ┌──────────────▼─────────────┐
 *        │  Write to stdout or file   │
 *        └────────────────────────────┘
 * 
 * ========================
 * SHARED PATTERNS
 * ========================
 * 
 * Pattern: Cleanup-on-goto
 * - Used by: All OpenSSL apps and libraries
 * - Rationale: C has no RAII or exceptions
 * - Safety: Ensures resources freed on all paths
 * 
 * Pattern: BIO abstraction
 * - Used by: All I/O in OpenSSL
 * - Rationale: Portability, testability
 * - Benefits: Filter chains, consistent error handling
 * 
 * Pattern: Error stack
 * - Used by: All OpenSSL functions
 * - Rationale: Rich error context
 * - Benefits: Debugging, error propagation
 * 
 * Pattern: NULL-safe free functions
 * - Used by: All OpenSSL memory management
 * - Rationale: Simplifies cleanup code
 * - Safety: Can call free(NULL) without checking
 * 
 * ========================
 * SYSTEM-WIDE IMPACT
 * ========================
 * 
 * IF BIO API changes:
 * - This tool breaks
 * - Must update BIO usage
 * - Impact: High (core dependency)
 * 
 * IF ASN.1 API changes:
 * - This tool breaks
 * - Must update parsing code
 * - Impact: Critical (core functionality)
 * 
 * IF option parsing changes:
 * - This tool breaks
 * - Must update opt_* calls
 * - Impact: Medium (can be adapted)
 * 
 * IF error reporting changes:
 * - This tool needs update
 * - Must update ERR_* calls
 * - Impact: Low (isolated to error paths)
 * 
 * ========================
 * TESTING DEPENDENCIES
 * ========================
 * 
 * Test infrastructure:
 * - Requires: Test::More (Perl)
 * - Requires: Test::Harness (Perl)
 * - Uses: OpenSSL test utilities
 * 
 * Test data:
 * - Location: test/asn1parse/
 * - Types: Valid ASN.1, invalid ASN.1, edge cases
 * - Generated: Some from scripts, some manual
 * 
 * Test execution:
 * - Platform: Unix (bash), Windows (batch)
 * - Automation: make test, ctest
 * - CI: GitHub Actions, buildbot
 * 
 * ========================
 * BUILD DEPENDENCIES
 * ========================
 * 
 * Build time:
 * - C compiler (gcc, clang, msvc)
 * - Make or CMake
 * - Perl (for test scripts)
 * 
 * Link time:
 * - libcrypto.a or libcrypto.so
 * - No other libraries needed
 * 
 * Runtime:
 * - libcrypto.so (if dynamic linking)
 * - Standard C library
 * - Operating system (file I/O, memory)
 * 
 * ========================
 * VERSIONING
 * ========================
 * 
 * This file:
 * - Added: OpenSSL 0.9.1 (1998)
 * - Major updates: 0.9.6, 0.9.8, 1.0.0, 3.0.0
 * - Current: Part of OpenSSL 3.0+
 * 
 * API compatibility:
 * - libcrypto 3.0+: Fully supported
 * - libcrypto 1.1.1: Mostly works (deprecated warnings)
 * - libcrypto 1.0.2: Works with modifications
 * - libcrypto < 1.0: Not compatible
 * 
 * ========================
 * FUTURE RELATIONSHIPS
 * ========================
 * 
 * OpenSSL 4.0 plans:
 * - May break some ASN.1 APIs
 * - May require updates to this file
 * - Deprecation period: 2+ years
 * 
 * Potential new dependencies:
 * - JSON output format (optional)
 * - XML output format (optional)
 * - Remote ASN.1 fetch (optional)
 * 
 * ========================
 * RELATIONSHIP GRAPH
 * ========================
 * 
 * This tool's dependency graph:
 * 
 *     asn1parse.c
 *         ├── apps.h (sibling, same tree)
 *         │   └── (no external deps)
 *         ├── openssl/bio.h
 *         │   └── openssl/crypto.h (memory, threads)
 *         ├── openssl/asn1.h
 *         │   ├── openssl/bio.h
 *         │   └── openssl/bn.h (big numbers)
 *         ├── openssl/pem.h
 *         │   ├── openssl/bio.h
 *         │   └── openssl/asn1.h
 *         └── openssl/err.h
 *             └── openssl/crypto.h
 * 
 * Total dependencies (transitive): ~15 headers
 * All from OpenSSL, no external libraries
 * 
 * ========================
 * ISOLATION & TESTABILITY
 * ========================
 * 
 * This file is:
 * - Moderately coupled (depends on libcrypto heavily)
 * - Testable via command-line (integration tests)
 * - Not unit-testable (no internal functions exposed)
 * - Mockable at BIO level (for testing I/O independently)
 * 
 * To improve testability:
 * - Extract parsing logic to separate functions
 * - Add internal test entry points
 * - Reduce direct libcrypto coupling
 * - Add dependency injection for BIO creation
 */
```

This comprehensive relationship documentation shows:
- Complete architectural position
- All dependencies (direct and transitive)
- Integration points and protocols
- Data flow through system
- Shared patterns and conventions
- System-wide impact analysis
- Testing and build relationships
- Future evolution plans

Someone reading this understands not just WHAT this component does, but HOW it fits into the larger ecosystem and what would break if changed.

---

**Remember**: Relationships documentation is about understanding the web of dependencies. Every "what else does this affect?" question should have an answer. Document the ecosystem, not just the component.
