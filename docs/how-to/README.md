---
description: A practical, end-to-end guide for designing a secure AI system, worked through a single example from the decision to use AI through controls, testing, scaling, and PACE resilience.
---

# How To: Design a Secure AI System

The rest of this site is organised by topic: threats here, controls there, infrastructure over there. This section puts it together. It walks one realistic system from a blank page to a design you could hand to an engineering team, making the decisions an architect actually has to make and showing the reasoning behind each one.

It is deliberately opinionated about *method* and deliberately neutral about *products*. You will see categories of technical solution (a gateway, an evaluator, a vault) but no endorsements. The right product is the one that fits your constraints; the method for choosing controls is the same regardless.

## The worked example

Throughout this section we design the same system: **Meridian Bank's customer-service assistant**, an authenticated chat assistant in the bank's web and mobile apps. It answers account and product questions from the bank's own documents, can look up a balance and recent transactions, can raise a transaction dispute, and can update a customer's contact details. It hands off to a human agent when it cannot help.

That single system is enough to exercise nearly every decision: sensitive data, retrieval, tool use, actions of varying impact, and a clear business case to test against.

## The path

| Step | Page | The question it answers |
|------|------|--------------------------|
| 1 | [Should You Use AI?](should-you-use-ai.md) | Is AI the right solution here, or is something simpler and safer? |
| 2 | [Worked Example](worked-example.md) | How do the threat model, risk tier, and controls come together end to end? |
| 3 | [Selecting Guardrails](selecting-guardrails.md) | How do I choose the right guardrails and match each control to the risk? |
| 4 | [Scaling and PACE](scaling-and-pace.md) | How do I scale this, and how do I use PACE resilience properly? |

!!! tip "Read it as a path, use it as a reference"
    The first time through, read in order; the example builds on itself. Afterwards, each page stands alone as a how-to you can return to. Every step links back to the underlying reference pages ([Threat Modelling](../threat-modelling.md), [Risk Tiers](../core/risk-tiers.md), [Controls](../core/controls.md), [Infrastructure & Operations](../infrastructure/README.md)) when you need the detail.

!!! info "References"
    - [Threat Modelling for AI Systems](../threat-modelling.md)
    - [Risk Tiers and Control Selection](../core/risk-tiers.md)
    - [Controls: Guardrails, Judge, and Human Oversight](../core/controls.md)
    - [AI Runtime Security](https://airuntimesecurity.io/)
