---
description: Security considerations for self-hosted AI infrastructure, including GPU clusters, on-premises deployments, and air-gapped environments.
---

# Self-Hosted Infrastructure

Self-hosted AI infrastructure means running models on hardware you control: on-premises data centres, co-located GPU clusters, or dedicated cloud instances you manage end-to-end. You get full control. You also get full responsibility.

## When self-hosting makes sense

Self-hosting is not the default choice. It makes sense when:

- **Data sovereignty is non-negotiable.** Sensitive data cannot leave your environment under any circumstances.
- **Regulatory requirements demand it.** Certain sectors or jurisdictions require on-premises processing.
- **Air-gapped environments.** Defence, critical infrastructure, or classified workloads that cannot connect to external services.
- **You need full model control.** You require the ability to inspect, modify, and fully control model behaviour.
- **Cost at scale.** At very high inference volumes, self-hosted infrastructure can be more cost-effective than API pricing.

## Security responsibilities

When you self-host, you own the entire stack.

| Layer | What you must secure |
|-------|---------------------|
| **Hardware** | Physical security, GPU provisioning, hardware lifecycle |
| **Network** | Segmentation, firewalls, ingress/egress controls, DDoS protection |
| **Operating system** | Patching, hardening, configuration management |
| **Container runtime** | Image security, runtime policies, orchestration security |
| **ML framework** | Framework versions, dependency management, vulnerability patching |
| **Model storage** | Encryption at rest, access controls, integrity verification |
| **Inference endpoint** | Authentication, authorisation, rate limiting, input validation |
| **Logging** | Audit trails, log aggregation, tamper resistance, retention |

## GPU cluster security

GPU infrastructure introduces specific security considerations beyond standard compute.

**Driver and firmware management.** GPU drivers (NVIDIA CUDA, ROCm) must be kept updated. Vulnerabilities in GPU drivers can compromise the host system. NVIDIA regularly publishes security bulletins.

**Multi-tenancy risks.** If GPU resources are shared between workloads, ensure proper isolation. GPU memory can leak data between processes if not properly managed. Use frameworks that clear GPU memory between inference calls.

**Resource management.** GPU out-of-memory conditions can crash inference services. Implement resource limits and monitoring. Plan capacity for peak load, not average.

**Supply chain.** GPU firmware itself is part of your supply chain. Verify firmware integrity and keep it patched.

## Container security for ML workloads

Most self-hosted AI deployments use containers. ML containers have specific security considerations.

**Image size and complexity.** ML container images are large (often 5 to 15 GB) with many dependencies. This expands the attack surface.

- Scan container images for vulnerabilities before deployment
- Use minimal base images where possible
- Pin all dependency versions, including CUDA libraries
- Remove unnecessary tools and packages from production images

**Secrets in images.** ML workflows commonly embed API keys, model endpoint credentials, or data access tokens in container images during development. Audit images for secrets before production use.

**Runtime privileges.** GPU access typically requires elevated privileges (`--gpus`, device mounting). Understand what privileges are required and restrict to the minimum necessary.

## Notebook security

Jupyter notebooks are the standard development environment for ML but are frequently insecure.

- **Authentication.** Default Jupyter installations have no authentication or use a single token. Always configure proper authentication.
- **Network exposure.** Notebooks running on port 8888 are frequently exposed to the network unintentionally. Bind to localhost or use a VPN.
- **Code execution.** Notebooks execute arbitrary code. Treat notebook servers as high-privilege environments.
- **Data access.** Notebooks typically have direct access to training data, model storage, and infrastructure credentials. Apply least privilege.
- **Notebook outputs.** Cell outputs can contain sensitive data (PII from training sets, model weights, credentials). Clear outputs before committing notebooks to version control.

## Operational considerations

**Patching cadence.** Self-hosted infrastructure requires active patching. ML frameworks, GPU drivers, OS packages, container runtimes, and application dependencies all need regular updates. Establish a patching schedule and stick to it.

**Backup and recovery.** Model files are large and expensive to recreate. Implement backup strategies that account for model storage size and recovery time objectives.

**Monitoring.** Self-hosted infrastructure needs monitoring for both traditional metrics (CPU, memory, disk, network) and ML-specific metrics (GPU utilisation, inference latency, model loading times, queue depth).

**Incident response.** You are responsible for detecting, responding to, and recovering from security incidents. Have a plan that covers AI-specific scenarios (model compromise, data poisoning discovery, unauthorised model access).

!!! info "References"
    - [NVIDIA GPU Security Updates](https://www.nvidia.com/en-us/security/)
    - [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks)
    - [OWASP Docker Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)
    - [Jupyter Security Best Practices](https://jupyter-server.readthedocs.io/en/latest/operators/security.html)
