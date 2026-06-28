---
description: A LOW-tier worked example, a public website FAQ assistant, showing risk-proportionate control selection, the real risks of a public-facing bot, and why not to over-engineer.
---

# LOW Tier: Public FAQ Assistant

**The system:** an unauthenticated chatbot on a company's public website that answers product and support questions from the company's public documentation. No login, no personal data, no actions. It only retrieves from public content and replies in text.

This example exists to show the opposite of heavy control: where the risk is genuinely low, the discipline is *not over-engineering*, while still respecting the one or two risks that are real even here.

## Why this is LOW tier

Run the [classification process](../core/risk-tiers.md#classification-process): no sensitive data, no decisions, no actions, public information only, and the worst realistic outcome is an embarrassing or wrong answer. Impact is minimal across every dimension, so the system lands at LOW. A LOW tier does not mean *no controls*; it means a small, proportionate set aimed at the few risks that survive.

## The risks that are still real

A public bot has no data to leak, but it has a brand to damage and a bill to run up.

| Risk | Why it still matters at LOW |
|------|------------------------------|
| **Reputational prompt injection** | A visitor coaxes the bot into saying something offensive, off-brand, or into "agreeing" to a commitment. Public, screenshot-able, and the classic way these bots make the news. |
| **RAG over editable content** | If the public corpus can be edited by many hands, a careless or malicious change becomes the bot's answer. Even public content is an [indirect-injection](../threat-modelling.md) surface. |
| **Off-topic use** | The bot is turned into a free general-purpose assistant, a coding helper, or a soapbox, none of which you want to host or pay for. |
| **Abuse and cost** | Automated traffic runs up token cost or degrades availability. There is no authentication to hide behind. |

!!! warning "The cautionary tale"
    The well-known cases of public chatbots being talked into absurd statements or "selling" something for a token amount were almost all LOW-tier systems with no output guardrails and no topic scope. The lesson is not "add more AI controls"; it is "scope the bot and check its output before it speaks."

## Controls that match the risk

| Risk | Control | Depth at LOW |
|------|---------|--------------|
| Reputational injection | Output guardrails: brand-safety and topic checks before the reply is shown | Basic but present |
| Off-topic use | Input scope limits; refuse and redirect outside the supported topics | Basic |
| RAG content integrity | Control who can edit the public corpus; review changes; mark retrieved text untrusted | Basic |
| Abuse and cost | Rate limiting and spend caps at the [gateway](../infrastructure/controls/network-and-segmentation.md); abuse monitoring | Basic |
| Everything | Logging of inputs and outputs, so you can see what happened | All tiers |

What you do **not** need at LOW: a full [Model-as-Judge](../core/controls.md#2-model-as-judge) on every response (sampling is plenty), human review queues, network micro-segmentation, or agentic controls, because there are no agents and no actions. Adding them here spends budget and latency on risks the system does not have.

!!! tip "The LOW-tier test"
    If you find yourself designing approval workflows for a bot that cannot do anything, you have mis-tiered it or mis-scoped it. Go back to [Should You Use AI?](should-you-use-ai.md) and confirm the scope, then apply only the controls the real risks justify.

## What this example teaches

Risk-proportionate means proportionate in *both* directions. The skill on display here is restraint: identify the two or three risks that survive at LOW (brand, corpus integrity, abuse), control those well, and consciously [deselect](../core/risk-tiers.md) the rest. Contrast it with the [MEDIUM Internal Knowledge Assistant](example-knowledge-medium.md), where adding sensitive data and real users changes the picture entirely.

!!! info "References"
    - [Risk Tiers and Control Selection](../core/risk-tiers.md)
    - [Controls: Guardrails, Judge, and Human Oversight](../core/controls.md)
    - [Threat Modelling for AI Systems](../threat-modelling.md)
    - [AI Runtime Security: the Chevrolet $1 chatbot walkthrough](https://airuntimesecurity.io/walkthrough-chevrolet-1-dollar/)
