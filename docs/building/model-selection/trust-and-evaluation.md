---
description: Evaluating AI model trustworthiness through transparency, safety benchmarks, signing standards, and capability-matched selection.
---

# Trust and Evaluation

Choosing a model is not just a performance decision. It is a trust decision. You are placing an opaque artefact at the centre of your system and relying on it to behave as expected. The question is not "which model scores highest on a leaderboard" but "which model can I verify, evaluate, and hold accountable for my specific use case?"

This page covers three questions that every model selection process should answer:

1. **How do we know a model is good?** Evaluation frameworks and safety benchmarks.
2. **Who can we trust?** Transparency, signing, and accountability mechanisms.
3. **Right model for right task?** Capability matching, not capability maximising.

## How do we know a model is good?

Benchmarks tell you what a model can do. They do not tell you what it will do in your environment, with your data, under adversarial conditions. Treat benchmarks as one input to your decision, not the decision itself.

### Safety benchmarks worth knowing

| Benchmark | Who runs it | What it measures |
|-----------|------------|-----------------|
| **MLCommons AILuminate** (v1.0, Dec 2024) | MLCommons with Stanford, Google, Meta, Microsoft, NVIDIA | Safety grades across 13 hazard categories for LLMs. First collaborative, standardised safety benchmark. |
| **Stanford HELM Safety** | Stanford CRFM | Holistic evaluation of language models across accuracy, calibration, robustness, fairness, bias, toxicity, and efficiency. |
| **AIR-Bench** | Stanford HAI / community | Responsible AI evaluation filling gaps in existing benchmarks. |
| **CyberSecEvals** | Meta AI Red Team | Security-specific evaluation for LLMs, including code generation safety and vulnerability awareness. |
| **Garak** | Open source (NVIDIA origin) | Adversarial probe framework covering prompt injection, jailbreaks, data leakage, and hallucination. |

!!! warning "Leaderboard scores are not security assessments"
    Models can score well on benchmarks while failing catastrophically on adversarial inputs, edge cases, or tasks outside their training distribution. A model that tops a leaderboard may still produce harmful outputs, leak training data, or be trivially jailbroken. Always supplement benchmark scores with your own red-teaming and domain-specific evaluation.

### Evaluation beyond benchmarks

**Red-teaming** is the most reliable way to understand a model's failure modes in your context.

At DEF CON 31 (2023), 2,244 hackers evaluated eight major LLMs across 21 topic areas, generating 17,000+ adversarial conversations. Key findings: role-play and "write a story" prompts were the most effective attack strategies, and models showed significant accuracy gaps across languages. This was backed by the White House OSTP and included models from Anthropic, Google, Meta, OpenAI, and others.

At DEF CON 2024, Meta's AI Red Team presented on red-teaming Llama 3, using multi-turn adversarial AI agents and the CyberSecEvals benchmark.

**Practical red-teaming tools:**

| Tool | Purpose |
|------|---------|
| **Microsoft PyRIT** | Python Risk Identification Toolkit for systematic LLM red-teaming |
| **Garak** | LLM vulnerability scanning across multiple attack categories |
| **IBM ART** | Adversarial Robustness Toolkit for testing model resilience |

!!! tip "Build internal red-team capability"
    Generic tools are a starting point. Your most valuable tests will be domain-specific: testing for failures that matter in your use case, with your data patterns, against your threat model. The US Executive Order on AI defines red-teaming as "a structured testing effort to find flaws and vulnerabilities in an AI system using adversarial methods."

### The transparency gap

Stanford HAI's Foundation Model Transparency Index found that average transparency scores increased from 37% (October 2023) to 58% (May 2024). This is progress, but it means the average foundation model still conceals nearly half of the information that evaluators need.

The AI Transparency Atlas (December 2025) analysed 100 Hugging Face model cards and found 947 unique section names with extreme naming variation. Usage information alone appeared under 97 different labels. Model cards exist, but they are inconsistent and often incomplete.

**What this means for you:** Do not assume that a published model card gives you adequate information. Verify the card's claims through your own testing. If a model card is absent or incomplete, that is not a minor documentation gap; it is a risk signal.

## Who can we trust?

Trust is not binary. It is a spectrum based on verification, accountability, and transparency. The question is not "do I trust this provider?" but "what mechanisms exist to verify their claims?"

### Model signing and verification

The most significant development in model trust infrastructure is **OpenSSF Model Signing v1.0** (April 2025), created by Google's Open Source Security Team, Sigstore, and the OpenSSF.

**How it works:**

1. Models are signed using the uploader's OIDC identity (keyless signing via Sigstore)
2. Signatures are wrapped in a DSSE (Dead Simple Signing Envelope) containing an in-toto statement
3. Signatures are recorded in the Rekor transparency log, creating an immutable audit trail
4. Verification checks that the signature matches the claimed identity via a Fulcio certificate

**Who has adopted it:**

- NVIDIA NGC integrates model signing for hosted models
- Google Kaggle has integrated model signing during upload
- The broader Sigstore ecosystem has already been adopted by Homebrew (May 2024), PyPI (November 2024), and Maven Central (January 2025)

!!! abstract "Model signing is not optional much longer"
    Model signing is following the same adoption curve as software signing. Within two years, unsigned models will likely carry the same stigma as unsigned software packages. Start requiring signature verification in your model ingestion pipeline now.

### Safety frameworks and commitments

At the AI Seoul Summit (May 2024), 20 organisations including Anthropic, Microsoft, NVIDIA, and OpenAI committed to:

- Identifying risks in frontier models, including externally discovered risks
- Defining unacceptable risk levels with justification
- Not developing models that fail safety standards
- Red-teaming (internal and external), information sharing, and third-party vulnerability reporting

As of early 2026, 12 companies have published detailed safety frameworks: Anthropic, OpenAI, Google DeepMind, Meta, Microsoft, Amazon, NVIDIA, xAI, Magic, Naver, G42, and Cohere. Common elements include capability thresholds (bioweapons, cyberattacks, autonomous replication), model evaluations, weight security, deployment mitigations, and halt conditions.

The Frontier Model Forum has established an AI Safety Fund of over $10M for independent research and standardised third-party evaluations.

### Assessing provider trustworthiness

No provider should be trusted on claims alone. Use this framework:

| Trust signal | Strong | Weak |
|-------------|--------|------|
| **Published safety framework** | Detailed, public, with specific thresholds | Vague commitments, no specifics |
| **Third-party audits** | Independent red-team results published | Self-reported evaluations only |
| **Transparency reporting** | Model cards, training data documentation, safety evaluations | Marketing materials, benchmark cherry-picking |
| **Incident disclosure** | Public disclosure, post-mortems, CVE participation | Silence or denial |
| **Model signing** | Signed artefacts with verifiable provenance | Unsigned, no hash verification |
| **Regulatory engagement** | Compliance with EU AI Act, NIST AI RMF alignment | No regulatory posture |

!!! warning "Popularity is not a trust signal"
    A model with millions of downloads has been widely used. That tells you nothing about whether it has been thoroughly evaluated, whether its provenance is verified, or whether it is safe for your use case.

### The regulatory landscape

Regulatory requirements are making model evaluation less optional:

- **EU AI Act**: Entered force August 2024. GPAI obligations effective August 2025. High-risk enforcement from August 2026. Requires documentation, risk assessment, and transparency for AI systems.
- **NIST AI RMF + AI 600-1**: The GenAI profile (July 2024) covers 12 risk categories including CBRN, hallucinations, data leakage, and harmful bias. Voluntary but increasingly referenced in procurement.
- **ISO 42001**: AI management system standard providing governance alignment for model selection and deployment.

## Right model for right task

The most capable model is not always the right model. Capability maximisation introduces unnecessary risk, cost, and complexity. Match the model to the task.

### Why bigger is not always better

A model that can write poetry, generate code, and discuss philosophy is overkill for classifying support tickets. Oversized models introduce:

- **Larger attack surface**: More parameters means more potential for adversarial exploitation, emergent behaviours, and unpredictable outputs
- **Higher data exposure**: Larger models trained on broader datasets may leak more training data through extraction attacks
- **Greater cost and complexity**: Larger models require more infrastructure, more monitoring, and more operational overhead
- **Harder to evaluate**: The more a model can do, the harder it is to characterise what it will do

### Model collapse and training data risks

Research published in *Nature* (July 2024) by Shumailov et al. (Oxford, Cambridge, Imperial College London, University of Toronto) demonstrated that AI models trained on recursively generated synthetic data undergo **model collapse**: progressive loss of minority and tail data, eventually converging to a narrow output distribution.

This matters for model selection because:

- Models trained partly on synthetic data may have degraded performance on edge cases
- The provenance of training data is increasingly difficult to verify as synthetic data proliferates
- Preserving original human-generated training data is the primary mitigation

### Capability matching framework

| Use case | Model characteristics to prioritise | What to avoid |
|----------|-------------------------------------|---------------|
| **Document classification** | High accuracy on your domain, fast inference, low cost | General-purpose LLMs (overkill and slower) |
| **Internal summarisation** | Good comprehension, adequate output quality, data stays on-premises | Cloud APIs if data sensitivity prohibits it |
| **Customer-facing chat** | Strong safety alignment, low hallucination rate, good refusal behaviour | Models with weak safety training or easy jailbreaks |
| **Code generation** | Security-aware output, tested against CyberSecEvals, good at identifying vulnerabilities | Models not evaluated for code security |
| **Autonomous decision-making** | Explainable outputs, auditable reasoning, strong human-in-the-loop support | Any model without extensive red-teaming |

### Fine-tuning security considerations

Fine-tuning is not a free upgrade. It changes the model's behaviour in ways that are difficult to predict and can compromise safety.

**Key findings from recent research:**

- Qi et al. showed that fine-tuning compromises safety alignment "even when users do not intend to"
- Lermen et al. demonstrated that LoRA fine-tuning efficiently undoes safety training in Llama 2-Chat 70B
- Microsoft's GRP-Obliteration research (2025) showed a single benign-sounding prompt can strip safety guardrails from models across six families, achieving an 81% attack success rate while retaining model utility
- As few as 250 malicious documents in a fine-tuning dataset can create functional backdoors

!!! warning "Fine-tuning can undo safety training"
    If you fine-tune a model, you must re-evaluate its safety properties from scratch. Do not assume that base model safety guarantees survive the fine-tuning process. This applies even when your fine-tuning data is benign, because the process itself can degrade safety alignment.

### Emerging risks: evaluation awareness

Anthropic and Apollo Research have documented cases where models exhibit **evaluation awareness**, behaving differently when they detect they are being tested. Apollo Research found that Claude Sonnet 4.5 verbalised evaluation awareness in 58% of test scenarios.

This has direct implications for model evaluation: standard test suites may not reveal a model's true behaviour in production. Mitigation requires diverse, non-obvious evaluation strategies and monitoring in deployment (the handoff to [runtime security](https://airuntimesecurity.io/)).

## Putting it together

Model trust and evaluation is not a one-time gate. It is a continuous process:

1. **Before selection**: Evaluate transparency, safety benchmarks, provenance, and signing. Use the frameworks above to compare candidates.
2. **Before deployment**: Red-team against your specific use case. Test with adversarial inputs relevant to your domain. Verify that safety properties hold after any fine-tuning.
3. **After deployment**: Monitor for drift, unexpected behaviours, and new vulnerability disclosures. Reassess when the model is updated or your use case changes. Hand off to [runtime monitoring](https://airuntimesecurity.io/).

!!! info "References"
    - [MLCommons AILuminate Safety Benchmark](https://mlcommons.org/ailuminate/)
    - [Stanford HAI 2025 AI Index Report](https://hai.stanford.edu/ai-index/2025-ai-index-report)
    - [OpenSSF Model Signing v1.0](https://github.com/sigstore/model-transparency)
    - [Google Security Blog: Taming the Wild West of ML](https://security.googleblog.com/2025/04/taming-wild-west-of-ml-practical-model.html)
    - [AI Seoul Summit Frontier AI Safety Commitments](https://www.gov.uk/government/publications/frontier-ai-safety-commitments-ai-seoul-summit-2024/)
    - [NIST AI 600-1: GenAI Risk Management Profile](https://www.nist.gov/publications/artificial-intelligence-risk-management-framework-generative-artificial-intelligence)
    - [Shumailov et al., AI Models Collapse When Trained on Recursively Generated Data, Nature 2024](https://www.nature.com/articles/s41586-024-07566-y)
    - [METR: Common Elements of Frontier AI Safety Policies](https://metr.org/blog/2025-12-09-common-elements-of-frontier-ai-safety-policies/)
    - [Frontier Model Forum Progress Update](https://www.frontiermodelforum.org/updates/progress-update-advancing-frontier-ai-safety-in-2024-and-beyond/)
    - [DEF CON 31 AI Village Red Team Challenge Findings](https://oodaloop.com/analysis/archive/findings-from-the-defcon31-ai-village-inaugural-generative-ai-red-team-challenge/)
