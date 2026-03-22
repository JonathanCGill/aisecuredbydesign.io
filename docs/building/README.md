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

!!! tip "Start with risk classification"
    If you have not yet classified the risk tier of your AI system, do that first. The [Getting Started](../getting-started/README.md) section walks through risk classification, regulatory alignment, and testing requirements. The tier you assign drives the level of rigour required across everything in this section. Once you have a tier, start with [Model Selection](model-selection/README.md), then work through platform, DevOps, and MLOps in order. Each builds on the previous. Once you have covered these topics, continue to [AI Runtime Security](https://airuntimesecurity.io/) for what comes after deployment.
