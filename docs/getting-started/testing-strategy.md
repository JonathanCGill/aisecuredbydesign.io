---
description: How to test AI systems before deployment. The full testing taxonomy, what each test type proves, which testing applies at each risk tier, and the exit criteria for production and for the handover to runtime security.
---

# Testing Strategy

Design reviews prove intent. Testing proves reality. Everything else on this site helps you *choose* the right model, platform, pipeline, and controls; testing is where you find out whether those choices actually hold when something pushes against them.

This page is the overview of the **Test & Validate** stage. It answers three questions in order: how AI testing is done and what kinds of tests exist, which of those tests you owe at each [risk tier](risk-classification.md), and what has to be true before the system reaches production and before [runtime security](https://airuntimesecurity.io/) takes over. Two deep-dive pages sit underneath it: [Adversarial Testing](adversarial-testing.md) for the attack-focused work, and [Production Readiness](production-readiness.md) for the operational deployment gate.

!!! info "This is pre-runtime testing"
    Everything here happens before the system is live. It validates that the controls you designed work at all. [Runtime security](https://airuntimesecurity.io/) then validates that they keep working under real traffic. The test cases you build here are not throwaway: they become the regression suite and feed directly into runtime detection.

## How AI testing is different

Traditional software testing is deterministic: input X produces output Y, so a single pass or fail is meaningful. AI systems are stochastic. The same prompt can produce different outputs on different runs, safety behaviour varies by category, and a model update can move the whole attack surface without warning.

That changes how you test in three concrete ways.

- **Test as a pass rate, not a pass or fail.** Run each test case multiple times and set a threshold (for example, "blocks the injection on 99 of 100 runs"). A control that works once is not a control that works.
- **Test the model you will ship, and re-test on every change.** Provider-side model updates, prompt changes, new tools, and new data sources all invalidate previous results. Treat any of them as a trigger to re-run the suite.
- **Judge correctness, not just compliance.** Whether an output is *policy-compliant* is easy to check. Whether it is *correct* often is not. Where correctness cannot be verified automatically, that is a signal to lean on human evaluation and, downstream, on human oversight.

### Where testing happens

| Environment | What it is for |
|-------------|----------------|
| **Component / unit** | Individual guardrails, filters, and tool wrappers, tested in isolation against known inputs. |
| **Staging** | The assembled system on representative data, exercised end to end before any user sees it. |
| **Shadow (parallel run)** | The system runs alongside the existing process or in detect-only mode, producing outputs with no live effect, so you can calibrate controls against reality. |
| **Canary** | A small, real slice of production traffic, watched closely, with a fast rollback path. |

### How outputs get evaluated

No single method is enough on its own. Combine them and size the mix to the tier.

- **Golden datasets.** A curated set of inputs with known-good expected behaviour, scored automatically. The backbone of repeatable capability and regression testing.
- **Human evaluation.** Domain experts review sampled outputs for quality, safety, and correctness the automated checks cannot judge.
- **Model-as-judge (offline).** A model scores sampled outputs against explicit criteria at a scale humans cannot reach. This is the *same* [Model-as-Judge](../core/controls.md#the-model-as-judge) pattern you will run at runtime, used here in evaluation mode. Keep the judge honest with [Judge Assurance](../core/judge-assurance.md).
- **Statistical monitoring.** Aggregate measures (refusal rates, drift, fairness metrics, latency distributions) that only mean something across many runs.

## The types of testing

"Testing" is not one activity. These are the test types a pre-runtime programme draws on. Not every system needs every type; the [next section](#testing-by-risk-tier) maps them to tiers.

1. **Functional and capability evaluation.** Does the system do its actual job, accurately and consistently, on representative inputs? Run against a golden dataset and score it.
2. **Guardrail and control testing.** Do the input and output guardrails, scanners, and the semantic firewall fire when they should and stay quiet when they should not? Test each control against known-good and known-bad inputs, ideally in shadow mode so you can tune the false-positive rate before it holds live traffic. See [Selecting Guardrails](../how-to/selecting-guardrails.md).
3. **Adversarial testing and red-teaming.** Can someone *make* the system misbehave on purpose? Prompt injection (direct and indirect), data exfiltration, output manipulation, tool abuse. This is a whole discipline: see [Adversarial Testing](adversarial-testing.md).
4. **Data and retrieval testing.** For RAG and any system that ingests external content, test what happens when that content is poisoned or carries hidden instructions. Retrieved text must be treated as data, never as instruction. See [Data Governance](../building/mlops/data-governance.md) and [Data Protection](../infrastructure/controls/data-protection.md).
5. **Robustness and consistency testing.** Does the same request, reworded or repeated, produce stable and safe behaviour? Test paraphrases, edge cases, long contexts, and multi-turn conversations, and measure variance across runs.
6. **Bias, fairness, and harm testing.** Does the system produce discriminatory or harmful outputs across the groups and categories it will touch? Safeguard strength varies sharply by category, so test the categories *your* use case actually engages rather than trusting a provider's default coverage.
7. **Performance, latency, and cost testing.** Does the system meet its latency budget under peak load, and what does inline evaluation cost per request? Controls that are too slow or too expensive get switched off, which is a security failure by another route.
8. **Resilience and failover testing.** When a component degrades or fails, does the system fall back the way its [PACE plan](../building/devops/resilience.md) says it should? Deliberately break dependencies and confirm the fail posture (fail-open or fail-closed) is correct for the tier.
9. **Integration and human-oversight testing.** Does the end-to-end system work with its real tools and downstream systems, and does the human-oversight path actually function? Test the escalation, the review queue, and the kill switch, not just the model.
10. **Regression testing.** Every fixed finding becomes a permanent test case. Re-run the accumulated suite on every model update and system change so old failures cannot quietly return.

## Testing by risk tier

The tier you assigned during [risk classification](risk-classification.md) sets how much of the above you owe. Over-testing a LOW-tier FAQ bot wastes effort; under-testing a CRITICAL-tier decisioning system is negligence. The cells below describe the *depth* expected, not a different activity.

| Test type | LOW | MEDIUM | HIGH | CRITICAL |
|-----------|-----|--------|------|----------|
| **Functional / capability** | Spot-check | Golden set, sampled | Full scored eval set | Full eval set, independently reviewed |
| **Guardrail / control** | Basic on/off check | Input and output tested | Shadow-mode calibration | Per-control assurance, continuous |
| **Adversarial / red-team** | Basic injection suite | Structured test suite | Red-team exercise | Independent adversarial assessment |
| **Data / retrieval** | If applicable | Source vetting | Indirect-injection and poisoning tests | Full provenance and integrity tests |
| **Robustness / consistency** | Optional | Repeat-run sampling | Paraphrase and multi-run thresholds | Statistical consistency bounds |
| **Bias / fairness / harm** | Optional | Basic checks | Domain harm categories tested | Formal fairness assessment |
| **Performance / latency / cost** | Basic timing | Load-tested | Tested under peak and degradation | Full capacity and cost-cap tests |
| **Resilience / PACE failover** | Plan documented | Fallback tested | Failover drills | Full PACE cycle exercised |
| **Integration / human oversight** | Smoke test | End-to-end | Oversight workflow tested end to end | Escalation and kill switch drilled |
| **Regression** | On major change | Before each deploy | Every model update | Every change, automated gate |

**Reading the tiers as a progression:**

- **LOW.** Prove it works and that the obvious injection does not. A single tester and a small suite are enough.
- **MEDIUM.** A structured, repeatable suite run before each deployment, with guardrails validated and no HIGH-severity findings left open. Testing moves off the developer's desk to QA or security.
- **HIGH.** A dedicated red team, domain-specific harm testing, and an oversight workflow proven end to end. Findings are remediated or formally risk-accepted, not just noted.
- **CRITICAL.** An independent assessment, ground-truth validation through shadow and canary running, and senior sign-off on whatever residual risk remains. Nothing autonomous ships on internal testing alone.

## Exit criteria: ready for production

Testing ends in a decision, not a document. The [deployment gate](production-readiness.md#the-deployment-gate) is that decision point, and it is a hard gate: no AI system reaches production without passing testing appropriate to its tier. Production Readiness holds the full operational checklist; the *testing* conditions that gate depends on are these.

| Tier | Testing is "done" when |
|------|------------------------|
| **LOW** | Basic capability and injection suites pass. No known unmitigated high-severity issue. |
| **MEDIUM** | Structured suite passes with no open HIGH-severity findings. Guardrails validated in staging. Regression suite established. |
| **HIGH** | Red-team exercise complete and findings remediated or formally accepted. Domain harm and robustness tests pass. Human-oversight and failover paths proven end to end. |
| **CRITICAL** | Independent adversarial assessment complete. Behaviour validated against ground truth in shadow or canary. Senior stakeholder sign-off on residual risk. All findings remediated or explicitly board-accepted. |

!!! warning "Untested controls are unverified controls"
    A guardrail that has never been tested against the attack it is meant to stop is a design assumption, not a control. At HIGH and CRITICAL tiers, treat any control without evidence it works as if it were absent when you weigh residual risk.

## Handover: before runtime security takes over

Passing the gate makes a system *deployable*. The handover to [runtime security](https://airuntimesecurity.io/) makes it *owned*. This is not a clean break, it is a structured transition: responsibility moves, but the context testing produced has to move with it, or runtime security starts blind. [Production Readiness](production-readiness.md#the-runtime-security-handoff) covers the full handoff; from a testing standpoint, two things must be true.

**The evidence must be transferred, not just filed.** Runtime security inherits what you learned, not only what you shipped.

- **Test report and residual-risk register.** What was tested, what passed, what findings were accepted rather than fixed, and the known failure modes that came out of testing.
- **The regression suite and discovered attack patterns.** Every attack you found during adversarial testing is a pattern to monitor for in production. Hand over the suite so runtime detection can be seeded from it, and so the same suite can gate future updates.
- **Control configuration and calibration.** The guardrail thresholds, judge policies, and false-positive rates you tuned in shadow mode are the runtime starting point. Without them, runtime re-derives everything from scratch.

**The definition of "trustworthy" must be shared.** Pre-runtime testing ensures that what gets deployed *is* trustworthy. Runtime security ensures it *stays* trustworthy. That handoff only works if both sides agree on what trustworthy means for this system and how it is measured: the same risk tier, the same control set, the same evaluation criteria carried across the boundary. For HIGH and CRITICAL systems, walk through it in a formal handoff meeting rather than a document drop.

<div class="runtime-callout" markdown>
<p class="runtime-callout__label">Continue to</p>
<p class="runtime-callout__title">AI Runtime Security</p>
<p class="runtime-callout__desc">Testing proved the controls work before launch. Runtime security proves they keep working: guardrails to prevent, Model-as-Judge to detect, humans to decide. Carry the tier, the configuration, and the test suite across the boundary.</p>

[Continue to AI Runtime Security](https://airuntimesecurity.io/){ .md-button }
</div>

!!! info "References"
    - [Adversarial Testing](adversarial-testing.md)
    - [Production Readiness](production-readiness.md)
    - [OWASP LLM Top 10](https://owasp.org/www-project-top-10-for-large-language-model-applications/)
    - [MITRE ATLAS: Adversarial Threat Landscape for AI Systems](https://atlas.mitre.org/)
    - [NIST AI 100-2: Adversarial Machine Learning](https://csrc.nist.gov/pubs/ai/100/2/e2023/final)
    - [NIST AI Risk Management Framework](https://www.nist.gov/itl/ai-risk-management-framework)
    - [AI Runtime Security](https://airuntimesecurity.io/)
