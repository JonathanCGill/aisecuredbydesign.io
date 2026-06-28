---
description: A CRITICAL-tier worked example, a self-hosted fine-tuned model assisting credit decisions, focused on model poisoning and backdoors, provenance and integrity, the open-weight burden, fairness, and maximum human oversight.
---

# CRITICAL Tier: Credit Decisioning Support

**The system:** a model that scores credit applications to support, and in some segments automate, lending decisions. To meet data-residency and performance needs, the bank runs a **self-hosted, open-weight model fine-tuned on its own historical lending data**. Outputs feed an adjudication workflow; for low-value segments the decision is automated, for the rest it informs a human underwriter.

This is the example where **the model is the risk**. The previous examples secured what goes *into* and *around* a trusted model. Here the bank built the model, so it owns a class of risk the others could outsource: poisoning, backdoors, provenance, and fairness. It is also where runtime oversight is at its most demanding.

## Why this is CRITICAL tier

From the [classification process](../core/risk-tiers.md#classification-process): automated decisions with direct financial and legal consequence, regulated fairness obligations, and sensitive personal data. Every dimension scores at the top. This is **CRITICAL**, the tier where automated-only operation for significant decisions is not acceptable and the control depth is maximum across the board.

## The open-weight burden shifts to you

Choosing a self-hosted, fine-tuned open-weight model is a security decision before it is a performance one. With a managed API, the provider carries much of the model-integrity burden. Self-host and [that burden shifts to you](https://airuntimesecurity.io/insights/open-weight-models-shift-the-burden/): you are now responsible for the weights, the fine-tuning pipeline, and everything that could be hiding in them.

## Model poisoning and supply chain

These risks are decided **pre-runtime**, during model selection and training, which is why this example leans on this site's [Model Selection](../building/model-selection/README.md) and [MLOps](../building/mlops/README.md) sections.

| Risk | What goes wrong | Where it is addressed |
|------|-----------------|------------------------|
| **Backdoors and trojans in the base model** | An open-weight model carries a hidden trigger that flips behaviour on a specific input | [Vulnerability Scanning](../building/model-selection/vulnerability-scanning.md), [SUP-01](../infrastructure/agentic/supply-chain.md) |
| **Provenance and integrity** | You cannot prove the weights are the ones you vetted, unmodified | [Provenance and Integrity](../building/model-selection/provenance-and-integrity.md), [SUP-01](../infrastructure/agentic/supply-chain.md) |
| **Serialisation risks** | Model files in unsafe formats execute code on load | [Vulnerability Scanning](../building/model-selection/vulnerability-scanning.md) |
| **Fine-tuning data poisoning** | Corrupted or biased training data bends the model's decisions, subtly and persistently | [Secure ML Pipelines](../building/mlops/secure-ml-pipelines.md), [SUP-04](../infrastructure/agentic/supply-chain.md), [Data Governance](../building/mlops/data-governance.md) |
| **Pipeline compromise** | An insecure training pipeline means you cannot trust what was deployed | [Secure ML Pipelines](../building/mlops/secure-ml-pipelines.md), [CI/CD for AI](../building/devops/ci-cd-for-ai.md) |

The controls are verification and integrity at every step: verify base-model provenance and scan it before use, secure and attest the fine-tuning pipeline, govern the training data's lineage, sign the resulting model, and verify that signature at load. A poisoned model is a poisoned system, and no runtime guardrail reliably detects a well-built backdoor.

## Fairness is a security property here

A credit model carries regulatory fairness obligations. Bias introduced through training data or fine-tuning is both a compliance failure and a poisoning symptom. Pre-deployment **bias and fairness testing** and **adversarial evaluation** are mandatory gates, not optional, alongside the explainability the decision must carry. See [Adversarial Testing](../getting-started/adversarial-testing.md), [Trust and Evaluation](../building/model-selection/trust-and-evaluation.md), and [Regulatory Alignment](../getting-started/regulatory-alignment.md).

## Maximum runtime oversight

At CRITICAL the [control matrix](../core/risk-tiers.md#control-matrix) calls for the deepest runtime controls, and the design must honour them:

- **Human oversight on every significant decision.** The model *recommends*; a human *decides* for anything material. Automation is confined to a narrow, well-evidenced low-value segment with tight thresholds. See [Human Oversight](../core/controls.md#3-human-oversight-hitl).
- **Real-time Judge.** Evaluate outputs (and the reasoning behind them) inline, not just on a sample, with conservative thresholds. See [Model-as-Judge](../core/controls.md#2-model-as-judge) and [Judge Assurance](../core/judge-assurance.md).
- **Full audit and explainability.** Every decision is logged with its inputs, the model version, and the rationale, sufficient to answer a regulator and to reconstruct any decision. See [Logging & Observability](../infrastructure/controls/logging-and-observability.md).
- **Circuit breakers and a non-AI fallback.** A tested, dependency-isolated manual adjudication path the system can fall back to. See [Scaling and PACE](scaling-and-pace.md) and [Circuit Breakers](../core/agentic.md#5-circuit-breakers).

!!! warning "You cannot inspect your way out of a poisoned model"
    Runtime monitoring catches anomalous *behaviour*, but a backdoor that only fires on a rare trigger may never show up in monitoring until it is exploited. That is why the integrity work happens before deployment: provenance, scanning, a secure fine-tuning pipeline, and signing. At CRITICAL, pre-runtime model security is not a nicety; it is the load-bearing control.

## What this example teaches

When you own the model, you own its integrity. The centre of gravity moves earlier, into model selection and MLOps, and the runtime controls (real-time Judge, human decision, full audit, circuit breaker) are the maximum the framework defines. Compare this with the [LOW FAQ Assistant](example-faq-low.md): same framework, opposite ends of the dial. The method, [Should You Use AI?](should-you-use-ai.md) → threat model → tier → controls, is identical; only the depth changes.

!!! info "References"
    - [Model Selection](../building/model-selection/README.md)
    - [Provenance and Integrity](../building/model-selection/provenance-and-integrity.md)
    - [Vulnerability Scanning](../building/model-selection/vulnerability-scanning.md)
    - [Secure ML Pipelines](../building/mlops/secure-ml-pipelines.md)
    - [Supply Chain Security Controls](../infrastructure/agentic/supply-chain.md)
    - [AI Runtime Security: Open-Weight Models Shift the Burden](https://airuntimesecurity.io/insights/open-weight-models-shift-the-burden/)
