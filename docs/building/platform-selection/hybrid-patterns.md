---
description: Hybrid AI deployment patterns that combine cloud and self-hosted infrastructure to balance security, control, and operational efficiency.
---

# Hybrid Patterns

Most organisations do not go fully cloud or fully self-hosted. They use hybrid patterns, running different parts of their AI workload in different places based on data sensitivity, regulatory requirements, and operational needs.

Hybrid patterns are practical but introduce complexity. The security challenge is managing trust boundaries across environments.

## Common hybrid patterns

### Pattern 1: Sensitive inference on-premises, everything else in cloud

**How it works:** Training, experimentation, and non-sensitive inference happen in the cloud. Sensitive workloads (PII processing, regulated use cases) run on self-hosted infrastructure.

**Security considerations:**

- Clear data classification determines which workloads go where
- Model transfer between environments must preserve integrity (hash verification, signed artefacts)
- Network connectivity between environments needs encryption and access controls
- Logging must span both environments for complete audit trails

**When to use:** Organisations with a mix of sensitive and non-sensitive AI use cases, where running everything on-premises would be operationally impractical.

### Pattern 2: Cloud training, self-hosted inference

**How it works:** Models are trained in the cloud (where GPU resources are elastic) and deployed to self-hosted infrastructure for inference.

**Security considerations:**

- Training data must be secured during upload to and processing in the cloud
- Model artefacts must be verified during the transfer from cloud to on-premises
- Cloud training environments should be ephemeral, spun up for training and torn down after
- Credentials for cloud resources must be managed carefully, especially in automated pipelines

**When to use:** Organisations that need cloud-scale GPU for training but require inference to stay on-premises for data sovereignty or latency reasons.

### Pattern 3: API gateway with routing

**How it works:** A single API gateway routes requests to different backends based on content classification. Sensitive requests go to self-hosted models. Non-sensitive requests go to cloud AI services.

**Security considerations:**

- The gateway becomes a critical security component and a single point of failure
- Content classification must happen before the routing decision (the gateway sees all data)
- Misclassification sends sensitive data to the wrong backend
- Gateway must be secured as a high-value target

**When to use:** Organisations that want to offer a unified AI service to internal consumers while maintaining data classification controls.

### Pattern 4: Edge inference with cloud orchestration

**How it works:** Small, quantised models run at the edge (on-device, branch offices, factories). A cloud service manages model distribution, versioning, and monitoring.

**Security considerations:**

- Edge devices are physically accessible to attackers
- Models on edge devices can be extracted and inspected
- Model updates over the network must be authenticated and integrity-verified
- Edge devices may have limited security capabilities (no TPM, limited logging)
- Cloud orchestration service controls what models are deployed where

**When to use:** IoT, manufacturing, retail, and other use cases where inference must happen close to the data source.

## Managing trust boundaries

The core challenge of hybrid deployments is managing trust boundaries: the points where data, models, or control signals cross from one environment to another.

### Principles for trust boundaries

**Verify at every crossing.** When a model moves from cloud to on-premises, verify its integrity. When data crosses an environment boundary, verify its classification. Do not assume that because something was secure in one environment, it is secure in another.

**Encrypt in transit.** All data and model transfers between environments must be encrypted. Use mutual TLS where possible.

**Minimise crossings.** Each trust boundary crossing is a potential point of compromise. Design your architecture to minimise the number of times sensitive data or critical artefacts cross boundaries.

**Log boundary crossings.** Every transfer of data or models across environments should be logged with enough detail for audit and incident response.

**Consistent identity.** Use consistent identity and access management across environments. A user or service that is authorised in one environment should not automatically be authorised in another.

## Common pitfalls

**Inconsistent security posture.** The cloud environment has strong controls, but the self-hosted environment does not (or vice versa). Attackers target the weakest environment.

**Credential sprawl.** Hybrid deployments require credentials for multiple environments. Without centralised secrets management, credentials proliferate and become difficult to track and rotate.

**Logging gaps.** Each environment has its own logging. Without aggregation, you cannot trace an action across environments. Incident response becomes difficult when you have partial visibility.

**Drift between environments.** The cloud environment is updated frequently, but the self-hosted environment lags behind. Version mismatches between environments cause compatibility issues and security gaps.

!!! tip "Start simple"
    Begin with the simplest hybrid pattern that meets your requirements. Each additional environment and trust boundary crossing adds complexity and risk. You can always add complexity later. You cannot easily remove it.

!!! info "References"
    - [NIST SP 800-210: Cloud Security Technical Reference Architecture](https://csrc.nist.gov/publications/detail/sp/800-210/final)
    - [AI Runtime Security: Infrastructure Controls](https://airuntimesecurity.io/infrastructure/)
