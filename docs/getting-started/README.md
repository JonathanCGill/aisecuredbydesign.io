---
description: Start here. Classify the risk level of your AI system, understand your regulatory obligations, and follow the right security path for your context.
---

# Getting Started

Before building controls, you need to know what you are building controls for. This section helps you answer three questions:

1. **What is the risk level of your AI system?** A public FAQ bot and an autonomous trading agent need very different security postures.
2. **What are your legal and regulatory obligations?** Your country, industry, and the nature of the AI system determine the compliance baseline.
3. **What does the right security path look like for your context?** Not every system needs every control. Risk-proportionate security means applying the right controls at the right level.

## Where to start

<div class="home-paths" markdown>
<div class="home-path" markdown>
#### AI-Aware SDLC
The complete lifecycle from ideation through production. If you want to see how everything fits together, start here. It maps each phase to the relevant guidance across this site and shows where risk classification, model selection, infrastructure controls, testing, and runtime handoff connect.

[View the Lifecycle](ai-sdlc.md){ .md-button }
</div>

<div class="home-path" markdown>
#### Risk Classification
Determine the risk tier for your AI system. The tier drives every subsequent security decision, from control selection to testing cadence to human oversight requirements. This framework aligns with the [AI Runtime Security](https://airuntimesecurity.io/core/risk-tiers/) risk tiers so that pre-runtime and runtime controls stay in sync.

[Classify Your System](risk-classification.md){ .md-button }
</div>

<div class="home-path" markdown>
#### Regulatory Alignment
Identify the laws and standards that apply to your AI system. The EU AI Act, privacy regulations, cyber security laws, and industry-specific rules all factor into your risk posture and control requirements.

[Check Your Obligations](regulatory-alignment.md){ .md-button }
</div>

<div class="home-path" markdown>
#### Adversarial Testing
Understand when and how to test your AI system against deliberate attacks. Testing requirements scale with risk tier, from basic validation at LOW to continuous red-teaming at CRITICAL.

[Plan Your Testing](adversarial-testing.md){ .md-button }
</div>

<div class="home-path" markdown>
#### Production Readiness
Prepare your AI system for the transition from development to production. This includes deployment gates, observability setup, and ensuring runtime security teams have visibility from day one.

[Prepare for Production](production-readiness.md){ .md-button }
</div>
</div>

## The risk-first approach

Everything on this site is risk-proportionate. A LOW-tier system (a public FAQ bot using only public data) does not need the same controls as a CRITICAL-tier system (an autonomous agent making financial decisions). Starting with risk classification ensures you invest security effort where it matters most.

The risk tiers used here are the same tiers used by [AI Runtime Security](https://airuntimesecurity.io/). This is intentional. Pre-runtime decisions (model selection, platform choice, pipeline security, data governance) and runtime controls (guardrails, Judge evaluation, human oversight) must operate from the same risk framework. Otherwise, you build to one standard and operate to another.

!!! tip "Risk appetite is yours to define"
    This framework provides structure, not mandates. Your organisation's risk appetite, combined with applicable laws and the specific context of each AI use case, determines where you set the line. Two organisations using the same model for the same purpose may legitimately arrive at different tier assignments based on their risk tolerance, regulatory environment, and operational maturity.
