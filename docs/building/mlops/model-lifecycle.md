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

## Provider model deprecation

If you use a hosted foundation model, the provider decides when it is retired. Providers publish deprecation schedules, and retirement dates can be months rather than years after release. When a model is retired, requests to it fail or are redirected to a successor. Either way, you are now running a model you have not tested.

Treat every provider deprecation as a forced model change that goes through the full lifecycle, on a deadline you do not control.

### Before it happens

- **Pin model versions** in configuration. Avoid aliases such as "latest" that silently move to a new model. See [Foundation Model Access](foundation-model-access.md).
- **Track deprecation notices** for every model in the AI-BOM, with an owner who reads them. Add retirement dates to the system's risk register.
- **Keep the evaluation suite runnable on demand.** A migration is only as fast as your ability to re-run regression, safety, and injection evals against a new model.
- **Name a tested alternate** in the system's [PACE plan](../devops/resilience.md), so a successor is already partly qualified.

### Migration checklist

When a deprecation is announced:

- [ ] Select the successor model and run the [model risk assessment](../model-selection/risk-assessment.md) on it. A successor from the same provider is still a new model.
- [ ] Re-run regression, safety, and injection evals. Expect some prompts to need rework.
- [ ] Re-tune guardrail thresholds. Output style and length changes can shift false positive rates.
- [ ] Re-calibrate any model-as-judge, both where the judge model itself is deprecated and where the judged model changes. See [Judge Assurance](../../core/judge-assurance.md).
- [ ] Re-check the [risk classification](../../getting-started/risk-classification.md) if the successor has new capabilities, such as tool use, longer context, or multimodal input.
- [ ] Update technical documentation, the AI-BOM, and the model card reference.
- [ ] Deploy through the normal staged rollout with the old version still available for rollback until the retirement date.

!!! warning "Start the day the notice arrives"
    Teams that wait until the final month often ship the successor with reduced testing. Plan the migration as soon as the deprecation is announced, and escalate early if the timeline does not fit your release gates.

## Decommissioning an AI system

Retiring an AI system leaves more behind than retiring a conventional application. Credentials, stored context, derived data, and model artefacts can all outlive the system and become an exposure.

| Area | Decommissioning step |
|------|---------------------|
| **Identities and credentials** | Revoke agent identities, service accounts, API keys, OAuth grants, and delegated tokens. Confirm no other system still uses them. See [Identity and Access](../../infrastructure/controls/identity-and-access.md) |
| **Tool and integration access** | Remove the system's entries from the tool gateway manifest and disconnect MCP servers and webhooks |
| **Stored context** | Delete vector stores, embeddings, conversation history, and agent memory, or move them under the retention policy that applies to their source data |
| **Model artefacts** | Archive or delete fine-tuned weights and adapters according to data governance. Fine-tuned models can memorise training data, so deleting the dataset alone is not enough. See [Data Governance](data-governance.md#right-to-erasure-and-model-retention) |
| **Provider resources** | Delete provisioned throughput, fine-tuning jobs, stored files, and batch outputs held by the model provider |
| **Logs and evidence** | Keep audit logs for the required retention period. Delete operational logs that hold personal data once they are no longer needed |
| **Inventory** | Mark the system and its components as retired in the AI-BOM and the AI system inventory, with the date and the owner who signed off |
| **Users and dependants** | Tell downstream systems and users, and confirm nothing depends on the system's outputs |

Decommissioning follows the same approval pattern as deployment: a named owner signs off that each step is complete. For HIGH and CRITICAL systems, security confirms that credentials were revoked and data deleted. This also supports NIST AI RMF GOVERN 1.7 and MANAGE 4.2, which cover decommissioning.

!!! info "References"
    - [MLflow Model Registry](https://mlflow.org/docs/latest/model-registry.html)
    - [Google: MLOps Continuous Delivery](https://cloud.google.com/architecture/mlops-continuous-delivery-and-automation-pipelines-in-machine-learning)
    - [AI Runtime Security: Risk Tiers](https://airuntimesecurity.io/core/risk-tiers/)
    - [Anthropic: Model deprecations](https://docs.anthropic.com/en/docs/about-claude/model-deprecations)
    - [OpenAI: Deprecations](https://platform.openai.com/docs/deprecations)
    - [NIST AI RMF Playbook (GOVERN 1.7, MANAGE 4.2)](https://airc.nist.gov/airmf-resources/playbook/)
