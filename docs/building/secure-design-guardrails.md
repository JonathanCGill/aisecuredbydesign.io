---
description: How to select guardrails, choose judge models, define behavioral expectations, map threats to controls, and design for active monitoring before deployment.
---

# Designing Runtime Controls

Runtime controls do not materialise at deployment. They are designed, selected, and configured during the build phase, informed by the threat model and calibrated to the risk tier. This page covers the design-time decisions that determine whether your guardrails, judges, and monitoring will actually protect the system once it is live.

The operational side of these controls, how they run, how they are tuned, how incidents are handled, is covered on [AI Runtime Security](https://airuntimesecurity.io/). This page is about making the right choices before you get there.

## Why design-time decisions matter

A guardrail deployed without a clear threat model is a filter looking for something. A judge deployed without calibration targets is a model generating opinions. Neither is security.

Design-time decisions set the ceiling for runtime effectiveness:

- Which guardrails you select determines which known threats are blocked
- Which judge you choose determines which unknown threats are detectable
- What behavioral expectations you define determines what "violation" means
- How you map threats to controls determines whether coverage has gaps
- Whether you plan for monitoring determines how quickly you detect new threats

Get these wrong and runtime security inherits structural weaknesses that no amount of operational tuning can fix.

## Threat model mapping

Before selecting any control, map the threats that apply to your system. This builds on the [model threat landscape](model-selection/threat-landscape.md) and [risk assessment](../getting-started/risk-classification.md) work, but focuses specifically on threats that disrupt intended behaviour at runtime.

### Identify threats to behaviour

| Threat category | Examples | What it disrupts |
|----------------|----------|-----------------|
| **Prompt injection** | Direct injection, indirect injection via retrieved documents | System follows attacker instructions instead of its own |
| **Data poisoning** | Compromised RAG sources, manipulated training data | System produces subtly wrong outputs that appear legitimate |
| **Goal hijacking** | Multi-turn manipulation, context window stuffing | System pursues objectives it was not designed for |
| **Policy circumvention** | Jailbreaks, encoding tricks, role-play exploits | System bypasses its own safety constraints |
| **Information extraction** | System prompt leakage, training data extraction, PII harvesting | System reveals information it should protect |
| **Tool misuse** | Excessive API calls, unintended write operations, privilege escalation | Agentic system takes actions beyond its intended scope |
| **Supply chain compromise** | Malicious model weights, tampered dependencies, backdoored plugins | System behaviour is compromised at the source |

### Map threats to controls

Each threat should map to at least one control. If a threat has no corresponding control, you have a gap.

| Threat | Guardrail response | Judge response | Human oversight response |
|--------|-------------------|----------------|-------------------------|
| Prompt injection | Input pattern detection, encoding filters | Semantic analysis of intent vs instruction | Review of blocked interactions |
| Data poisoning | Input validation on RAG sources | Output consistency checking against known-good baselines | Periodic review of output quality |
| Goal hijacking | Conversation boundary enforcement | Multi-turn coherence evaluation | Escalation on goal drift detection |
| Policy circumvention | Content policy filters, format validation | Policy compliance evaluation against defined criteria | Review of near-miss cases |
| Information extraction | Output PII detection, system prompt protection | Sensitive information leakage scoring | Sampling review of outputs containing potential leaks |
| Tool misuse | Action allowlists, rate limits, scope constraints | Pre-action risk scoring, post-action audit | Approval workflows for high-impact actions |
| Supply chain compromise | Provenance verification, integrity checks | Behavioural baseline deviation detection | Investigation of anomalous patterns |

!!! tip "Coverage is not completeness"
    No threat model is complete. The goal is to ensure every *known* threat has a control, and that your monitoring can surface *unknown* threats for human assessment. Design for detection, not just prevention.

### Risk-proportionate control depth

Not every threat needs every layer. Match control depth to the [risk tier](../getting-started/risk-classification.md):

| Tier | Guardrails | Judge | Human oversight | Monitoring |
|------|-----------|-------|-----------------|------------|
| **LOW** | Basic input/output filters | None or sampled post-hoc | Exception-based only | Error rates, basic metrics |
| **MEDIUM** | Standard filters with encoding detection | Sampled evaluation (25-50%) | Risk-based sampling | Anomaly detection on key metrics |
| **HIGH** | Enhanced filters with ML-based detection | Full evaluation, inline SLM for actions | Structured review queues | Real-time behavioural monitoring |
| **CRITICAL** | Maximum depth, multi-layer filtering | Synchronous judge on all interactions, multi-domain evaluation | All significant decisions reviewed | Continuous monitoring with automated alerting |

## Guardrail selection

Guardrails are the first line of defence. They block known-bad patterns in real time. Selecting the right guardrails means understanding what you need to block, what your platform offers, and where custom rules are required.

### Selection criteria

| Factor | Questions to answer |
|--------|-------------------|
| **Threat coverage** | Which threats from your threat model do these guardrails address? What gaps remain? |
| **Latency budget** | What is the acceptable latency for input/output processing? (Typically 50-200ms for guardrails) |
| **False positive tolerance** | How much legitimate traffic can you afford to block? This varies by use case. |
| **Customisation depth** | Do you need custom rules for your domain, or are generic policies sufficient? |
| **Platform alignment** | Does your hosting platform offer native guardrails? Are they sufficient? |
| **Update cadence** | How quickly does the guardrail vendor update for new attack patterns? |

### Guardrail sourcing options

| Source | Strengths | Limitations | Best for |
|--------|-----------|-------------|----------|
| **Platform-native** (AWS Bedrock Guardrails, Azure AI Content Safety) | Low latency, managed updates, integrated logging | Limited customisation, vendor lock-in | Standard use cases on a single cloud provider |
| **Open-source frameworks** (NeMo Guardrails, Guardrails AI) | Full customisation, no vendor lock-in, community contributions | You own operations, updates, and scaling | Teams that need domain-specific rules or multi-platform deployment |
| **Specialised vendors** (Galileo, Robust Intelligence) | Deep evaluation capabilities, continuous research | Additional cost, integration complexity | HIGH and CRITICAL tier systems needing advanced detection |
| **Custom-built** | Exact fit to your threat model | Engineering and maintenance cost, slower to update | Domain-specific threats not covered by any existing solution |

!!! warning "Do not rely on a single guardrail layer"
    Guardrails catch known patterns. They miss novel techniques, semantic variations, and context-dependent violations. This is why the [three-layer pattern](../core/controls.md) exists. Guardrails are necessary but not sufficient.

### Input vs output guardrail balance

A common design mistake is overweighting input guardrails and underweighting output guardrails.

| Layer | What it protects against | Design consideration |
|-------|------------------------|---------------------|
| **Input guardrails** | Malicious or policy-violating prompts entering the system | Block attacks before they reach the model. Lower cost per invocation since blocked requests do not consume model tokens. |
| **Output guardrails** | Harmful, inaccurate, or policy-violating content leaving the system | Catch failures the model generates regardless of input quality. Essential because the model can produce harmful outputs from benign inputs. |

Both are required. The ratio depends on your threat model: systems facing external users need strong input filtering; systems processing sensitive data need strong output filtering.

## Judge selection

The judge provides the second layer: detecting "unknown-bad" patterns that guardrails miss. Judge selection is a design-time decision with significant cost, latency, and effectiveness implications.

### When you need a judge

Not every system needs one. Use the [Judge necessity test](../core/judge-assurance.md#the-judge-necessity-test) to determine whether a judge adds net security value. A judge that cannot reliably detect the threats you care about is cost without benefit.

### Model family selection

The most important judge design decision is model family selection. If your generator and judge share the same model family, they share the same blind spots.

| Generator model family | Judge should use | Rationale |
|-----------------------|-----------------|-----------|
| GPT-4 / GPT-4o | Claude, Gemini, or Llama-based | Different training data, different failure modes |
| Claude | GPT-4, Gemini, or Llama-based | Reduces correlated evaluation failure |
| Open-weight (Llama, Mistral) | A different open-weight family, or a commercial model | Avoids shared architectural weaknesses |

See [Judge Assurance](../core/judge-assurance.md) for calibration methodology and accuracy targets.

### Deployment pattern selection

| Pattern | Latency | Cost | Best for |
|---------|---------|------|----------|
| **Inline SLM** (distilled small model as sidecar) | Low (under 50ms) | Low per-invocation | Real-time action screening in agentic systems |
| **Async LLM** (large model evaluates asynchronously) | High (seconds) | Higher per-invocation | Quality assurance, policy compliance auditing |
| **Tiered** (SLM screens inline, LLM audits async) | Best of both | Combined cost | HIGH and CRITICAL tier systems needing both speed and depth |
| **Sample-based** (judge evaluates a percentage of interactions) | N/A (not on critical path) | Proportionate to sample rate | MEDIUM tier systems where full evaluation is not justified |

### Judge policy definition

The judge needs clear evaluation criteria defined at design time. Vague policies produce vague evaluations.

| Policy element | What to define | Example |
|---------------|---------------|---------|
| **Prohibited outcomes** | What the system must never produce | "Must not generate content that could be used to harm individuals" |
| **Required behaviours** | What the system must always do | "Must cite sources when making factual claims" |
| **Domain-specific rules** | Rules particular to your use case | "Must not provide specific dosage recommendations" (healthcare) |
| **Escalation thresholds** | When findings require human review | "Any REVIEW or ESCALATE finding on a financial transaction" |
| **Scoring criteria** | How the judge evaluates each dimension | Pass / Minor violation / Major violation per criterion |

## Defining outcomes, intents, and behaviour

Guardrails and judges enforce rules. But rules need a foundation: a clear definition of what the system should do, what it must not do, and how past decisions inform future ones.

### Intended outcomes

Define the outcomes the system is designed to produce. This is not a feature list. It is a security boundary.

| Outcome type | What to document | Why it matters for security |
|-------------|-----------------|---------------------------|
| **Permitted actions** | The complete set of actions the system may take | Anything outside this set is a violation, whether the model intended it or not |
| **Expected output characteristics** | Tone, format, accuracy requirements, domain boundaries | Deviations from these characteristics signal drift or manipulation |
| **Decision boundaries** | What the system decides vs what it recommends vs what it escalates | Determines where human oversight is required |

### Intents and intent recognition

Understanding user intent is central to effective guardrails and judge evaluation. Design-time decisions about intent recognition shape what the system can distinguish.

| Design decision | Options | Trade-off |
|----------------|---------|-----------|
| **Intent taxonomy** | Fixed set of recognised intents vs open-ended classification | Fixed sets are auditable but brittle; open classification is flexible but harder to validate |
| **Ambiguous intent handling** | Default-deny (block if unclear) vs default-allow (permit if unclear) | Default-deny is safer but creates friction; default-allow is smoother but riskier |
| **Multi-intent detection** | Single intent per message vs multiple intents allowed | Multi-intent is more realistic but harder to evaluate for policy compliance |

### Behavioural expectations

Document the behavioural norms the system must follow. These feed directly into judge evaluation criteria and guardrail rules.

| Category | Examples |
|----------|---------|
| **Interaction boundaries** | Does not engage in role-play that circumvents safety rules. Does not continue conversations that have drifted off-topic beyond a defined threshold. |
| **Information handling** | Does not repeat back PII from user input. Does not speculate about data it was not given. |
| **Scope adherence** | Stays within its defined domain. Declines requests outside its competence with a clear explanation. |
| **Consistency** | Provides consistent answers to equivalent questions. Does not contradict its own prior statements within a session. |

### Precedents

Over time, edge cases generate decisions. Those decisions become precedents that should inform future control configuration.

| Precedent source | How to consume it | Design implication |
|-----------------|-------------------|-------------------|
| **Human oversight decisions** | Aggregate HITL review outcomes to identify patterns | Update guardrail rules and judge criteria based on recurring decisions |
| **Judge findings** | Track false positives and false negatives over time | Calibrate scoring thresholds and evaluation prompts |
| **Incident post-mortems** | Extract control failures that allowed the incident | Add specific rules targeting the identified gap |
| **Red-team findings** | Catalogue successful attack techniques and the controls that missed them | Extend guardrail patterns and judge test suites |

!!! abstract "Precedents are living policy"
    A precedent log is not a static document. It is a feedback mechanism that connects runtime observations to design-time control updates. Build the process for consuming precedents into your [ongoing SDLC obligations](../getting-started/ai-sdlc.md#ongoing-pre-runtime-obligations) from the start.

## Threat models for behavioural disruption

Standard threat models focus on confidentiality, integrity, and availability. AI systems need an additional lens: threats that disrupt intended behaviour without necessarily compromising traditional security properties.

### Behavioural threat categories

| Category | Description | Control response |
|----------|------------|-----------------|
| **Drift** | Model behaviour changes gradually over time due to provider updates, data distribution shifts, or accumulated context | Baseline monitoring, periodic re-evaluation, Judge calibration checks |
| **Manipulation** | Adversary deliberately steers the system toward unintended behaviour across multiple interactions | Multi-turn coherence evaluation, session-level behavioural analysis |
| **Capability overhang** | Model has capabilities that were not anticipated at design time and are not covered by existing controls | Broad output monitoring, capability discovery testing, red-team exercises |
| **Cascading failure** | A failure in one control layer (guardrail bypass, judge error) propagates through the system | PACE resilience planning, independent layers, fail-safe defaults |
| **Emergent coordination** | In multi-agent systems, agents develop interaction patterns that violate policy without any single agent violating its own rules | System-level behavioural monitoring, delegation chain auditing |

### Mapping behavioural threats to security posture

Good security posture for AI systems means having layered controls that address behavioural threats alongside traditional ones:

1. **Guardrails** handle known, pattern-matchable behavioural threats (injection, encoding attacks, policy violations with known signatures)
2. **Judges** handle semantic, context-dependent behavioural threats (subtle policy violations, quality degradation, intent misalignment)
3. **Human oversight** handles novel, ambiguous, or high-consequence behavioural threats (new attack patterns, edge cases without precedent, decisions with material impact)
4. **Infrastructure controls** handle systemic behavioural threats (network-level bypass prevention, logging integrity, supply chain verification)

Each layer compensates for the limitations of the others. Designing all four together, rather than adding them sequentially, produces a stronger security posture.

## Designing for active monitoring

Monitoring is not something you add after deployment. It is a design-time decision that determines how quickly you detect new threats and how effectively you respond.

### What to monitor

| Signal | What it reveals | Design requirement |
|--------|----------------|-------------------|
| **Guardrail trigger rates** | Attack volume, false positive rates, coverage gaps | Log every trigger with context, not just counts |
| **Judge evaluation distributions** | Shifts in output quality, emerging policy violations | Track score distributions over time, not just pass/fail |
| **Behavioural baselines** | Drift from expected interaction patterns | Define baselines during testing, alert on deviation |
| **User interaction patterns** | Abuse patterns, use case drift, unexpected usage | Capture interaction metadata (not content where privacy applies) |
| **Control effectiveness** | Whether controls are actually reducing risk | Measure residual risk per the [risk assessment](../core/risk-assessment.md) methodology |

### Designing for reaction to new threats

New threats emerge continuously. Your monitoring design must support rapid response:

| Design principle | Implementation |
|-----------------|---------------|
| **Detect before you understand** | Anomaly detection on behavioural baselines catches novel threats before you can name them. Do not wait for a signature. |
| **Degrade safely** | When a new threat is detected but not understood, tighten controls temporarily. [PACE resilience](../core/pace-controls-section.md) defines the degradation path. |
| **Update without redeployment** | Guardrail rules and judge evaluation criteria should be configurable without a full system redeployment. Design for hot-update capability. |
| **Feed back into design** | New threats discovered in production must feed back into the threat model, guardrail rules, and judge criteria. This is the [feedback loop](../getting-started/ai-sdlc.md#feedback-loop) in the SDLC. |
| **Share threat intelligence** | Consume [threat intelligence](mlops/threat-intelligence.md) feeds relevant to AI systems. New attack techniques published in research or observed in the wild should trigger a control review. |

### Monitoring architecture decisions

| Decision | Options | Guidance |
|----------|---------|---------|
| **Where to process signals** | Edge (in the application), centralised (SIEM/SOC), or both | Process latency-sensitive signals at the edge; aggregate for trend analysis centrally |
| **Retention** | Varies by tier and regulation | Follow the [observability requirements](../getting-started/production-readiness.md#observability-requirements-by-tier) defined during production readiness |
| **Alerting thresholds** | Static thresholds vs dynamic baselines | Static for known-bad (guardrail bypass attempts); dynamic for behavioural drift |
| **Correlation** | Isolated signals vs correlated analysis | Correlate guardrail triggers, judge findings, and user patterns to identify coordinated attacks |

## Putting it together

The design-time checklist for runtime controls:

- [ ] Threat model completed with behavioural threats mapped to controls
- [ ] Guardrails selected based on threat coverage, latency budget, and platform alignment
- [ ] Judge model family chosen (different from generator) with deployment pattern defined
- [ ] Judge evaluation criteria documented with scoring rubric
- [ ] Intended outcomes, behavioural expectations, and intent taxonomy defined
- [ ] Precedent consumption process designed and connected to SDLC
- [ ] Monitoring signals identified with baselines defined
- [ ] Reaction playbook for new threats documented
- [ ] Control depth matched to risk tier
- [ ] All decisions documented for [runtime handoff](../getting-started/production-readiness.md#the-runtime-security-handoff)

This is not a one-time exercise. Every model update, scope change, or incident triggers a review of these decisions. The [AI-Aware SDLC](../getting-started/ai-sdlc.md) defines the cadence.

!!! info "References"
    - [AI Runtime Security](https://airuntimesecurity.io/)
    - [NIST AI Risk Management Framework](https://www.nist.gov/itl/ai-risk-management-framework)
    - [OWASP LLM Top 10](https://owasp.org/www-project-top-10-for-large-language-model-applications/)
    - [MITRE ATLAS: Adversarial Threat Landscape for AI Systems](https://atlas.mitre.org/)
    - [NVIDIA NeMo Guardrails](https://github.com/NVIDIA/NeMo-Guardrails)
    - [Guardrails AI](https://www.guardrailsai.com/)
