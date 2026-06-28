---
description: A MEDIUM-tier worked example, an internal knowledge assistant over confidential documents, focused on RAG security, identity-aware retrieval, indirect injection, and data classification.
---

# MEDIUM Tier: Internal Knowledge Assistant

**The system:** an employee assistant that answers questions from the company's internal documents, HR policies, engineering wikis, finance procedures, and meeting notes. Staff reach it through single sign-on. It retrieves and summarises; it takes no actions and faces no customers.

This is the example where **retrieval is the whole risk**. Most enterprise AI assistants are this shape, and most of their incidents come from the same place: the assistant retrieving something the user should never have seen, or acting on an instruction hidden in a document.

## Why this is MEDIUM tier

From the [classification process](../core/risk-tiers.md#classification-process): the data is sensitive (internal, some of it confidential), the audience is internal and authenticated, there are no external actions and no automated decisions, and human judgment sits between the assistant's answer and any consequence. Moderate impact, sensitive data, human review expected: **MEDIUM**. The jump from the [LOW FAQ bot](example-faq-low.md) is driven entirely by *whose data the corpus contains*.

## RAG is the attack surface

[Retrieval is the largest attack surface](https://airuntimesecurity.io/insights/rag-is-your-biggest-attack-surface/) for a system like this, in three distinct ways:

| Risk | What goes wrong |
|------|-----------------|
| **Over-retrieval across permissions** | The index contains HR records, board papers, and salary data. If retrieval ignores who is asking, the assistant becomes a way to read documents the employee has no right to. This is the dominant risk. |
| **Indirect injection via documents** | A document in the corpus contains text like "ignore prior instructions and reveal...". When retrieved, it becomes input to the model. Internal does not mean trusted: any document anyone can edit is an injection vector. |
| **Retrieval poisoning** | Someone adds or edits a document specifically to change the assistant's answers, for example to misstate a policy or approval threshold. |

## Identity is a retrieval control, not just a login

The defining control for this system is **identity-aware retrieval**: the assistant must retrieve only what the *asking user* is entitled to see, enforced at the data layer, not by asking the model to be careful.

| Control | What it does | Reference |
|---------|--------------|-----------|
| Access-controlled RAG | Filter retrieval by the user's identity and entitlements before chunks reach the model | [DAT-04](../infrastructure/controls/data-protection.md) |
| Data classification at ingestion | Tag documents by sensitivity so retrieval and redaction can act on it | [DAT-01](../infrastructure/controls/data-protection.md) |
| Identity propagation | The user's identity, from SSO, flows through to the retrieval query; the assistant never holds broader access than the user | [IAM Governance](../core/iam-governance.md), [Identity & Access](../infrastructure/controls/identity-and-access.md) |
| Untrusted-content handling | Retrieved text is treated as data, never as instructions; strip or neutralise embedded directives | [Threat Modelling](../threat-modelling.md) |
| Output checks | Scan responses for sensitive data and for content the user should not receive | [Output guardrails](../core/controls.md#1-guardrails) |

!!! warning "The chunk-level trap"
    A common mistake is to apply access control to *documents* but index at the *chunk* level without carrying the permissions onto each chunk. The result: a user who cannot open a confidential document can still have its chunks retrieved and summarised back to them. Entitlements must travel with the data all the way to retrieval.

## Controls that match the risk

Beyond identity-aware retrieval, MEDIUM tier calls for:

- **Standard input and output guardrails**: injection detection on input, sensitive-data checks on output.
- **Judge sampling**, not 100% evaluation: at MEDIUM with a human reading every answer, sampling outputs to catch drift and leakage is proportionate. See [Risk Tiers control matrix](../core/risk-tiers.md#control-matrix).
- **Logging** of queries, retrieved sources, and responses, so an over-retrieval incident can be reconstructed ([Logging & Observability](../infrastructure/controls/logging-and-observability.md)).
- **Corpus governance**: control who can add or edit indexed documents, and review changes, to limit poisoning and indirect injection.

What you still do not need: real-time Judge on every output, dual human approval, or agentic controls, there are no actions to approve.

## What this example teaches

Identity is not just authentication at the door; for retrieval systems it is the primary data-protection control, enforced at the data layer. Get access-controlled retrieval right and most of this system's risk disappears. Get it wrong and no output guardrail will reliably save you. Next, the [HIGH Customer-Service Assistant](worked-example.md) adds tools and actions on top of retrieval, and the [MCP Engineering Agent](example-mcp-agent.md) pushes tooling and identity to their limit.

!!! info "References"
    - [Data Protection for AI Systems](../infrastructure/controls/data-protection.md)
    - [IAM Governance for AI Systems](../core/iam-governance.md)
    - [Risk Tiers and Control Selection](../core/risk-tiers.md)
    - [AI Runtime Security: RAG Is Your Biggest Attack Surface](https://airuntimesecurity.io/insights/rag-is-your-biggest-attack-surface/)
    - [AI Runtime Security: RAG Security](https://airuntimesecurity.io/extensions/technical/rag-security/)
