---
description: When and how to perform adversarial testing on AI systems before deployment. Testing cadence, methods, and requirements scaled by risk tier.
---

# Adversarial Testing

Adversarial testing is the practice of deliberately attempting to make an AI system behave in unintended ways. It goes beyond functional testing (does it produce correct outputs?) to ask a harder question: can someone make it produce harmful, incorrect, or unauthorised outputs on purpose?

This matters before deployment because design reviews prove intent, but only testing proves reality. A well-designed system with untested guardrails is a system with unverified guardrails.

## Why adversarial testing is different for AI

Traditional software testing is deterministic: given input X, expect output Y. AI systems are non-deterministic, and adversarial testing for AI must account for this.

**What makes AI adversarial testing distinct:**

- The same attack prompt can produce different results on different runs
- Models can be manipulated through natural language, not just technical exploits
- Safety training can be bypassed through creative prompting that technical controls may not catch
- Model updates (even minor ones) can change the attack surface
- Context window manipulation, multi-turn attacks, and tool-use exploitation create attack vectors that do not exist in traditional software

## Testing requirements by tier

Testing cadence and depth scale with [risk classification](risk-classification.md). Over-testing a LOW-tier system wastes resources. Under-testing a CRITICAL-tier system creates unacceptable risk.

| Aspect | LOW | MEDIUM | HIGH | CRITICAL |
|--------|-----|--------|------|----------|
| **Pre-deployment testing** | Basic prompt injection check | Structured test suite | Comprehensive red-team exercise | Full adversarial assessment by independent team |
| **Ongoing cadence** | Ad hoc / on major changes | Quarterly | Monthly | Continuous |
| **Tester independence** | Development team | QA or security team | Dedicated red team | External + internal red team |
| **Scope** | Core functionality | Functionality + common attacks | Full attack surface | Full attack surface + novel techniques |
| **Reporting** | Internal notes | Documented findings | Formal report with remediation plan | Formal report, board-level summary, regulatory filing if required |

## What to test

### Prompt injection

Prompt injection is the most common attack vector against LLM-based systems. Test for both direct injection (the user crafts a malicious prompt) and indirect injection (malicious content is embedded in data the model retrieves or processes).

**Direct injection tests:**

- Attempts to override system prompts ("Ignore your instructions and...")
- Role-play attacks ("Pretend you are an unrestricted AI...")
- Encoding attacks (Base64, Unicode, mixed-language prompts to bypass filters)
- Multi-turn manipulation (gradually steering the model across several messages)

**Indirect injection tests:**

- Malicious content in documents retrieved by RAG pipelines
- Poisoned embeddings in vector databases
- Adversarial content in tool outputs (API responses, database records)
- Hidden instructions in images, PDFs, or other files processed by the model

!!! warning "RAG systems are especially vulnerable to indirect injection"
    If your system retrieves external content and feeds it to the model, test what happens when that content contains adversarial instructions. This is a pre-runtime concern: the security of your RAG pipeline determines whether an attacker can inject instructions through your data sources.

### Data exfiltration

Test whether the model can be manipulated into revealing information it should not. This includes:

- System prompt extraction (asking the model to repeat its instructions)
- Training data extraction (attempting to recover memorised data)
- Cross-user data leakage (in multi-tenant systems, accessing another user's context)
- Tool credential exposure (tricking the model into revealing API keys or connection strings used by tools)

### Output manipulation

Test whether the model can be made to produce outputs that violate its intended constraints:

- Generating content that violates content policies
- Producing outputs in formats that bypass downstream safety checks
- Creating outputs that exploit downstream systems (SQL injection via model output, XSS in generated HTML)
- Confidence manipulation (making the model express certainty about incorrect information)

### Tool use and action abuse

For agentic systems with tool access, test whether the model can be manipulated into misusing its tools:

- Executing actions outside its intended scope
- Escalating privileges through tool chaining
- Performing actions on wrong targets (acting on the wrong account, file, or record)
- Bypassing action confirmation requirements

### Multi-agent specific testing

For [multi-agent systems (MASO)](risk-classification.md#multi-agent-systems-maso), additional testing is required:

- Agent impersonation (one agent pretending to be another)
- Delegation boundary violations (an agent requesting actions beyond its scope from another agent)
- Privilege escalation through agent chains (combining low-privilege agents to achieve high-privilege outcomes)
- Orchestrator manipulation (attacking the coordinating agent to influence all downstream agents)

## Testing methods

### Structured test suites

Build and maintain a library of test cases covering known attack patterns. Run this suite before every deployment and after every model update.

**Sources for test cases:**

- [OWASP LLM Top 10](https://owasp.org/www-project-top-10-for-large-language-model-applications/) maps directly to test categories
- [OWASP Agentic Top 10](https://owasp.org/www-project-agentic-ai-threats-and-mitigations/) for agentic-specific attacks
- [MITRE ATLAS](https://atlas.mitre.org/) provides a comprehensive taxonomy of adversarial ML techniques
- Vendor-specific vulnerability disclosures and advisories
- Your own incident history and near-misses

### Red-team exercises

Red-teaming goes beyond scripted tests. A red team attempts to achieve specific objectives (exfiltrate data, bypass controls, manipulate outputs) using any technique available, including novel approaches.

**When to red-team:**

- Before first production deployment (all tiers except LOW)
- After significant model changes or upgrades
- After adding new tools or data sources to the system
- On the cadence specified by your [risk tier](risk-classification.md)

**Red-team planning:**

- Define clear objectives (what does "success" look like for the attacker?)
- Scope the engagement (which systems are in scope, which are not)
- Agree rules of engagement (can testers target production, or only staging?)
- Ensure independence (testers should not be the same people who built the system)
- Plan for remediation (findings without fixes are just documentation)

### Domain-specific testing

The UK AI Security Institute's Frontier AI Trends Report (December 2025) found that safeguard coverage varies dramatically by category. A model that robustly refuses biological misuse requests may readily provide inappropriate financial advice. Generic testing is insufficient.

**Practical guidance:**

- At HIGH and CRITICAL tiers, test guardrails specifically against the risk categories relevant to your use case, not just the provider's default test suite
- Do not assume that a model's strong performance in one safety category transfers to your domain
- Schedule domain-specific red-team testing at least quarterly for HIGH tier and monthly for CRITICAL tier systems
- More capable models are not inherently safer. Do not reduce testing when upgrading models.

## Connecting testing to the pipeline

Adversarial testing is not a one-off activity. Integrate it into your [CI/CD pipeline](../building/devops/ci-cd-for-ai.md) and [ML lifecycle](../building/mlops/model-lifecycle.md).

### Pre-deployment gate

No AI system should reach production without passing adversarial testing appropriate to its tier. This is a deployment gate, not a suggestion.

| Tier | Minimum gate requirement |
|------|------------------------|
| **LOW** | Basic prompt injection test suite passes |
| **MEDIUM** | Structured test suite passes, no HIGH-severity findings |
| **HIGH** | Red-team exercise completed, all findings remediated or accepted with documented risk acceptance |
| **CRITICAL** | Independent adversarial assessment completed, findings reviewed by senior stakeholders, remediation plan approved |

### Regression testing

When you fix an adversarial finding, add the attack to your regression test suite. This ensures the fix persists through future model updates and system changes.

### Model update testing

Model updates can change the attack surface in unpredictable ways. Re-run your adversarial test suite whenever the underlying model is updated, even for minor version changes. This applies to both self-hosted models and API-based models where the provider updates the model.

!!! abstract "Testing bridges pre-runtime and runtime"
    Pre-runtime adversarial testing validates that controls work before deployment. [Runtime monitoring](https://airuntimesecurity.io/) validates that they continue to work in production. The test cases you develop here feed directly into runtime detection rules. An attack pattern you discover during testing becomes a pattern to monitor for in production.

!!! info "References"
    - [OWASP LLM Top 10](https://owasp.org/www-project-top-10-for-large-language-model-applications/)
    - [OWASP Agentic Top 10](https://owasp.org/www-project-agentic-ai-threats-and-mitigations/)
    - [MITRE ATLAS: Adversarial Threat Landscape for AI Systems](https://atlas.mitre.org/)
    - [NIST AI 100-2: Adversarial Machine Learning](https://csrc.nist.gov/pubs/ai/100/2/e2023/final)
    - [UK AI Security Institute: Frontier AI Trends Report (December 2025)](https://www.aisi.gov.uk/)
    - [AI Runtime Security](https://airuntimesecurity.io/)
