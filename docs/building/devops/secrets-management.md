---
description: Managing secrets in AI systems, covering the expanded credential surface of model endpoints, data stores, experiment trackers, and API keys.
---

# Secrets Management

AI systems have a broader secrets surface than traditional applications. Beyond standard credentials (database passwords, API keys, service tokens), AI workloads introduce model endpoint credentials, data store access tokens, experiment tracker API keys, model registry credentials, and embedding service tokens.

Each secret is a potential attack vector. Compromise one credential, and the blast radius depends on what that credential can access.

## The AI secrets surface

| Secret type | Where it is used | What compromise enables |
|------------|-----------------|------------------------|
| **Model API keys** | Inference calls to cloud AI services | Unauthorised model access, cost abuse, data exfiltration through prompts |
| **Model registry credentials** | Pushing/pulling models from registries | Model tampering, supply chain attacks, model theft |
| **Training data credentials** | Accessing training datasets | Data exfiltration, data poisoning |
| **Vector database credentials** | RAG pipeline data access | Knowledge base poisoning, data exfiltration |
| **Experiment tracker tokens** | Logging experiments and metrics | IP theft (hyperparameters, results), experiment manipulation |
| **Embedding service keys** | Generating embeddings for RAG | Cost abuse, data exfiltration through embedding inputs |
| **Pipeline service accounts** | CI/CD and MLOps automation | Full pipeline compromise, model and data manipulation |

## Core principles

### Never in code, never in config files

Secrets must not appear in:

- Source code (obvious, but still happens)
- Configuration files committed to version control
- Container images or Dockerfiles
- IaC templates (Terraform, CloudFormation, etc.)
- Jupyter notebooks (cell outputs can contain credentials)
- Experiment tracking logs (hyperparameters sometimes include credentials)
- Model training scripts checked into repositories

### Use a secrets manager

All secrets should be stored in a dedicated secrets manager and injected at runtime:

| Platform | Secrets manager | Notes |
|----------|----------------|-------|
| AWS | Secrets Manager, Parameter Store | Use Secrets Manager for rotation; Parameter Store for static config |
| Azure | Key Vault | Integrates with Azure AI services via managed identity |
| GCP | Secret Manager | Integrates with Vertex AI via service accounts |
| Self-hosted | HashiCorp Vault, CyberArk | Requires operational investment but provides full control |

### Least privilege for every credential

Each credential should grant the minimum access required:

- **Inference-only credentials** should not allow model upload or modification
- **Training job credentials** should access only the specific training data needed
- **Pipeline credentials** should be scoped to the specific actions the pipeline performs
- **Human user credentials** should not be used for automated processes

### Rotate regularly

AI secrets are often long-lived because rotation is seen as operationally complex. This is a risk.

- Automate rotation where the secrets manager supports it
- Set rotation schedules appropriate to the sensitivity (model API keys quarterly at minimum)
- Test that rotation does not break running services before deploying to production
- Monitor for use of revoked credentials

## Common pitfalls

### Notebook credentials

Jupyter notebooks are the most common place AI credentials leak. Developers connect to data stores, model endpoints, and experiment trackers from notebooks, often hardcoding credentials for convenience.

**Mitigations:**

- Use environment variables or IAM roles, never hardcoded credentials
- Clear notebook outputs before committing to version control
- Use pre-commit hooks that scan for secrets (tools: `detect-secrets`, `gitleaks`, `truffleHog`)
- Configure notebook environments to pull credentials from a secrets manager

### Experiment tracking leaks

Experiment trackers (MLflow, Weights & Biases, Neptune) log parameters, metrics, and artefacts. Credentials sometimes end up in logged parameters.

**Mitigations:**

- Review what is logged before enabling automatic parameter logging
- Filter sensitive keys from parameter logging
- Restrict access to experiment tracking data

### Pipeline credential sprawl

As AI pipelines grow, credentials accumulate. Each new data source, model endpoint, or service adds a credential. Without discipline, nobody knows what credentials exist, what they access, or when they were last rotated.

**Mitigations:**

- Maintain an inventory of all credentials used in AI pipelines
- Assign an owner to each credential
- Audit credential usage regularly
- Remove unused credentials promptly

### Shared credentials between environments

Development and production share the same model API key, the same data store credentials, or the same experiment tracker token. A compromise in development compromises production.

**Mitigation:** Separate credentials per environment. No exceptions.

!!! warning "Secrets scanning is not optional"
    Run secrets scanning in your CI/CD pipeline and as pre-commit hooks. Tools like `gitleaks`, `detect-secrets`, and `truffleHog` catch most accidental credential commits. A secret committed to version control is a secret that exists in Git history forever, even after deletion.

!!! info "References"
    - [OWASP Secrets Management Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html)
    - [gitleaks](https://github.com/gitleaks/gitleaks)
    - [detect-secrets](https://github.com/Yelp/detect-secrets)
    - [HashiCorp Vault](https://www.vaultproject.io/)
