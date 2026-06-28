---
description: Why AI systems need different security practices, what makes them distinct from traditional software, and practical guidance for securing every decision from model selection through deployment.
---

# Build & Deploy

Once you have threat modelled the system and chosen controls, you have to build and deploy it without undoing that work. This section covers the platform, pipeline, and data decisions that turn a control design into a running system: where you host it, how the pipeline moves it to production, and how you keep integrity from training through deployment.

Two related design decisions live in their own sections: choosing and verifying the model sits under [Threats & Risk](model-selection/README.md), and designing the runtime control set sits under [Controls](secure-design-guardrails.md). This section is everything between those choices and a deployed system.

## Why the build pipeline matters

Runtime security gets most of the attention. Guardrails, output filtering, anomaly detection, human oversight. These are important. But they work best when the system being monitored is fundamentally sound.

When pre-runtime security is weak, runtime has a much harder job:

- A model trained on poisoned data produces subtly wrong outputs that are difficult to distinguish from normal behaviour
- A backdoor introduced during fine-tuning may only activate under specific conditions, making it hard to catch at runtime
- A pipeline with no integrity controls means runtime security cannot trust what was deployed
- Weak platform access controls create exposure that runtime monitoring may not cover
- Unverified model provenance means runtime controls are protecting a system of unknown origin

Runtime security can still contain damage in these cases, but the problems are harder to detect, slower to surface, and more costly to fix. Pre-runtime security addresses these root causes directly, so runtime controls can focus on genuinely unexpected behaviour rather than inherited weaknesses.

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

## The AI security lifecycle

| Phase | Focus | Covered by |
|-------|-------|------------|
| **Threat modelling** | Mapping the attack surface | [Threat Modelling](../threat-modelling.md) |
| **Model selection** | Choosing and verifying models | [Threats & Risk](model-selection/README.md) |
| **Control design** | Selecting the runtime control set | [Controls](secure-design-guardrails.md) |
| **Platform selection** | Infrastructure and hosting decisions | This section |
| **Development** | Secure AI-aware SDLC | [Start Here](../getting-started/ai-sdlc.md) |
| **Pipeline security** | DevOps and MLOps for AI | This section |
| **Data security** | Training data, RAG pipelines, embeddings | This section |
| **Validation** | Pre-deployment testing and gates | [Test & Validate](../getting-started/adversarial-testing.md) |
| **Deployment** | The handoff point | [Production Readiness](../getting-started/production-readiness.md) |
| **Operations** | Identity, logging, monitoring, incident response | [Infrastructure & Operations](../infrastructure/README.md) |

## Building securely

Each choice, which platform, which pipeline, which data, constrains what is possible downstream and determines the security posture of the deployed system. This section covers three areas where those build-and-deploy decisions are made:

- **[Platform Selection](platform-selection/README.md)** covers where and how you host AI workloads
- **[AI DevOps](devops/README.md)** covers the pipelines that build, test, and deploy AI systems
- **[MLOps Security](mlops/README.md)** covers the ML-specific lifecycle from training through production

These areas are not independent. A platform choice constrains pipeline design. A pipeline design constrains what validation is possible. Security decisions compound, which is why they follow the model choice ([Threats & Risk](model-selection/README.md)) and the control design ([Controls](secure-design-guardrails.md)) rather than preceding them.

!!! tip "Start with risk classification"
    If you have not yet classified the risk tier of your AI system, do that first. The [Start Here](../getting-started/README.md) section walks through risk classification, regulatory alignment, and the lifecycle. The tier you assign drives the level of rigour required across everything in this section. Then work through platform, DevOps, and MLOps in order.

!!! info "References"
    - [OWASP Machine Learning Security Top 10](https://owasp.org/www-project-machine-learning-security-top-10/)
    - [NIST AI Risk Management Framework](https://www.nist.gov/itl/ai-risk-management-framework)
    - [MITRE ATLAS](https://atlas.mitre.org/)
    - [AI Runtime Security](https://airuntimesecurity.io/)
