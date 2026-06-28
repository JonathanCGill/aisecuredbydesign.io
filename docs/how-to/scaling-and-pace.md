---
description: How to scale an AI system's controls from pilot to production without losing affordability or oversight, and how to use PACE resilience properly to define fail postures for every control layer.
---

# Scaling and PACE

A design that works for a hundred conversations a day can quietly fail at a hundred thousand: the Judge bill grows linearly, the human review queue overflows, and a second agent turns a simple system into a multi-agent one. This page covers the two things that remain after the [Worked Example](worked-example.md) is built: scaling the controls with the system, and defining what happens when each control degrades.

## Scaling is not just more traffic

There are four independent axes of scale, and they stress different controls:

| Axis | What grows | What it stresses |
|------|-----------|------------------|
| **Volume** | Requests per second | Guardrail and Judge cost and latency; logging throughput |
| **Scope** | Number of use cases the system covers | Threat surface; per-use-case tuning; classification drift |
| **Autonomy** | How much the system does without a human | Oversight capacity; agentic controls |
| **Agents** | Number of cooperating agents | Trust between agents; emergent failure ([MASO](https://airuntimesecurity.io/maso/)) |

Scaling safely means scaling the *controls* along the axis that is actually growing, not uniformly.

### Scaling the Judge and human review

These two are where cost and capacity bite first.

- **The Judge** evaluates with a model, so 100% evaluation at scale is expensive and adds latency. Scale it with **risk-proportionate sampling**: evaluate all high-risk outputs (customer-facing, financial, PII-bearing) and sample the rest, using a tiered cascade (cheap rule check → small model → large model → human) so the expensive evaluation only runs when the cheap one is uncertain. The depth follows the tier, not a flat rate.
- **Human review** does not scale linearly; people do not. Design so that review volume is a function of *flagged* items, not total items, and tune the flagging threshold to the capacity you can actually staff. If you cannot staff the review your tier requires, that is a finding, not a detail: either raise automation thresholds (and accept more blocking) or narrow scope.

For Meridian, going to the full customer base means the Judge moves to "all high-risk plus sampled" rather than "all outputs," and the dispute-confirmation queue gets staffed to its expected flag rate with headroom.

### Scaling autonomy and agents

Adding autonomy or a second agent is a re-tiering event, not a tuning change. Re-run the [decision filter](should-you-use-ai.md) and the [threat model](../threat-modelling.md). When agents start talking to agents, the failure modes become emergent and the controls move into [MASO](https://airuntimesecurity.io/maso/) territory; treat that as a new design, not an extension of the old one.

!!! tip "Log what you drop"
    Every scaling shortcut (sampling instead of full evaluation, threshold-based flagging) means some things are not inspected. Record what is sampled out and at what rate, so "we evaluate at scale" never silently becomes "we evaluate almost nothing."

## Using PACE properly

PACE is borrowed from communications planning: **Primary, Alternate, Contingency, Emergency**. Applied to AI security it answers one question for every control: *what do we do when this degrades?* It is a mandatory design input, decided before launch, not an operational afterthought. The full model lives in [Control Layer Resilience](../core/pace-controls-section.md); this is how to use it.

### The two axes

People most often misuse PACE by treating it as a single fallback chain. It is two axes:

- **Per-control (vertical):** each control layer has its own degradation states, from Normal down to Compromised, with a defined response at each. The [PACE control-layer page](../core/pace-controls-section.md) defines these for guardrails, the Judge, and human oversight.
- **Cross-layer (horizontal):** when one layer is exhausted (at its Emergency state), the architecture-level response decides whether the remaining layers can carry the load or whether the [circuit breaker](../core/agentic.md#5-circuit-breakers) trips to a non-AI fallback.

### The four states, correctly

For each control layer, at each risk tier, define:

| State | Meaning | The decision it forces |
|-------|---------|------------------------|
| **Primary** | Normal operation | What "healthy" looks like, so you can detect departure from it |
| **Alternate** | Degraded but functioning | Fall back to a simpler, stricter mode; over-block rather than under-block |
| **Contingency** | The layer is down | Fail open or fail closed? The tier decides |
| **Emergency** | The layer is compromised | Stop, preserve forensics, escalate |

The single most important choice is **fail-open versus fail-closed at Contingency**, and it is tier-dependent: a LOW-tier assistant may keep serving when guardrails drop (fail-open, relying on the Judge); a HIGH or CRITICAL system holds or stops (fail-closed). Decide this per layer, per tier, in writing, before launch.

### The non-AI fallback

Every system at MEDIUM tier and above needs a documented, tested non-AI fallback that **shares no dependencies** with the AI system. It is what the circuit breaker routes to when AI operation is no longer safe. An untested fallback is not a fallback.

### Worked example: Meridian's fail postures

A few of Meridian's HIGH-tier decisions, taken from the [control-layer PACE model](../core/pace-controls-section.md):

- **Guardrails down (Contingency):** fail closed. Hold outputs for Judge plus human review; if the Judge is also degraded, route to the non-AI path (search and contact-centre handoff).
- **Judge down (Contingency):** hold outputs for human review until restored; if the review queue exceeds capacity, throttle assistant throughput to match.
- **Review queue overloaded (Contingency):** tighten Judge thresholds to cut borderline flags, pull in trained reviewers; if still overloaded, constrain the assistant to read-only so no gated action can queue.
- **Two layers compromised at once:** circuit breaker trips immediately regardless of tier; the non-AI path serves traffic; incident response begins.

Meridian writes these into the design and tests them, using the [PACE checklist](../core/pace-checklist-section.md), the same way it tests the controls themselves.

!!! tip "PACE is design, not documentation"
    A fail posture that exists only on paper fails in production. Trigger each transition in testing: degrade a guardrail, take the Judge offline, flood the queue, and confirm the system does what the plan says. Resilience you have not exercised is a hypothesis.

!!! info "References"
    - [Control Layer Resilience: Internal PACE](../core/pace-controls-section.md)
    - [PACE for Agentic AI](../core/pace-agentic-section.md)
    - [PACE Resilience Checklist](../core/pace-checklist-section.md)
    - [Agentic AI Controls: Circuit Breakers](../core/agentic.md#5-circuit-breakers)
    - [AI Runtime Security: MASO](https://airuntimesecurity.io/maso/)
