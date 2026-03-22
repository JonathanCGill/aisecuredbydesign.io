---
description: Securing end-to-end ML pipelines, covering training integrity, reproducibility, attestation, and pipeline-level security controls.
---

# Secure ML Pipelines

An ML pipeline moves data through training, evaluation, and deployment. Each stage transforms inputs into outputs that the next stage depends on. If any stage is compromised, everything downstream is affected. Pipeline security means ensuring the integrity and trustworthiness of this entire chain.

## Pipeline threat model

Before securing a pipeline, understand what can go wrong:

| Threat | Attack surface | Impact |
|--------|---------------|--------|
| **Data poisoning** | Training data ingestion | Model learns attacker-chosen behaviour |
| **Pipeline tampering** | Pipeline definition, build environment | Arbitrary code runs during training |
| **Model substitution** | Model storage, registry | Wrong or malicious model is deployed |
| **Credential theft** | Pipeline secrets, environment variables | Attacker accesses data, models, or infrastructure |
| **Configuration manipulation** | Hyperparameters, serving config | Model behaviour altered without changing weights |
| **Supply chain compromise** | Framework dependencies, base images | Malicious code executes during training |

## Training integrity

Training is where the model is created. Compromising training compromises the model.

### Data integrity

- **Verify data sources.** Training data should come from approved, verified sources. Maintain an inventory of data sources with their classification and approval status.
- **Hash datasets.** Compute and store hashes of training datasets. If the data changes unexpectedly, the hash mismatch signals a problem.
- **Access control on training data.** Not everyone who can run a training job should have access to all training data. Apply least privilege to data access.
- **Data validation.** Before training begins, validate that the data matches expected schema, distributions, and quality thresholds. Automated data validation catches poisoning attempts and data quality issues.

### Compute integrity

- **Ephemeral training environments.** Training should run on freshly provisioned infrastructure. Persistent environments accumulate risk.
- **Locked dependencies.** Pin all framework versions, library versions, and system packages. Verify hashes of downloaded dependencies.
- **Network isolation.** Training environments should have minimal network access. They need access to training data and model storage, not the internet.
- **Resource monitoring.** Monitor training compute for anomalous behaviour: unexpected network traffic, unusual disk I/O, or resource usage patterns that do not match expected training workloads.

### Reproducibility

Reproducibility is a security control, not just a research convenience. If you cannot reproduce a training run, you cannot verify that it produced the model you think it did.

- **Log everything.** Random seeds, hyperparameters, data versions, framework versions, hardware configuration, environment variables.
- **Version data alongside code.** Use tools like DVC to version training data alongside the code that processes it.
- **Deterministic where possible.** Set random seeds, use deterministic algorithms where available, and document where non-determinism is unavoidable.
- **Verify reproducibility.** Periodically re-run training and compare results. Significant divergence is a signal that something has changed.

## Pipeline attestation

Pipeline attestation creates a verifiable record of what happened during a pipeline run. It answers: who ran this pipeline, with what inputs, using what code, and what did it produce?

### What to attest

- **Pipeline definition.** The exact pipeline code that was executed (commit hash, not just branch name).
- **Inputs.** Data versions, model versions (for fine-tuning), configuration files.
- **Environment.** Framework versions, dependency versions, hardware configuration.
- **Outputs.** Model artefact hashes, evaluation metrics, logs.
- **Identity.** Who or what triggered the pipeline run. Service accounts should be traceable to responsible humans.
- **Timing.** When the pipeline ran, how long each stage took.

### Attestation formats

Follow SLSA (Supply-chain Levels for Software Artifacts) principles adapted for ML:

| SLSA Level | ML equivalent |
|------------|--------------|
| **Level 1** | Pipeline definition is version-controlled, builds are logged |
| **Level 2** | Pipeline runs on a hosted, authenticated build service |
| **Level 3** | Pipeline definition is from a trusted source, builds are isolated |
| **Level 4** | All inputs are verified, builds are fully reproducible |

Most organisations should target Level 2 as a minimum, with Level 3 for production-bound models.

## Pipeline access control

### Who can do what

| Action | Who should be allowed |
|--------|----------------------|
| **Define the pipeline** | ML engineers, reviewed by security |
| **Trigger a training run** | ML engineers with project access |
| **Access training data** | Training jobs (service accounts), not humans directly |
| **Publish a model to the registry** | Pipeline automation only, not individuals |
| **Promote a model to production** | Requires explicit approval (see [Model Lifecycle](model-lifecycle.md)) |
| **Modify pipeline configuration** | Reviewed changes through version control |

### Separation of duties

No single person should be able to:

- Modify training data AND approve the resulting model
- Change the pipeline definition AND trigger a production deployment
- Access production credentials AND modify model serving configuration

Separation of duties makes it harder for a single compromised account or malicious insider to impact the entire pipeline.

!!! info "References"
    - [SLSA: Supply-chain Levels for Software Artifacts](https://slsa.dev/)
    - [Google: ML Pipeline Security Best Practices](https://cloud.google.com/architecture/mlops-continuous-delivery-and-automation-pipelines-in-machine-learning)
    - [MITRE ATLAS: ML Pipeline Attacks](https://atlas.mitre.org/)
    - [AI Runtime Security](https://airuntimesecurity.io/)
