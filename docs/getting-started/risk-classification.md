---
description: Classify the risk tier of your AI system using a structured decision process. The tier drives control selection, testing requirements, and human oversight levels across pre-runtime and runtime security.
---

# Risk Classification

Risk tiers exist so that controls are proportionate to the harm an AI system could cause. The purpose is not to impose a uniform set of requirements. It is to help AI product owners quickly identify the controls they need and consciously deselect the ones they do not, based on the risk profile of each use case and the way their organisation works.

This classification framework is shared with [AI Runtime Security](https://airuntimesecurity.io/core/risk-tiers/). When you classify a system here during development, that same tier carries through to runtime. Pre-runtime controls (model selection, pipeline security, data governance) and runtime controls (guardrails, Judge evaluation, human oversight) operate from the same risk baseline.

## Tier definitions

### CRITICAL

**Direct, automated decisions affecting customers, finances, or safety.**

- Autonomous decision-making with real-world impact
- Financial transactions or credit decisions
- Health, safety, or legal implications
- Minimal human review before action

*Examples: credit approval, fraud blocking, medical triage, automated trading*

### HIGH

**Significant influence on decisions or access to sensitive data.**

- Recommendations typically followed
- Access to confidential customer data
- External-facing with brand impact
- Decisions affecting employment or access

*Examples: customer service with account access, HR screening, legal document analysis*

### MEDIUM

**Moderate impact, primarily internal, human review expected.**

- Internal users with domain expertise
- Output is input to human decision
- Limited sensitive data access
- Recoverable errors

*Examples: internal Q&A, document drafting, code generation with review*

### LOW

**Minimal impact, non-sensitive context.**

- Public information only
- No personal data access
- No decisions, just information
- Easy to verify or ignore

*Examples: public FAQ bot, content suggestions, general lookup*

## Classification decision tree

Use this decision tree to determine your system's risk tier. Follow the path that matches your AI system's characteristics.

![Risk Classification Decision Tree](../images/risk-classification-decision-tree.svg){ .arch-diagram }

The decision tree encodes a simple principle: **if any dimension suggests a higher tier, use it.** A system that is mostly LOW-risk but processes PII is not LOW-risk. A system that is mostly MEDIUM but makes autonomous decisions is not MEDIUM.

## Classification process

### Step 1: Score impact dimensions

Work through each dimension for the specific AI use case you are classifying.

| Dimension | Question |
|-----------|----------|
| **Decision authority** | Does the system make decisions, or does it inform human decisions? |
| **Reversibility** | Can errors be undone? At what cost? |
| **Data sensitivity** | Does it process PII? Financial data? Confidential information? |
| **Audience** | Internal experts or external customers? |
| **Scale** | How many people are affected by outputs? |
| **Regulatory** | Is this a regulated activity in your jurisdiction? |

### Step 2: Apply the highest tier

If any single dimension suggests a higher tier, use that tier. The highest-scoring dimension sets the floor.

| Scenario | Key factor | Tier |
|----------|-----------|------|
| Internal Q&A, no PII | Low stakes | **MEDIUM** |
| Internal Q&A, HR data access | Sensitive data | **HIGH** |
| Customer chat, public info | External but low stakes | **LOW** |
| Customer chat, sees accounts | Sensitive data | **HIGH** |
| Customer chat, takes actions | Actions + external | **CRITICAL** |

!!! warning "Internal does not mean low risk"
    An internal system with access to employee HR data, financial records, or trade secrets can be HIGH or CRITICAL. "Internal" reduces audience risk, not data sensitivity risk. Classify based on what the system can access and do, not just who uses it.

### Step 3: Document the classification

Record and get approval for the tier assignment. This is your audit trail and feeds into both pre-runtime control selection and runtime security configuration.

- Tier assigned
- Driving factors (which dimensions pushed the tier up)
- Mitigating controls selected
- Review date (annual minimum, or triggered by scope changes)

## Host application risk alignment

AI does not run in isolation. It runs inside an application, on infrastructure, serving a user base. The risk profile of the host application sets a floor for the AI component's risk tier.

**The AI tier cannot be lower than the application it serves.**

If your application is internet-facing, the AI component is internet-facing. If your application requires 99.99% uptime, the AI component must meet that same availability target. If your application processes financial data, the AI component inherits that data sensitivity classification.

| Host application characteristic | Impact on AI risk tier |
|--------------------------------|----------------------|
| **Internet-facing** | AI tier is at minimum MEDIUM, regardless of AI-specific factors |
| **High-availability requirement** | PACE resilience planning is mandatory; AI component must not be the weakest link in the availability chain |
| **Processes regulated data** | AI tier inherits the data classification; a LOW-risk AI feature in a CRITICAL application is not LOW-risk |
| **Part of critical business process** | Failure of the AI component disrupts the business process; tier reflects the business impact, not just the AI impact |
| **Multi-tenant** | Cross-tenant data isolation requirements apply to the AI component, including model context, embeddings, and cached responses |

!!! warning "A chatbot in a banking app is not a LOW-risk chatbot"
    Consider a simple FAQ chatbot that uses only public information and makes no decisions. In isolation, that might be LOW. But if it runs inside a banking application, it inherits the application's attack surface, regulatory obligations, and availability requirements. An attacker who compromises the chatbot may use it as a pivot point into the broader application. The chatbot's tier must reflect this context.

When scoring [impact dimensions](#step-1-score-impact-dimensions), include the host application's characteristics alongside the AI-specific factors. The highest tier across both the AI assessment and the application context wins.

## What the tier means for pre-runtime security

The tier you assign here drives decisions across every section of this site.

| Pre-runtime area | How the tier affects it |
|-------------------|----------------------|
| **[Model selection](../building/model-selection/README.md)** | Higher tiers require stricter provenance verification, more thorough vulnerability scanning, and documented risk assessment |
| **[Platform selection](../building/platform-selection/README.md)** | Higher tiers constrain platform choices based on data residency, isolation requirements, and compliance needs |
| **[DevOps](../building/devops/README.md)** | Higher tiers require stronger pipeline integrity controls, more rigorous secrets management, and tested resilience plans |
| **[MLOps](../building/mlops/README.md)** | Higher tiers require stricter data governance, more validation gates, and formal model lifecycle management |
| **[Adversarial testing](adversarial-testing.md)** | Testing cadence and depth scale directly with tier, from basic validation to continuous red-teaming |
| **[Production readiness](production-readiness.md)** | Higher tiers require more deployment gates, broader observability, and more formal handoff to runtime security |

## What the tier means for runtime security

The same tier drives runtime control intensity. This is configured and operated by [AI Runtime Security](https://airuntimesecurity.io/core/risk-tiers/), but the decisions are made here during development.

### Input guardrails

| Control | LOW | MEDIUM | HIGH | CRITICAL |
|---------|-----|--------|------|----------|
| **Injection detection** | Basic | Standard | Enhanced + ML | Multi-layer |
| **PII detection** | - | Warn | Block | Block + alert |
| **Content policy** | Basic | Standard | Strict | Maximum |
| **Rate limiting** | Standard | Standard | Strict | Strict + anomaly |

### Output guardrails

| Control | LOW | MEDIUM | HIGH | CRITICAL |
|---------|-----|--------|------|----------|
| **Content filtering** | Basic | Standard | Enhanced | Maximum |
| **PII in output** | Warn | Block | Block + alert | Block + alert + log |
| **Grounding check** | - | Basic | Required | Required + citation |
| **Confidence threshold** | - | - | Required | Required + escalation |

### Judge evaluation

| Aspect | LOW | MEDIUM | HIGH | CRITICAL |
|--------|-----|--------|------|----------|
| **Coverage** | 1-5% (optional) | 5-10% | 20-50% | 100% |
| **Timing** | - | Batch (daily) | Near real-time | Real-time |
| **Depth** | - | Basic quality | Full policy | Full + reasoning |
| **Escalation** | - | Weekly | Same-day | Immediate |

!!! abstract "Guardrails prevent. Judge detects. Humans decide."
    "Real-time" Judge evaluation for CRITICAL tier means near-real-time parallel assessment. The Judge evaluates alongside or immediately after delivery. It does not mean inline blocking, which is the Guardrail's role.

### Human oversight

| Aspect | LOW | MEDIUM | HIGH | CRITICAL |
|--------|-----|--------|------|----------|
| **Review trigger** | Exceptions | Sampling + flags | All flags | All significant |
| **Review SLA** | 72h | 24h | 4h | 1h |
| **Reviewer** | General | Domain knowledge | Expert | Senior + expert |
| **Approval required** | - | - | High-impact | All external |

### Logging

| Aspect | LOW | MEDIUM | HIGH | CRITICAL |
|--------|-----|--------|------|----------|
| **Content** | Metadata | Full | Full + context | Full + reasoning |
| **Retention** | 90 days | 1 year | 3 years | 7 years |
| **Protection** | Standard | Standard | Enhanced | Immutable |

## Simplified tier mapping

Some operational contexts use a simplified three-tier system. This is intentional: the three-tier system is a practical shorthand where the distinction between LOW and MEDIUM or HIGH and CRITICAL is less material than the distinction between internal, customer-facing, and regulated.

| Simplified tier | Named risk tiers | Description |
|----------------|-----------------|-------------|
| **Tier 1** (Low) | LOW, MEDIUM | Internal users, no regulated decisions, recoverable errors |
| **Tier 2** (Medium) | HIGH | Customer-facing, sensitive data access, human reviews before delivery |
| **Tier 3** (High) | CRITICAL | Regulated decisions, autonomous agents with write access, financial/medical/legal |

!!! info "MASO uses Tier 1/2/3 for a different purpose"
    The [MASO Framework](https://airuntimesecurity.io/core/) (Multi-Agent Security Operations) also uses Tier 1/2/3, but for multi-agent autonomy levels: Supervised, Managed, and Autonomous. This is a separate dimension from risk classification. A CRITICAL-risk system might operate at MASO Tier 1 (Supervised) while building confidence, then progress to Tier 2 (Managed) as controls mature.

## Single agent vs. multi-agent: choosing the right framework

Your system's architecture determines which security framework applies.

### Single agent systems

Most AI deployments are single agent: one model, one set of tools, one execution context. These systems use the Foundation Framework (80+ controls) from [AI Runtime Security](https://airuntimesecurity.io/core/). Pre-runtime security decisions are straightforward. You select one model, configure one set of guardrails, and validate one pipeline.

**Pre-runtime considerations for single agents:**

- Model selection is a single decision with clear accountability
- Pipeline security covers one deployment path
- Testing scope is bounded to one model's behaviour
- PACE resilience planning covers one set of components

### Multi-agent systems (MASO)

When your system involves multiple AI agents coordinating, delegating, or orchestrating, the attack surface expands significantly. The [MASO Framework](https://airuntimesecurity.io/core/) (128 controls) extends the Foundation Framework with controls specific to agent coordination, delegation, and autonomy management.

**Pre-runtime considerations for multi-agent systems:**

- Each agent needs independent risk classification (an orchestrator agent may be CRITICAL while a lookup agent is LOW)
- Inter-agent communication channels need integrity controls
- Delegation boundaries must be defined and enforced before deployment
- Testing must cover agent interaction patterns, not just individual agent behaviour
- The overall system risk tier is driven by the highest-risk agent in the chain

### MASO autonomy levels

Multi-agent systems progress through autonomy levels as operational confidence grows.

| MASO tier | Autonomy level | Description | Pre-runtime requirements |
|-----------|---------------|-------------|------------------------|
| **Tier 1** | Supervised | Human approval required for significant actions | Full testing, conservative guardrails, detailed logging |
| **Tier 2** | Managed | Agents operate within defined boundaries, human review on escalation | Proven Tier 1 track record, expanded testing, calibrated boundaries |
| **Tier 3** | Autonomous | Agents operate independently within policy, human oversight is exception-based | Extensive operational history, mature controls, continuous monitoring |

!!! warning "Start at Tier 1"
    Regardless of your risk classification, new multi-agent systems should start at MASO Tier 1 (Supervised) and graduate upward as controls mature and operational confidence builds. Autonomy is earned, not assumed.

## Tier changes

Risk classification is not permanent. Systems change, and their risk profile changes with them.

**Upgrade triggers** (tier goes up):

- Adding sensitive data access
- Adding action capability (read-only to read-write)
- Moving from internal to external users
- An incident revealing higher risk than anticipated

**Downgrade requirements** (tier goes down):

- Six or more months of stable operation at the current tier
- No significant incidents
- Reduced scope documented and verified
- Product owner decision, documented with explicit risk acceptance

## Your risk appetite

This framework provides structure. Your organisation provides context. Two organisations running the same model for the same purpose may legitimately arrive at different tier assignments. That is expected, not a failure of the framework.

Factors that shape your risk appetite:

- **Regulatory environment.** Jurisdictions with prescriptive AI regulation (like the EU AI Act) may constrain how low you can classify certain use cases. See [Regulatory Alignment](regulatory-alignment.md).
- **Industry norms.** Financial services, healthcare, and legal sectors typically operate at higher baseline tiers due to sector-specific regulation and the consequences of error.
- **Organisational maturity.** An organisation with mature security operations, incident response capability, and AI governance may accept risks that a less mature organisation should not.
- **Liability exposure.** Consider who bears the cost when the system fails. Higher liability exposure warrants higher tiers.

The key principle: **document your reasoning.** A defensible tier assignment is one where the rationale is recorded, the driving factors are identified, and the decision was made by someone with the authority to accept the associated risk.

!!! info "References"
    - [AI Runtime Security: Risk Tiers](https://airuntimesecurity.io/core/risk-tiers/)
    - [AI Runtime Security: MASO Framework](https://airuntimesecurity.io/core/)
    - [NIST AI Risk Management Framework](https://www.nist.gov/itl/ai-risk-management-framework)
    - [ISO/IEC 42001: AI Management System](https://www.iso.org/standard/81230.html)
    - [UK AI Security Institute: Frontier AI Trends Report (December 2025)](https://www.aisi.gov.uk/)
