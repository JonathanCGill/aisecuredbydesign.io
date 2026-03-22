---
description: Adapting CI/CD pipelines for AI workloads, including model validation gates, artefact management, and pipeline integrity.
---

# CI/CD for AI

Continuous integration and continuous delivery for AI systems extends traditional CI/CD with new artefact types, new validation steps, and new integrity requirements. The pipeline is the last line of defence before deployment. If it is compromised, every model it touches is suspect.

## How AI CI/CD differs

Traditional CI/CD pipelines build, test, and deploy code. AI CI/CD pipelines must also handle:

- **Model artefacts** that are orders of magnitude larger than code
- **Data dependencies** that change independently of code
- **Non-deterministic tests** that require statistical validation rather than binary pass/fail
- **Longer build times** when training or fine-tuning is part of the pipeline
- **Multiple artefact types** (code, model weights, configuration, prompt templates, evaluation datasets)

## Pipeline integrity

A compromised pipeline is a compromised deployment. Integrity controls for AI pipelines include:

### Build environment security

- **Ephemeral build environments.** Build agents should be provisioned fresh for each run. Persistent build environments accumulate state and risk.
- **Locked dependencies.** Pin all dependencies including ML framework versions, CUDA versions, and system libraries. Use lock files and verify hashes.
- **Minimal base images.** Start with the smallest base image that works. Every additional package is attack surface.
- **No internet access during build.** Where practical, restrict build environments from accessing the internet. Pull dependencies from an internal mirror or cache.

### Pipeline-as-code

- **Version control your pipeline.** The pipeline definition lives in the same repository as the code. Changes to the pipeline go through the same review process as code changes.
- **Signed commits.** Require signed commits for pipeline definition changes.
- **Branch protection.** Protect the branch that triggers production deployments. Require reviews and status checks.
- **Audit trail.** Every pipeline run should produce a complete log of what was built, what was tested, what was deployed, and who triggered it.

### Artefact integrity

- **Sign model artefacts.** Every model artefact produced by the pipeline should be signed. Verify signatures before deployment.
- **Hash everything.** Compute and store cryptographic hashes for all artefacts (models, data snapshots, configuration files).
- **Immutable artefact storage.** Once an artefact is published, it should not be overwritable. Use immutable storage or versioned registries.
- **Provenance records.** Generate and store provenance records (SLSA-style) that document how each artefact was produced.

## Validation gates

AI pipelines need validation gates that go beyond unit tests and linting.

### Pre-merge gates

Before code or configuration changes merge:

- [ ] Code review completed (human review, not just automated checks)
- [ ] Unit tests pass
- [ ] Linting and formatting checks pass
- [ ] Security scanning (dependency vulnerabilities, secrets detection)
- [ ] Prompt template validation (if prompt changes are included)

### Pre-deployment gates

Before a model deploys to production:

- [ ] Model provenance verified (hash, signature, source)
- [ ] Model format validated (reject unsafe serialisation formats)
- [ ] Performance benchmarks meet minimum thresholds
- [ ] Safety evaluations pass (bias, toxicity, refusal rates)
- [ ] Adversarial test suite passes (prompt injection, jailbreak resistance)
- [ ] Regression tests pass (no degradation from previous version)
- [ ] Resource requirements validated (fits within allocated compute)
- [ ] Approval recorded (who approved this deployment, when, based on what evidence)

### Post-deployment verification

After deployment but before full traffic:

- [ ] Canary deployment healthy (no errors, latency within bounds)
- [ ] Output quality sampling passes spot checks
- [ ] Monitoring and alerting confirmed active
- [ ] Rollback tested and ready

## Managing large artefacts

Model files do not fit in Git. Standard approaches:

| Solution | Approach | Tradeoffs |
|----------|----------|-----------|
| **Git LFS** | Large files tracked by Git, stored externally | Simple, but versioning large files is expensive |
| **DVC** | Data and model versioning alongside code | Purpose-built for ML, integrates with Git |
| **Model registry** | Dedicated registry (MLflow, Weights & Biases, etc.) | Best for model lifecycle management |
| **Object storage** | S3, GCS, Azure Blob with naming conventions | Simple, flexible, requires discipline |

Whichever approach you use, apply the same integrity controls: hash verification, access control, and immutability for production artefacts.

## Pipeline security anti-patterns

**Shared credentials across environments.** Development, staging, and production use different credentials. Never share.

**Model files committed to Git.** Large binary files in Git cause repository bloat and make history management difficult. Use a model registry or object storage.

**No validation between training and deployment.** A model that finishes training is not a model that is ready for production. Always validate.

**Manual deployment steps.** Any manual step is a step that can be skipped, done wrong, or done by the wrong person. Automate everything.

**Tests that always pass.** If your AI tests have never failed, your thresholds are too lenient. Calibrate evaluation thresholds based on actual requirements, not convenience.

!!! info "References"
    - [SLSA: Supply-chain Levels for Software Artifacts](https://slsa.dev/)
    - [DVC: Data Version Control](https://dvc.org/)
    - [CIS Software Supply Chain Security](https://www.cisecurity.org/benchmark/software_supply_chain_security)
    - [AI Runtime Security](https://airuntimesecurity.io/)
