---
description: An end-to-end worked example of securing an AI system, taking a retail bank's customer-service assistant from threat model through risk tiering, control selection, technical architecture, testing, and resilience.
---

# Worked Example: Meridian Bank's Customer-Service Assistant

This is the whole workflow on one system, and the most detailed of the [worked examples](README.md#the-worked-examples). It walks the full method end to end; the other examples (from a [LOW public bot](example-faq-low.md) to a [CRITICAL decisioning model](example-decisioning-critical.md)) reuse this method and focus on what differs at their tier. We pick up where [Should You Use AI?](should-you-use-ai.md) left off: Meridian has decided to build an authenticated assistant that answers questions and performs read-only lookups, with high-impact actions scoped behind extra controls. Now we design it.

The system under design:

- **Channels:** authenticated web and mobile app
- **Knowledge:** retrieval over the bank's own product and policy documents (RAG)
- **Read tools:** balance lookup, recent transactions
- **Write tools:** raise a transaction dispute, update contact details (both scoped, see below)
- **Escape hatch:** hand off to a human agent

## Step 1: Confirm the decision and scope

From the decision filter, two capabilities were deliberately constrained: changing contact details and raising disputes are **proposed, not executed**. The assistant prepares the action; a deterministic step (step-up authentication for contact changes, human confirmation for disputes) commits it. This is a scoping decision made before any control is chosen, and it removes the highest-impact autonomous action from the design entirely.

## Step 2: Threat model

Following the [threat modelling method](../threat-modelling.md): scope the assets, draw the trust boundaries, enumerate the AI-specific threats.

**Assets:** customer PII and account data, the ability to move or expose money, the bank's reputation, the retrieval corpus, and the assistant's tools and credentials.

**Trust boundaries and their threats:**

| Boundary | Primary threat |
|----------|----------------|
| Customer to model | Prompt injection, jailbreak, social engineering of the assistant |
| Retrieved document to model | Indirect injection or poisoned content in the policy corpus |
| Tool result to model | A crafted transaction memo or account field steering the next action |
| Model to tool | The assistant invoking a write action it should not, or with wrong parameters |
| Model to customer | Leaking another customer's data, or this customer's data to the wrong session |

**Threat catalogue (mapped to the [OWASP LLM Top 10](../infrastructure/mappings/owasp-llm-top10.md)):** prompt injection, sensitive-information disclosure, excessive agency, supply-chain risk in the retrieval corpus and tools, and data poisoning of the RAG index.

The output of this step is not a control list yet. It is a ranked set of things that can go wrong, which we now size.

## Step 3: Size the risk

Using the [classification process](../core/risk-tiers.md#classification-process), score the impact dimensions and take the highest:

| Dimension | Assessment | Drives |
|-----------|------------|--------|
| Decision impact | Influences account actions and money movement | HIGH |
| Data sensitivity | Customer PII and financial data | HIGH |
| Autonomy | Read actions autonomous; write actions gated | HIGH overall |
| User exposure | External, authenticated customers at scale | HIGH |

**The system is HIGH tier.** Two specific actions, contact-detail change and dispute creation, carry CRITICAL-style consequences (account takeover, financial impact) and so attract CRITICAL-level controls *for those actions* even though the system as a whole is HIGH. Tiering the actions, not just the system, is what lets you spend control budget where the harm is.

## Step 4: Select controls to match the risk

Now map each threat to a control at the depth the tier demands. The [control matrix](../core/risk-tiers.md#control-matrix) gives the HIGH-tier baseline; [Selecting Guardrails](selecting-guardrails.md) covers the *how* of choosing them. The result for Meridian:

| Threat | Control | Layer | Depth at HIGH |
|--------|---------|-------|---------------|
| Prompt injection (direct) | Input guardrails: injection detection, topic and length limits | [Guardrails](../core/controls.md#1-guardrails) | Enhanced |
| Indirect injection via RAG | Treat retrieved content as untrusted; strip instructions; access-controlled retrieval | [Guardrails](../core/controls.md#1-guardrails) + [Data Protection](../infrastructure/controls/data-protection.md) | Enhanced |
| Sensitive-data disclosure | Output guardrails: PII checks, cross-customer leakage prevention, response scanning | [Guardrails](../core/controls.md#1-guardrails) + [DAT-06](../infrastructure/controls/data-protection.md) | Enhanced |
| Unknown-bad behaviour | Model-as-Judge evaluating 100% of outputs async, high-risk first | [Judge](../core/controls.md#2-model-as-judge) | All outputs |
| Excessive agency | Tool permission broker, parameter bounds, action classification by reversibility | [Agentic](../core/agentic.md#control-categories) + [Tool Access Controls](../infrastructure/agentic/tool-access-controls.md) | Enforced at gateway |
| High-impact write actions | Step-up auth (contact change) and human confirmation (dispute) | [Human Oversight](../core/controls.md#3-human-oversight-hitl) + [Approval Workflows](../core/agentic.md#4-approval-workflows) | Required |
| Identity and least privilege | Authenticate every entity; session-scoped, least-privilege tokens | [IAM Governance](../core/iam-governance.md) + [Identity & Access](../infrastructure/controls/identity-and-access.md) | All |
| Detection and audit | Log model I/O, guardrail decisions, Judge scores, tool calls; correlate to SIEM | [Logging & Observability](../infrastructure/controls/logging-and-observability.md) | All |
| Supply-chain risk | Verify model and tool provenance; AI-BOM | [Supply Chain](../infrastructure/agentic/supply-chain.md) | All |

The principle running through this table is **infrastructure beats instructions**: the tool broker enforces permissions, not a line in the system prompt asking the model to behave. A prompt can be overridden; a gateway cannot.

## Step 5: Turn controls into an architecture

Controls become real as components. Described in vendor-neutral terms, the design has these moving parts:

| Component | Role | Implements |
|-----------|------|------------|
| **API gateway** | Single entry point; authenticates, rate-limits, routes | NET-07, IAM-01 |
| **Input guardrail service** | Filters and inspects every request before the model sees it | Input guardrails |
| **Retrieval service** | Access-controlled RAG; returns only documents this customer may see, with retrieved text marked untrusted | DAT-04, indirect-injection defence |
| **Model runtime** | The LLM; no direct network or credential access | Least privilege |
| **Tool broker** | Holds the credentials and enforces which tools, with which parameters, the agent may call | Tool access controls, scope enforcement |
| **Output guardrail service** | Scans responses for PII, leakage, and policy breaches before they reach the customer | Output guardrails |
| **Judge (async)** | Evaluates outputs and proposed actions out of band; holds or flags below threshold | Model-as-Judge |
| **Human review queue** | Where flagged outputs and gated actions go for confirmation | Human oversight |
| **Secrets vault** | Issues short-lived, scoped credentials; never in the prompt | SEC-01, SEC-02 |
| **Logging pipeline** | Captures I/O, decisions, scores, and tool calls; feeds the SIEM | LOG-01..10 |

These sit in [segmented network zones](../infrastructure/controls/network-and-segmentation.md): the model runtime cannot reach the internet or the account systems directly; it can only ask the tool broker, which is the sole holder of those credentials. If the model is fully compromised through injection, the blast radius is still bounded by what the broker will allow.

!!! abstract "How a single request flows"
    Customer message → gateway (authn, rate limit) → input guardrails → retrieval (access-controlled, untrusted-marked) → model → proposed response or action → output guardrails → tool broker (if action, check permission and parameters; if high-impact, route to confirmation) → response to customer. The Judge evaluates the exchange asynchronously and can raise an alert or hold future actions. Every hop is logged.

## Step 6: Test the design

A design is a hypothesis until it is attacked. Following [Adversarial Testing](../getting-started/adversarial-testing.md), Meridian tests at HIGH-tier depth:

- **Direct injection and jailbreak** attempts against the input guardrails.
- **Indirect injection**: seed the test corpus with documents containing instructions and confirm the model does not act on them.
- **Cross-customer leakage**: attempt to retrieve or have the model reveal another customer's data.
- **Tool abuse**: attempt to invoke write tools with out-of-bounds parameters, or to escalate a read into a write.
- **Oversight bypass**: confirm high-impact actions cannot complete without the gating step.

Findings feed back into control tuning before the system goes through [Production Readiness](../getting-started/production-readiness.md) gates.

## Step 7: Operate, scale, and plan for failure

The design is not finished at deployment. Two things remain, each with its own page:

- **Scaling.** Meridian will grow from a pilot to the full customer base, and may later add use cases or agents. The controls have to scale with it without becoming unaffordable or unmonitorable. See [Scaling and PACE](scaling-and-pace.md).
- **Resilience.** Every control layer will eventually degrade. Before launch, Meridian defines the fail posture for each layer at HIGH tier: what happens when guardrails slow down, when the Judge is unavailable, when the review queue overflows. This is the PACE design input, covered in the same page.

!!! tip "What to carry away"
    The order matters as much as the content. Decide, then threat model, then size the risk, then choose controls, then build the architecture, then test. Reverse it, starting from a product or a control you like, and you will secure the wrong things at the wrong depth.

!!! info "References"
    - [Threat Modelling for AI Systems](../threat-modelling.md)
    - [Risk Tiers and Control Selection](../core/risk-tiers.md)
    - [Controls: Guardrails, Judge, and Human Oversight](../core/controls.md)
    - [Agentic AI Controls](../core/agentic.md)
    - [Infrastructure & Operations](../infrastructure/README.md)
    - [OWASP Top 10 for LLM Applications](https://owasp.org/www-project-top-10-for-large-language-model-applications/)
