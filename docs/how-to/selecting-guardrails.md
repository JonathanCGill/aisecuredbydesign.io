---
description: How to select the right guardrails for an AI system, match each control to the risk it addresses, and choose among categories of technical solution without endorsing specific products.
---

# Selecting Guardrails and Matching Controls to Risk

Guardrails are the layer most teams reach for first and configure worst. The failure mode is predictable: turn on everything the platform offers, over-block legitimate traffic, erode trust, then turn it all off. This page is the method for choosing guardrails deliberately, so each one is there because a specific threat at a specific risk tier put it there.

It continues the [Worked Example](worked-example.md): we already know Meridian is HIGH tier with a known threat catalogue. Now we choose the guardrails.

## Start from threats and tier, never from the feature list

A guardrail is a control, and a control exists to reduce a specific risk. So the selection order is fixed:

1. **Take the threats** from your [threat model](../threat-modelling.md).
2. **Take the tier** from your [risk classification](../core/risk-tiers.md).
3. **For each threat, ask what would have to be true to stop it**, then pick the guardrail that makes it true at the depth the tier demands.

The [control matrix](../core/risk-tiers.md#control-matrix) gives the baseline depth per tier (Basic, Standard, Enhanced, Maximum). The matrix tells you *how much*; the threat tells you *which*.

## Input versus output guardrails

The two do different jobs and fail differently.

| | Input guardrails | Output guardrails |
|---|---|---|
| **Job** | Stop bad things reaching the model | Stop bad things reaching the user or a tool |
| **Catches** | Injection, jailbreaks, off-topic, oversized input | PII leakage, policy breaches, unsafe or malformed output |
| **Failure if missing** | Model is manipulated | Manipulation reaches the world |

You need both. Input guardrails reduce how often the model is pushed off course; output guardrails are what stand between a model that *was* pushed off course and the consequence. At HIGH and above, never rely on input filtering alone, because injection techniques evolve faster than input filters.

## What to turn on first

Order by leverage, not by what is easiest to enable:

1. **Logging.** You cannot tune what you cannot see. Capture model I/O, guardrail decisions, and tool calls before anything else ([Logging & Observability](../infrastructure/controls/logging-and-observability.md)).
2. **The few high-value filters.** PII detection on output, injection detection on input, and topic/scope limits catch the largest share of real problems for the least false-positive cost.
3. **Schema and parameter validation** wherever the model's output drives an action. A write tool should accept only well-formed, in-bounds parameters.
4. **The Judge in shadow mode.** Let it evaluate without acting, so you can calibrate before you let it hold traffic ([Model-as-Judge](../core/controls.md#2-model-as-judge)).
5. **Then tune up** based on what the logs and the Judge actually surface.

## Matching controls to risk: the method

For each threat, write one line: *threat → control → enforcement point → tier depth*. The enforcement point matters as much as the control. **Infrastructure beats instructions**: a control enforced by a gateway, a broker, or a vault holds under attack; the same control expressed as a sentence in the system prompt does not.

Meridian's mapping, abbreviated:

| Threat | Control | Enforcement point | HIGH depth |
|--------|---------|-------------------|-----------|
| Direct injection | Injection detection + scope limit | Input guardrail service | Enhanced |
| Indirect injection (RAG) | Untrusted-content handling; instructions stripped | Retrieval service | Enhanced |
| PII / cross-customer leakage | Output PII and leakage checks | Output guardrail service | Enhanced |
| Excessive agency | Tool permissions and parameter bounds | Tool broker (not the prompt) | Enforced |
| High-impact action | Step-up auth / human confirmation | Gating step before commit | Required |

If a control can only be expressed as "we ask the model not to," it is not yet a control. Move it to an enforcement point.

## Categories of technical solution

These are categories, not recommendations. The right choice depends on latency budget, data residency, in-house skills, and how much you are willing to operate yourself. No product is named because the method does not depend on one.

| Category | Good at | Watch out for |
|----------|---------|---------------|
| **Deterministic filters** (regex, denylists, schema validation) | Fast, explainable, cheap; ideal for structured checks and known patterns | Brittle against paraphrase and novel attacks |
| **Classifier models** (small, purpose-trained) | Catching fuzzy categories (toxicity, injection) that rules miss | Need calibration; add latency; can drift |
| **LLM-based evaluators** (the Judge) | Nuanced, context-aware evaluation of open-ended output | Cost and latency; can themselves be fooled ([Judge Assurance](../core/judge-assurance.md)) |
| **Policy / authorization engines** | Deterministic decisions about who and what may act | Only as good as the policy; must sit outside the model |
| **Gateways and brokers** | Enforcing identity, rate limits, and tool permissions at the boundary | A single point that must be hardened and highly available |
| **Platform-managed guardrails** | Fast to adopt; maintained for you | Less control; verify coverage against *your* threats, not the vendor's list |

### Build, buy, or use managed

A quick way to decide, without naming products:

- **Use managed/platform controls** when your threats are common, your latency budget is generous, and you would rather not operate the control yourself. Verify the managed control actually covers the threats in *your* model.
- **Buy a dedicated tool** when you need depth or coverage the platform lacks and the category is mature.
- **Build** only the thin layer that encodes *your* policy and *your* enforcement points, which no vendor can know. Most teams should build less than they think and integrate more.

!!! warning "Over-blocking is a security failure too"
    A guardrail tuned so tight that staff route around the system, or customers abandon it, has reduced security, not increased it. Measure false-positive rate alongside catch rate, and tune to the tier: a LOW-tier FAQ bot should err toward letting traffic through; a CRITICAL action should err toward blocking.

!!! info "References"
    - [Controls: Guardrails, Judge, and Human Oversight](../core/controls.md)
    - [Risk Tiers: Control Matrix](../core/risk-tiers.md#control-matrix)
    - [Judge Assurance](../core/judge-assurance.md)
    - [Logging & Observability](../infrastructure/controls/logging-and-observability.md)
    - [OWASP Top 10 for LLM Applications](https://owasp.org/www-project-top-10-for-large-language-model-applications/)
