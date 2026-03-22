---
description: Building AI systems securely, from model selection through platform decisions, DevOps pipelines, and MLOps practices.
---

# Building Securely

Building an AI system is a series of security decisions. Each choice, which model, which platform, which pipeline, which data, constrains what is possible downstream and determines the security posture of the deployed system.

This section covers four areas where those decisions are made:

- **[Model Selection](model-selection/README.md)** covers choosing and verifying the models your system depends on
- **[Platform Selection](platform-selection/README.md)** covers where and how you host AI workloads
- **[AI DevOps](devops/README.md)** covers the pipelines that build, test, and deploy AI systems
- **[MLOps Security](mlops/README.md)** covers the ML-specific lifecycle from training through production

These areas are not independent. A model choice constrains platform options. A platform choice constrains pipeline design. A pipeline design constrains what validation is possible. Security decisions compound.

!!! tip "Start where the risk is highest"
    If you are new to AI pre-runtime security, start with [Model Selection](model-selection/README.md). A compromised model defeats every other control. Then work through platform, DevOps, and MLOps in order. Each builds on the previous.
