# 7-Dimensional Documentation Framework
## Understanding Code Through Governance Evidence Records (GER)

The 7D Framework offers a systematic approach to observing context about source code through **Governance Evidence Records (GERs)**—structured annotations embedded at Ground Zero that document how code operates across seven complementary dimensions.

### Ground Zero: Location and Definition

**Ground Zero** is the point in the source code where context matters most—inline with the code itself, not in external documents. It is the location where code and its dimensional understanding coexist. When a developer modifies a function, debugs an issue, or reviews a change, Ground Zero is where they encounter both the code and the understanding required to work with it safely. GERs embedded at Ground Zero remain synchronized with code because they change when code changes. External documentation—wikis, design docs, architecture diagrams—can be out-of-date minutes after code is modified. Ground Zero documentation cannot.

---

### The Documentation Synchronization Problem

In software development, understanding drifts from code. Traditional external documentation—Jira tickets, wiki pages, separate design documents—quickly falls out of sync with the live source. This creates immediate and expensive synchronization loss.

Organizations typically face a choice: continuously update external artifacts (which developers naturally resist), or accept the cost of documentation drift (higher bug rates, slower debugging, riskier modifications). The 7D Framework addresses this by embedding dimensional context directly into source code as Governance Evidence Records, keeping critical understanding at Ground Zero where changes occur.

### A Multi-Dimensional View

Code exists in seven observable dimensions. Each dimension answers a distinct category of questions that humans and AI systems need to answer when working with the code. The framework captures these systematically.

An astronomical analogy clarifies the concept: our eyes perceive the night sky as a 2D field of light. By adding unseen dimensions—redshift, distance, magnitude, direction—we gain profound insights into cosmic structure. Similarly, source code appears as 2D text, but dimensions like threat surface, mechanism, rationale, and evolution reveal structure that remains invisible otherwise.

***

### A Foundation, Not a Replacement

The 7D Framework does not replace all external documentation. Project management systems (Jira), high-level architecture documents, and user-facing API guides serve vital functions in organizational workflow.

Instead, the framework shifts the synchronization burden by making code-embedded context the **single source of truth** for low-level, critical understanding. External systems become consumers of this guaranteed inline context, ensuring consistency across the documentation ecosystem.

***

### Ground Zero: The Strategic Location

Documentation embedded directly into source code—at Ground Zero—provides unparalleled efficiency advantages:

* **Human maintainers** understand code faster and modify it with greater confidence, using code-intimate context as their primary reference
* **New developers** onboard more quickly with intent and design rationale immediately accessible
* **AI systems** receive the structured context they require for detailed analysis. Evidence suggests AI comprehension improves from ~50-60% to 85-95% when informed by dimensional context. Without this context, AI relies on syntactic pattern matching. With context, AI recognizes logical boundaries and organizational intent.
* **Auditors** gain instantly auditable records reflecting the current state of the codebase
* **Testing and validation** become more precise when algorithms, invariants, and design assumptions are explicitly documented

Ultimately, if a system cannot accurately understand code from GERs, neither can a new maintainer, junior developer, or the original author after a long absence. The 7D Framework functions as an objective test of code clarity.

***

## Philosophy

The 7D Framework recognizes that understanding code requires multiple, interlinked perspectives. Each dimension illuminates different aspects of how code operates:

| Dimension | Question | Focus |
|-----------|----------|-------|
| **GER-D1: Syntax** | WHAT does the code accept and return? | Interface contracts |
| **GER-D2: Relationships** | WHERE does it fit in the system? | Dependencies and threat surface |
| **GER-D3: Structure** | HOW does it accomplish its task? | Algorithms and flow |
| **GER-D4: Intent** | WHY does it exist and why this design? | Rationale and assumptions |
| **GER-D5: History** | WHEN and WHY did it evolve? | Patterns and lessons learned |
| **GER-D6: Quality & Telemetry** | WHAT'S WRONG and how do we observe it? | Debt, risks, and instrumentation |
| **GER-D7: Verification** | PROOF that it works as designed | Compliance and certification |

### Why This Order Matters

**D1-D5 form the core understanding layer.** They document what the code IS, how it connects to other systems, and how it evolved. Organizations typically discover these dimensions in this sequence:

- **D1 (Syntax)** comes first: you need to know the contract before anything else
- **D2 (Relationships)** comes early: understanding the threat surface—what the code touches and what touches it—determines its risk profile and modification impact
- **D3 (Structure)** follows: now you understand what the code connects to, so understanding how it works internally makes sense
- **D4 (Intent)** comes next: with mechanism understood, the rationale for design choices becomes meaningful
- **D5 (History)** completes the picture: patterns and lessons learned inform future modifications

**D6-D7 form the governance layer.** They document what's wrong and provide compliance proof. These dimensions are adopted when organizations require formal verification, audit trail documentation, or safety certification.

***

## What Are Governance Evidence Records?

**Governance Evidence Records (GERs)** are structured annotations embedded in source code that document dimensional context across all seven dimensions. All of GER-D1 through GER-D7 are captured as GERs—not just D6-D7. Unlike traditional comments (which explain code syntax), GERs systematically document the understanding required to comprehend, modify, and verify code.

GERs are:
- **Embedded at Ground Zero**: Inline with code, not in external documents
- **Dimensional**: Organized across all seven information dimensions (D1-D5 for understanding, D6-D7 for governance)
- **Structured**: Following consistent patterns for reliable parsing by humans and machines
- **Verifiable**: Amenable to automated validation and audit trail creation
- **Governance evidence**: Formal records suitable for compliance and certification frameworks

GERs differ from comments in scope and function. Comments typically explain syntax ("this loop counts to n"). GERs document understanding ("this is a threat surface; these are the invariants; this pattern appeared in three CVEs"). **All seven dimensions are documented as GERs**: GER-D1 (interface contracts), GER-D2 (threat surface and relationships), GER-D3 (algorithms and structure), GER-D4 (design intent and rationale), GER-D5 (history and patterns) form the core understanding layer. GER-D6 (technical debt and observability) and GER-D7 (compliance and certification) form the governance layer.

When organizations scale documentation from ad-hoc comments to systematic GERs across dimensions, comprehension typically improves 4-8x, and AI analysis accuracy increases from ~50% to 85-95%.

***

## The Seven Dimensions Defined

### Dimension 1: Syntax
**What the code accepts and returns**

Documents the exact contract between the function and its callers.

**Observable questions:**
- What parameters does it take?
- What does it return?
- What are valid input ranges?
- What error conditions are possible?
- What are preconditions?
- What are postconditions?

**GER-D1 content typically includes:**
- Function signatures with parameter meanings
- Return values and error codes
- Valid ranges and constraints
- Input validation requirements
- Pre/post conditions

**Example usage:**
"I'm calling this function—what do I need to provide and what will I get back?"

[See dimension-1-syntax.md (GER-D1 Specification) for complete specification]

---

### Dimension 2: Relationships
**Where the code fits in the system**

Documents the code's position within the larger system—what it depends on and what depends on it.

**Observable questions:**
- What does this code depend on?
- What depends on this code?
- What systems does it integrate with?
- Where is the threat surface?
- What data flows through it?
- What would break if this changed?

**GER-D2 content typically includes:**
- Dependencies (required and optional)
- Integration points and protocols
- Call graph and data flow
- Cross-system patterns
- Shared conventions
- Impact radius of changes

**Example usage:**
"If I change this, what else will break? What systems does this touch?"

[See dimension-2-relationships.md (GER-D2 Specification) for complete specification]

---

### Dimension 3: Structure
**How the code works internally**

Documents the internal mechanics and algorithms.

**Observable questions:**
- What algorithm does it implement?
- How does data flow through execution?
- What are the loop invariants?
- How is memory managed?
- What's the complexity?
- What are key decision points?

**GER-D3 content typically includes:**
- Algorithm descriptions and patterns
- Data flow (textual representation)
- Control flow logic
- Loop invariants and termination conditions
- Memory management strategies
- Complexity analysis (time/space)

**Example usage:**
"I need to modify this—how does it actually work internally?"

[See dimension-3-structure.md (GER-D3 Specification) for complete specification]

---

### Dimension 4: Intent
**Why the code exists and design decisions**

Documents the rationale and context behind code.

**Observable questions:**
- Why does this code exist?
- What problem does it solve?
- Why this approach over alternatives?
- What assumptions underlie the design?
- What are the security implications?
- What business logic is encoded?

**GER-D4 content typically includes:**
- Purpose and motivation
- Design rationale and alternatives considered
- Assumptions and constraints
- Business or system logic context
- Security considerations
- Trade-offs made

**Example usage:**
"Why was it done this way instead of the obvious alternative?"

[See dimension-4-intent.md (GER-D4 Specification) for complete specification]

---

### Dimension 5: History
**How and why the code evolved**

Documents the timeline of changes, bug patterns, and lessons learned.

**Observable questions:**
- When and why did this change?
- What bugs were found and fixed?
- What patterns recur across versions?
- What lessons emerged from failures?
- What attack patterns have been discovered?
- What deprecated approaches were replaced?

**GER-D5 content typically includes:**
- Evolution timeline with rationale
- Bug fixes linked to root cause
- CVE patterns and lessons
- Performance improvements with benchmarks
- API changes and migration notes
- Deprecated patterns and replacements
- Recurring issue patterns

**Example usage:**
"This looks unusual—what's the history? Have similar patterns caused problems before?"

[See dimension-5-history.md (GER-D5 Specification) for complete specification]

---

### GOVERNANCE LAYER BOUNDARY

The following dimensions address compliance, safety certification, and formal audit requirements. Organizations adopt these when they require formal verification, safety certification, or regulatory compliance documentation.

---

### Dimension 6: Quality, Technical Debt & Telemetry
**Known issues, improvement opportunities, and how to observe them**

Documents honest assessment of code health and instrumentation for runtime visibility.

**Observable questions:**
- What known issues exist in this code?
- What should be improved?
- What are the security risks?
- What are performance bottlenecks?
- How do we detect issues at runtime?
- What constraints limit modification?

**GER-D6 content typically includes:**
- Known bugs and workarounds
- Technical debt with priority assessment
- Performance bottlenecks with analysis
- Security concerns and threat models
- Refactoring opportunities and costs
- Logging points and metrics hooks
- Trace context and observability

**Example usage:**
"What issues exist? Should I be worried about this? How will we detect problems at runtime?"

[See dimension-6-quality.md (GER-D6 Specification) for complete specification]

---

### Dimension 7: Verification & Compliance
**Certification proof and system artifacts**

Documents the definitive, auditable record of compliance status and verification evidence.

**Observable questions:**
- What is the current certified verification level?
- Where are formal definitions of critical symbols and constants?
- What validation proof is linked to this code?
- What system configuration is required?
- What are the integrity checkpoints?
- What is the compliance status and attestation?

**GER-D7 content typically includes:**
- Verification/Safety Integrity Level
- Compliance certification ID
- Symbol and constant dictionary (Ground Zero definitions)
- Validation proof links (test reports, coverage)
- System configuration parameters
- Checkpoint metadata (time, hash, integrity)
- Attestation records and audit trail

**Example usage:**
"Where is the proof this code is safe and compliant?"

[See dimension-7-verification-compliance.md (GER-D7 Specification) for complete specification]

---

## Mapping the 7D Framework to IEEE 1012-2024

Organizations pursuing formal verification typically map the framework to IEEE Standard for Software Verification and Validation (IEEE Std 1012), particularly for safety-critical systems (Level 4):

| 7D Dimension | V&V Process Area (IEEE 1012) |
| :--- | :--- |
| **GER-D1: Syntax** | **Requirements V&V** (Formal specification of I/O) |
| **GER-D2: Relationships** | **Interface V&V** and **Integration V&V** |
| **GER-D3: Structure** | **Design V&V** (Algorithm implementation) |
| **GER-D4: Intent** | **Requirements Traceability** (Design rationale) |
| **GER-D5: History** | **Anomaly Resolution V&V** (Root cause and patch rationale) |
| **GER-D6: Quality & Telemetry** | **Management V&V** and **Operational V&V** |
| **GER-D7: Verification** | **V&V Final Report** (Certification proof) |

---

## Adoption Patterns

### Understanding Code: Multi-Pass Approach

Organizations typically discover code understanding in multiple passes, adding dimensional context incrementally. This reflects observed adoption patterns rather than prescriptive requirements:

**Pass 1: Interface (GER-D1)**
1. Document function contracts
2. Define parameters and return values
3. Establish valid input ranges and error codes

**Pass 2: Threat Surface (GER-D2)**
4. Map dependencies and integrations
5. Identify what depends on this code
6. Document integration points

**Pass 3: Mechanism (GER-D3)**
7. Explain the algorithm
8. Describe data flow
9. Document loop invariants

**Pass 4: Rationale (GER-D4)**
10. Explain design choices
11. Document assumptions
12. Capture business logic

**Pass 5: Patterns (GER-D5)**
13. Document evolution history
14. Note bug patterns and lessons
15. Record recurring issues

**Pass 6: Quality & Observability (GER-D6)** - *When needed*
16. Identify technical debt
17. Document security concerns
18. Add telemetry documentation

**Pass 7: Compliance & Certification (GER-D7)** - *When required*
19. Establish verification level (IEEE 1012 or equivalent)
20. Create symbol/constant dictionary
21. Link validation proofs
22. Obtain compliance attestation

### For Legacy Code Documentation

1. **Read thoroughly**: Trace execution, understand algorithms, map dependencies
2. **Document GER-D1 through GER-D5 incrementally**: Start with Syntax, add Relationships, then Structure, Intent, History
3. **Assess code health (GER-D6)**: Document technical debt honestly when it becomes visible
4. **Formal verification (GER-D7)**: Only when compliance requirements exist

### For AI-Assisted Analysis

Organizations increasingly use AI systems to draft GERs, then validate for accuracy:

1. Provide code with existing context
2. Specify which dimensions are needed
3. AI generates dimensional documentation draft
4. Humans validate accuracy and add missing context
5. Iterate until complete
6. Review for hallucinations and technical accuracy

---

## Core vs. Governance Layer

**D1-D5 (Core Understanding Layer)** address how code operates. Most code comprehension, modification, and debugging occurs within these dimensions. Organizations typically adopt GER-D1 through GER-D5 incrementally to improve code understanding.

**D6-D7 (Governance Layer)** address compliance, audit trail, and formal verification. These dimensions are adopted when organizations require safety certification, regulatory compliance, or formal audit documentation.

**When D1-D5 is sufficient:**
- Internal projects without safety criticality
- Open source maintenance (community understanding)
- Feature development and debugging
- Code review and comprehension
- Onboarding and knowledge transfer

**When D6-D7 becomes necessary:**
- Safety-critical systems (automotive, medical, industrial)
- Regulated industries (finance, healthcare, aviation)
- Systems requiring audit trail documentation
- Compliance certifications (ISO, IEC, IEEE standards)
- Insurance or liability frameworks

---

## Scaling the Framework

Organizations adapt the framework based on their needs:

**For small teams:**
- Focus on GER-D1 through GER-D5 for critical files
- Document as code changes
- Use simple GER structure

**For safety-critical systems:**
- Implement full GER-D1 through GER-D7 with three-persona governance
- Establish formal verification processes
- Maintain audit trail documentation

**For compliance-heavy industries:**
- Map GER-D1 through GER-D7 to regulatory requirements
- Establish symbol dictionaries and Ground Zero definitions
- Create formal attestation records

**For AI-assisted analysis:**
- Use GER-D1 through GER-D5 as context input for AI systems
- Validate AI-generated documentation
- Iteratively improve dimensional coverage

---

## Benefits by Stakeholder

### For Maintainers
- Understand code in minutes rather than hours
- Know modification impact before changing
- Identify root causes more quickly
- Reduce cognitive load on complex code

### For New Developers
- Faster onboarding with code-embedded context
- Clear understanding of design rationale
- Known issues and constraints visible
- Integration points documented

### For AI Systems
- Improved vulnerability detection (evidence suggests 85-95% accuracy with context vs. 50-60% without)
- Fewer hallucinations when intent is explicit
- More accurate code analysis and refactoring suggestions
- Safer automation when constraints are documented

### For Security Auditors
- Complete context for security analysis
- Clear threat surface and dependency mapping
- Historical context of past issues and patterns
- Risk assessment informed by technical debt
- Formal compliance documentation (GER-D7)

### For Organizations
- Faster comprehension reduces maintenance cost
- Known issues systematically documented and tracked
- Improved security posture through systematic analysis
- Preserved institutional memory
- Formalized audit trail when needed (GER-D7)

---

## Framework Portability: Mapping to Functional Safety Standards

The 7D Framework maps to functional safety standards because it focuses on generating **certified artifacts** at Ground Zero, while standards focus on the **process** required to generate those artifacts.

### ISO 26262 (Automotive Functional Safety)

| 7D Dimension | ISO 26262 Part/Phase | Typical Artifact |
| :--- | :--- | :--- |
| **GER-D1: Syntax** | Part 6: Software Implementation | Software Unit Design Specification |
| **GER-D2: Relationships** | Part 6: Integration | Interface Specification |
| **GER-D3: Structure** | Part 6: Software Implementation | Detailed Design Specification |
| **GER-D4: Intent** | Part 4: System Design | Safety Requirements Traceability |
| **GER-D5: History** | Part 8: Supporting Processes | Change/Anomaly Records |
| **GER-D6: Quality & Telemetry** | Part 8: Management | Technical Debt Assessment |
| **GER-D7: Verification** | Part 6: Testing | V&V Report |

### IEC 61508 (Industrial Functional Safety)

| 7D Dimension | IEC 61508 Phase/Requirement | Typical Artifact |
| :--- | :--- | :--- |
| **GER-D1: Syntax** | Part 3: Software Requirements | Detailed Design |
| **GER-D2: Relationships** | Part 3: Integration | Interface Control Document |
| **GER-D3: Structure** | Part 3: Software Requirements | Implementation Detail |
| **GER-D4: Intent** | Part 1: Functional Safety Assessment | Safety Rationale |
| **GER-D5: History** | Part 1: Change Management | Modification Records |
| **GER-D6: Quality & Telemetry** | Part 1: Safety Management | Diagnostics and Monitoring |
| **GER-D7: Verification** | Part 3: Verification | Verification Report |

---

## Measurement and Observation

Organizations typically track dimensional coverage to understand code comprehension:

**Dimension 1 (Syntax):**
- % of functions with GER-D1 parameter documentation
- % of functions with GER-D1 return value documentation
- % of functions with GER-D1 pre/post conditions

**Dimension 2 (Relationships):**
- % of dependencies documented in GER-D2
- % of integration points identified in GER-D2
- % of data flows mapped in GER-D2

**Dimension 3 (Structure):**
- % of algorithms documented in GER-D3
- % of loop invariants recorded in GER-D3
- % of complex sections explained in GER-D3

**Dimension 4 (Intent):**
- % of design decisions documented in GER-D4
- % of assumptions stated in GER-D4
- % of security implications noted in GER-D4

**Dimension 5 (History):**
- % of significant changes documented in GER-D5
- % of bug fixes with root cause in GER-D5
- % of recurring patterns noted in GER-D5

**Dimension 6 (Quality & Telemetry):**
- % of known issues documented in GER-D6
- % of technical debt assessed in GER-D6
- % of critical logging points documented in GER-D6

**Dimension 7 (Verification & Compliance):**
- % of compliance artifacts linked in GER-D7
- % of critical symbols in Ground Zero Dictionary (GER-D7)
- % of code blocks with Compliance IDs (GER-D7)

### Comprehension Improvement Patterns

Evidence from organizations adopting the framework suggests:
- AI comprehension improves from ~50% to 85-95% with full GER-D1 through GER-D5 coverage
- Developer onboarding time reduces by 60-70% with GER-D1 through GER-D4 coverage
- Bug detection accuracy improves with GER-D2 through GER-D5 context
- Audit preparation time reduces by 40-60% with complete GER-D6 and GER-D7 coverage

---

## Common Observations

### ❌ Patterns that reduce effectiveness:

1. **Documenting syntax instead of intent** - Explain WHY, not WHAT the code does
2. **Neglecting relationship mapping (GER-D2)** - Threat surface determines risk profile
3. **Ignoring technical debt** - Document honestly without judgment
4. **Over-documenting trivial code** - Focus on complex, critical code
5. **Treating GERs as comments** - GERs are structured governance evidence
6. **Separation from code** - External documentation drifts out of sync
7. **Incomplete GER-D7 chain** - Break in audit trail reduces compliance value

### ✅ Patterns that increase effectiveness:

1. **Focus on intent** - Explain WHY decisions were made
2. **Map threat surface early (GER-D2)** - Understand impact before understanding mechanism
3. **Be specific about problems** - Document technical debt with context
4. **Think about multiple readers** - New devs, auditors, AI systems, maintainers
5. **Embed at Ground Zero** - Keep GERs with code
6. **Update with code changes** - Treat GERs as integral to modification
7. **Maintain audit trail completeness** - For GER-D7 value

---

## Implementation Patterns

### Greenfield Projects

Start with GER-D1 and GER-D2, add GER-D3 and GER-D4 as code stabilizes, add GER-D5 as patterns emerge. GER-D6 and GER-D7 only when compliance required.

### Existing Codebases

Begin with most critical or most-modified files. Document GER-D1 (interface), then GER-D2 (threat surface). Incrementally add GER-D3 through GER-D5 as understanding deepens.

### Legacy Systems

Read code thoroughly before writing documentation. Document as you understand each dimension. Focus on GER-D1 through GER-D5 for code comprehension; GER-D6 and GER-D7 only when audit/compliance requirements exist.

### AI-Assisted Documentation

Use AI to generate drafts across dimensions, then validate and refine. AI typically requires human context for GER-D4 (intent) and GER-D5 (history). AI improves when given existing GER-D1 through GER-D5 coverage to build from.

---

## Framework Development Attribution

> *"It's time for AI work to be used and acknowledged, not unlike giving attribution to OSS code when used."*

The 7D Framework evolved through collaborative human-AI analysis with transparent attribution.

### AI Contributors

**Kimi K2 (Moonshot AI):**
- Identified the need for verification dimension (GER-D7)
- Suggested three-persona governance model

**Gemini (Google):**
- Developed three-persona structure (Builder, Auditor, Economist)
- Contributed to Ground Zero principle refinement
- Technical debt assessment patterns

**Claude (Anthropic):**
- Resolved GER-D7 architectural clarity (Verification vs. Diagnostics)
- Validated IEEE 1012-2024 alignment
- Dimensional ordering analysis (GER-D2 before GER-D3)
- Terminology and structural refinement
- GER-D1 through GER-D7 notation system

### Human Direction

- Framework architecture and strategic decisions
- Dimensional ordering based on threat-first analysis
- GER terminology and governance positioning
- Integration and validation of AI contributions

### Development Approach

Multi-AI collaborative analysis with human-in-the-loop validation. This approach reflects the framework's own principles: AI systems identified gaps and proposed solutions, humans provided direction and validated results, multiple perspectives converged on refined understanding.

---

## Next Steps

### To Begin

1. **Select a file**: Pick one critical or frequently-modified file
2. **Document GER-D1**: Function contracts and interface
3. **Document GER-D2**: Dependencies and integration points
4. **Document GER-D3**: Internal algorithm and structure
5. **Measure improvement**: Compare before/after comprehension

### To Scale

1. **Incrementally add GER-D4 and GER-D5**: Intent and history follow as understanding deepens
2. **Train on GER structure**: Team learns dimensional approach
3. **Establish patterns**: Create standard GER formats
4. **Track metrics**: Monitor dimensional coverage

### When Compliance Needed

1. **Implement GER-D6 and GER-D7**: Add quality and verification dimensions
2. **Establish symbol dictionary**: Ground Zero definitions
3. **Create audit trail**: Link to validation proofs
4. **Obtain attestation**: Three-persona governance

---

## Summary

The 7D Framework transforms code documentation by systematically capturing understanding across seven dimensions as Governance Evidence Records. All dimensions (GER-D1 through GER-D7) are structured evidence records embedded at Ground Zero. Instead of treating documentation as separate from code, GERs embed dimensional context where it's needed most.

Organizations that adopt the framework incrementally (GER-D1 through GER-D5 for understanding, GER-D6 and GER-D7 for governance) typically observe:
- Faster code comprehension
- Improved AI analysis accuracy
- Better debugging and modification confidence
- Systematic technical debt management
- Auditable compliance records (when needed)

The result: code that can be understood, modified, and verified with greater confidence and less risk.

---

**Version**: 5.1  
**Last Updated**: 2025-12-13  
**Status**: Production framework  
**License**: CC BY 4.0

---

*"We can afford to build systems. We cannot afford to not understand them."*