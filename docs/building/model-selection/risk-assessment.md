---
description: Risk assessment for AI model selection, evaluating open-weight versus closed API models, fine-tuning risks, and use-case-specific security considerations.
---

# Risk Assessment

Model selection risk assessment evaluates whether a specific model is acceptable for a specific use case. This is not a generic exercise. A model that is perfectly acceptable for internal experimentation may be completely unacceptable for customer-facing production use.

## Risk dimensions

Every model carries risk across multiple dimensions. Assess each one for your specific context.

### Model origin risk

| Factor | Lower risk | Higher risk |
|--------|-----------|-------------|
| **Provider** | Established lab with security track record | Unknown publisher, community upload |
| **Training data** | Documented, curated, licensed | Undocumented, web-scraped, unknown |
| **Training process** | Reproducible, auditable | Opaque, no documentation |
| **Distribution** | Official channels, signed artefacts | Mirrors, unsigned, reshared |

### Deployment context risk

The same model has different risk profiles depending on how it will be used.

| Use case | Risk factors to assess |
|----------|----------------------|
| **Internal tool** | Data leakage, employee misuse, integration with internal systems |
| **Customer-facing** | Output quality, bias, regulatory compliance, reputational risk |
| **Decision support** | Accuracy, fairness, explainability, human oversight requirements |
| **Autonomous action** | All of the above, plus: scope of action, reversibility, blast radius |

### Open-weight vs. closed API

This is not a binary security decision. Both models have distinct risk profiles.

**Open-weight models** (Llama, Mistral, Gemma, etc.)

- You can inspect, modify, and host the model yourself
- You bear full responsibility for security, patching, and infrastructure
- Supply chain risk at download time (provenance verification is critical)
- No data leaves your environment during inference
- You must manage compute, scaling, and availability
- Fine-tuning is fully under your control

**Closed API models** (GPT-4, Claude, Gemini, etc.)

- Provider manages model security and infrastructure
- Data is sent to a third party for processing (data residency, privacy implications)
- You depend on the provider's security posture
- No visibility into model weights or training data
- Provider may update the model without your knowledge or consent
- Rate limiting and availability are outside your control

!!! abstract "Neither is inherently more secure"
    Open-weight models give you more control but more responsibility. Closed API models give you less responsibility but less control. The right choice depends on your threat model, compliance requirements, data sensitivity, and operational capability.

### Fine-tuning risk

Fine-tuning a model introduces new risks on top of the base model's risk profile.

**Data risks:**

- Training data may contain PII, proprietary information, or copyrighted content
- Poisoned fine-tuning data can introduce backdoors
- Small, targeted datasets can override base model safety training

**Process risks:**

- Fine-tuning without safety evaluation can degrade base model guardrails
- Hyperparameter choices affect model behaviour in non-obvious ways
- The resulting model inherits base model vulnerabilities plus any new ones

**Operational risks:**

- Fine-tuned models need separate versioning and lifecycle management
- Rollback requires maintaining previous model versions
- Each fine-tuning run produces a distinct model that needs independent validation

## Conducting a model risk assessment

### Step 1: Define the use case

Before evaluating any model, document:

- What the model will do (specific tasks, not general capabilities)
- Who will interact with it (internal users, customers, automated systems)
- What data it will process (sensitivity classification)
- What actions it can take (read-only, write, execute, decide)
- What the consequences of failure are (reputational, financial, safety, legal)

### Step 2: Identify candidate models

For each candidate, document:

- Model name, version, and provider
- Model type (base, fine-tuned, distilled, quantised)
- Licence and terms of use
- Available documentation (model card, technical report)

### Step 3: Assess against risk dimensions

Score each candidate against the risk dimensions above. Use a simple framework:

| Dimension | Acceptable | Needs mitigation | Unacceptable |
|-----------|-----------|-------------------|--------------|
| Origin risk | Verified provenance, documented training | Some gaps, can be mitigated | No provenance, no documentation |
| Data sensitivity | Model does not process sensitive data | Sensitive data with controls | Sensitive data without controls |
| Deployment context | Low-impact internal use | Customer-facing with oversight | Autonomous high-impact decisions |
| Compliance | Meets all requirements | Gaps with remediation plan | Cannot meet requirements |

### Step 4: Document and approve

Record the assessment, the decision, accepted risks, and required mitigations. Have the appropriate authority approve. This is your audit trail.

!!! warning "Reassess on model updates"
    A risk assessment is valid for a specific model version. When the model is updated (new version, additional fine-tuning, provider-side changes), the assessment must be reviewed. Treat model updates like you would treat a new deployment.

!!! info "References"
    - [NIST AI 100-1: AI Risk Management Framework](https://www.nist.gov/itl/ai-risk-management-framework)
    - [ISO/IEC 42001: AI Management System](https://www.iso.org/standard/81230.html)
    - [OWASP LLM Top 10: LLM Supply Chain Vulnerabilities](https://owasp.org/www-project-top-10-for-large-language-model-applications/)
    - [AI Runtime Security: Risk Tiers](https://airuntimesecurity.io/core/risk-tiers/)
