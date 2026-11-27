---
description: "Glossary of AI security terms for the pre-runtime lifecycle, with direct anchor links to the canonical shared taxonomy on airuntimesecurity.io for concepts that span both sites."
---

# Glossary and Unified Taxonomy

Concepts like **PACE**, **MASO**, and **risk tiers** span both this site and [airuntimesecurity.io](https://airuntimesecurity.io/). To keep a single source of truth, the **canonical definitions of the shared runtime taxonomy live on airuntimesecurity.io** and this page links straight to them. Pre-runtime terms specific to Secure by Design are defined here.

!!! info "Why two glossaries, one source"
    Shared terms are defined once, on the runtime site, and linked by anchor. Where a term below points to `airuntimesecurity.io/glossary/#...`, that is the authoritative definition. This site only defines the pre-runtime terms it owns.

## Shared taxonomy (canonical on airuntimesecurity.io)

| Term | Definition |
|------|-----------|
| **PACE** | Primary, Alternate, Contingency, Emergency resilience model. → [canonical](https://airuntimesecurity.io/glossary/#pace) |
| **MASO** | Multi-Agent Security Operations. → [canonical](https://airuntimesecurity.io/glossary/#maso) |
| **ASO** | Agent Security Operations (single-system AIRS). → [canonical](https://airuntimesecurity.io/glossary/#aso) |
| **Risk tiers** | LOW / MEDIUM / HIGH / CRITICAL, and the simplified Tier 1/2/3 shorthand. → [canonical](https://airuntimesecurity.io/glossary/#risk-tiers) &middot; [this site's tiers](core/risk-tiers.md) |
| **Guardrails (Layer 01)** | Deterministic prevention. → [canonical](https://airuntimesecurity.io/glossary/#guardrails) |
| **Model-as-Judge (Layer 02)** | Probabilistic detection. → [canonical](https://airuntimesecurity.io/glossary/#model-as-judge) |
| **Human Oversight (Layer 03)** | Human decision on high-consequence actions. → [canonical](https://airuntimesecurity.io/glossary/#human-oversight) |
| **Circuit breaker** | Containment failsafe, maps to PACE Emergency. → [canonical](https://airuntimesecurity.io/glossary/#circuit-breaker) |
| **Objective Intent** | An agent's declared, checkable objective. → [canonical](https://airuntimesecurity.io/glossary/#objective-intent) |

## Pre-runtime taxonomy (canonical here)

### Secure by Design

AI security *before* deployment: model selection, platform selection, DevOps, MLOps, data security, and governance. This site decides *what* to enforce and builds the infrastructure that makes enforcement possible at runtime. Its runtime counterpart is [AI Runtime Security](https://airuntimesecurity.io/glossary/#ai-runtime-security-airs). The point at which the two meet is the [Control Handoff Matrix](infrastructure/handoff-matrix.md).

### AI-aware SDLC

The software development lifecycle adapted for AI systems: risk classification, threat modelling, secure design, adversarial testing, and production-readiness gates, in addition to the normal SDLC. See [AI-Aware SDLC](getting-started/ai-sdlc.md).

### Model provenance and integrity

Evidence of where a model came from and proof that its weights have not been tampered with: signed artefacts, hash verification, and a documented chain of custody before a model is allowed into a pipeline (SUP-01). See [Provenance and Integrity](building/model-selection/provenance-and-integrity.md).

### Model risk assessment

The structured evaluation of a model's suitability and risk before adoption, feeding the tier decision and the guardrail configuration it will need (SUP-02). See [Model Risk Assessment](building/model-selection/risk-assessment.md).

### Infrastructure controls (the 80)

The 80 technical controls that make behavioural security enforceable, across identity, logging, network, data, secrets, supply chain, incident response, and four agentic domains. This site mirrors them into the pre-runtime lifecycle; airuntimesecurity.io is authoritative for their definitions. See the [Infrastructure Controls](infrastructure/README.md) and the [machine-readable catalog](infrastructure/catalog/README.md).

### Control ID scheme

Every infrastructure control has a stable ID of the form `PREFIX-NN`:

| Prefix | Domain | Prefix | Domain |
|--------|--------|--------|--------|
| `IAM` | Identity & Access | `IR` | Incident Response |
| `LOG` | Logging & Observability | `TOOL` | Agentic - Tool Access |
| `NET` | Network & Segmentation | `SESS` | Agentic - Session & Scope |
| `DAT` | Data Protection | `DEL` | Agentic - Delegation Chains |
| `SEC` | Secrets & Credentials | `SAND` | Agentic - Sandbox Patterns |
| `SUP` | Supply Chain | | |

### AI-BOM

**AI Bill of Materials.** A maintained inventory of the models, datasets, tools, and dependencies a system uses, so coverage and provenance can be verified systematically (SUP-07). The AI analogue of a software SBOM.

### Lethal trifecta

The combination of **access to private data**, **exposure to untrusted content**, and **a way to communicate externally** in one AI system. With all three present, prompt injection can lead to data exfiltration. Term coined by Simon Willison. See [Injection-Resistant Design](core/injection-resistant-design.md#the-lethal-trifecta).

### Agents Rule of Two

A design rule from Meta: within one session, an agent should hold no more than two of untrusted input, sensitive access, and the ability to change state or communicate externally. Sessions needing all three require human approval. See [Injection-Resistant Design](core/injection-resistant-design.md#the-agents-rule-of-two).

### Dual LLM pattern

An isolation pattern where a privileged model holds tools but never reads untrusted content, and a quarantined model reads untrusted content but has no tools. See [Injection-Resistant Design](core/injection-resistant-design.md#design-patterns).

### Slopsquatting

Registering a package name that AI coding tools tend to hallucinate, so that developers who accept the suggestion install malicious code. See [AI-Assisted Development](building/devops/ai-assisted-development.md).

### Tool poisoning

Hiding instructions in a tool's description or schema, which the model reads but the user usually does not. A **rug pull** is the related attack where an approved tool's description changes after approval. See [Prompt and Configuration Management](building/devops/prompt-and-config-management.md#tool-definitions-poisoning-and-rug-pulls).

### Content provenance

Evidence attached to or embedded in generated content showing that it was AI-generated and by which system, using signed metadata (such as C2PA Content Credentials), watermarks, or fingerprints. Required for synthetic content under EU AI Act Article 50(2). See [Regulatory Alignment](getting-started/regulatory-alignment.md#transparency-obligations-and-content-provenance-article-50).

!!! info "References"
    - [Glossary and Unified Taxonomy (airuntimesecurity.io, canonical)](https://airuntimesecurity.io/glossary/)
    - [Risk Tiers](core/risk-tiers.md)
    - [Infrastructure Controls](infrastructure/README.md)
    - [Control Handoff Matrix](infrastructure/handoff-matrix.md)
    - [Machine-Readable Control Catalog](infrastructure/catalog/README.md)
