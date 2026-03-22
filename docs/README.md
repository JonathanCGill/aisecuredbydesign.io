---
description: AI Secured by Design, securing AI before it runs. The complete pre-runtime security framework for AI systems.
hide:
  - title
---

<div class="home-subtitle" markdown>
**Secure AI before it runs.**

Pre-runtime security covers every decision made before an AI system reaches production: which model to use, where to host it, how to build the pipeline, and how to validate what you are deploying.
</div>

<div class="pull-quote" markdown>
> A compromised model makes AI even less predictable. A poisoned dataset corrupts outputs in ways that may be subtle and slow to surface. An insecure pipeline makes every deployment suspect. Security starts before deployment, because the harder you make it for problems to reach production, the less runtime security has to catch.
</div>

## The problem

Most AI security guidance focuses on what happens after deployment: guardrails, monitoring, incident response. That matters. But by the time a model is running in production, the most consequential security decisions have already been made.

Which model did you choose, and can you verify its integrity? Where is it hosted, and who controls the infrastructure? How does your pipeline move a model from experiment to production? What data trained it, and who had access?

These are pre-runtime questions. Get them wrong, and runtime security has to work much harder to prevent issues that could have been avoided entirely.

## Start here

<div class="home-paths" markdown>
<div class="home-path" markdown>
#### Getting Started
Classify the risk level of your AI system, understand your regulatory obligations, and follow the right security path. Everything else on this site is risk-proportionate, so start with classification.

[Classify Your System](getting-started/README.md){ .md-button }
</div>
</div>

## What this site covers

<div class="home-paths" markdown>
<div class="home-path" markdown>
#### Model Selection
Choosing a model is a security decision. Provenance verification, risk assessment, vulnerability scanning, and understanding the tradeoffs between open-weight and closed API models.

[Explore Model Selection](building/model-selection/README.md){ .md-button }
</div>

<div class="home-path" markdown>
#### Platform Selection
Where you run AI determines your security posture. Cloud AI services, self-hosted infrastructure, and hybrid patterns each carry distinct risks and responsibilities.

[Explore Platform Selection](building/platform-selection/README.md){ .md-button }
</div>

<div class="home-path" markdown>
#### AI DevOps
CI/CD for AI is not the same as CI/CD for software. Pipeline integrity, infrastructure as code for ML environments, and secrets management for model endpoints and data credentials.

[Explore AI DevOps](building/devops/README.md){ .md-button }
</div>

<div class="home-path" markdown>
#### MLOps Security
The pipeline that trains, validates, and deploys models must itself be secure. Secure ML pipelines, model lifecycle management, and experiment tracking security.

[Explore MLOps Security](building/mlops/README.md){ .md-button }
</div>
</div>

## Runtime controls and infrastructure

This site now includes the runtime control definitions and infrastructure controls that were previously only on [AI Runtime Security](https://airuntimesecurity.io/). This means you can see the full picture in one place: the [three-layer control pattern](core/controls.md) (guardrails, Judge, human oversight), the [80 infrastructure controls](infrastructure/README.md) (IAM, logging, network, data protection, secrets, supply chain, incident response), and [stakeholder-specific views](stakeholders/README.md) for every role involved in AI security.

The [AI-Aware SDLC](getting-started/ai-sdlc.md) ties everything together into a single lifecycle from ideation through production.

## What comes next: runtime security

This site covers the complete AI security lifecycle, from pre-runtime decisions through to the control definitions that runtime operations implement. [AI Runtime Security](https://airuntimesecurity.io/) is the operational companion, covering the day-to-day execution of guardrails, Judge evaluation, human oversight, and incident response in production.

<div class="runtime-callout" markdown>
<p class="runtime-callout__label">Continue to</p>
<p class="runtime-callout__title">AI Runtime Security</p>
<p class="runtime-callout__desc">The sequel to this site. Once your AI system is deployed, runtime controls take over: guardrails, monitoring, human oversight, and incident response.</p>

[Continue to AI Runtime Security](https://airuntimesecurity.io/){ .md-button }
</div>
