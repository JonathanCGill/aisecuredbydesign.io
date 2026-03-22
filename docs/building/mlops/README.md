---
description: MLOps security, securing the ML-specific lifecycle from training through validation, registry, and production deployment.
---

# MLOps Security

MLOps is the discipline of managing the machine learning lifecycle: training, evaluation, registration, deployment, and monitoring. If DevOps secures the delivery pipeline, MLOps secures what flows through it.

An insecure MLOps practice means every model it produces is suspect. Training on the wrong data, skipping validation, deploying without approval, losing track of which model version is in production: these are all MLOps failures with direct security consequences.

## What MLOps security covers

| Stage | Security concern | Consequence of failure |
|-------|-----------------|----------------------|
| **Training** | Data integrity, compute security, reproducibility | Poisoned or compromised models |
| **Evaluation** | Honest metrics, adversarial testing, bias detection | Unsafe models pass validation |
| **Registration** | Versioning, integrity, access control | Wrong model deployed, tampering undetected |
| **Deployment** | Approval, canary, rollback | Untested models reach production |
| **Monitoring** | Drift detection, anomaly alerting | Degradation goes unnoticed |

## Core topics

- **[Secure ML Pipelines](secure-ml-pipelines.md)** covers end-to-end pipeline security from training through deployment, including reproducibility and attestation.
- **[Model Lifecycle](model-lifecycle.md)** covers managing models through their entire lifecycle: versioning, staging, production, retirement, and the approval gates between each stage.
- **[Experiment Tracking](experiment-tracking.md)** covers securing the experiment process, protecting intellectual property in hyperparameters and results, and managing access to experiment data.

!!! tip "MLOps is where pre-runtime and runtime meet"
    The deployment stage of MLOps is where this site's coverage ends and [AI Runtime Security](https://airuntimesecurity.io/) picks up. Pre-runtime ensures the model is trustworthy. Runtime ensures it stays trustworthy. A clean handoff requires both sides to agree on what "trustworthy" means and how to verify it.
