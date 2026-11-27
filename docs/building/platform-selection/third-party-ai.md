---
description: Securing AI you buy rather than build, covering AI features inside SaaS products, AI apps connected through OAuth, discovery of shadow AI, vendor assessment, configuration, and contract terms.
---

# AI in Third-Party Software

Much of the AI in an organisation was never designed there. It arrives as a feature inside software you already use: an assistant in the office suite, AI summaries in the CRM, a meeting bot, an email agent, or an app a team connected with a few OAuth clicks. You do not control the model, the prompts, or the guardrails. You do control what it can reach, whether it is switched on, and what the contract says.

This page covers that case. For AI platforms you build on, see [Cloud AI Services](cloud-ai-services.md).

## Why it needs its own approach

| Property | AI you build | AI in third-party software |
|----------|--------------|---------------------------|
| **Model, prompts, guardrails** | Yours to choose and test | The vendor's, and they change without notice |
| **When it switches on** | When you deploy it | Often by vendor update, sometimes on by default |
| **Data access** | Designed per use case | Inherits the product's existing access, which is often broad |
| **Actions** | Scoped by your tool gateway | Whatever the product's connectors and the user's permissions allow |
| **Evidence** | Your own logs | Whatever the vendor exposes |

The risk is real. In June 2025, Aim Security disclosed **EchoLeak** (CVE-2025-32711), a zero-click prompt injection in Microsoft 365 Copilot. A crafted email, never opened by the user, could cause the assistant to pull internal data into a response and send it out through a link. The assistant read untrusted content, had access to the user's data, and had an outbound channel: the [lethal trifecta](../../core/injection-resistant-design.md#the-lethal-trifecta) inside a product the customer did not build.

## Discover what is in use

You cannot assess what you have not found. Sources, roughly in order of effort:

- **SSO and OAuth grant logs.** Apps users have authorised against your identity provider or office suite, with the scopes they hold.
- **Admin consoles of major SaaS products.** AI features that are available, enabled, or in preview.
- **Network and SSE or CASB logs.** Traffic to AI services and AI-enabled SaaS.
- **Browser extension management.** AI extensions that can read every page a user visits.
- **Procurement and expense data.** Team-level subscriptions that never went through IT.

Record each one in the same inventory as the AI you build, with an owner and a [risk tier](../../getting-started/risk-classification.md).

## Assess before enabling

Use a vendor questionnaire scaled to the tier. A detailed template is on [airuntimesecurity.io](https://airuntimesecurity.io/extensions/templates/vendor-assessment-questionnaire/). The questions that matter most for embedded AI:

| Area | Ask |
|------|-----|
| **Training and retention** | Are prompts, outputs, or your content used for training? How long are they kept, and where? |
| **Model providers** | Which model providers process your data, as subprocessors, and in which regions? |
| **Agentic actions** | What can the AI do, not just read? Send, post, edit, delete, buy, or call other systems? |
| **Untrusted content** | Does it read content from outside your organisation, such as inbound email, shared files, or web pages? How is prompt injection handled, and what testing evidence exists? |
| **Outbound channels** | Can its output cause requests to leave your boundary, such as rendered images, links, or connectors? |
| **Admin controls** | Can you disable it, limit it to groups, restrict it to labelled data, or turn off specific actions? |
| **Logging** | Are prompts, responses, and actions logged, and can you export the logs to your SIEM? |
| **Change notice** | Will you be told before new AI features or model changes reach your tenant? |
| **Incidents** | What is the notification time for incidents involving the AI feature? |
| **Regulation** | Who is the provider and who is the deployer under the EU AI Act for this feature? See [Regulatory Alignment](../../getting-started/regulatory-alignment.md) |

Map the answers to the Rule of Two. If the feature reads untrusted content, has access to sensitive data, and can act or send externally, it needs confirmation before actions or one of those capabilities removed through configuration. See [Injection-Resistant Design](../../core/injection-resistant-design.md#the-agents-rule-of-two).

## Configure before rollout

- **Off until assessed.** Disable new AI features by default where the admin console allows it, and enable them per group after assessment.
- **Least privilege connectors.** Review the scopes on AI connectors and OAuth apps. Read-only where possible. Remove access to mailboxes, drives, or systems the use case does not need.
- **Data boundaries.** Use sensitivity labels or equivalent so the AI cannot read data above the classification the use case allows. See [Data Protection](../../infrastructure/controls/data-protection.md).
- **Confirm before acting.** Require user confirmation for sends, posts, and edits made by the AI, especially where it reads external content.
- **Close outbound channels.** Disable external image rendering and link unfurling in AI output where the product allows it.
- **Log centrally.** Send audit events for AI use to your SIEM. See [Logging and Observability](../../infrastructure/controls/logging-and-observability.md).

## Contract terms

| Term | Why |
|------|-----|
| No training on your data without opt-in | Keeps your content out of the vendor's models |
| Named model subprocessors and regions, with notice of change | Data residency and supply chain visibility |
| Advance notice of new AI features and model changes | Time to reassess before they reach users |
| Ability to disable AI features without losing the core product | Keeps you in control of the risk |
| Audit log access for AI prompts, responses, and actions | Evidence for incidents and audits |
| Incident notification time that covers AI features | Response starts on your timeline, not the vendor's |

## Keep it current

- Re-assess when the vendor announces new AI features, especially agentic ones.
- Review OAuth grants for AI apps every quarter and revoke unused ones.
- Track the vendor's model changes the same way as your own: a new model behind a feature is a change in risk. See [Model Lifecycle](../mlops/model-lifecycle.md#provider-model-deprecation).

## Controls by risk tier

| Tier | Minimum expectation |
|------|---------------------|
| **LOW** | In the inventory, training opt-out confirmed, default-on features reviewed |
| **MEDIUM** | Vendor questionnaire, least privilege connectors, central logging |
| **HIGH** | Rule of Two assessment, confirmation before actions, outbound channels closed, contract terms in place |
| **CRITICAL** | Avoid embedded AI with agentic actions on critical data unless the vendor provides evidence of injection testing and you can enforce confirmation on every action |

!!! info "References"
    - [Aim Security: EchoLeak, zero-click AI vulnerability in Microsoft 365 Copilot](https://www.aim.security/lp/aim-labs-echoleak-blogpost)
    - [NVD: CVE-2025-32711](https://nvd.nist.gov/vuln/detail/CVE-2025-32711)
    - [AI Runtime Security: AI Vendor Assessment Questionnaire](https://airuntimesecurity.io/extensions/templates/vendor-assessment-questionnaire/)
    - [OWASP LLM02:2025 Sensitive Information Disclosure](https://genai.owasp.org/llmrisk/llm022025-sensitive-information-disclosure/)
    - [NIST CSF 2.0: Supply Chain Risk Management (GV.SC)](https://www.nist.gov/cyberframework)
