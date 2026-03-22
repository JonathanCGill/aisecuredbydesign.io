---
description: Infrastructure as code for AI workloads, covering GPU provisioning, inference endpoints, and secure environment configuration.
---

# Infrastructure as Code

Infrastructure as Code (IaC) for AI workloads follows the same principles as traditional IaC: define infrastructure declaratively, version control it, review changes, and apply them through automated pipelines. AI workloads add specific resources and configurations that must be captured.

## What AI adds to IaC

Traditional IaC manages compute, networking, storage, and services. AI workloads add:

| Resource type | What to define | Security relevance |
|--------------|---------------|-------------------|
| **GPU instances** | Instance types, driver versions, CUDA versions | Driver vulnerabilities, resource isolation |
| **Model storage** | Buckets, registries, access policies | Data protection, integrity, access control |
| **Inference endpoints** | Endpoint configuration, scaling policies, authentication | Exposure surface, authentication, rate limiting |
| **Vector databases** | Cluster configuration, access policies, encryption | RAG data protection, query access control |
| **Experiment tracking** | Server configuration, access policies | Experiment data protection, IP protection |
| **Training infrastructure** | Cluster configuration, spot instance policies | Data access during training, compute security |

## Principles for AI IaC

### Everything in code, no exceptions

Every piece of AI infrastructure should be defined in code:

- GPU cluster configuration
- Model serving endpoint configuration
- Network policies for AI workloads
- IAM roles and policies for model access
- Encryption configuration for model storage
- Logging and monitoring configuration

Manual configuration is configuration that cannot be audited, reproduced, or reviewed.

### Environment parity

Development, staging, and production environments should be as similar as possible. For AI workloads, this includes:

- Same model serving framework version
- Same inference configuration (not just the model, but the serving parameters)
- Same network policies and access controls
- Same logging and monitoring setup

Where environments must differ (smaller GPU instances in development, for example), document the differences explicitly and assess their impact on testing validity.

### Least privilege for AI resources

AI workloads often accumulate broad permissions during development that persist into production.

Common over-permissions to watch for:

- Training jobs with read access to all S3 buckets (should be restricted to specific training data buckets)
- Inference endpoints with write access to model storage (inference should be read-only)
- Notebooks with admin-level cloud permissions (should have only what is needed for the current task)
- CI/CD pipelines with broad IAM permissions (scope to specific actions on specific resources)

### Secrets as configuration, not in configuration

IaC files should reference secrets, not contain them. This means:

- API keys stored in a secrets manager, referenced by ARN or path
- Database credentials injected at runtime, not baked into templates
- Model endpoint tokens pulled from a vault, not committed to the repository

See [Secrets Management](secrets-management.md) for detailed guidance.

## Common IaC patterns for AI

### Model serving endpoint

Define the complete serving configuration:

```yaml
# Example: model serving endpoint definition (tool-agnostic)
model_endpoint:
  name: "product-classifier-v2"
  model_source: "s3://models/product-classifier/v2.1.0/model.safetensors"
  model_hash: "sha256:abc123..."
  instance_type: "ml.g5.xlarge"
  min_instances: 2
  max_instances: 10
  authentication: "iam"
  network:
    vpc_endpoint: true
    public_access: false
  logging:
    request_logging: true
    response_logging: true
    log_retention_days: 90
  monitoring:
    latency_alarm_threshold_ms: 500
    error_rate_alarm_threshold: 0.01
```

### GPU cluster for training

```yaml
# Example: training cluster definition
training_cluster:
  name: "model-training"
  instance_type: "p4d.24xlarge"
  max_nodes: 4
  spot_enabled: true
  spot_fallback: "on-demand"
  network:
    subnet: "private-training-subnet"
    security_group: "training-sg"
    internet_access: false
  storage:
    training_data: "s3://training-data/approved/"
    model_output: "s3://models/training-output/"
    temp_storage_gb: 500
  iam_role: "training-execution-role"
  encryption:
    ebs_encryption: true
    kms_key: "arn:aws:kms:..."
```

## Drift detection

IaC is only effective if actual infrastructure matches the defined state. Drift, where actual configuration diverges from IaC, is a security risk.

**Detect drift regularly.** Run plan/diff operations on a schedule, not just before changes.

**Alert on drift.** Unexpected changes to AI infrastructure should trigger alerts. Someone manually changing a model endpoint's configuration bypasses your review process.

**Remediate automatically where safe.** For non-destructive drift (a security group rule was added manually), consider automatic remediation. For destructive drift (a resource was modified), alert and investigate.

!!! info "References"
    - [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/)
    - [AWS Well-Architected Framework: Machine Learning Lens](https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/)
    - [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks)
