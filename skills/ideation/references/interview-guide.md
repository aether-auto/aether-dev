# Interview Guide — Adaptive Question Bank

60% of questions must be context-dependent (reference prior answers). Max 2 questions per round.

## 1. Question Bank by Stage

### Stage 1: Vision & Goals (Rounds 1-2)

| ID | Question | Targets | Notes |
|----|----------|---------|-------|
| Q1.1 | "Describe your app in 2-3 sentences. What problem does it solve and for whom?" | §1, §12 | Always first. Extract: user types (nouns), core actions (verbs), domain keywords. |
| Q1.2 | "If wildly successful in 6 months, what does that look like? What metrics?" | §2 | Triggers: revenue → payment branch; team usage → roles branch |
| Q1.3 | "What existing tools do people use today? What's broken about them?" | §1, §12 | Suggest 2-3 competitors if identifiable |
| Q1.4 | "Focused single-purpose tool or multi-feature platform?" | §12 | Options: "Focused (1-2)", "Small (3-5)", "Larger (6+)". Larger → more rounds. |

### Stage 2: Context & Users (Rounds 2-3)

| ID | Question | Targets | Notes |
|----|----------|---------|-------|
| Q2.1 | "Who are the different types of people who will use this?" | §3 | Suggest personas from Q1.1. 3+ types → Persona Deep-Dive |
| Q2.2 | "For {persona}: typical day? What triggers them to open this app?" | §3, §5 | Context-dependent on Q2.1 |
| Q2.3 | "Desktop, mobile, or both? How frequently?" | §9, §11 | Options: desktop/mobile/both/depends on user type |
| Q2.4 | "You mentioned {pain points}. If you could only solve ONE, which?" | §4, §12 | Context-dependent on Q1.1/Q1.3 |

### Stage 3: Core Features (Rounds 3-5)

| ID | Question | Targets | Notes |
|----|----------|---------|-------|
| Q3.1 | "Walk me through the most important thing a user does, step by step." | §4, §5 | Narrative. Extracts: data entities, screens. |
| Q3.2 | "What are the main 'things' in your app?" | §6 | Context-dependent: suggest entities from Q3.1 |
| Q3.3 | "Beyond the core workflow, what other actions matter?" | §4, §7 | Options: CRUD, sharing, search, notifications, export |
| Q3.4 | "What happens when {context-specific error scenario}?" | §4, §7 | Context-dependent on Q3.1 |
| Q3.5 | "Of {features discussed}, which are essential for launch vs. v2?" | §12 | Context-dependent: list features from prior answers |

### Stage 4: Technical Constraints (Rounds 5-6)

| ID | Question | Targets | Notes |
|----|----------|---------|-------|
| Q4.1 | "Any tech stack preferences or constraints?" | §10 | Options: "Next.js+PG", "React+Node+Mongo", "No preference" |
| Q4.2 | "How should users log in? Different permissions by type?" | §8 | Options: email/pw, social, magic link, SSO |
| Q4.3 | "External services needed? Payment, email, storage, APIs?" | §7, §10 | 2+ integrations → Integration Deep-Dive |
| Q4.4 | "How many users initially? Growth target?" | §9 | Options: <100, 100-1K, 1K-10K, 10K+ |

### Stage 5: Validation (Final Round)

| ID | Question | Targets | Notes |
|----|----------|---------|-------|
| Q5.1 | "Here's what I understand: {summary}. Accurate? Anything missed?" | All | Full summary from prior answers |
| Q5.2 | "How should it feel visually? More like {A} or {B}?" | §11 | Context-appropriate comparisons |
| Q5.3 | "Anything else important we haven't discussed?" | §12, §13 | Options: "Covered everything", "One more thing..." |

## 2. Adaptive Branching Rules

| Signal | Branch | Insert After | Template |
|--------|--------|--------------|----------|
| 3+ user types | Persona Deep-Dive | Stage 2 | "For each type, what can they create/view/edit/delete?" |
| Real-time features | Architecture Probe | Stage 3 | "How quickly should user B see user A's changes? Simultaneous edits?" |
| Payment/sensitive data | Security & Compliance | Stage 3 | "What needs encryption? Compliance? Data deletion?" |
| 2+ integrations | Integration Deep-Dive | Stage 4 | "Data in, out, or both? Sync frequency? If unavailable?" |
| Complex data (5+ entities) | Data Model Deep-Dive | Stage 3 | "Relationships: 1-1, 1-N, N-M? On delete of parent, what happens?" |

## 3. Context-Dependent Templates

- **Personas:** "You said {persona} needs to {action}. Walk me through how they'd do that."
- **Pain Points:** "{workaround} fails because {reason}. How should the solution differ?"
- **Features:** "For {feature} — who uses it, {persona A} or {persona B}? How often?"
- **Data:** "{entity} has {properties}. Does {property} change after creation?"
- **Scope:** "{feature} is out of scope. Should the data model still accommodate it?"

## 4. Anti-Patterns

| Anti-Pattern | BAD | GOOD |
|-------------|-----|------|
| Leading | "Don't you think real-time would be great?" | "Does this need real-time, or is it single-user?" |
| Anchoring | "Most apps have 5-7 user types. How many?" | "Who are the different types of people using this?" |
| Solutioning | "We'll use WebSockets for notifications" | "When something important happens, how should the user find out?" |
| Multiple Qs | "Tech stack? Auth? File uploads?" | "Let's talk tech stack. Preferences?" |
| Assuming | "You'll need a shopping cart" | "Walk me through finding a product to purchasing" |

## 5. Example Sequences

**Simple (~4 rounds):** Vision+metrics → users+workflow → features+tech → summary+design. No branches.

**Complex (~7 rounds):** Vision+metrics → users+persona → Persona Deep-Dive → core workflow+real-time → Security/payment → integration+tech → summary+design. Branches: Persona, Architecture, Security.

## Exit Checklist

- [ ] ≥3 AskUserQuestion rounds
- [ ] All 5 stages touched
- [ ] ≥60% context-dependent questions
- [ ] ≤2 questions per round
- [ ] All branching signals detected and pursued
- [ ] Summary confirmed by user
