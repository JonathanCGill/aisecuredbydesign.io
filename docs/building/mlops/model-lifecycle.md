---
description: Managing the model lifecycle securely, from training output through staging, production, and retirement with approval gates at each transition.
---

# Model Lifecycle

A model's lifecycle runs from its creation through production use to eventual retirement. Each stage transition is a decision point where security controls must apply. Without lifecycle management, you lose track of what is deployed, what was approved, and what should be retired.

## Lifecycle stages

```
Training → Evaluation → Registration → Staging → Production → Retirement
              ↑                           ↑          ↑
          Validation                  Approval    Monitoring
            gate                       gate       (runtime)
```

### Training output

A training run produces a model artefact. At this point, the model is an unvalidated output, not yet trusted for any purpose.

**Required before moving forward:**

- Training run attestation recorded (inputs, environment, outputs)
- Model artefact hash computed and stored
- Training metrics logged (loss, accuracy, training curves)
- No errors or anomalies in training logs

### Evaluation

The model is tested against validation datasets, safety benchmarks, and adversarial test suites.

**Required before moving forward:**

- Performance meets minimum thresholds for the target use case
- Safety evaluations pass (bias, toxicity, refusal rates)
- Adversarial tests pass (prompt injection resistance, jailbreak resistance)
- Regression tests pass (no degradation from current production model)
- Evaluation results stored as immutable artefacts

!!! warning "Evaluation must be independent"
    The team that trained the model should not be the only team evaluating it. Independent evaluation, whether by a separate team, automated pipeline, or both, reduces the risk of confirmation bias and missed issues.

### Registration

An evaluated model is registered in the model registry with its metadata, evaluation results, and provenance information.

**The registry should store:**

| Field | Purpose |
|-------|---------|
| **Model name and version** | Unique identification |
| **Model hash** | Integrity verification |
| **Training attestation** | Provenance and reproducibility |
| **Evaluation results** | Evidence of fitness for purpose |
| **Model card** | Documentation of capabilities, limitations, intended use |
| **Licence** | Legal and compliance information |
| **Owner** | Who is responsible for this model |
| **Status** | Current lifecycle stage (registered, staging, production, retired) |

### Staging

The model is deployed to a staging environment that mirrors production. This validates that the model works correctly in the target infrastructure, not just in the evaluation environment.

**What staging validates:**

- Model loads and serves correctly on production hardware
- Latency and throughput meet requirements
- Integration with upstream and downstream services works
- Logging and monitoring are active and producing expected data
- Rollback procedures work (deploy previous version, verify it serves correctly)

### Production approval

Moving from staging to production requires explicit approval. This is the final pre-runtime gate.

**Approval should document:**

- Who approved the deployment and when
- What evidence was reviewed (evaluation results, staging validation)
- What risks were accepted
- What monitoring and rollback plans are in place
- When the next review is scheduled

**Who approves depends on the risk tier:**

| Risk tier | Approval authority |
|-----------|-------------------|
| **Low** (internal tools, non-sensitive) | ML team lead |
| **Medium** (customer-facing, non-critical) | Product owner + ML lead |
| **High** (decision-making, regulated) | AI risk committee or equivalent |

### Production

The model is serving production traffic. From this point, [runtime security](https://airuntimesecurity.io/) takes over for monitoring, guardrails, and incident response.

Pre-runtime responsibilities that continue during production:

- Monitoring for model drift (performance degradation over time)
- Responding to newly discovered vulnerabilities in the model or its dependencies
- Planning and executing model updates through the full lifecycle

### Retirement

Models do not run forever. Retirement is a planned lifecycle stage, not an afterthought.

**Retirement triggers:**

- A newer model replaces it
- The use case is discontinued
- A security vulnerability is discovered that cannot be mitigated
- Regulatory changes make the model non-compliant
- Performance has degraded below acceptable thresholds

**Retirement process:**

- Traffic is migrated to the replacement model (or the service is decommissioned)
- The model is removed from production serving
- The model remains in the registry with a "retired" status for audit purposes
- Associated resources (compute, storage) are cleaned up
- Documentation is updated to reflect retirement

## Version management

### Version numbering

Adopt a consistent versioning scheme. Semantic versioning adapted for models:

| Change type | Version bump | Example |
|------------|-------------|---------|
| **Architecture change** | Major | 1.0.0 → 2.0.0 |
| **Retrained on new data** | Minor | 1.0.0 → 1.1.0 |
| **Configuration change** | Patch | 1.0.0 → 1.0.1 |
| **Quantisation or distillation** | Qualifier | 1.0.0 → 1.0.0-q4 |

### What constitutes a new version

Every change that could affect model behaviour produces a new version:

- New training data
- Changed hyperparameters
- Updated base model (for fine-tuned models)
- Different quantisation
- Changed serving configuration (if it affects output)
- Updated prompt templates (for LLM systems)

!!! tip "Prompt changes are model changes"
    For LLM-based systems, changing the system prompt can alter behaviour as significantly as retraining. Treat prompt changes as version changes that go through the same lifecycle gates.

## Rollback

Every production deployment must have a tested rollback plan.

**Rollback requirements:**

- Previous model version remains available and deployable
- Rollback can be executed quickly (minutes, not hours)
- Rollback procedure is documented and tested during staging
- Rollback does not require the person who deployed the model

**When to rollback:**

- Output quality drops below acceptable thresholds
- Safety monitoring triggers alerts
- A security vulnerability is discovered in the model
- Downstream systems report integration issues

!!! info "References"
    - [MLflow Model Registry](https://mlflow.org/docs/latest/model-registry.html)
    - [Google: MLOps Continuous Delivery](https://cloud.google.com/architecture/mlops-continuous-delivery-and-automation-pipelines-in-machine-learning)
    - [AI Runtime Security: Risk Tiers](https://airuntimesecurity.io/core/risk-tiers/)
