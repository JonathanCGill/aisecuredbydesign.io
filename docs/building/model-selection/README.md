---
description: Secure model selection, choosing AI models with verified provenance, assessed risk, and scanned vulnerabilities.
---

# Model Selection

Choosing a model is the first and most consequential security decision in an AI project. A compromised model defeats all downstream controls: no guardrail catches a backdoored model, no output filter fixes a model trained on poisoned data, no monitoring dashboard alerts on a supply chain compromise that happened during training.

Model selection is not a performance benchmarking exercise with security bolted on. It is a security decision that also considers performance.

## The decision landscape

| Model type | Security profile | You control |
|------------|-----------------|-------------|
| **Closed API** (GPT-4, Claude, Gemini) | Provider manages model security. You manage access, data handling, and integration. | API keys, prompt templates, data sent to the API |
| **Open-weight** (Llama, Mistral, Gemma) | You manage everything. Full responsibility for provenance, integrity, hosting, and patching. | Model weights, infrastructure, fine-tuning, deployment |
| **Fine-tuned** (any base + your data) | Inherits base model risks plus introduces new risks from your training data and process. | Training data, fine-tuning process, resulting model |

Each type carries different risks and requires different security controls. The choice is not just technical; it has compliance, cost, and operational security implications.

## What to evaluate

Before selecting a model, assess:

1. **Provenance**: Can you verify where this model came from and who trained it? See [Provenance and Integrity](provenance-and-integrity.md).
2. **Risk**: What are the specific risks of this model type for your use case? See [Risk Assessment](risk-assessment.md).
3. **Vulnerabilities**: Has the model been scanned for known attack vectors? See [Vulnerability Scanning](vulnerability-scanning.md).

!!! warning "Model registries are not app stores"
    Hugging Face, Model Zoo, and similar repositories host models uploaded by anyone. Popularity is not a proxy for security. Treat model downloads like you would treat running untrusted code, because that is exactly what you are doing.

## Key principles

**Verify before you trust.** Every model should have its provenance verified before it enters your environment. This means hash verification, signature checking, and understanding the training lineage.

**Assess for your use case.** A model that is safe for internal document summarisation may be unacceptable for customer-facing decisions. Risk assessment must be use-case specific.

**Scan before you deploy.** Known vulnerability classes exist for ML models (backdoors, trojans, adversarial triggers, serialisation exploits). Scanning is not optional.

**Document your decision.** Record which model was selected, why, what risks were accepted, and who approved it. This is both good practice and increasingly a regulatory requirement.
