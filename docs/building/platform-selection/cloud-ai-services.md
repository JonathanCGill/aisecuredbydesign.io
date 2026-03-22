---
description: Security evaluation of cloud AI services, including AWS Bedrock, Azure AI, Google Vertex AI, and their shared responsibility models.
---

# Cloud AI Services

Cloud AI services (AWS Bedrock, Azure AI, Google Vertex AI, and similar) offer managed model hosting, inference endpoints, and integrated tooling. They reduce operational burden but introduce a shared responsibility model where the security boundary between you and the provider must be clearly understood.

## The shared responsibility model for AI

Cloud providers have well-established shared responsibility models for traditional workloads. AI workloads extend this model with additional considerations.

| Responsibility | Provider manages | You manage |
|---------------|-----------------|------------|
| **Model infrastructure** | Compute, scaling, availability, patching | Model selection, configuration, prompt design |
| **Data processing** | Inference infrastructure, request routing | Data sent to the API, data classification, consent |
| **Access control** | Platform IAM, API authentication | Your IAM policies, API key management, least privilege |
| **Encryption** | Encryption in transit, encryption at rest (default keys) | Key management policy, customer-managed keys where needed |
| **Logging** | Platform-level logging | Enabling logging, log analysis, retention policy |
| **Compliance** | Platform certifications (SOC 2, ISO 27001, etc.) | Your compliance obligations, data handling, audit evidence |

!!! warning "Shared responsibility has gaps"
    The shared responsibility model does not cover everything. Prompt security, output validation, data leakage through model outputs, and use-case-specific risks remain entirely your responsibility regardless of platform.

## Evaluating cloud AI services

### Data handling

The most critical question: what happens to your data?

- **Training data usage.** Does the provider use your inputs or outputs to train their models? Most providers now offer opt-out, but verify this explicitly. Check the terms of service, not just the marketing materials.
- **Data retention.** How long does the provider retain your inputs and outputs? For what purpose? Can you configure retention?
- **Data residency.** In which region is your data processed? Can you restrict processing to specific regions? This matters for GDPR, POPIA, and sector-specific regulations.
- **Data isolation.** Is your data isolated from other customers? What guarantees exist?

### Model access and configuration

- **Model versioning.** Can you pin to a specific model version? Providers frequently update models. An uncontrolled model update is a change you did not approve.
- **Model availability.** What SLAs exist? What happens if the provider deprecates a model you depend on?
- **Custom models.** If you fine-tune through the provider's service, who owns the resulting model? Where is it stored? Can you export it?

### Network and integration security

- **Private endpoints.** Can you access the service through a private network (VPC endpoints, Private Link)? This avoids exposing API traffic to the public internet.
- **API authentication.** What authentication mechanisms are available? Prefer IAM-based authentication over API keys where possible.
- **Rate limiting.** What rate limits apply? Can they be configured? Rate limits affect both availability and cost.
- **Egress controls.** Can you control what data leaves your environment to reach the AI service?

### Compliance and audit

- **Certifications.** What compliance certifications does the provider hold? (SOC 2, ISO 27001, HIPAA, FedRAMP, etc.)
- **Audit logs.** Are all API calls logged? Can you access these logs? Are they tamper-resistant?
- **Data Processing Agreements.** Does the provider offer a DPA that meets your requirements?
- **Subprocessors.** Does the provider use subprocessors? Who are they? Where are they located?

## Platform-specific considerations

### AWS Bedrock

- Model access through VPC endpoints available
- Customer-managed KMS keys for encryption
- CloudTrail integration for audit logging
- Model invocation logging for compliance
- Data not used for training by default

### Azure AI

- Private endpoint support through Azure Private Link
- Customer-managed keys via Azure Key Vault
- Integration with Azure Monitor and Log Analytics
- Content filtering configurable per deployment
- Data processing within selected Azure regions

### Google Vertex AI

- VPC Service Controls for network isolation
- Customer-managed encryption keys (CMEK)
- Cloud Audit Logs integration
- Data residency controls by region
- Model Garden for managed model selection

!!! tip "Evaluate, do not assume"
    Provider documentation describes what is available, not what is configured. Default configurations are rarely sufficient for production security. Evaluate actual configurations against your requirements, and verify through testing, not just documentation review.

!!! info "References"
    - [AWS Shared Responsibility Model](https://aws.amazon.com/compliance/shared-responsibility-model/)
    - [Azure AI Services Security](https://learn.microsoft.com/en-us/azure/ai-services/security-features)
    - [Google Cloud AI Security](https://cloud.google.com/vertex-ai/docs/general/security)
    - [AI Runtime Security: Platform Patterns](https://airuntimesecurity.io/infrastructure/reference/platform-patterns/aws-bedrock/)
