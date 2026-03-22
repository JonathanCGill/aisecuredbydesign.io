---
description: Secure platform selection for AI workloads, evaluating cloud AI services, self-hosted infrastructure, and hybrid deployment patterns.
---

# Platform Selection

Where you run AI determines your security posture. The platform decision is not just about compute and cost. It defines who controls your data, who manages your infrastructure, what compliance commitments you can make, and what attack surface you expose.

This decision is often made early and is expensive to change. Get it right.

## The platform spectrum

| Approach | You manage | Provider manages | Best for |
|----------|-----------|-----------------|----------|
| **Cloud AI services** | Integration, data handling, access control | Model hosting, compute, scaling, patching | Teams without ML infrastructure expertise |
| **Self-hosted** | Everything: hardware, software, models, networking | Nothing | Maximum control, data sovereignty, air-gapped environments |
| **Hybrid** | Sensitive workloads on-premises, others in cloud | Cloud components | Balancing control with operational efficiency |

There is no universally correct choice. The right platform depends on your data sensitivity, regulatory requirements, operational capability, and threat model.

## Security considerations across all platforms

Regardless of which approach you choose, assess these:

**Data residency.** Where does your data physically reside? Where is it processed? Can you guarantee it stays within required jurisdictions?

**Access control.** Who can access the AI infrastructure, models, data, and outputs? How is access authenticated and authorised?

**Encryption.** Is data encrypted at rest and in transit? Who holds the encryption keys? Can you bring your own keys?

**Logging and audit.** What actions are logged? Can you access logs for compliance and incident response? How long are logs retained?

**Network security.** What is exposed to the internet? What network segmentation exists between AI workloads and other systems?

**Supply chain.** What dependencies does the platform introduce? What is the provider's security posture?

## Choosing your path

- **[Cloud AI Services](cloud-ai-services.md)** covers managed AI platforms from major cloud providers, their security models, and what to evaluate.
- **[Self-Hosted Infrastructure](self-hosted-infrastructure.md)** covers running AI on your own infrastructure, from GPU clusters to on-premises deployments.
- **[Hybrid Patterns](hybrid-patterns.md)** covers combining cloud and self-hosted approaches to balance security, control, and operational efficiency.

!!! tip "Start with your data classification"
    The most effective way to choose a platform is to start with your data. Classify the data your AI system will process. The sensitivity of that data constrains your platform options more than any other factor.
