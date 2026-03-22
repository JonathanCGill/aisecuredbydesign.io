---
description: AI DevOps security, adapting CI/CD, infrastructure as code, and secrets management for AI workloads.
---

# AI DevOps

DevOps for AI is not the same as DevOps for traditional software. The principles are familiar (automation, repeatability, version control, testing), but AI workloads introduce new artefact types, larger files, different testing requirements, and additional secrets to manage.

Teams that apply standard DevOps practices without adaptation leave gaps that become security vulnerabilities.

## What is different about AI DevOps

| Traditional DevOps | AI DevOps |
|-------------------|-----------|
| Code is the primary artefact | Code, models, data, and configuration are all primary artefacts |
| Artefacts are small (MB) | Model artefacts are large (GB to TB) |
| Tests are deterministic | Tests are probabilistic (pass/fail thresholds, not exact matches) |
| Build reproducibility is straightforward | Training reproducibility depends on hardware, random seeds, data order |
| Secrets are API keys and database credentials | Secrets also include model endpoints, data store credentials, experiment tracker tokens |
| Deployment is rolling out new code | Deployment is rolling out new models, which may behave differently than tested |

## Core topics

- **[CI/CD for AI](ci-cd-for-ai.md)** covers how to adapt continuous integration and delivery pipelines for AI workloads, including model validation gates and artefact management.
- **[Infrastructure as Code](infrastructure-as-code.md)** covers defining and managing AI infrastructure declaratively, from GPU provisioning to inference endpoint configuration.
- **[Secrets Management](secrets-management.md)** covers the expanded secrets surface of AI systems and how to manage credentials for models, data stores, experiment trackers, and API endpoints.

!!! abstract "DevOps secures the pipeline. MLOps secures the ML lifecycle."
    DevOps and [MLOps](../mlops/README.md) overlap but are not the same. DevOps focuses on the infrastructure and delivery pipeline. MLOps focuses on the ML-specific lifecycle (training, evaluation, registry, deployment). Both must be secured. This section covers the DevOps side.
