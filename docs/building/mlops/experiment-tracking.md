---
description: Securing experiment tracking systems, protecting intellectual property in hyperparameters and results, and managing access to experiment data.
---

# Experiment Tracking

Experiment tracking records the details of ML experiments: hyperparameters, metrics, artefacts, code versions, and results. Tools like MLflow, Weights & Biases, Neptune, and Comet are standard in ML workflows. They are also a security-relevant system that most organisations overlook.

## Why experiment tracking is a security concern

Experiment data is intellectual property. It contains:

- **Hyperparameters** that represent accumulated expertise in model tuning
- **Training configurations** that reveal your ML architecture and approach
- **Evaluation results** that show model capabilities and limitations
- **Model artefacts** from every experimental run (not just the final production model)
- **Data references** that point to training datasets and their locations
- **Code snapshots** tied to specific experiments

An attacker with access to your experiment tracking system has a comprehensive view of your ML capabilities, limitations, and infrastructure.

## Securing experiment tracking systems

### Authentication and access control

- **Require authentication.** No anonymous access to experiment tracking systems. This sounds obvious, but MLflow's default deployment has no authentication.
- **Role-based access.** Not everyone needs access to all experiments. Segment by team, project, or sensitivity level.
- **API key management.** Experiment tracker API keys are secrets. Manage them like any other credential (see [Secrets Management](../devops/secrets-management.md)).
- **Service account separation.** Automated experiment logging should use service accounts, not personal credentials.

### Network security

- **Private deployment.** Experiment tracking servers should not be exposed to the public internet. Deploy within your VPC or private network.
- **Encrypted connections.** All communication with the experiment tracker should use TLS.
- **Access logging.** Log who accessed what experiments, when, and from where.

### Data protection

- **No secrets in parameters.** Experiment parameters should never contain credentials, API keys, or connection strings. This happens frequently when auto-logging captures environment variables.
- **Data classification.** Experiment data inherits the classification of the training data it references. If training data is confidential, experiment results are confidential.
- **Artefact storage security.** Experiment artefacts (saved models, plots, data samples) should be stored with appropriate access controls and encryption.
- **Retention policy.** Define how long experiment data is retained. Old experiments may contain references to deprecated infrastructure, retired models, or decommissioned data sources.

## Common experiment tracking risks

### Exposed tracking servers

MLflow, when deployed without additional configuration, runs with no authentication on an open port. This is intended for local development, but teams frequently deploy it this way on shared infrastructure.

**Mitigation:** Always deploy experiment tracking servers with authentication, behind a reverse proxy, within a private network. Use the provider's managed version (Databricks MLflow, managed W&B) where possible, as these include authentication by default.

### Over-logging

Auto-logging features capture everything: environment variables, system paths, installed packages, hardware details. This convenience creates a detailed fingerprint of your ML environment that is useful to attackers.

**Mitigation:** Review what auto-logging captures. Disable logging of sensitive environment variables. Use allow-lists rather than logging everything by default.

### Shared experiments across trust boundaries

Teams share experiment results across organisational boundaries (with partners, contractors, or open-source collaborators). Experiment metadata can reveal more than intended about your infrastructure and capabilities.

**Mitigation:** Sanitise experiment data before sharing. Remove infrastructure details, absolute paths, credential references, and internal identifiers. Share results, not raw experiment logs.

### Stale experiments with live references

Old experiments reference data sources, model endpoints, and infrastructure that may have been reconfigured. These stale references can mislead investigations or reveal historical infrastructure details.

**Mitigation:** Periodically audit experiment references. Archive experiments associated with retired projects. Document the lifecycle of experiment data alongside the models it produced.

## Experiment tracking in the pipeline

Experiment tracking integrates with the broader ML pipeline:

1. **Development.** Experiments are logged during model development and iteration.
2. **Training pipeline.** Automated training runs log to the experiment tracker with consistent metadata.
3. **Evaluation.** Evaluation results are compared across experiments to select the best candidate.
4. **Registration.** The selected model's experiment is linked to the registry entry for traceability.
5. **Audit.** Experiment records provide the evidence trail for why a specific model was chosen.

This chain of traceability from experiment to production is valuable for both security audits and incident response. When a production model behaves unexpectedly, the experiment record helps you understand what it was trained on, how it was configured, and what its known limitations are.

!!! info "References"
    - [MLflow Security Best Practices](https://mlflow.org/docs/latest/auth/index.html)
    - [Weights & Biases Security](https://docs.wandb.ai/guides/hosting/security)
    - [OWASP: Logging and Monitoring](https://owasp.org/www-project-web-security-testing-guide/latest/4-Web_Application_Security_Testing/11-Client-side_Testing/)
