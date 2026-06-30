---
description: "Mapping infrastructure controls to the CSA AI Controls Matrix (AICM) v1.1, covering all 18 security domains, the five contextual pillars, and the Shared Security Responsibility Model."
---

# CSA AI Controls Matrix (AICM) Mapping

> Maps infrastructure controls to the Cloud Security Alliance **AI Controls Matrix (AICM) v1.1**, across all 18 security domains.
>
> Part of the [AI Security Infrastructure Controls](../README.md) framework.
> Companion to [AI Runtime Security](https://airuntimesecurity.io/).

## What the AICM is

The **AI Controls Matrix** is CSA's vendor-agnostic control framework for cloud-based generative AI and LLM systems. It is the AI-era successor to the Cloud Controls Matrix (CCM): **243 control objectives across 18 security domains**, with every control enriched by contextual mappings and cross-referenced to ISO/IEC 42001, ISO/IEC 27001, BSI AIC4, NIST AI 600-1, and the EU AI Act.

What makes the AICM distinct from a flat control list is its five **pillars** of context per control, and its **Shared Security Responsibility Model**. Both align closely with how this framework already thinks about pre-runtime AI security, which is why the AICM is a natural baseline to map against.

### The five pillars

Each AICM control objective is characterised along five dimensions:

- **Control Type.** Preventive, detective, or corrective. This maps directly to the three-layer pattern used here: **Guardrails** prevent, **Model-as-Judge** detects, **Human Oversight** corrects.
- **Control Applicability and Ownership.** Which actor in the supply chain owns the control (see the SSRM below).
- **Architectural Relevance.** Which layer the control acts on: physical, network, compute, storage, application, or data.
- **LLM Lifecycle Relevance.** Where in the lifecycle the control applies, from data preparation through to model retirement.
- **Threat Category.** The AI-specific threats the control addresses, including prompt injection, model and data poisoning, model theft, and sensitive data disclosure.

### Shared Security Responsibility Model

The AICM assigns ownership of every control across five actors:

| AICM actor | Owns | Typical relationship to this framework |
|-----------|------|----------------------------------------|
| **Cloud Service Provider** | Physical infrastructure, virtualisation, datacenter security | Their responsibility. Inherited via [Cloud AI Services](../../building/platform-selection/cloud-ai-services.md). |
| **Model Provider** | Model training, foundation model safety, provenance | Their responsibility. Verified, not implemented, via [Model Selection](../../building/model-selection/README.md). |
| **Orchestrated Service Provider** | Agent frameworks, tool gateways, retrieval pipelines | Shared. Where you build agentic systems you own these controls. |
| **Application Provider** | Application logic, prompts, input/output handling | **Usually you.** The bulk of this framework's controls land here. |
| **AI Customer** | Data classification, access policy, acceptable use | **Usually you.** Configuration and governance decisions. |

For most teams using this framework, you are the **Application Provider** and the **AI Customer**, and often the **Orchestrator** as well. The Cloud and Model Provider columns are controls you *inherit and verify* rather than build. This is the same boundary the [platform selection](../../building/platform-selection/README.md) guidance draws when it separates "you manage" from "provider manages."

## Scope and Limitations

This mapping covers the **technical infrastructure layer** of the AICM. The AICM spans both organisational and technical controls. The 80 infrastructure controls in this framework address the technical objectives; organisational domains (**Human Resources**, **Audit and Assurance** planning, much of **Governance Risk and Compliance**) are addressed by the parent framework's [risk tiers](../../core/risk-tiers.md) and governance model, and by the implementing organisation's management system.

Three AICM domains are predominantly **provider-owned or out of technical scope** for a pre-runtime application builder: **Datacenter Security (DCS)**, **Human Resources (HRS)**, and **Universal Endpoint Management (UEM)**. They are listed below for completeness with the supporting controls this framework does provide, and a note on the ownership gap.

The mapping is at the **domain level**. AICM control objectives use the same two-letter domain prefixes as this framework's own control IDs in some cases (for example both use `IAM` and `LOG`), so domain-level mapping avoids ambiguity. Where a single framework control is the principal answer to a domain, it is called out.

## Mapping by AICM Domain

### MDS - Model Security

The net-new AI domain, and the heart of the AICM. Covers model provenance, training integrity, evaluation, and protection against poisoning and theft.

| AICM focus | Infrastructure Controls | Notes |
|-----------|------------------------|-------|
| Model provenance and integrity | SUP-01, SUP-06 | Provenance verification and safety-model integrity verification are the deployment gates. See [Provenance and Integrity](../../building/model-selection/provenance-and-integrity.md). |
| Model risk and trust evaluation | SUP-02, LOG-03 | Pre-adoption risk assessment and Judge evaluation logging. See [Trust and Evaluation](../../building/model-selection/trust-and-evaluation.md). |
| Training and fine-tuning security | SUP-04 | Fine-tuning pipeline security protects against training-time poisoning. |
| Poisoning and drift | SUP-03, LOG-05 | RAG source integrity addresses data poisoning; drift detection identifies behavioural change post-deployment. |
| Model theft and extraction | SEC-07, NET-04, TOOL-05 | Endpoint credential protection, egress control, and rate limiting raise the cost of extraction attacks. |
| Adversarial robustness | LOG-06, SUP-08 | Prompt injection detection and vulnerability monitoring. See [Vulnerability Scanning](../../building/model-selection/vulnerability-scanning.md). |

### IAM - Identity and Access Management

| AICM focus | Infrastructure Controls | Notes |
|-----------|------------------------|-------|
| Authentication and least privilege | IAM-01, IAM-02 | Authenticate all entities; enforce least privilege. |
| Plane separation and control-plane access | IAM-03, NET-06 | Control and data plane separation; control-plane network path protection. |
| Agent and tool authorisation | IAM-04, IAM-05 | Constrain agent tool invocation; human approval for high-impact actions. |
| Credential lifecycle | IAM-06, SEC-06 | Session-scoped credentials; per-session agent credential isolation. |
| Access accountability | IAM-08, DEL-05 | Audit all access changes; propagate user identity through delegation chains. |
| Access-controlled retrieval | DAT-04 | RAG retrieval constrained to documents the user is authorised to see. |

### DSP - Data Security and Privacy Lifecycle Management

| AICM focus | Infrastructure Controls | Notes |
|-----------|------------------------|-------|
| Classification and minimisation | DAT-01, DAT-02 | Classify data at AI boundaries; enforce data minimisation. |
| PII handling | DAT-03, LOG-09 | Detect and redact PII at I/O boundaries and in logs. |
| Leakage prevention | DAT-06, SEC-04 | Response leakage prevention; credential pattern scanning in model I/O. |
| Retention and lifecycle | DAT-07, LOG-08 | Conversation history retention limits; log retention policy. |
| Evaluation data protection | DAT-08 | Tokenise PII before it transits to the Judge. |

### LOG - Logging and Monitoring

| AICM focus | Infrastructure Controls | Notes |
|-----------|------------------------|-------|
| Comprehensive logging | LOG-01, LOG-02, LOG-03, LOG-04 | Model I/O, guardrail decisions, Judge evaluations, and agent decision chains. |
| Detection signals | LOG-05, LOG-06 | Behavioural drift detection; prompt injection detection. |
| Log integrity and retention | LOG-07, LOG-08 | Tamper-proof logs; enforced retention. |
| Agent observability | TOOL-06, DEL-02 | Log every tool invocation; maintain delegation audit trail. |
| Enterprise integration | LOG-10 | Correlate AI events with enterprise SIEM. See [Logging and Observability](../controls/logging-and-observability.md). |

### STA - Supply Chain Management, Transparency, and Accountability

The domain that operationalises the Shared Security Responsibility Model.

| AICM focus | Infrastructure Controls | Notes |
|-----------|------------------------|-------|
| Component provenance | SUP-01, SUP-06 | Verify model and safety-model provenance and integrity. |
| Third-party risk | SUP-02, SUP-05 | Model risk assessment; tool and plugin supply chain auditing. See [Supply Chain](../agentic/supply-chain.md). |
| Data source integrity | SUP-03 | RAG data source allowlisting and content scanning. |
| Inventory and transparency | SUP-07 | Maintain an AI-BOM as the single source of truth for deployed components. |
| Delegation accountability | DEL-04, DEL-05 | Require explicit delegation authorisation; propagate user identity end to end. |

### SEF - Security Incident Management, E-Discovery, and Cloud Forensics

| AICM focus | Infrastructure Controls | Notes |
|-----------|------------------------|-------|
| Incident taxonomy and detection | IR-01, IR-02 | AI-specific incident categories and automated detection triggers. |
| Containment and recovery | IR-03, IR-04 | Containment procedures; model rollback and guardrail hot-reload. |
| Investigation and forensics | IR-05, LOG-04, LOG-07 | Investigation procedures backed by tamper-proof agent decision chains. |
| Review and enterprise integration | IR-07, IR-08 | Post-incident review; integration with enterprise IR. See [Incident Response](../controls/incident-response.md). |

### AIS - Application and Interface Security

| AICM focus | Infrastructure Controls | Notes |
|-----------|------------------------|-------|
| Single enforced entry point | NET-07, NET-02 | API gateway as single entry; network-level guardrail bypass prevention. |
| Input and output guardrails | LOG-06, DAT-03, DAT-06 | Injection detection; PII redaction; response leakage prevention. |
| Agent interface enforcement | TOOL-01, TOOL-02, TOOL-03 | Tool manifest, gateway enforcement, parameter constraints. See [Tool Access Controls](../agentic/tool-access-controls.md). |

### IVS - Infrastructure Security

| AICM focus | Infrastructure Controls | Notes |
|-----------|------------------------|-------|
| Network zone architecture | NET-01, NET-08 | Zone architecture; cross-zone traffic monitoring. See [Network and Segmentation](../controls/network-and-segmentation.md). |
| Pipeline and runtime separation | NET-05 | Separate ingestion from runtime to contain poisoned data. |
| Judge isolation | NET-03 | Isolate Judge evaluation infrastructure for evaluation independence. |
| Sandbox isolation | SAND-01, SAND-02, SAND-03, SAND-05 | Isolated execution, file-system and network restriction, ephemeral state. See [Sandbox Patterns](../agentic/sandbox-patterns.md). |
| Session isolation | SESS-02 | Isolate agent sessions to bound blast radius. |

### CCC - Change Control and Configuration Management

| AICM focus | Infrastructure Controls | Notes |
|-----------|------------------------|-------|
| Configuration integrity | IAM-03, NET-06 | Control and data plane separation; protected control-plane path. |
| Artefact integrity | SUP-01, SUP-06, SEC-08 | Provenance verification, safety-model integrity, and pre-deployment credential and config scanning. |
| Safe rollback | IR-04 | Model rollback and hot-reload for rapid, controlled change reversal. |

### TVM - Threat and Vulnerability Management

| AICM focus | Infrastructure Controls | Notes |
|-----------|------------------------|-------|
| Vulnerability monitoring | SUP-08 | Monitor AI components for new vulnerabilities and attack patterns. |
| Code and content scanning | SAND-06, SEC-08 | Scan generated code before execution; scan code and config for embedded credentials. |
| Threat detection | LOG-06, NET-08 | Injection detection and cross-zone anomaly monitoring. See [Adversarial Testing](../../getting-started/adversarial-testing.md). |
| Risk-based prioritisation | SUP-02 | Model risk assessment informs remediation priority. |

### CEK - Cryptography, Encryption, and Key Management

| AICM focus | Infrastructure Controls | Notes |
|-----------|------------------------|-------|
| Encryption at rest and in transit | DAT-05 | Encrypt AI data across all states. |
| Secret storage | SEC-03 | Centralise secrets in a vault. See [Secrets and Credentials](../controls/secrets-and-credentials.md). |
| Token and key lifecycle | SEC-02, SEC-05 | Short-lived scoped tokens; rotation on exposure. Bring-your-own-key is provider-dependent. |

### BCR - Business Continuity Management and Operational Resilience

| AICM focus | Infrastructure Controls | Notes |
|-----------|------------------------|-------|
| Recovery and rollback | IR-04, IR-03 | Rollback, hot-reload, and containment procedures. |
| Capacity and abuse resilience | SAND-04, TOOL-05, SESS-01 | Resource limits, rate limiting, and session boundaries resist resource-exhaustion attacks. |
| Graceful degradation | - | Failover and degraded-mode design are addressed in [Resilience](../../building/devops/resilience.md) and [PACE](../../how-to/scaling-and-pace.md). |

### A&A - Audit and Assurance

| AICM focus | Infrastructure Controls | Notes |
|-----------|------------------------|-------|
| Evidence integrity | LOG-07, LOG-08 | Tamper-proof, retained logs provide the evidence base for audit. |
| Change attestation | IAM-08, SUP-07 | Access-change auditing and AI-BOM support assurance activities. |
| Continuous improvement | IR-07 | Post-incident review feeds the assurance loop. |

!!! info "Mostly organisational"
    Audit planning, scope definition, and independent assessment are organisational activities. This framework provides the **auditable technical evidence**; it does not define the audit programme.

### GRC - Governance, Risk, and Compliance

| AICM focus | Infrastructure Controls | Notes |
|-----------|------------------------|-------|
| Risk assessment | SUP-02 | Model risk assessment at adoption. See [Risk Tiers](../../core/risk-tiers.md) and [Risk Assessment](../../core/risk-assessment.md). |
| Inventory and accountability | SUP-07, IAM-08 | AI-BOM and access auditing support governance reporting. |
| Compliance alignment | - | The [Regulatory Alignment](../../getting-started/regulatory-alignment.md) guidance and the other [standards mappings](controls-to-three-layers.md) address compliance demonstration. |

!!! info "Mostly organisational"
    Policy definition, risk appetite, and governance structures are organisational. Infrastructure controls enforce what governance declares.

### IPY - Interoperability and Portability

| AICM focus | Infrastructure Controls | Notes |
|-----------|------------------------|-------|
| Component inventory | SUP-07 | AI-BOM records components and versions, supporting portability planning. |
| Provenance for migration | SUP-01 | Verified provenance enables trustworthy component substitution. |

!!! info "Largely architectural"
    Avoiding lock-in is principally a [platform selection](../../building/platform-selection/README.md) and architecture decision. See [Hybrid Patterns](../../building/platform-selection/hybrid-patterns.md).

### DCS - Datacenter Security

| AICM focus | Infrastructure Controls | Notes |
|-----------|------------------------|-------|
| Physical and facility security | - | **Provider-owned.** Inherited from the Cloud Service Provider under the SSRM. |
| Logical zone enforcement | NET-01 | Zone architecture is the logical analogue this framework controls. |

!!! info "Provider responsibility"
    For cloud and managed-platform deployments, DCS controls are inherited. Verify them through provider attestations rather than implementing them. Relevant only for [self-hosted infrastructure](../../building/platform-selection/self-hosted-infrastructure.md).

### HRS - Human Resources

| AICM focus | Infrastructure Controls | Notes |
|-----------|------------------------|-------|
| Access on joining and leaving | IAM-01, IAM-08 | Authentication and access-change auditing enforce HR-driven access decisions. |

!!! info "Organisational domain"
    Personnel screening, training, and acceptable-use policy are organisational. This framework only enforces the access consequences of HR decisions.

### UEM - Universal Endpoint Management

| AICM focus | Infrastructure Controls | Notes |
|-----------|------------------------|-------|
| Endpoint credential protection | SEC-07 | Protects model-endpoint credentials held by managed endpoints. |

!!! info "Largely out of scope"
    Managing client and operator devices sits outside this pre-runtime AI framework. The one relevant intersection is protecting credentials used to reach AI endpoints.

## Coverage summary

| AICM domain | Coverage | Owner |
|------------|----------|-------|
| MDS - Model Security | Strong | App / Model Provider |
| IAM - Identity and Access Management | Strong | App / Customer |
| DSP - Data Security and Privacy | Strong | App / Customer |
| LOG - Logging and Monitoring | Strong | App / Orchestrator |
| STA - Supply Chain, Transparency, Accountability | Strong | All actors |
| SEF - Security Incident Management and Forensics | Strong | App / Customer |
| AIS - Application and Interface Security | Strong | App / Orchestrator |
| IVS - Infrastructure Security | Strong | Orchestrator / Cloud |
| CCC - Change Control and Configuration | Partial | App / Orchestrator |
| TVM - Threat and Vulnerability Management | Partial | App / Orchestrator |
| CEK - Cryptography and Key Management | Partial | App / Cloud |
| BCR - Business Continuity and Resilience | Partial | App / Cloud |
| A&A - Audit and Assurance | Evidence only | Customer |
| GRC - Governance, Risk, and Compliance | Evidence only | Customer |
| IPY - Interoperability and Portability | Light | Customer / Cloud |
| DCS - Datacenter Security | Inherited | Cloud Provider |
| HRS - Human Resources | Organisational | Customer |
| UEM - Universal Endpoint Management | Out of scope | Customer |

The eight "Strong" domains are where this framework's pre-runtime, application-layer focus concentrates. The remaining domains are either provider-inherited, organisational, or principally addressed by the parent framework's governance and resilience guidance. This division mirrors the AICM's own Shared Security Responsibility Model: the controls you build land in the Application Provider, Orchestrator, and AI Customer columns, while Cloud and Model Provider controls are inherited and verified.

!!! info "References"
    - [AI Controls Matrix v1.1 (Cloud Security Alliance)](https://cloudsecurityalliance.org/artifacts/ai-controls-matrix-v1-1)
    - [Introducing the CSA AI Controls Matrix](https://cloudsecurityalliance.org/blog/2025/07/10/introducing-the-csa-ai-controls-matrix-a-comprehensive-framework-for-trustworthy-ai)
    - [Cloud Controls Matrix (Cloud Security Alliance)](https://cloudsecurityalliance.org/research/cloud-controls-matrix)
