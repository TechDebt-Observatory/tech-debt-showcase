# Dimension 2: Structure

## Purpose
Document HOW the code accomplishes its task - the internal mechanics, algorithms, and data flow.

## What to Document

### Algorithm Description
- High-level approach (what algorithm/pattern is used)
- Key steps in the process
- Loop invariants and termination conditions
- Complexity characteristics (time/space)

### Data Flow
- How data moves through the function
- Transformations applied at each step
- Intermediate representations
- Buffer management strategies

### Control Flow Logic
- Decision points and their rationale
- Branch conditions and what they guard against
- Error handling paths
- Early exit conditions

### Data Structure Usage
- Which structures are used and why
- Memory layout considerations
- Access patterns
- Lifetime and ownership

## Example Pattern

```c
/**
 * STRUCTURE: ASN.1 parsing with nested drilling
 * 
 * ALGORITHM:
 * 1. Load entire file into memory buffer (streaming not possible for ASN.1)
 * 2. For each strparse offset:
 *    a. Parse ASN.1 structure at current position
 *    b. Validate type is drillable (SEQUENCE, SET, STRING types)
 *    c. Advance pointer into nested structure
 *    d. Repeat until all offsets processed
 * 3. Parse final structure and display
 * 
 * DATA FLOW:
 *   File → BIO → Buffer → str pointer → strparse loop → final parse → display
 *   
 * KEY INVARIANTS:
 * - Buffer always contains complete ASN.1 structure (no partial reads)
 * - Pointer arithmetic maintains alignment (tmpbuf points within valid buffer)
 * - Each parse operation validates before advancing
 * 
 * MEMORY STRATEGY:
 * - Single allocation for entire file (BUF_MEM)
 * - Pointer manipulation avoids copies (efficiency over safety)
 * - All intermediate ASN1_TYPE structs freed immediately
 * 
 * COMPLEXITY:
 * - Time: O(n * d) where n=file size, d=strparse depth
 * - Space: O(n) - single buffer plus temporary parse structures
 */
static int parse_asn1_nested(unsigned char *str, long num, 
                             STACK_OF(OPENSSL_STRING) *offsets) {
    // Implementation showing the algorithm in action
    
    // Loop through each drilling offset
    for (i = 0; i < sk_OPENSSL_STRING_num(offsets); i++) {
        // Parse offset value (STRUCTURE: why no error check? legacy pattern)
        j = strtol(sk_OPENSSL_STRING_value(offsets, i), NULL, 0);
        
        // Bounds validation (STRUCTURE: guard against buffer overrun)
        if (j <= 0 || j >= tmplen) {
            continue;  // Skip invalid offset
        }
        
        // Advance pointer (STRUCTURE: pointer arithmetic into nested structure)
        tmpbuf += j;
        tmplen -= j;
        
        // Parse ASN.1 at new position
        at = d2i_ASN1_TYPE(NULL, &ctmpbuf, tmplen);
        
        // Validate drillable type (STRUCTURE: prevent drilling into primitives)
        typ = ASN1_TYPE_get(at);
        if (typ == V_ASN1_OBJECT || typ == V_ASN1_BOOLEAN || typ == V_ASN1_NULL) {
            return -1;  // Can't drill into these types
        }
        
        // Point to nested data (STRUCTURE: "evil but works" direct access)
        tmpbuf = at->value.asn1_string->data;
        tmplen = at->value.asn1_string->length;
    }
}
```

## Key Patterns to Document

### Loop Patterns
```c
/**
 * STRUCTURE: Accumulator loop with overflow protection
 * 
 * Pattern: Read chunks until EOF or error
 * Invariant: num never overflows LONG_MAX
 * Termination: BIO_read returns <= 0
 */
for (;;) {
    if (!BUF_MEM_grow(buf, num + BUFSIZ))
        goto end;
    i = BIO_read(in, &(buf->data[num]), BUFSIZ);
    if (i <= 0)
        break;
    // Check AFTER read but BEFORE use (TECHNICAL DEBT: should be before grow)
    if (i > LONG_MAX - num)
        goto end;
    num += i;
}
```

### State Machine Patterns
```c
/**
 * STRUCTURE: Format-dependent input processing state machine
 * 
 * States:
 * 1. PEM format → PEM_read_bio → point buffer at decoded data
 * 2. Base64 format → Push base64 filter → accumulator loop
 * 3. DER format → Direct accumulator loop
 * 4. Generation → do_generate → synthetic data
 * 
 * Transition logic:
 * - genconf/genstr set → State 4
 * - informat == PEM → State 1
 * - informat == BASE64 → State 2
 * - else → State 3
 * 
 * Exit condition: buf contains complete data, str points to it
 */
if (genconf || genstr) {
    // State 4: Generate
    num = do_generate(genstr, genconf, buf);
} else if (informat == FORMAT_PEM) {
    // State 1: PEM decode
    PEM_read_bio(in, &name, &header, &str, &num);
} else {
    // States 2 & 3: Direct or filtered read
    if (informat == FORMAT_BASE64) {
        // State 2: Insert base64 filter
        b64 = BIO_new(BIO_f_base64());
        BIO_push(b64, in);
    }
    // Accumulator loop for both states 2 & 3
    num = 0;
    for (;;) { /* ... */ }
}
```

### Resource Management Patterns
```c
/**
 * STRUCTURE: Cleanup-on-goto error handling
 * 
 * Pattern: C error handling idiom (pre-RAII)
 * 
 * Setup phase:
 * - Allocate resources in order
 * - Initialize to NULL/safe values
 * - Check each allocation
 * 
 * Work phase:
 * - On error: goto end
 * - No cleanup in work phase
 * 
 * Cleanup phase (end label):
 * - Free everything (NULL-safe functions)
 * - Print errors if ret != 0
 * - Return status code
 * 
 * Safety properties:
 * - Resources freed exactly once
 * - Safe to goto from any point
 * - No leaks on any path
 */
int function() {
    Resource *a = NULL, *b = NULL, *c = NULL;
    int ret = 1;  // Pessimistic: assume failure
    
    // Allocate phase
    if ((a = create_a()) == NULL) goto end;
    if ((b = create_b()) == NULL) goto end;
    if ((c = create_c()) == NULL) goto end;
    
    // Work phase
    if (use_resources(a, b, c) < 0) goto end;
    
    ret = 0;  // Success
    
end:
    // Cleanup phase (NULL-safe)
    free_c(c);
    free_b(b);
    free_a(a);
    return ret;
}
```

## Common Anti-Patterns to Flag

### Magic Number Operations
```c
// BAD: Unexplained constant
if (!BUF_MEM_grow(buf, BUFSIZ * 8))  // Why 8?

// GOOD: Explain the structure
/**
 * STRUCTURE: Pre-allocate typical ASN.1 structure size
 * 
 * 8 * BUFSIZ = ~64KB, sized for:
 * - Typical X.509 certificate: 1-4KB
 * - Certificate chain (3 certs): 12KB
 * - With extensions: up to 64KB
 * 
 * Avoids multiple reallocs for common cases while not being excessive.
 */
#define ASN1_PARSE_INITIAL_BUFFER (BUFSIZ * 8)
if (!BUF_MEM_grow(buf, ASN1_PARSE_INITIAL_BUFFER))
```

### Pointer Arithmetic Without Explanation
```c
// BAD: "Evil" pointer manipulation
tmpbuf = at->value.asn1_string->data;

// GOOD: Explain the structure
/**
 * STRUCTURE: Direct pointer into ASN1_TYPE internal data
 * 
 * ASN1_TYPE layout (for constructed types):
 *   ASN1_TYPE
 *   └── value.asn1_string (ASN1_STRING*)
 *       ├── data (unsigned char*) ← points into original buffer
 *       └── length (int)
 * 
 * Why this works:
 * - ASN1_TYPE wraps decoded structure
 * - For SEQUENCE/SET/STRING, data points to nested content
 * - Original buffer 'str' is kept alive, so pointer is valid
 * - We keep 'at' in scope so ASN1_TYPE isn't freed
 * 
 * Safety dependencies:
 * - 'str' buffer must remain allocated
 * - 'at' structure must not be freed while tmpbuf in use
 * - No writes through tmpbuf (read-only access)
 */
tmpbuf = at->value.asn1_string->data;
tmplen = at->value.asn1_string->length;
```

## Documenting Complex Algorithms

### Three-Level Approach

**Level 1: Overview (what algorithm)**
```c
/**
 * STRUCTURE: Two-pass DER encoding
 * Uses OpenSSL's standard pattern for size-then-encode
 */
```

**Level 2: Steps (how it works)**
```c
/**
 * STRUCTURE: Two-pass DER encoding
 * 
 * Pass 1: Calculate required buffer size
 * - Call i2d_ASN1_TYPE(atyp, NULL)
 * - NULL pointer means "don't encode, just tell me the size"
 * - Returns number of bytes needed
 * 
 * Pass 2: Actually encode the data
 * - Allocate buffer of exact size
 * - Call i2d_ASN1_TYPE(atyp, &p)
 * - Function writes data and advances pointer
 */
```

**Level 3: Details (why this way)**
```c
/**
 * STRUCTURE: Two-pass DER encoding
 * 
 * Pass 1: Calculate required buffer size
 * - Call i2d_ASN1_TYPE(atyp, NULL)
 * - NULL pointer means "don't encode, just tell me the size"
 * - Returns number of bytes needed
 * - Why: Avoids realloc during encoding (more efficient)
 * 
 * Pass 2: Actually encode the data
 * - Allocate buffer of exact size (no waste, no realloc)
 * - Point p at buffer start
 * - Call i2d_ASN1_TYPE(atyp, &p)
 * - Function writes data and advances p past written bytes
 * - Why pointer-to-pointer: allows function to update caller's pointer
 * - After call: p points one byte past end of encoded data
 * 
 * Benefits of two-pass:
 * - No buffer reallocation during encoding (fast)
 * - No wasted space (exact size)
 * - Clean API (encode function doesn't manage buffer)
 * 
 * Tradeoff:
 * - Two passes through data structure (slightly slower)
 * - But realloc would be much worse for large structures
 */
len = i2d_ASN1_TYPE(atyp, NULL);      // Pass 1: get size
if (!BUF_MEM_grow(buf, len))          // Allocate exact size
    goto err;
p = (unsigned char *)buf->data;       // Set pointer
i2d_ASN1_TYPE(atyp, &p);              // Pass 2: encode
```

## Integration with Other Dimensions

Structure dimension complements:

- **D1 (Syntax)**: Syntax says "what parameters", Structure says "how parameters are used"
- **D3 (Intent)**: Intent says "why we chose this approach", Structure says "how we implement it"
- **D4 (History)**: History says "how this evolved", Structure documents "current implementation"
- **D5 (Relationships)**: Relationships say "what this calls", Structure says "how it calls them"
- **D6 (Quality)**: Quality flags problems, Structure explains what needs to change

## Checklist for Complete Structure Documentation

- [ ] Algorithm identified by name/pattern
- [ ] Major steps enumerated
- [ ] Loop invariants stated
- [ ] Termination conditions explained
- [ ] Data flow path documented
- [ ] Memory strategy described
- [ ] Complexity characterized
- [ ] Key decision points explained
- [ ] Error paths documented
- [ ] Resource lifecycle clear

## Common Mistakes to Avoid

❌ **Don't**: Just describe WHAT the code does line-by-line
✅ **Do**: Explain the ALGORITHM and how pieces work together

❌ **Don't**: Omit the "why this way" rationale  
✅ **Do**: Connect structure to requirements and constraints

❌ **Don't**: Ignore loop invariants and termination
✅ **Do**: Document what makes the algorithm correct

❌ **Don't**: Skip complexity analysis
✅ **Do**: Note if algorithm is O(n²) and why that's acceptable

❌ **Don't**: Forget to document memory strategy
✅ **Do**: Explain allocation, ownership, lifetime

## When Structure Documentation is Most Critical

1. **Complex algorithms**: Parsing, encoding, cryptographic operations
2. **State machines**: Multi-step processes with transitions
3. **Resource management**: Allocation, lifecycle, cleanup patterns
4. **Buffer manipulation**: Pointer arithmetic, memory layout
5. **Performance-critical code**: Where algorithm choice matters
6. **Security-sensitive code**: Where structure affects security properties

## Example: Complete Structure Documentation

```c
/**
 * STRUCTURE: Streaming file reader with dynamic buffer growth
 * 
 * ALGORITHM: Incremental read with exponential buffer growth
 * 1. Start with initial buffer size (BUFSIZ * 8 = ~64KB)
 * 2. Read in BUFSIZ chunks (typically 8KB)
 * 3. Grow buffer as needed (BUF_MEM_grow doubles on each grow)
 * 4. Continue until EOF or error
 * 
 * DATA FLOW:
 *   File → BIO (buffered I/O) → buf->data[num...num+BUFSIZ] → num += bytes_read
 *   
 * BUFFER MANAGEMENT:
 * - Buffer starts at 64KB (covers most certificate files without growing)
 * - Grows by doubling (efficient for large files)
 * - 'num' tracks bytes written (not buffer capacity)
 * - buf->max tracks allocated size
 * 
 * CONTROL FLOW:
 * - Loop forever (broken by EOF or error)
 * - Grow before read (ensures space available)
 * - Break on read error (i <= 0)
 * - Check for overflow before accumulating
 * 
 * INVARIANTS:
 * - 0 <= num <= buf->max (num never exceeds allocated space)
 * - num < LONG_MAX (checked explicitly to prevent overflow)
 * - buf->data[0...num-1] contains valid data
 * - buf->data[num...max-1] is allocated but unused
 * 
 * TERMINATION:
 * - BIO_read returns 0 (EOF) or -1 (error)
 * - Overflow check fails (i > LONG_MAX - num)
 * - Buffer grow fails (out of memory)
 * 
 * COMPLEXITY:
 * - Time: O(n) where n = file size (single pass)
 * - Space: O(n) for buffer
 * - Grow operations: O(log n) due to doubling strategy
 * 
 * SECURITY PROPERTIES:
 * - Overflow check prevents wraparound
 * - Buffer grow checks prevent heap corruption
 * - Size limit (LONG_MAX) prevents DOS via huge files
 * 
 * PERFORMANCE NOTES:
 * - Doubling strategy minimizes realloc calls
 * - Initial 64KB covers common case without growing
 * - BUFSIZ chunks match OS page size (efficient I/O)
 * 
 * TECHNICAL DEBT:
 * - Overflow check happens AFTER read, should be BEFORE grow
 * - No maximum file size limit (could DOS via memory exhaustion)
 * - Error on grow is silent (should print error message)
 */
static long read_file_streaming(BIO *in, BUF_MEM *buf) {
    long num = 0;
    int i;
    
    // Pre-allocate typical certificate size
    if (!BUF_MEM_grow(buf, BUFSIZ * 8))
        return -1;
    
    // Read loop: accumulate until EOF
    for (;;) {
        // Ensure buffer has space for next chunk
        if (!BUF_MEM_grow(buf, num + BUFSIZ))
            return -1;
            
        // Read next chunk
        i = BIO_read(in, &(buf->data[num]), BUFSIZ);
        if (i <= 0)
            break;  // EOF or error
            
        // Guard against overflow (TECHNICAL DEBT: should be before grow)
        if (i > LONG_MAX - num)
            return -1;
            
        // Accumulate
        num += i;
    }
    
    return num;
}
```

This example shows complete structure documentation that would allow someone to:
- Understand the algorithm immediately
- Identify the loop invariants
- See the security properties
- Spot the technical debt
- Modify the code safely

---

**Remember**: Structure documentation is about understanding HOW the machine works, not just WHAT it does. Think like you're explaining to someone who needs to modify the algorithm or fix a bug - what would they need to know?
