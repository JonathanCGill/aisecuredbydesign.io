---
description: A decision guide for whether AI is the right solution to a problem, the questions to ask before building, and the cases where simpler or more deterministic technology is the safer choice.
---

# Should You Use AI?

The most effective AI security control is sometimes the decision not to use AI. Before any threat model or control selection, an architect should be able to answer one question honestly: **is a probabilistic, non-deterministic system the right tool for this problem, or are we reaching for it because it is fashionable?**

This page is the filter. If a use case passes it, the rest of the guide shows you how to secure it. If it fails, you have saved yourself the cost and risk of securing something that should not have been built.

## Start with the problem, not the technology

Describe the problem without mentioning AI. Then ask what class of solution fits:

| If the problem is... | The better tool is often... |
|----------------------|------------------------------|
| A fixed set of rules with known inputs | Deterministic logic, a workflow engine, or a form |
| Looking something up | Search, a database query, or a knowledge base |
| A calculation with a correct answer | Code that computes it |
| Routing or classification with stable categories | A conventional classifier or rules |
| Open-ended language understanding, summarisation, or generation | A language model, possibly |

AI earns its place where the input is genuinely open-ended and a deterministic system cannot economically cover the variation. If a cheaper, testable, deterministic tool solves it, that tool is also easier to secure, because you can verify it before it runs.

## The five questions

Run every candidate use case through these. A "no" is not automatically disqualifying, but it tells you where the risk and cost will land.

1. **Can a wrong answer be tolerated or caught?** Non-determinism means the system will sometimes be wrong. If a wrong answer is catastrophic *and* cannot be verified before it has effect, AI is a poor fit unless a human or a deterministic check sits in front of the consequence.
2. **Can you verify the output?** If neither a person nor another system can tell a good output from a bad one, you cannot build assurance around it. Verifiability is a precondition for the [Judge](../core/controls.md#2-model-as-judge) and [human oversight](../core/controls.md#3-human-oversight-hitl) layers.
3. **Do you have, and may you use, the data?** AI needs representative data and the legal right to use it. If the data is unavailable, low quality, or restricted, the system will underperform or create compliance exposure regardless of controls.
4. **Can you oversee it at the scale you intend to run it?** A control set that depends on human review only works if you can staff the review at production volume. If you cannot, you are designing oversight you will not have.
5. **Is the benefit worth the control cost?** Securing an AI system is not free: guardrails, evaluation, logging, and oversight all carry cost and latency. If the value is marginal, the secured system may not be worth building.

!!! warning "The temptation to over-scope"
    Most failed AI projects are not insecure; they are mis-scoped. A system that tries to *answer questions and take high-impact actions and exercise judgment* concentrates risk. Splitting the safe, high-value part from the risky, low-value part is itself a security decision.

## Worked example: Meridian Bank

Meridian wants an assistant that deflects repetitive customer-service contacts. Running the filter:

- **The problem without AI:** customers ask account and product questions in their own words, at volume, around the clock. Search exists but customers struggle to phrase queries; the contact centre is expensive. This is open-ended language understanding over the bank's own content. AI is a credible fit for the *question-answering* part.
- **Wrong answers:** a wrong product answer is recoverable and can be caught by evaluation and disclaimers. A wrong *contact-detail change* is not easily recoverable and enables account takeover. These are different risk problems hiding in one product.
- **Verifiability:** answers can be checked against source documents; actions can be checked against account state. Both are verifiable, which means assurance is buildable.
- **Decision:** AI is justified for question-answering and read-only lookups. The high-impact write actions (changing contact details, raising disputes) are scoped tightly: they are *proposed* by the assistant but require either step-up authentication or human confirmation, rather than being executed autonomously. The lowest-value, highest-risk capability is deliberately not automated.

That scoping decision shapes everything that follows. Carry it into the [Worked Example](worked-example.md), where we threat model the system we actually chose to build.

!!! tip "Revisit the decision"
    "Should you use AI" is not a one-time gate. As the use case grows (more actions, more autonomy, more agents), re-run the five questions. The answer that held for a read-only assistant may not hold once it can move money.

!!! info "References"
    - [Threat Modelling for AI Systems](../threat-modelling.md)
    - [Risk Tiers and Control Selection](../core/risk-tiers.md)
    - [AI-Aware SDLC](../getting-started/ai-sdlc.md)
    - [AI Runtime Security: Should You Use AI at All?](https://airuntimesecurity.io/should-you-use-ai/)
