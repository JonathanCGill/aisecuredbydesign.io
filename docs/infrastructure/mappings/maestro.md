---
description: "Mapping infrastructure controls to the seven layers of the CSA MAESTRO agentic AI threat modelling framework, with specific mitigations per layer."
---

# MAESTRO Layer-to-Control Mapping

> Maps infrastructure controls to the seven layers of MAESTRO (*Multi-Agent Environment, Security, Threat, Risk, and Outcome*), the Cloud Security Alliance's agentic AI threat modelling framework.
>
> Part of the [AI Security Infrastructure Controls](../README.md) framework.
> Companion to [Threat Modelling for AI Systems](../../threat-modelling.md).

MAESTRO decomposes an agent stack into seven layers and asks you to enumerate threats at each layer and across the seams between them. This page closes the loop: once MAESTRO tells you *where* a threat enters, this mapping tells you *which* controls address it. Use it after Step 3 of the [threat modelling method](../../threat-modelling.md), then size the selection to your [risk tier](../../core/risk-tiers.md) at Step 4.

!!! abstract "How to read this"
    **Primary** controls are the ones that directly defend the layer. **Secondary** controls reduce blast radius or support detection and recovery. Layer 6 (Security and Compliance) is a cross-layer function, so its controls recur across the other six layers by design.

## Layer 1: Foundation Models

The core model the agent is built on. Threats include training-data poisoning, jailbreaks, alignment failure, and a compromised or tampered model artefact.

| Control Type | Controls | How It Mitigates |
|-------------|----------|-----------------|
| **Primary** | SUP-01, SUP-02, SUP-06, SUP-08, LOG-06, NET-02 | Provenance verification (SUP-01) detects a tampered model. Risk assessment (SUP-02) screens a model before adoption. Safety model integrity (SUP-06) ensures the guardrail model itself is trustworthy. Vulnerability monitoring (SUP-08) tracks model and dependency CVEs. Injection detection (LOG-06) and bypass prevention (NET-02) catch and contain jailbreak attempts at the model boundary. |
| **Secondary** | SUP-04, LOG-05, LOG-03, SEC-07 | Fine-tuning pipeline security (SUP-04) prevents poisoning during customisation. Drift detection (LOG-05) flags behavioural change that may signal a compromised model. Judge evaluation (LOG-03) gives an independent read on output quality. Endpoint credential protection (SEC-07) secures access to the model itself. |

## Layer 2: Data Operations

Ingestion, transformation, storage, RAG corpora, and memory. Threats include retrieval poisoning, embedding manipulation, memory poisoning, and disclosure of sensitive data through the data path.

| Control Type | Controls | How It Mitigates |
|-------------|----------|-----------------|
| **Primary** | SUP-03, DAT-04, DAT-01, NET-05, DAT-05 | RAG data source integrity (SUP-03) prevents poisoning through the knowledge base. Access-controlled RAG (DAT-04) enforces document-level permissions on retrieval. Data classification at boundaries (DAT-01) identifies what is sensitive. Ingestion/runtime separation (NET-05) isolates write paths from query paths. Encryption (DAT-05) protects data and embeddings at rest and in transit. |
| **Secondary** | DAT-02, DAT-03, DAT-07, SESS-02, SESS-05 | Data minimisation (DAT-02) and PII redaction (DAT-03) limit what enters context. Conversation history management (DAT-07) controls what persists in memory. Session isolation (SESS-02) and cleanup (SESS-05) prevent poisoned memory crossing sessions. |

## Layer 3: Agent Frameworks

Planning, tool use, and delegation: the logic that turns reasoning into action. Threats include excessive agency, tool misuse, and privilege escalation through delegation.

| Control Type | Controls | How It Mitigates |
|-------------|----------|-----------------|
| **Primary** | TOOL-01, TOOL-02, TOOL-03, TOOL-04, IAM-04, DEL-01 | Declared manifests (TOOL-01) bound permitted actions. Gateway enforcement (TOOL-02) makes the boundary real rather than self-policed. Parameter constraints (TOOL-03) limit scope within a tool. Action classification (TOOL-04) routes high-impact actions to review. Agent tool constraints (IAM-04) enforce least privilege per tool. Least delegation (DEL-01) blocks privilege escalation through hand-off. |
| **Secondary** | TOOL-05, TOOL-06, SESS-03, DEL-03, DEL-05, LOG-04 | Rate limiting (TOOL-05) and full invocation logging (TOOL-06) constrain and record tool use. Task scope (SESS-03) and delegation depth limits (DEL-03) bound how far agency can expand. User identity propagation (DEL-05) keeps actions attributable. Agent chain logging (LOG-04) reconstructs multi-step sequences. |

## Layer 4: Deployment Infrastructure

Hosting, sandboxing, and network: the environment the agent runs in. Threats include unexpected code execution, sandbox escape, lateral movement, and control-plane tampering.

| Control Type | Controls | How It Mitigates |
|-------------|----------|-----------------|
| **Primary** | SAND-01, SAND-02, SAND-03, SAND-04, NET-01, IAM-03 | Sandbox isolation (SAND-01) contains generated code. File system (SAND-02) and network restrictions (SAND-03) limit what that code can reach. Resource limits (SAND-04) cap consumption. Zone architecture (NET-01) segments the environment. Control/data plane separation (IAM-03) protects configuration from runtime access. |
| **Secondary** | SAND-05, SAND-06, NET-06, NET-07, SEC-03 | Ephemeral state (SAND-05) and pre-execution scanning (SAND-06) reduce persistence and dangerous code. Control plane network protection (NET-06) and API gateway enforcement (NET-07) harden the entry and management paths. Centralised secrets (SEC-03) keep credentials out of the runtime. |

## Layer 5: Evaluation and Observability

Logging, tracing, and evaluation: the ability to see what the agent did and judge whether it was acceptable. Threats include blind spots, log tampering, and an unmonitored evaluation path.

| Control Type | Controls | How It Mitigates |
|-------------|----------|-----------------|
| **Primary** | LOG-01, LOG-02, LOG-03, LOG-04, LOG-05, IR-02 | Model I/O logging (LOG-01), guardrail decision logs (LOG-02), Judge evaluations (LOG-03), agent chain logs (LOG-04), and drift detection (LOG-05) provide the observability MAESTRO assumes. Detection triggers (IR-02) turn that telemetry into alerts. |
| **Secondary** | LOG-07, LOG-10, NET-03, DAT-08, IR-05 | Log integrity (LOG-07) prevents evidence tampering. SIEM correlation (LOG-10) links AI events to enterprise monitoring. Judge isolation (NET-03) and evaluation data protection (DAT-08) secure the evaluation path. Non-deterministic investigation (IR-05) makes the telemetry usable after an incident. |

## Layer 6: Security and Compliance

A cross-layer function over the whole stack: identity, secrets, governance, and incident response. Threats include identity and privilege abuse, credential leakage, and gaps in detection, response, and audit.

| Control Type | Controls | How It Mitigates |
|-------------|----------|-----------------|
| **Primary** | IAM-01, IAM-02, IAM-08, SEC-01, IR-01, IR-03 | Authentication (IAM-01) and least privilege (IAM-02) establish who can do what. Access auditing (IAM-08) detects change. Credential isolation from context (SEC-01) removes the highest-value target. Incident categories (IR-01) and containment procedures (IR-03) make response real rather than aspirational. |
| **Secondary** | SEC-02, SEC-04, SEC-05, SUP-07, LOG-08, LOG-09, IR-07, IR-08 | Short-lived tokens (SEC-02), credential scanning (SEC-04), and rotation on exposure (SEC-05) limit credential blast radius. AI-BOM (SUP-07) underpins compliance and supply-chain visibility. Retention (LOG-08) and log redaction (LOG-09) satisfy governance. Post-incident review (IR-07) and enterprise IR integration (IR-08) close the loop. |

## Layer 7: Agent Ecosystem

Other agents, tool marketplaces, and the wider environment the agent interacts with. Threats include insecure inter-agent communication, agentic supply-chain compromise, and confused-deputy failures across agents.

| Control Type | Controls | How It Mitigates |
|-------------|----------|-----------------|
| **Primary** | DEL-02, DEL-04, DEL-05, NET-04, SUP-05, IAM-01 | Delegation audit trails (DEL-02) and explicit delegation authorisation (DEL-04) prevent ad-hoc agent-to-agent trust. User identity propagation (DEL-05) and authentication at each hop (IAM-01) keep cross-agent actions attributable. Agent egress control (NET-04) limits where an agent can reach. Tool supply chain auditing (SUP-05) screens externally sourced tools and agents. |
| **Secondary** | SUP-02, SUP-01, NET-08, LOG-04, IR-08 | Risk assessment (SUP-02) and provenance verification (SUP-01) screen runtime-discovered components. Cross-zone monitoring (NET-08) and agent chain logging (LOG-04) detect ecosystem-spanning abuse. Enterprise IR integration (IR-08) handles incidents that cross organisational boundaries. |

## Control Coverage Summary

### MAESTRO Layers - Primary Control Distribution

| Layer | Primary Controls |
|-------|-----------------|
| L1 Foundation Models | SUP-01, SUP-02, SUP-06, SUP-08, LOG-06, NET-02 |
| L2 Data Operations | SUP-03, DAT-04, DAT-01, NET-05, DAT-05 |
| L3 Agent Frameworks | TOOL-01, TOOL-02, TOOL-03, TOOL-04, IAM-04, DEL-01 |
| L4 Deployment Infrastructure | SAND-01, SAND-02, SAND-03, SAND-04, NET-01, IAM-03 |
| L5 Evaluation and Observability | LOG-01, LOG-02, LOG-03, LOG-04, LOG-05, IR-02 |
| L6 Security and Compliance | IAM-01, IAM-02, IAM-08, SEC-01, IR-01, IR-03 |
| L7 Agent Ecosystem | DEL-02, DEL-04, DEL-05, NET-04, SUP-05, IAM-01 |

!!! info "References"
    - [CSA, Agentic AI Threat Modeling Framework: MAESTRO](https://cloudsecurityalliance.org/blog/2025/02/06/agentic-ai-threat-modeling-framework-maestro)
    - [Threat Modelling for AI Systems](../../threat-modelling.md)
    - [AI Security Infrastructure Controls](../README.md)
    - [OWASP LLM Top 10 and Agentic Top 10 Mapping](owasp-llm-top10.md)
