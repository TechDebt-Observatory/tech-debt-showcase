# Frequently Asked Questions

## General Questions

### Q: Who are you?

Anonymous systems programmer with 40+ years experience.
Learned on IBM System/360, worked through every major evolution of systems programming.
Want focus on the work, not the person.

### Q: Why anonymous?

Technical merit should stand alone.
Want feedback on the analysis, not debates about credentials.
Satoshi Nakamoto proved anonymity works for technical projects.

### Q: What's your goal?

Show what's possible with AI-assisted code analysis.
Start conversation about systematic technical debt tracking in open source.
Maybe build something useful if there's interest.

### Q: Are you affiliated with OpenSSL/Anthropic/anyone?

No. Completely independent. No funding, no sponsors, no commercial interest.

---

## About the Analysis

### Q: How accurate is this?

This analysis had 0% false positives (all 12 findings validated). But:
- Only one file tested
- Manual validation by one person
- Your mileage may vary

Always validate independently.

### Q: Can AI really understand code?

AI doesn't "understand" like humans do, but it can:
- Pattern match against known issues
- Identify common vulnerabilities
- Suggest improvements based on training
- Generate useful documentation

It's a tool, not a replacement for human expertise.
Ask yourself this: What if AI finds just 20% of the code that causes 80% of real issues in seconds...

### Q: Why Claude vs GPT-4/Gemini/etc?

Started with Claude because:
- Long context window (200K tokens)
- Strong at code analysis
- Free tier available
- Good at explanations

Planning to test others. Want to help? See CONTRIBUTING.md

### Q: How much did this cost?

Analysis of one file:
- Via API: ~$0.05
- Via web: Free
- Time: ~2 minutes AI + 30 min validation

Full OpenSSL would be ~$142 via API.

---

## About Technical Debt

### Q: What is technical debt?

Code that works but has issues making it:
- Harder to maintain
- More likely to have bugs
- Risky for security
- Expensive to change

Like financial debt: not always bad, but should be tracked.

### Q: Is technical debt always bad?

No! Sometimes it's pragmatic:
- Ship faster, clean up later
- Prototype to test idea
- Legacy code that works

But should be:
- Conscious decision
- Documented
- Tracked
- Eventually addressed

### Q: Why focus on OpenSSL?

Because:
- Critical infrastructure
- Everyone cares about security
- History of issues (Heartbleed)
- Good test case
- C codebase (common)

Not picking on OpenSSL - they do great work under constraints.

---

## Using This Analysis

### Q: Can I use this for my project?

Yes! Methodology is open source. But:
- Validate findings yourself
- Don't blindly trust AI
- Consider your context
- Test any changes

See LICENSE.md and LIMITATIONS.md

### Q: Should I deploy based on this?

NO. This is:
- Research/educational
- Not professional audit
- Not security certification
- Not tested at scale

Always get professional review for critical decisions.

### Q: Can you analyze my code?

Currently proof of concept with one file. If this gets traction:
- Might expand to more projects
- Might build API
- Might allow submissions

Leave feedback about what you'd want.

### Q: How do I reproduce this?

See METHODOLOGY.md for exact steps:
1. Get source code
2. Use Claude.ai (free)
3. Paste exact prompt
4. Compare results
5. Validate findings

---

## About the Site

### Q: Why this format?

Wanted to show before/after transformation:
- Raw code → What's the challenge
- Analysis → What AI found
- Comments → What better docs look like
- Scale → What's possible

Story format more engaging than just publishing analysis.

### Q: Can I download the analysis?

Yes! Everything is on GitHub:
- Source code
- Prompts used
- Raw AI output
- Validation notes

See repository link on site.

### Q: Do you track users?

No. Only aggregate stats (page views, not individuals).
No cookies, no tracking pixels, no personal data.

### Q: How is this funded?

It's not. Personal project. No ads, no sponsors, no revenue.

If it grows might accept donations for hosting, but committed to staying non-commercial.

---

## Technical Questions

### Q: Did you cherry-pick the best result?

No. This was the first analysis. One shot. If there were false positives, would have disclosed them.

Showing reality, not marketing.

### Q: How did you validate findings?

Manual code review:
- Check line numbers
- Verify issue exists
- Assess severity
- Test if fix viable

30 minutes per file. See VALIDATION.md for details.

### Q: What if I find an error?

Please report it! Via contact form or GitHub issue.

Will:
- Investigate
- Correct if confirmed
- Update analysis
- Acknowledge reporter

Errors are learning opportunities.

### Q: Could this have false negatives?

Absolutely. AI will miss things:
- Subtle logic bugs
- Domain-specific issues
- Performance problems
- Design issues

This is why human review still essential.

---

## Future Plans

### Q: Will you analyze more files?

Based on feedback. If community finds this useful:
- Full OpenSSL codebase
- Other critical projects
- Weekly tracking
- Public dashboard

Gauging interest first.

### Q: Will you compare different AIs?

Yes! Planning to test:
- GPT-4 Turbo
- GPT-4o
- Gemini Pro 1.5
- Llama 3

Want to see which performs best at code analysis.

### Q: Can I contribute?

Absolutely! See CONTRIBUTING.md for:
- Testing with different AIs
- Validating findings
- Analyzing other projects
- Improving methodology

This is community effort.

### Q: Will this stay free?

Committed to:
- Free public access
- Open methodology
- No paywalls
- No data selling

May need donations for hosting if scales up, but analysis stays free.

---

## Concerns

### Q: Won't this make OpenSSL look bad?

Goal is to help, not hurt. Every project has technical debt. OpenSSL:
- Does critical work
- Has limited resources
- Makes pragmatic trade-offs
- Deserves support

If anything, this shows they need more funding/contributors.

### Q: Could attackers use this?

Everything found is already:
- In public source code
- Findable with other tools
- Already known to experts

Not revealing secrets. Just systematizing what's visible.

### Q: What about maintainer burnout?

Valid concern. That's why:
- Frame positively
- Focus on helping
- Recognize constraints
- Don't shame

Technical debt is normal. Acknowledging it helps justify resources.

---

## Contact

### Q: How do I reach you?

Contact form on website. Anonymous email forwarding.

Respond to:
- Bug reports
- Methodology questions
- Collaboration ideas
- Feedback

May be slow - one person project.

### Q: Will you reveal your identity?

No plans to. Anonymity allows:
- Focus on work
- Avoid credentials debate
- Honest analysis
- Protection from blowback

If project succeeds, proven anonymity works for technical contributions.

---

**Still have questions?** Use the contact form on the website.
