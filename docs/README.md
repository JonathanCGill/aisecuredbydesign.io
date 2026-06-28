---
description: AI Secured by Design, the security architect's hub for designing AI systems that achieve runtime security. Threat modelling, risk-based control selection, testing, identity, logging, and monitoring.
hide:
  - title
---

<div class="home-subtitle" markdown>
**Design AI systems that achieve runtime security.**

A working hub for the security architect: how to threat model an AI system, which risks to worry about, which controls to apply for each risk, what to test, and how to run identity, logging, and monitoring once it is live.
</div>

<div class="pull-quote" markdown>
> Runtime security is won or lost at design time. The architect who maps the threats, sizes the risk, and chooses controls that match it gives the running system far less to catch. This site is where that design work happens.
</div>

## Who this is for

You are designing or reviewing an AI system and you are accountable for it being secure when it runs. You need technical answers, not slideware: where the threats are, which controls actually address them, how to size the effort to the risk, and how to prove it works. The material here is organised as the path an architect walks, from a blank threat model to a system you can operate.

## The design workflow

<div class="home-paths" markdown>
<div class="home-path" markdown>
#### 1. Threat model
Map the assets, trust boundaries, and AI-specific attack surface (prompt injection, poisoning, tool abuse, data exfiltration) before you choose a single control.

[Start threat modelling](threat-modelling.md){ .md-button }
</div>

<div class="home-path" markdown>
#### 2. Size the risk
Classify the system into a risk tier and quantify residual risk, so the controls you choose are proportionate to the harm the system could cause.

[Classify and assess risk](core/risk-tiers.md){ .md-button }
</div>

<div class="home-path" markdown>
#### 3. Choose controls
Apply the three-layer pattern (guardrails, Judge, human oversight) and the agentic and IAM controls each risk tier demands. Select what applies, deselect what does not.

[Select controls](core/README.md){ .md-button }
</div>

<div class="home-path" markdown>
#### 4. Test and validate
Adversarially test the design, then run it through production-readiness gates before it ships.

[Test the design](getting-started/adversarial-testing.md){ .md-button }
</div>

<div class="home-path" markdown>
#### 5. Operate
Stand up the infrastructure that makes the controls real: identity and access, logging and observability, network segmentation, secrets, and incident response.

[Operate securely](infrastructure/README.md){ .md-button }
</div>
</div>

## Choosing the model and platform

Two decisions shape every control choice that follows: **which model** you trust and **where** you run it. Model selection (provenance, evaluation, vulnerability scanning) and platform selection (cloud, self-hosted, hybrid) each carry distinct risks, and the secure pipeline that builds and deploys the system has to hold them together. See [Build & Deploy](building/README.md) and [Model Selection](building/model-selection/README.md).

## How this aligns with AI Runtime Security

[AI Runtime Security](https://airuntimesecurity.io/) (AIRS) is the parent framework and the operational companion: it owns the runtime control definitions, the [MASO](https://airuntimesecurity.io/maso/) multi-agent framework, and the day-to-day execution of guardrails, Judge evaluation, human oversight, and incident response. This site is the **design counterpart**, where an architect assembles those controls into a solution. Where the two overlap, airuntimesecurity.io is authoritative.

<div class="runtime-callout" markdown>
<p class="runtime-callout__label">Operational companion</p>
<p class="runtime-callout__title">AI Runtime Security</p>
<p class="runtime-callout__desc">Once the system you designed is running, AIRS covers the operations: guardrails, monitoring, the Judge, human oversight, MASO, and incident response.</p>

[Go to AI Runtime Security](https://airuntimesecurity.io/){ .md-button }
</div>
