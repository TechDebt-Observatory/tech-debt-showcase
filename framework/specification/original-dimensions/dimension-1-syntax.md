# Dimension 1: Syntax

## Purpose
Document the contract between the function and its callers.

## What to Document

### Function Signature
- Function name and purpose (one-line summary)
- Each parameter: name, type, meaning, valid ranges
- Return value: type, meaning, possible values
- Error conditions and codes

### Example Pattern

```c
/**
 * @brief Validates and parses DH parameters from ASN.1 format
 * 
 * @param ctx OpenSSL context for memory allocation [required, non-NULL]
 * @param in Input BIO containing ASN.1 encoded DH parameters [required]
 * @param informat Format of input: FORMAT_PEM or FORMAT_ASN1
 * @param out Output BIO for parsed parameters [optional, may be NULL]
 * 
 * @return 1 on success, 0 on parse error, -1 on memory allocation failure
 * 
 * @pre ctx must be initialized via SSL_CTX_new()
 * @post On success, DH parameters are loaded into ctx
 * @post On failure, no state changes occur
 */
int parse_dh_parameters(SSL_CTX *ctx, BIO *in, int informat, BIO *out);
```

## Doxygen Tags to Use

- `@brief` - One-line summary
- `@param` - Parameter documentation
- `@return` - Return value meaning
- `@pre` - Preconditions
- `@post` - Postconditions

## Common Mistakes to Avoid

- Don't just repeat the parameter name
- Don't omit error conditions  
- Don't forget to document NULL handling
- Don't skip valid range information
