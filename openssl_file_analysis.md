# OpenSSL Repository File Size Analysis
**Date:** November 28, 2024  
**Repository:** ~/Projects/tech-debt-showcase/local-repos/openssl

---

## 📊 SUMMARY: Core Library Target (Recommended Scope)

### What We Excluded
- ✅ `apps/` - CLI tools (98 files, 4%)
- ✅ `test/` - Test harnesses (309 files, 13%)
- ✅ Assembly code (*/asm/*)
- ✅ Generated tables (*_table.c, *_dat.h, obj_mac.h)
- ✅ Files >200KB (monster auto-gen files)

### What Remains: **1,818 Core Library Files**

```
Mean:   10,488 bytes  (~2,622 tokens)
Median:  4,894 bytes  (~1,223 tokens)  ← Most files are TINY
P90:    25,638 bytes  (~6,409 tokens)
P95:    38,387 bytes  (~9,596 tokens)
P99:    82,329 bytes  (~20,582 tokens)
Max:   168,923 bytes  (~42,230 tokens)
```

### Distribution
```
86% Small    (<20KB / <5K tokens)   - 1,569 files  ← SINGLE-PASS TERRITORY
11% Medium   (20-60KB / 5-15K)      -   209 files  ← ADD CHECKPOINTS
 1% Large    (60-120KB / 15-30K)    -    30 files  ← MULTI-PASS CANDIDATE
 0.5% XL     (120-200KB / 30-50K)   -    10 files  ← SPECIAL HANDLING
```

---

## 🎯 Strategic Implications

### Your Current Approach is PERFECT for 97% of Files
- **Single-pass Phase 1 v6** handles files up to ~40KB (P95)
- **86% of files** are in your sweet spot (<5K tokens)
- **97% of files** fit in <15K tokens (comfortable single-pass range)

### The 10 "Problem Children" (120-200KB / 30-50K tokens)
```
168,923 bytes  ./ssl/t1_lib.c                    (TLS extensions - monster)
157,776 bytes  ./ssl/quic/quic_impl.c            (QUIC implementation)
153,694 bytes  ./ssl/statem/statem_srvr.c        (Server state machine)
147,076 bytes  ./crypto/ec/ec_curve.c            (Elliptic curve params)
145,278 bytes  ./ssl/quic/quic_channel.c         (QUIC channel)
141,020 bytes  ./ssl/s3_lib.c                    (SSLv3 compatibility)
140,499 bytes  ./ssl/statem/statem_clnt.c        (Client state machine)
136,816 bytes  ./crypto/evp/e_aes.c              (AES EVP wrapper)
135,507 bytes  ./crypto/x509/x509_vfy.c          (X.509 verification)
127,099 bytes  ./ssl/ssl_local.h                 (SSL internal header)
```

**Reality check:** These are protocol implementation files. They're:
- Well-commented already (OpenSSL standard)
- Complex by necessity (protocol state machines)
- Actively maintained (unlikely CVE goldmines)

**Recommendation:** Skip these 10 for Phase 1. Focus on mid-size files (20-60KB) where:
- Complexity is high enough to hide bugs
- Size is small enough for thorough documentation
- Maintenance is less active (legacy code)

---

## 💰 Cost Model for Phase 1 Documentation Bootcamp

### Scenario: Document 100 Core Library Files (Representative Sample)

**Distribution (based on actual percentages):**
- 86 small files (<20KB) @ $0.08 each = $6.88
- 11 medium files (20-60KB) @ $0.12 each = $1.32
- 3 large files (60-120KB) @ $0.20 each = $0.60

**Total Cost: ~$9 per 100 files**

**For 1,818 files:**
- All core library: ~$163 (single-pass only)
- With checkpoints for medium: ~$180
- Skip the 10 XL files: saves headaches, not much money

---

## 🔍 CVE Research Targets (High-Value Documentation)

### Where Bugs Hide (Your CVE Focus)
```
crypto/dh/dh_check.c           - Parameter validation  ✅ YOUR CVE
crypto/bn/bn_*.c               - Bignum arithmetic (off-by-one heaven)
crypto/rsa/rsa_oaep.c          - Padding oracle territory
ssl/statem/statem_*.c          - State machine confusion
ssl/ssl_lib.c                  - API misuse patterns
crypto/evp/evp_enc.c           - Encryption wrapper bugs
crypto/x509/x509_vfy.c         - Certificate validation
```

### What to Skip
```
crypto/aes/aes_core.c          - Proven algorithm implementation
crypto/sha/sha256.c            - Proven hash implementation
crypto/ec/ec_mult.c            - Math-heavy, well-audited
ssl/s3_lib.c                   - Legacy SSLv3 (deprecated anyway)
include/openssl/evp.h          - API header (just declarations)
```

---

## ✅ FINAL RECOMMENDATION

### Phase 1 Scope: 1,818 Core Library Files
**Exclude:**
- apps/ (CLI edge cases, not library bugs)
- test/ (test code, not production)
- 10 XL files >120KB (too complex, likely well-documented)

### Strategy by File Size
```
<20KB (86%):  Single-pass Sonnet 4.5           [Ship it]
20-60KB (11%): Single-pass + 2 checkpoints      [Week 2]
60-120KB (1%): Multi-pass OR manual review      [Future]
>120KB (10 files): SKIP or special handling     [Exclude]
```

### Next Steps
1. ✅ **Run 2,000-line litmus test** (ssl/statem/statem_clnt.c)
2. ✅ **Test Opus 4.5** on your 333-line dh_check.c (verify dictionary quality)
3. ✅ **Document 10 representative files** across size spectrum
4. ✅ **Measure quality degradation curve** (if any)
5. ✅ **Ship single-pass for 86% of files**
6. ⏭️ **Optimize for 11% medium files** (only if needed)

---

## 🎓 Key Insight

**You're not building for 10,000-line monoliths.**

**You're building for 1,223-token median files** (the actual OpenSSL codebase).

Your current Phase 1 v6 approach is **already optimized for the target distribution**.

The "scalability question" was premature optimization. The data shows:
- 97% of core library files fit comfortably in single-pass
- Quality issues at 333 lines suggest prompt tuning, not architecture overhaul
- Opus 4.5 might solve attention bias without any methodology changes

**Don't rebuild the architecture. Tune the prompt. Test Opus 4.5. Ship it.** 🚀
