---
description: What AI pre-runtime security means, why it matters, and how it fits into the complete AI security lifecycle.
---

# Securing AI Before Deployment

AI pre-runtime security is the discipline of securing AI systems before they reach production. It covers every decision and process from initial model selection through to the deployment gate: choosing models, selecting platforms, building pipelines, securing data, and validating that what you are about to deploy is trustworthy.

## Why pre-runtime matters

Runtime security gets most of the attention. Guardrails, output filtering, anomaly detection, human oversight. These are important. But they work best when the system being monitored is fundamentally sound.

When pre-runtime security is weak, runtime has a much harder job:

- A model trained on poisoned data produces subtly wrong outputs that are difficult to distinguish from normal behaviour
- A backdoor introduced during fine-tuning may only activate under specific conditions, making it hard to catch at runtime
- A pipeline with no integrity controls means runtime security cannot trust what was deployed
- Weak platform access controls create exposure that runtime monitoring may not cover
- Unverified model provenance means runtime controls are protecting a system of unknown origin

Runtime security can still contain damage in these cases, but the problems are harder to detect, slower to surface, and more costly to fix. Pre-runtime security addresses these root causes directly, so runtime controls can focus on genuinely unexpected behaviour rather than inherited weaknesses.

## The AI security lifecycle

| Phase | Focus | Covered by |
|-------|-------|------------|
| **Model selection** | Choosing and verifying models | This site |
| **Platform selection** | Infrastructure and hosting decisions | This site |
| **Development** | Secure AI-aware SDLC | This site |
| **Pipeline security** | DevOps and MLOps for AI | This site |
| **Data security** | Training data, RAG pipelines, embeddings | This site |
| **Validation** | Pre-deployment testing and gates | This site |
| **Deployment** | The handoff point | Both sites |
| **Runtime monitoring** | Guardrails, oversight, incident response | [AI Runtime Security](https://airuntimesecurity.io/) |

## Core principle

**Security decisions made before deployment constrain what is possible after deployment.**

A well-chosen model on a well-configured platform, built through a secure pipeline with validated data, gives runtime controls something worth protecting. A poorly chosen model on an insecure platform, pushed through an unverified pipeline with untested data, forces runtime controls to compensate for problems that should never have reached production.

## What is different about securing AI?

Traditional software security assumes deterministic systems. You write code, test it, deploy it, and it behaves as tested. AI systems break this assumption.

**Non-determinism.** The same input can produce different outputs. You cannot fully test what you cannot fully predict.

**Data dependency.** AI behaviour is shaped by training data, not just code. Changing the data changes the system, often in ways that are difficult to detect.

**Model opacity.** You cannot read a model's weights and understand what it will do. Verification requires different techniques than code review.

**Supply chain complexity.** Models come from external sources, trained on external data, using external frameworks. The attack surface is broader than traditional software.

**Prompt sensitivity.** In LLM-based systems, prompt changes can alter behaviour more significantly than code changes. This requires different change management approaches.

These differences mean that traditional security practices (code review, static analysis, penetration testing) are necessary but insufficient. AI systems require additional, AI-specific security controls applied before deployment.

## What you will find on this site

This site is organised around the practical decisions teams make when building AI systems:

1. **[Getting Started](getting-started/README.md)** covers risk classification, regulatory alignment, adversarial testing requirements, and production readiness. Start here to determine the right level of security for your specific AI system.
2. **Model Selection** covers choosing models securely: provenance, integrity, risk assessment, and vulnerability scanning
3. **Platform Selection** covers where to run AI: cloud services, self-hosted, and hybrid approaches with their distinct security tradeoffs
4. **AI DevOps** covers building and deploying securely: CI/CD for AI, infrastructure as code, and secrets management
5. **MLOps Security** covers the ML pipeline: training, validation, lifecycle management, and experiment tracking

Each section focuses on what you need to do, not just what you need to know. The goal is practical guidance that teams can apply immediately. Every recommendation is scaled to the [risk tier](getting-started/risk-classification.md) of your system, so controls are proportionate to the harm the system could cause.

!!! info "References"
    - [OWASP Machine Learning Security Top 10](https://owasp.org/www-project-machine-learning-security-top-10/)
    - [NIST AI Risk Management Framework](https://www.nist.gov/itl/ai-risk-management-framework)
    - [MITRE ATLAS](https://atlas.mitre.org/)
    - [AI Runtime Security](https://airuntimesecurity.io/)
