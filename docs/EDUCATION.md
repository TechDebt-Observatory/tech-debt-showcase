# Documentation-First Computer Science Education

> *"In the Navy, we didn't let anyone touch a Seahawk SH60B Helocopter until they could read every schematic, understand every system, and fix problems in a simulator. Why do we let developers touch production code without the same training?"*

---

## The Problem with CS Education

### What We Teach Now

**Current CS Curriculum (Typical 4-Year Program):**

| Year | Focus | Skills Learned |
|------|-------|----------------|
| 1 | Intro to Programming | Write Hello World, basic syntax |
| 2 | Data Structures & Algorithms | Implement trees, sort algorithms |
| 3 | Systems & Theory | OS concepts, compilers, databases |
| 4 | Senior Project | Build something new from scratch |

**What's Missing:**
- ❌ How to read large codebases
- ❌ How to understand existing systems
- ❌ How to document decisions
- ❌ How to work with legacy code
- ❌ How to maintain code long-term
- ❌ Why documentation matters
- ❌ How to reverse-engineer undocumented systems

**The Result:**
Graduates can build a React app but can't read the C code underneath. They can implement quicksort but can't understand a 10-year-old production codebase.

---

## The Military Training Model

### How We Trained Avionics Technicians

**Seahawk Helicopter Avionics Training (My Experience Simplified):**

**Phase 1: Fundamentals (12 weeks)**
- Electronics theory (circuits, signals, systems)
- Mathematics (the "why" behind the circuits)
- Reading technical documentation
- Schematic interpretation
- System interdependencies

**Phase 2: Mockup School (16 weeks)**
- **No touching real aircraft yet**
- Study complete system documentation
- Learn every component, every connection
- Understand failure modes
- Practice on simulators
- Fix problems using only documentation
- Write procedures for repairs
- Review each other's work

**Phase 3: On-Equipment Training (8 weeks)**
- Apply documentation skills to real aircraft
- Supervised maintenance
- Document everything you do
- Explain your reasoning
- Get signed off by senior techs

**Phase 4: Qualification (Ongoing)**
- Work under supervision
- Build confidence
- Eventually certify others
- Maintain documentation

**Total time before touching aircraft independently:** ~9 months

**Failure rate:** Low (because you understood before you acted)

**Cost of mistakes:** Lives on the line (so training was rigorous)

---

## Proposed CS Curriculum Addition

### CS 301: Code Archaeology & Documentation

**A mandatory junior-year course that teaches what the industry won't:**

---

### Course Structure (15-Week Semester)

#### **Module 1: Reading Before Writing (Weeks 1-4)**

**Week 1: The Problem**
- Lecture: The $50B documentation crisis
- Case studies: Knight Capital, Healthcare.gov, Heartbleed
- Reading: Industry research on technical debt costs
- Assignment: Survey 10 open source projects, rate documentation quality

**Week 2: How to Read Code**
- Lecture: Reading strategies (top-down, bottom-up, follow the data)
- Lab: Read 500 lines of well-documented code, quiz on functionality
- Tools: Source code browsers, debuggers, profilers
- Assignment: Map out architecture of small OSS project (1,000 lines)

**Week 3: Understanding System Architecture**
- Lecture: How systems are structured (layers, modules, interfaces)
- Guest speaker: Industry engineer on real-world architectures
- Lab: Trace a feature through multiple files/modules
- Assignment: Create architectural diagram from code

**Week 4: Reverse Engineering Undocumented Code**
- Lecture: Techniques for understanding code without docs
- Lab: Given undocumented 1,000-line program, figure out what it does
- Tools: Static analysis, dynamic tracing
- Assignment: Write "missing manual" for undocumented program

**Deliverable:** 10-page report documenting an undocumented system

---

#### **Module 2: Documentation Types & Standards (Weeks 5-7)**

**Week 5: Documentation Levels**
- File-level: Purpose, dependencies, public API
- Function-level: Parameters, return values, side effects, algorithm
- Inline: Why not what, edge cases, gotchas
- Architecture: System design, data flow, interfaces
- Lab: Analyze documentation at each level in Linux kernel

**Week 6: Industry Standards**
- Doxygen/JavaDoc style documentation
- MISRA C commenting standards
- SEI CERT secure coding annotations
- README, CHANGELOG, CONTRIBUTING files
- Lab: Document a module following each standard

**Week 7: The "Why" vs "What"**
- Lecture: Code shows WHAT and HOW, comments explain WHY
- Examples: Good vs bad comments
- Lab: Convert "what" comments to "why" comments
- Assignment: Take badly-commented code, improve comments

**Deliverable:** Fully documented module (500+ lines) with proper headers

---

#### **Module 3: Team Documentation Project (Weeks 8-11)**

**The Core Exercise (4 weeks):**

Students work in teams of 4, assigned a real OSS project module (2,000-5,000 lines).

**Week 8: Research Phase**
- Read the code thoroughly
- Study git history and PRs
- Interview maintainers (if possible)
- Map dependencies and data flow
- Document what you're learning

**Week 9: Documentation Phase**
- Add file-level headers
- Document all functions
- Add inline comments explaining "why"
- Create architectural documentation
- Write onboarding guide for the module

**Week 10: Validation Phase**
- Swap with another team
- Review their documentation
- Try to understand the code using only their docs
- Test their onboarding guide
- Provide feedback

**Week 11: Revision Phase**
- Incorporate feedback
- Fix documentation errors
- Improve clarity
- Submit to actual OSS project (optional but encouraged)
- Present to class

**Grading Criteria:**
- Accuracy (30%): Is the documentation correct?
- Completeness (25%): Did you document everything?
- Clarity (25%): Can someone else understand it?
- "Why" factor (20%): Do you explain WHY, not just WHAT?

**Deliverable:** Comprehensive documentation package for real OSS module

---

#### **Module 4: AI-Assisted Analysis (Weeks 12-13)**

**Week 12: Introduction to AI Code Analysis**
- Lecture: How AI can assist (not replace) documentation
- Tools: Claude, GPT-4, specialized code AI
- Lab: Use AI to analyze technical debt in a module
- Assignment: Validate AI findings (find false positives)

**Week 13: AI as Documentation Assistant**
- Lecture: Using AI to generate initial docs, then human review
- Lab: Generate docs with AI, critique and improve them
- Comparison: Human-only vs AI-assisted vs AI-only quality
- Assignment: Create workflow for AI-assisted documentation

**Deliverable:** Report on AI strengths/limitations in documentation

---

#### **Module 5: Legacy Code Maintenance (Week 14-15)**

**Week 14: Working with Legacy Systems**
- Lecture: Strategies for modifying code you don't fully understand
- Defensive documentation: Document before changing
- Safe refactoring with documentation
- Lab: Fix bug in undocumented legacy code, document your changes

**Week 15: Final Project Presentations**
- Each team presents their documented module
- Q&A from class (can they understand it?)
- Industry panel reviews documentation quality
- Best documentation wins recognition

**Final Exam: Code Reading Test**
- Given undocumented 500-line program
- 2 hours to understand and document it
- Graded on comprehension and documentation quality

---

### Prerequisites

**Required:**
- CS 201: Data Structures
- CS 202: Algorithms
- One systems course (OS or Networks)
- Ability to read C, C++, or Java

**Recommended:**
- Some industry internship experience
- Contribution to any open source project
- Familiarity with version control (Git)

---

### Learning Outcomes

By the end of this course, students will be able to:

1. **Read and comprehend** large codebases (10,000+ lines)
2. **Reverse-engineer** undocumented systems
3. **Document** code at all levels (file, function, inline, architecture)
4. **Explain "why"** not just "what" in comments
5. **Work in teams** to document complex systems
6. **Review and validate** others' documentation
7. **Use AI tools** to assist (not replace) documentation
8. **Apply industry standards** (Doxygen, MISRA, CERT)
9. **Communicate technical decisions** clearly
10. **Value documentation** as a first-class deliverable

---

## Extended Curriculum Options

### CS 401: Advanced Code Archaeology (Senior Year)

**For students who want to specialize:**

**Topics:**
- Security-critical code documentation
- Performance-critical systems documentation
- Cross-language systems (FFI, JNI)
- Documenting undocumented APIs
- Creating test suites from documentation
- Forensic code analysis (what went wrong?)

**Final Project:**
- 10-week project documenting a major OSS component (10,000+ lines)
- Submit documentation to project maintainers
- Public presentation of findings

---

### Graduate Seminar: Documentation Research

**For MS/PhD students:**

**Research Topics:**
- Automated documentation generation quality
- Measuring documentation effectiveness
- Documentation and code evolution
- AI in code comprehension
- Documentation debt in industry

**Deliverable:**
Conference or journal paper on documentation research

---

## Integration with Existing Curriculum

### How This Fits

**Current 4-Year CS Degree:**

```
Year 1: Programming Fundamentals
Year 2: Data Structures & Algorithms
Year 3: Systems + [CS 301: Documentation] ← NEW
Year 4: Senior Project + Electives
```

**Why Junior Year:**
- Students have enough coding experience
- Not yet in bad habits from internships
- Before senior project (apply immediately)
- Still have time to internalize

**Credit Hours:** 3 credits (standard course)

**Workload:** 9 hours/week (3 lecture + 6 lab/project)

---

## Assessment & Grading

### Grade Breakdown

| Component | Weight | Description |
|-----------|--------|-------------|
| Module 1 Assignments | 15% | Individual work |
| Module 2 Assignments | 15% | Documentation exercises |
| Team Project | 35% | Core group work |
| AI Analysis Report | 10% | Individual analysis |
| Final Exam | 15% | Code reading test |
| Participation | 10% | Code reviews, presentations |

### Rubric for Documentation Quality

**Accuracy (Does it match the code?)**
- A: 100% accurate, verified against code
- B: Mostly accurate, minor inconsistencies
- C: Some errors, needs revision
- D: Major errors, misleading
- F: Completely wrong

**Completeness (Did you document everything?)**
- A: Every file, function, complex section
- B: Most documented, minor gaps
- C: Half documented
- D: Bare minimum
- F: Severely incomplete

**Clarity (Can others understand it?)**
- A: Clear to junior developer
- B: Clear to peer
- C: Clear to expert only
- D: Confusing even to expert
- F: Incomprehensible

**"Why" Factor (Do you explain reasoning?)**
- A: Explains all design decisions
- B: Explains most decisions
- C: Explains some decisions
- D: Mostly "what" not "why"
- F: No explanation of reasoning

---

## Real-World Projects (Partner Programs)

### Industry Collaboration

**Partner with OSS projects needing documentation:**

**Tier 1: Critical Infrastructure**
- OpenSSL (cryptography)
- curl (data transfer)
- nginx (web serving)
- PostgreSQL (databases)

**Tier 2: Widely-Used Libraries**
- JSON parsers
- Image processing libraries
- Network protocols
- Compression algorithms

**Tier 3: Student-Appropriate**
- Smaller utilities (1,000-5,000 lines)
- Clear boundaries
- Active maintainers
- Welcoming to contributors

**Benefits for Projects:**
- Free documentation labor
- Fresh perspective
- Potential new contributors
- Community building

**Benefits for Students:**
- Real-world impact
- Portfolio material
- Open source contributions
- Industry connections

---

## Tools & Resources

### Required Tools

**Code Reading:**
- IDE with good navigation (VS Code, CLion, IntelliJ)
- Source code browser (ctags, cscope)
- Static analysis (cppcheck, clang-tidy)
- Debugger (gdb, lldb)

**Documentation:**
- Doxygen
- Markdown editors
- Diagram tools (draw.io, PlantUML)
- Version control (Git)

**AI Assistance:**
- Claude API access (or free tier)
- Alternative: GPT-4, Gemini
- GitHub Copilot (optional)

**Collaboration:**
- GitHub/GitLab
- Code review tools
- Project management (Trello, Jira)

### Course Materials

**Textbooks:**
1. *Code Reading* by Diomidis Spinellis
2. *Working Effectively with Legacy Code* by Michael Feathers
3. *The Art of Readable Code* by Boswell & Foucher
4. *Clean Code* by Robert Martin (with caveats about documentation)

**Papers:**
- Brooks: "The Mythical Man-Month"
- Parnas: "On the Criteria for Decomposing Systems"
- Research on documentation effectiveness (provided)

**Online Resources:**
- Linux Kernel documentation
- MISRA C guidelines
- SEI CERT coding standards
- OpenSSL developer docs

---

## Pilot Program Implementation

### Phase 1: Single University (Year 1)

**Setup:**
- Partner with one CS department
- Train 2-3 instructors
- Select 30 students (pilot cohort)
- Partner with 5 OSS projects

**Metrics:**
- Student satisfaction
- Documentation quality (external review)
- OSS project feedback
- Time to productivity in internships

**Cost:** ~$50K (instructor training, tools, admin)

### Phase 2: Expand (Year 2-3)

**Rollout:**
- 10 universities
- 300 students/year
- 50 OSS projects
- Industry partnerships

**Metrics:**
- Employment outcomes
- Employer satisfaction
- Contribution to OSS
- Documentation quality trends

**Cost:** ~$500K/year (grants, industry sponsorship)

### Phase 3: Standardization (Year 4-5)

**Goal:**
- Become standard CS curriculum
- ACM curriculum recommendation
- Industry hiring requirement
- Certification program

**Impact:**
- 10,000+ students/year
- Thousands of OSS projects documented
- Industry-wide culture shift

---

## Industry Integration

### Employer Benefits

**Companies that hire from this program get:**

✅ **Developers who can:**
- Read and understand existing code immediately
- Contribute to legacy systems day one
- Document their own work properly
- Ask the right questions
- Work with minimal supervision

✅ **Reduced costs:**
- Faster onboarding (weeks not months)
- Fewer bugs from misunderstanding
- Better knowledge transfer
- Lower turnover (people understand the system)

**Companies should:**
- Sponsor the curriculum
- Provide real codebases to document
- Offer internships to graduates
- Prioritize hiring from program

---

## Connection to Overall Goals

### How This Supports the Mission

**This curriculum directly addresses:**

1. **Documentation Crisis**
   - Trains next generation to value documentation
   - Creates documentation for critical OSS
   - Makes documentation a core skill, not afterthought

2. **30-Day Boot Camp**
   - Proves the model works in education
   - Companies can point to successful precedent
   - Students arrive pre-trained

3. **AI-Assisted Analysis**
   - Students learn to use AI tools properly
   - Understand AI limitations
   - Know when human judgment needed

4. **Culture Change**
   - Next generation expects documentation
   - Employers must provide documented code
   - Documentation becomes competitive advantage

5. **Economic Impact**
   - Graduates are more productive immediately
   - Companies save money on onboarding
   - Industry waste reduced systematically

---

## Measuring Success

### Key Performance Indicators

**Student Outcomes:**
- Time to first productive contribution in internship
- Employer satisfaction ratings
- Open source contributions
- Documentation portfolio quality

**Industry Impact:**
- Reduction in onboarding time
- Decrease in bugs from misunderstanding
- Improvement in code maintainability
- ROI for hiring from program

**Open Source Impact:**
- Number of projects documented
- Quality of documentation (external review)
- Maintainer satisfaction
- Adoption of documentation

**Long-term (5-10 years):**
- Industry documentation standards improve
- Technical debt decreases measurably
- Culture shift toward valuing documentation
- Fewer high-profile failures from undocumented code

---

## Getting Started

### For Universities

**Interested in piloting?**

1. Contact us via website
2. Review curriculum materials
3. Train instructors
4. Select student cohort
5. Partner with OSS projects
6. Launch pilot semester
7. Measure and iterate

**We provide:**
- Complete curriculum
- Training materials
- OSS project connections
- Assessment rubrics
- Best practices

### For Students

**Want this at your school?**

1. Share this with CS department
2. Gather student interest
3. Present to faculty
4. Cite industry demand
5. Offer to pilot

### For Employers

**Want to sponsor?**

1. Fund curriculum development
2. Provide codebases for study
3. Offer internships to graduates
4. Hire from program
5. Share success stories

---

## The Bottom Line

### Why This Works

**Military Model Applied to Code:**
- Simulators before real systems ✓
- Documentation before action ✓
- Understand before changing ✓
- Review before deployment ✓
- Training has consequences ✓

**The Avionics Tech to Software Engineer Pipeline:**

| Avionics Training | Software Training (Proposed) |
|-------------------|------------------------------|
| 12 weeks: Theory & fundamentals | Year 1-2: Programming fundamentals |
| 16 weeks: Mockup school | CS 301: Code archaeology |
| 8 weeks: Supervised work | Internship with documentation focus |
| Qualification: Certification | Graduation: Portfolio of documented code |
| Maintenance: Document everything | Career: Value documentation |

**Success Metrics:**
- Avionics techs: Near-zero failure rate on aircraft
- Software grads: Should be near-zero production bugs from misunderstanding

**The Standard:**
If you can't document it, you don't understand it.
If you don't understand it, you shouldn't change it.

---

## Call to Action

**This isn't just a course. It's a movement.**

We're proposing to:
- ✅ Fix CS education's biggest blind spot
- ✅ Train developers who can maintain, not just build
- ✅ Document critical infrastructure systematically
- ✅ Prove the 30-day boot camp model in education
- ✅ Change industry culture from the ground up

**The military figured this out decades ago.**

**It's time software caught up.**

---

**Interested in piloting this curriculum?**

Contact: [via website form]

**Want to support this initiative?**

- Sponsor curriculum development
- Provide codebases for students
- Hire graduates from program
- Share with your university

---

**Version:** 1.0  
**Author:** Anonymous Systems Programmer (ex-Navy Avionics Tech, System/360 era)  
**License:** CC BY 4.0  
**Status:** Open for pilot programs

---

*"We didn't let anyone touch a Seahawk until they could read every schematic. Why do we let developers touch production code without the same training?"*
