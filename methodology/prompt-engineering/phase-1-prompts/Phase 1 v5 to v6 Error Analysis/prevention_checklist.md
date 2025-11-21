# PREVENTION STRATEGY: Preserving Original Comments in Documentation

## ROOT CAUSE ANALYSIS
**What went wrong:** I modified/expanded existing comments instead of preserving them exactly
**Why it happened:** 
- Didn't verify comment preservation before starting
- No automated check for comment modifications
- No systematic process for identifying existing comments
- Treated "add documentation" as "improve all text" rather than "add new text only"

## PREVENTION CHECKLIST - USE BEFORE EVERY DOCUMENTATION TASK

### Phase 1: Pre-Documentation Analysis (MANDATORY)
```bash
# 1. Extract all existing comments from source file
grep -n "^\s*/\*" original_file.c > existing_comments.txt
grep -n "^\s*\*" original_file.c >> existing_comments.txt  
grep -n "^\s*\*/" original_file.c >> existing_comments.txt

# 2. Count total comment lines
COMMENT_COUNT=$(wc -l < existing_comments.txt)
echo "Original file has $COMMENT_COUNT comment lines to preserve"

# 3. Create checksum of all comment text
grep -o "/\*.*\*/" original_file.c | sort | md5sum > original_comments.md5
```

### Phase 2: Documentation Rules (ENFORCE)
- [ ] **Rule 1:** Read ENTIRE prompt including "EXISTING COMMENT HANDLING" section
- [ ] **Rule 2:** Mark all existing comments in source with ```[PRESERVE EXACTLY]``` tags in your working notes
- [ ] **Rule 3:** Add NEW documentation ONLY in these locations:
  - BEFORE functions (Doxygen headers)
  - BEFORE file (file header) 
  - In blank lines or after code with NO existing comments
- [ ] **Rule 4:** NEVER modify text inside ```/* */``` or ```/** */``` that already exists

### Phase 3: Post-Documentation Validation (MANDATORY)

```bash
# 1. Extract comments from documented version
grep -n "^\s*/\*" documented_file.c > new_comments.txt
grep -n "^\s*\*" documented_file.c >> new_comments.txt
grep -n "^\s*\*/" documented_file.c >> new_comments.txt

# 2. Verify original comments still present
grep -o "/\*.*\*/" documented_file.c | sort | md5sum > new_comments.md5

# 3. Check if original comments were preserved
if ! diff original_comments.md5 new_comments.md5; then
    echo "ERROR: Original comments were modified!"
    echo "ROLLBACK and try again"
    exit 1
fi

# 4. Visual inspection of a sample function
echo "Checking dh_test() function for comment preservation..."
sed -n '/^static int dh_test/,/^}/p' original_file.c > original_func.c
sed -n '/^static int dh_test/,/^}/p' documented_file.c > documented_func.c
diff -u original_func.c documented_func.c | grep "^-" | grep "/\*"
# Should show NO removed comments (only additions with +)
```

### Phase 4: Diff Review Process
```bash
# Show ONLY the added lines (not removed)
diff -u original_file.c documented_file.c | grep "^+"  | less

# Verify no original comments appear in removed lines
diff -u original_file.c documented_file.c | grep "^-" | grep "/\*"
# This should return EMPTY (no matches)
```

## AUTOMATED VALIDATION SCRIPT

```bash
#!/bin/bash
# save as: validate_comment_preservation.sh

ORIGINAL=$1
DOCUMENTED=$2

if [ ! -f "$ORIGINAL" ] || [ ! -f "$DOCUMENTED" ]; then
    echo "Usage: $0 original.c documented.c"
    exit 1
fi

echo "Validating comment preservation..."

# Extract original comment content (not line numbers, just content)
grep -oP '/\*.*?\*/' "$ORIGINAL" | sort > /tmp/orig_comments.txt
grep -oP '/\*.*?\*/' "$DOCUMENTED" | sort > /tmp/new_comments.txt

# Check if all original comments exist in new file
while IFS= read -r comment; do
    if ! grep -qF "$comment" /tmp/new_comments.txt; then
        echo "ERROR: Original comment missing or modified:"
        echo "$comment"
        exit 1
    fi
done < /tmp/orig_comments.txt

echo "✓ All original comments preserved"

# Check for removed comment lines
REMOVED_COMMENTS=$(diff -u "$ORIGINAL" "$DOCUMENTED" | grep "^-" | grep -c "/\*" || true)
if [ "$REMOVED_COMMENTS" -gt 0 ]; then
    echo "ERROR: $REMOVED_COMMENTS original comment lines were removed"
    diff -u "$ORIGINAL" "$DOCUMENTED" | grep "^-" | grep "/\*"
    exit 1
fi

echo "✓ No comments were removed"
echo "SUCCESS: Comment preservation validated"
```

## WORKFLOW CHANGES

### OLD (WRONG) WORKFLOW:
1. Read source code
2. Start documenting from top to bottom
3. "Improve" comments as I go
4. Submit without validation ❌

### NEW (CORRECT) WORKFLOW:
1. **Extract & catalog** all existing comments
2. **Mark locations** where NEW comments can be added
3. **Add documentation** ONLY in marked locations  
4. **Validate** using automated script
5. **Manual review** of diff showing only additions
6. Submit with confidence ✓

## RED FLAGS TO WATCH FOR

### During Documentation:
- [ ] Am I modifying text inside existing ```/* */```? → STOP
- [ ] Am I "fixing" an existing comment? → STOP, use @warning instead
- [ ] Am I removing any lines that contain ```/*```? → STOP
- [ ] Do I remember what the original comments said? → Re-check source

### During Review:
- [ ] Does diff show any ```-/* comment */``` lines? → ERROR
- [ ] Are there fewer comment lines in new version? → ERROR  
- [ ] Does checksum of comment text differ? → ERROR
- [ ] Can I account for every original comment location? → If NO, ERROR

## COMMITMENT TO USER

Going forward, I will:
1. **ALWAYS** run Phase 1 analysis before starting
2. **NEVER** modify existing comment text
3. **ALWAYS** validate with automated checks
4. **IMMEDIATELY** flag if original comments seem wrong (don't delete them)
5. **VERIFY** comment preservation before considering task complete

## TESTING THIS PREVENTION STRATEGY

Before applying to real files, test on this sample:

```c
/* Original comment */
int foo(void) {
    /* Important note */
    return 42;
}
```

**Correct documentation:**
```c
/**
 * @brief Returns the answer
 * @return Always returns 42
 */
/* Original comment */
int foo(void) {
    /* Important note */
    return 42;
}
```

**Incorrect documentation (what I did wrong):**
```c
/**
 * @brief Returns the answer
 */
/* Original comment - this was written in 1999 */  ← MODIFIED original
int foo(void) {
    /* Important note about the meaning of life and the universe */ ← EXPANDED original
    return 42;
}
```

## WHEN IN DOUBT

If you're uncertain whether a comment is original or should be modified:
1. **PRESERVE IT EXACTLY**
2. Add your clarification as a NEW comment with @note or @warning
3. Flag it for human review

**Remember:** It's better to over-preserve than to accidentally delete maintainer knowledge.
