---
description: MLOps security, securing the ML-specific lifecycle from training through validation, registry, and production deployment.
---

# MLOps Security

MLOps is the discipline of managing the machine learning lifecycle: training, evaluation, registration, deployment, and monitoring. If DevOps secures the delivery pipeline, MLOps secures what flows through it.

An insecure MLOps practice means every model it produces is suspect. Training on the wrong data, skipping validation, deploying without approval, losing track of which model version is in production: these are all MLOps failures with direct security consequences.

## What makes MLOps security different

Traditional software follows a predictable path from code to deployment. ML systems add layers that traditional security does not cover.

**Data is an input, not just a storage concern.** In conventional applications, data sits in databases and gets queried. In ML, data is consumed during training and embedded into the model's weights. Compromised training data produces a compromised model, and the compromise persists even after the data is corrected.

**Models are opaque artefacts.** A compiled binary can be decompiled and inspected. A trained model's behaviour emerges from billions of parameters that resist direct inspection. A backdoored model can pass standard evaluation and only activate when it encounters a specific trigger pattern.

**The pipeline is the product.** In traditional software, the pipeline builds and delivers the product. In ML, the pipeline (data preparation, training, evaluation) creates the product. Securing the pipeline is not just about protecting the delivery mechanism. It is about protecting the creation process itself.

**Non-determinism is the norm.** Identical training runs can produce slightly different models. This makes verification harder: you cannot simply hash the output and compare. Security controls must account for acceptable variation while detecting meaningful divergence.

## What MLOps security covers

| Stage | Security concern | Consequence of failure |
|-------|-----------------|----------------------|
| **Data governance** | Lineage, classification, quality, compliance | Untraceable data, regulatory violations, poisoned models |
| **Training** | Data integrity, compute security, reproducibility | Poisoned or compromised models |
| **Evaluation** | Honest metrics, adversarial testing, bias detection | Unsafe models pass validation |
| **Registration** | Versioning, integrity, access control | Wrong model deployed, tampering undetected |
| **Deployment** | Approval, canary, rollback | Untested models reach production |
| **Monitoring** | Drift detection, anomaly alerting | Degradation goes unnoticed |

## Core topics

- **[Threat Intelligence](threat-intelligence.md)** covers the MLOps threat landscape, MITRE ATLAS mapping, real-world attack patterns, and how to build an MLOps threat intelligence practice.
- **[Data Governance](data-governance.md)** covers data lineage, versioning, classification, quality controls, and regulatory compliance for ML workflows.
- **[Secure ML Pipelines](secure-ml-pipelines.md)** covers end-to-end pipeline security from training through deployment, including reproducibility and attestation.
- **[Model Lifecycle](model-lifecycle.md)** covers managing models through their entire lifecycle: versioning, staging, production, retirement, and the approval gates between each stage.
- **[Foundation Model Access](foundation-model-access.md)** covers the governance structure for accessing foundation models: sourcing classification, risk tiering, minimum requirements, evaluation criteria, approval processes, and ongoing monitoring.
- **[Experiment Tracking](experiment-tracking.md)** covers securing the experiment process, protecting intellectual property in hyperparameters and results, and managing access to experiment data.

## Key frameworks and standards

Several frameworks provide structured guidance for MLOps security:

| Framework | Focus |
|-----------|-------|
| **[MITRE ATLAS](https://atlas.mitre.org/)** | Adversarial threat landscape for AI systems: 15 tactics, 66 techniques, real-world case studies |
| **[OWASP ML Security Top 10](https://owasp.org/www-project-machine-learning-security-top-10/)** | Prioritised risk categories for machine learning systems |
| **[SLSA](https://slsa.dev/)** | Supply-chain integrity framework, adaptable to ML pipeline attestation |
| **[OpenSSF MLSecOps](https://openssf.org/blog/2025/08/05/visualizing-secure-mlops-mlsecops-a-practical-guide-for-building-robust-ai-ml-pipeline-security/)** | Practical guide for building secure AI/ML pipelines using open-source tools |

!!! tip "MLOps is where pre-runtime and runtime meet"
    The deployment stage of MLOps is where this site's coverage ends and [AI Runtime Security](https://airuntimesecurity.io/) picks up. Pre-runtime ensures the model is trustworthy. Runtime ensures it stays trustworthy. A clean handoff requires both sides to agree on what "trustworthy" means and how to verify it.
