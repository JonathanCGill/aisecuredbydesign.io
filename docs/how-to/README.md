---
description: A practical, end-to-end guide for designing a secure AI system, worked through a single example from the decision to use AI through controls, testing, scaling, and PACE resilience.
---

# How To: Design a Secure AI System

The rest of this site is organised by topic: threats here, controls there, infrastructure over there. This section puts it together. It walks one realistic system from a blank page to a design you could hand to an engineering team, making the decisions an architect actually has to make and showing the reasoning behind each one.

It is deliberately opinionated about *method* and deliberately neutral about *products*. You will see categories of technical solution (a gateway, an evaluator, a vault) but no endorsements. The right product is the one that fits your constraints; the method for choosing controls is the same regardless.

## The worked examples

There is no single AI design, so there is no single threat profile. A public FAQ bot and a credit-decisioning model share almost no risks. This section works through five systems across the risk tiers, each chosen to put a different cluster of risks in the foreground, so you can find the one closest to your design and see which risks it forces you to confront.

| Example | Tier | The system | Risks it spotlights |
|---------|------|------------|---------------------|
| [Public FAQ Assistant](example-faq-low.md) | LOW | Unauthenticated website chatbot over public docs | RAG over editable content, reputational prompt injection, abuse and cost, not over-engineering |
| [Internal Knowledge Assistant](example-knowledge-medium.md) | MEDIUM | Employee assistant over confidential internal documents | RAG security, identity-aware (access-controlled) retrieval, indirect injection, data classification |
| [Customer-Service Assistant](worked-example.md) | HIGH | Authenticated bank assistant with read and gated write tools | Tooling and excessive agency, identity and least privilege, sensitive-data leakage |
| [MCP Engineering Agent](example-mcp-agent.md) | HIGH | Internal agent operating systems through MCP servers | MCP and tool supply chain, tool-description and tool-output injection, delegation and non-human identity, sandboxing |
| [Credit Decisioning Support](example-decisioning-critical.md) | CRITICAL | Model assisting credit decisions, self-hosted and fine-tuned | Model poisoning and backdoors, provenance and integrity, open-weight burden, fairness and maximum oversight |

The [Customer-Service Assistant](worked-example.md) walks the **full method** end to end, from the decision to use AI through to resilience. The other four are focused: each states the system, justifies the tier, and concentrates on what is *different* about its risk profile and the controls that follow. Read the customer-service example first for the method, then the one nearest your design.

!!! tip "Match the example to your design, not your industry"
    The risks follow the *shape* of the system (does it retrieve, does it act, does it use MCP, do you host the model), not the sector. A healthcare RAG assistant and a legal RAG assistant face the Internal Knowledge Assistant's risks, not each other's.

## The path

| Step | Page | The question it answers |
|------|------|--------------------------|
| 1 | [Should You Use AI?](should-you-use-ai.md) | Is AI the right solution here, or is something simpler and safer? |
| 2 | [Worked Examples](worked-example.md) | How do the threat model, risk tier, and controls come together for a system like mine? |
| 3 | [Selecting Guardrails](selecting-guardrails.md) | How do I choose the right guardrails and match each control to the risk? |
| 4 | [Scaling and PACE](scaling-and-pace.md) | How do I scale this, and how do I use PACE resilience properly? |

!!! tip "Read it as a path, use it as a reference"
    The first time through, read in order; the examples build on the method. Afterwards, each page stands alone as a how-to you can return to. Every step links back to the underlying reference pages ([Threat Modelling](../threat-modelling.md), [Risk Tiers](../core/risk-tiers.md), [Controls](../core/controls.md), [Infrastructure & Operations](../infrastructure/README.md)) when you need the detail.

!!! info "References"
    - [Threat Modelling for AI Systems](../threat-modelling.md)
    - [Risk Tiers and Control Selection](../core/risk-tiers.md)
    - [Controls: Guardrails, Judge, and Human Oversight](../core/controls.md)
    - [AI Runtime Security](https://airuntimesecurity.io/)
