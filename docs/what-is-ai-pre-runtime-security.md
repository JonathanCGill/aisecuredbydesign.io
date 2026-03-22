---
description: What AI pre-runtime security means, why it matters, and how it fits into the complete AI security lifecycle.
---

# What is AI Pre-Runtime Security?

AI pre-runtime security is the discipline of securing AI systems before they reach production. It covers every decision and process from initial model selection through to the deployment gate: choosing models, selecting platforms, building pipelines, securing data, and validating that what you are about to deploy is trustworthy.

## Why pre-runtime matters

Runtime security gets most of the attention. Guardrails, output filtering, anomaly detection, human oversight. These are important. But they share a common assumption: the system being monitored is fundamentally sound.

That assumption breaks when:

- The model was trained on poisoned data
- A backdoor was introduced during fine-tuning
- The pipeline that built the model had no integrity controls
- The platform hosting the model has weak access controls
- Nobody verified the model's provenance before deploying it

No runtime guardrail catches a backdoored model. No output filter fixes a poisoned training set. No monitoring dashboard alerts on a supply chain compromise that happened three months ago during training.

Pre-runtime security addresses the root causes that runtime controls cannot.

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

A well-chosen model on a well-configured platform, built through a secure pipeline with validated data, gives runtime controls something worth protecting. A poorly chosen model on an insecure platform, pushed through an unverified pipeline with untested data, gives runtime controls an impossible job.

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

1. **Model Selection** covers choosing models securely: provenance, integrity, risk assessment, and vulnerability scanning
2. **Platform Selection** covers where to run AI: cloud services, self-hosted, and hybrid approaches with their distinct security tradeoffs
3. **AI DevOps** covers building and deploying securely: CI/CD for AI, infrastructure as code, and secrets management
4. **MLOps Security** covers the ML pipeline: training, validation, lifecycle management, and experiment tracking

Each section focuses on what you need to do, not just what you need to know. The goal is practical guidance that teams can apply immediately.

!!! info "References"
    - [OWASP Machine Learning Security Top 10](https://owasp.org/www-project-machine-learning-security-top-10/)
    - [NIST AI Risk Management Framework](https://www.nist.gov/itl/ai-risk-management-framework)
    - [MITRE ATLAS](https://atlas.mitre.org/)
    - [AI Runtime Security](https://airuntimesecurity.io/)
