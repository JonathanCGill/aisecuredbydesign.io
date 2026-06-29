---
description: A threat modelling method for AI systems, mapping assets, trust boundaries, and the AI-specific attack surface to risk tiers and the controls that address them.
---

# Threat Modelling for AI Systems

Threat modelling is the first design activity, before you choose a single control. The goal is to understand what you are defending, where it can be attacked, and which of those attacks matter enough to spend control budget on. For AI systems the method is familiar but the attack surface is not: the model is non-deterministic, untrusted text can become instructions, and an agent can take actions you never explicitly authorised.

This page gives you a repeatable method and connects each step to the rest of the site, so the output of your threat model is a control set you can actually build.

!!! abstract "The method in one line"
    Scope the system, draw the trust boundaries, enumerate the AI-specific threats, rate each against your [risk tier](core/risk-tiers.md), then select the [controls](core/README.md) that address the threats that matter.

## Why AI changes threat modelling

Traditional threat modelling assumes the system does what its code says. AI breaks three assumptions that most models rely on:

- **Inputs can become instructions.** Any text the model reads, from a user, a retrieved document, a tool result, or another agent, can attempt to redirect its behaviour. Prompt injection has no equivalent in a deterministic system.
- **The boundary between data and control collapses.** Retrieved context, memory, and tool outputs all flow into the same prompt. Data provenance and authority become security properties, not metadata.
- **Behaviour is emergent.** You cannot enumerate every output. The model can be exploited through its training data, its retrieval corpus, or a cleverly worded request, and the failure may be subtle.

## Step 1: Scope and assets

Define the system boundary and what an attacker would want. For an AI system the assets usually include:

| Asset | Why an attacker wants it |
|-------|--------------------------|
| **The decision or action** | The system's output influences money, access, safety, or reputation |
| **Training and retrieval data** | Source corpora can be poisoned to change behaviour, or exfiltrated |
| **Credentials and tools** | An agent's tools and tokens are a path to the wider environment |
| **The conversation and memory** | Sensitive data accumulates in context and persistent memory |
| **The model itself** | Weights, system prompts, and configuration are intellectual property and attack targets |

## Step 2: Draw trust boundaries

Map every point where data or control crosses from less-trusted to more-trusted. In an AI system the boundaries that matter most are:

- **User to model** (prompt injection, jailbreaks)
- **Retrieved content to model** (indirect injection through RAG, the largest attack surface for most systems)
- **Tool result to model** (poisoned tool output steering the next action)
- **Agent to agent** (a compromised or confused agent influencing others, the [MASO](https://airuntimesecurity.io/maso/) problem)
- **Model to tool** (an action the model should not have been able to invoke)

Each crossing is where a control will eventually go. The [infrastructure controls](infrastructure/README.md) are organised around exactly these boundaries: identity at the entry, network segmentation between zones, and tool access controls at the model-to-tool crossing.

## Step 3: Enumerate the AI-specific threats

Work through the attack surface systematically. The OWASP LLM Top 10 and the OWASP Agentic Top 10 are the most useful checklists; the [OWASP LLM Top 10 mapping](infrastructure/mappings/owasp-llm-top10.md) ties each risk to a control. The recurring categories:

!!! abstract "Use MAESTRO for agentic systems"
    Flat checklists are good at *what* can go wrong but weak on *where* it enters in a multi-agent system. **MAESTRO** (*Multi-Agent Environment, Security, Threat, Risk, and Outcome*), the Cloud Security Alliance's agentic threat modelling framework, decomposes an agent stack into seven layers and asks you to enumerate threats at each layer and across the seams between them:

    1. **Foundation models** (the LLM itself: poisoning, jailbreaks, alignment failure)
    2. **Data operations** (ingestion, RAG corpora, memory)
    3. **Agent frameworks** (planning, tool use, delegation)
    4. **Deployment infrastructure** (hosting, sandboxing, network)
    5. **Evaluation and observability** (logging, tracing, evals)
    6. **Security and compliance** (a cross-layer function over all the others)
    7. **Agent ecosystem** (other agents, marketplaces, the wider environment)

    The cross-layer and agent-to-agent seams are exactly the boundaries from Step 2 that flat checklists miss, including the [MASO](https://airuntimesecurity.io/maso/) failures. Use MAESTRO's layers to drive enumeration, then map what you find onto the categories below.

| Threat category | Example | Where it enters |
|-----------------|---------|-----------------|
| **Prompt injection** | User or document overrides the system prompt | User and retrieved content boundaries |
| **Data and model poisoning** | Corrupted training or RAG data changes behaviour | Supply chain, see [Model Threat Landscape](building/model-selection/threat-landscape.md) |
| **Sensitive data disclosure** | Model leaks PII or secrets in a response | Model to user boundary |
| **Excessive agency** | Agent takes an unauthorised or high-impact action | Model to tool boundary, see [Agentic AI Controls](core/agentic.md) |
| **Supply chain** | Compromised model, dependency, or tool | Build and acquisition, see [Supply Chain](infrastructure/agentic/supply-chain.md) |
| **Tool and plugin abuse** | Tool invoked with crafted parameters | Tool invocation, see [Tool Access Controls](infrastructure/agentic/tool-access-controls.md) |
| **Multi-agent emergent risk** | Confused-deputy and trust failures across agents | Agent to agent, hand off to [MASO](https://airuntimesecurity.io/maso/) |

## Step 4: Rate against your risk tier

Not every threat justifies a control. Classify the system into a [risk tier](core/risk-tiers.md) based on impact, autonomy, and data sensitivity, then rate each threat by likelihood and consequence at that tier. A LOW-tier internal FAQ bot and a CRITICAL-tier credit-decision agent face the same threat catalogue but warrant very different control depth. Use [Risk Assessment](core/risk-assessment.md) to quantify residual risk and decide where control budget earns the most reduction.

## Step 5: Select controls

Map each threat that matters to a control, and consciously deselect the rest:

- **Three-layer pattern** ([Controls](core/controls.md)): guardrails prevent known-bad, the Judge detects unknown-bad, humans decide on consequence.
- **Agentic controls** ([Agentic AI Controls](core/agentic.md)): constrain tools, scope sessions, and bound delegation when the system takes actions.
- **Identity** ([IAM Governance](core/iam-governance.md)): authenticate every entity, enforce least privilege across humans, services, and agents.
- **Infrastructure** ([Infrastructure & Operations](infrastructure/README.md)): the logging, segmentation, secrets, and incident response that make the behavioural controls enforceable.

The output of a threat model is this control set, sized to the tier. Take it into [Test & Validate](getting-started/adversarial-testing.md) to confirm the controls hold, then into [Infrastructure & Operations](infrastructure/README.md) to build and run them.

!!! tip "Keep the model alive"
    A threat model is not a one-time artefact. Re-run it when the use case changes, when you add tools or agents, or when a new attack class appears. Pair it with the [AI-Aware SDLC](getting-started/ai-sdlc.md) so it is revisited at each phase rather than filed and forgotten.

!!! info "References"
    - [OWASP Top 10 for Large Language Model Applications](https://owasp.org/www-project-top-10-for-large-language-model-applications/)
    - [OWASP Agentic Security Initiative](https://genai.owasp.org/initiatives/#agenticsecurity)
    - [CSA, Agentic AI Threat Modeling Framework: MAESTRO](https://cloudsecurityalliance.org/blog/2025/02/06/agentic-ai-threat-modeling-framework-maestro)
    - [MITRE ATLAS, Adversarial Threat Landscape for AI Systems](https://atlas.mitre.org/)
    - [AI Runtime Security, MASO multi-agent framework](https://airuntimesecurity.io/maso/)
