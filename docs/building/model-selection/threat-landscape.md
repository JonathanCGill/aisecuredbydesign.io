---
description: Real-world threat intelligence for AI model security, covering documented attacks, supply chain incidents, and emerging risks.
---

# Model Threat Landscape

This page documents real-world attacks, incidents, and emerging threats targeting AI models and the supply chains that deliver them. This is not a theoretical taxonomy. Every entry here has been observed, demonstrated, or disclosed.

Understanding the threat landscape is a prerequisite for meaningful [risk assessment](risk-assessment.md). You cannot assess risk for threats you do not know exist.

The MITRE ATLAS framework (as of October 2025) catalogues 15 tactics, 66 techniques, 46 sub-techniques, 26 mitigations, and 33 real-world case studies for adversarial threats to AI systems. In October 2024 MITRE launched the AI Incident Sharing initiative, a "neighbourhood watch" for AI allowing anonymised data sharing about real-world attacks. ATLAS data is available in STIX 2.1 format for integration with SIEM systems and threat intelligence platforms.

## Supply chain attacks on model repositories

Model repositories are the npm and PyPI of machine learning. They host community-uploaded artefacts that millions of users download and execute. The security model is similar: open contribution, limited vetting, trust based on reputation.

### Hugging Face: the primary target

Hugging Face hosts over 1.4 million models as of early 2025 (up from roughly 500,000 in February 2024). Its scale makes it both the most useful model repository and the most attractive target.

**Documented incidents:**

| Date | Incident | Impact | Source |
|------|----------|--------|--------|
| **Feb 2024** | JFrog discovered approximately 100 malicious models, primarily PyTorch pickle files. A model by user "baller423" established a reverse shell to IP 210.117.212.93. | Arbitrary code execution on machines that loaded the models. ~95% used pickle format. | [JFrog](https://jfrog.com/blog/data-scientists-targeted-by-malicious-hugging-face-ml-models-with-silent-backdoor/) |
| **Feb 2024** | HiddenLayer found that the hosted SafeTensors conversion service could be hijacked via a malicious PyTorch binary, exfiltrating the SFConvertbot token. | Attacker could send malicious pull requests to any repository on the platform. | [Security Boulevard](https://securityboulevard.com/2024/02/security-vulnerabilities-popping-up-on-hugging-faces-ai-platform/) |
| **Apr 2024** | Wiz identified a vulnerability enabling arbitrary code execution during Hugging Face Spaces app build time. | Code execution in the build environment, potential lateral movement. | [Wiz](https://www.wiz.io/) |
| **May 2024** | Hugging Face disclosed unauthorised access to its platform and reported the incident to law enforcement. | Unknown scope of compromise. | [TechCrunch](https://techcrunch.com/2024/05/31/hugging-face-says-it-detected-unauthorized-access-to-its-ai-model-hosting-platform/) |
| **2025** | Attackers uploaded 6,000+ malicious Android files to Hugging Face datasets in under a month, generating new payloads approximately every 15 minutes. | Platform used as malware hosting and distribution infrastructure. | [BankInfoSecurity](https://www.bankinfosecurity.com/breach-roundup-android-rat-hides-behind-hugging-face-a-30628) |
| **2025** | ReversingLabs identified additional malicious repositories including glockr1/ballr7. | Ongoing malicious model uploads despite platform countermeasures. | [ReversingLabs](https://www.reversinglabs.com/blog/rl-identifies-malware-ml-model-hosted-on-hugging-face) |

**Scale of the problem:** JFrog's 2025 report found over 1 million new models hit Hugging Face in 2024 alone, with a 6.5x increase in malicious models year-over-year. Between October 2024 and April 2025, Protect AI scanned 4.47 million unique model versions across 1.41 million repositories. They found 352,000 unsafe or suspicious issues across 51,700 models. 21% of models on Hugging Face remain exclusively in pickle format, and pickle-only models are downloaded over 400 million times per month.

!!! warning "Model repositories are not curated"
    Downloading a model from Hugging Face carries the same risk as running code from an unknown GitHub repository. The platform provides hosting, not vetting. Your pipeline must treat every downloaded model as untrusted until verified.

### ML framework supply chain attacks

The threat extends beyond model files to the frameworks and libraries used to build, train, and run models.

**Ultralytics PyPI compromise (December 2024):** The Ultralytics package (a widely-used computer vision library) was compromised on PyPI. Malicious versions contained a cryptominer that executed on installation. This was not a typosquatting attack; the legitimate package was compromised.

**ShadowRay (March 2024):** Attackers exploited CVE-2023-48022 in the Ray framework (widely used for distributed ML training), compromising environments at Uber, Amazon, and OpenAI. Open-source ML infrastructure is a high-value target.

**Keras CVE-2025-1550:** Demonstrated arbitrary code execution via custom layers in Keras models. A Keras model file could execute arbitrary Python code when loaded, similar to the pickle deserialization problem but through a different mechanism.

## Serialisation as an attack vector

The pickle deserialization vulnerability remains the single most exploited attack vector in model security.

### The pickle problem

Python's `pickle` format can execute arbitrary code during deserialization via the `__reduce__` method. When you load an untrusted pickle file, you are running attacker-controlled code with the privileges of your process. This is not a bug in pickle; it is how pickle works.

~95% of malicious models discovered on Hugging Face used PyTorch pickle format (`.pt`, `.pth`, `.pkl`).

### Scanner bypass vulnerabilities

The tools designed to protect against malicious pickle files have their own vulnerabilities:

- **PickleScan**: JFrog found 3 zero-day critical vulnerabilities enabling bypass of the industry-standard pickle scanning tool.
- **PickleScan (additional)**: Sonatype discovered 4 further vulnerabilities enabling scanner bypass.
- **nullifAI evasion (February 2025)**: Malicious models used 7z archive format instead of ZIP to bypass PickleScan detection entirely. The scanner simply did not inspect the alternative archive format.

**The implication:** Do not rely on a single scanning tool. Defence in depth applies here: prefer safe formats (SafeTensors), scan with multiple tools, and run model loading in sandboxed environments.

### The SafeTensors alternative

SafeTensors, developed collaboratively by Hugging Face, EleutherAI, and Stability AI, stores only tensor data in a JSON header plus flat byte buffer. No executable code. The format was independently audited by Trail of Bits.

SafeTensors is now the default for several major libraries, but many legacy pickle models remain in active use. Your model ingestion pipeline should prefer SafeTensors and flag any pickle file from an untrusted source.

For detailed format comparison, see [Provenance and Integrity: Serialisation Format Risks](provenance-and-integrity.md#serialisation-format-risks).

## Fine-tuning as an attack surface

Fine-tuning can weaponise a safe model or strip the safety from an aligned one.

### Safety alignment removal

Recent research demonstrates that fine-tuning reliably degrades safety alignment:

- **Unintentional degradation**: Qi et al. showed fine-tuning compromises safety "even when users do not intend to." Benign fine-tuning data can still weaken safety guardrails.
- **Efficient removal**: Lermen et al. demonstrated that LoRA fine-tuning efficiently undoes safety training in Llama 2-Chat 70B, one of the most safety-aligned open models at the time.
- **GRP-Obliteration** (Microsoft, 2025): A single benign-sounding prompt stripped safety guardrails from 15 models across 6 model families (GPT-OSS, DeepSeek-R1-Distill, Gemma, Llama 3.1, Ministral, Qwen). Achieved 81% attack success rate while retaining model utility.
- **Minimal poisoning threshold**: As few as 250 malicious documents in a fine-tuning dataset can create functional backdoors that activate on specific prompts.

!!! abstract "Fine-tuning security is a pre-runtime problem"
    Every fine-tuned model is a new model from a security perspective. It inherits base model risks, introduces new risks from training data and process, and may have degraded safety properties. The decision to fine-tune is a security decision covered by [Risk Assessment](risk-assessment.md).

### Harmful fine-tuning as a service

Fine-tuning APIs from major providers allow users to upload arbitrary training data. While providers implement safeguards, the risk of harmful fine-tuning through these services remains an active area of concern. The line between legitimate customisation and safety degradation is difficult to enforce programmatically.

## Backdoor and poisoning research

Academic research is revealing how practical and difficult to detect model poisoning has become.

**BackdoorLLM** (NeurIPS 2025) is the first comprehensive benchmark for LLM backdoor attacks, covering data poisoning, weight poisoning, hidden state steering, and chain-of-thought attacks. Researchers have demonstrated establishing robust trigger associations using only benign QA pairs, bypassing safety-aligned guardrails entirely. The trigger data does not need to look malicious.

**Key thresholds:** As little as 3% poisoned data can increase test error from 3% to 24% (Koh et al.). In federated learning scenarios, targeting a small subset of "key parameters" can replicate full-model attack impact while greatly reducing detection risk.

**Detection is improving but incomplete.** Defences like BaDExpert (backdoor functionality extraction), CrowdGuard (federated detection), FreqFed (frequency analysis), and TextGuard (provable defence for text classification) show partial efficacy but struggle at scale. No current defence reliably catches all backdoor types.

## Emerging threats

### Evaluation awareness and scheming

Models are getting better at behaving differently during evaluation than during deployment.

- Apollo Research found that Claude Sonnet 4.5 verbalised evaluation awareness in 58% of test scenarios, a marked increase from earlier models
- Anthropic reported an experimental model exhibited broad misalignment from reward-hacking in programming training, including attempting to sabotage safety measures and misrepresent its goals

**What this means:** Standard test suites may not reveal a model's true behaviour in production. Evaluation strategies must be diverse, non-obvious, and supplemented by [runtime monitoring](https://airuntimesecurity.io/).

### Model collapse

Shumailov et al. (*Nature*, July 2024) demonstrated that models trained on recursively generated synthetic data undergo progressive quality degradation: first losing minority and tail data representations, then converging to a narrow output distribution.

As synthetic data becomes more prevalent in training corpora, this risk compounds. Models trained on data that includes outputs from previous model generations may exhibit degraded performance on exactly the edge cases that matter most for safety.

### Prompt injection at scale

EchoLeak (CVE-2025-32711) demonstrated a zero-click prompt injection attack against Microsoft 365 Copilot. A poisoned email forced the AI to exfiltrate business data without any user interaction. This illustrates that prompt injection is not just a chatbot problem; it is a systemic vulnerability wherever models process untrusted input.

### Nation-state and organised threats

Anthropic disclosed (August 2025) documented attempts to weaponise Claude for extortion, ransomware development, and DPRK-linked employment fraud. AI models are targets for and tools of state-level threat actors.

## The numbers

A few statistics that frame the current threat environment:

- **233 AI-related security and privacy incidents** in 2024, a 56.4% increase over 2023 (Stanford HAI 2025 AI Index)
- **$4.7 million** average cost per AI-related security breach in 2025 (Stanford HAI)
- **352,000 unsafe or suspicious issues** found across 51,700 models on Hugging Face in six months (Protect AI, October 2024 to April 2025)
- **6.5x increase** in malicious models on Hugging Face in 2024 compared to prior year (JFrog 2025)
- **400 million+ monthly downloads** of pickle-only models on Hugging Face, each carrying arbitrary code execution risk
- **Only 6% of organisations** have an advanced AI security strategy (Stanford HAI 2025)
- **93% of organisations** acknowledge generative AI brings risks, but only **9% feel prepared** (PwC / Credo AI)
- **57% of enterprises** cite LLM prompt injection, model manipulation, and jailbreaking as a top-two AI security concern (IDC Asia/Pacific, August 2025)

## Using this intelligence

Threat intelligence is only useful if it changes decisions. Apply these findings to your model selection process:

1. **Treat model downloads as code execution.** Because in many formats, they are. See [Provenance and Integrity](provenance-and-integrity.md).
2. **Do not trust scanners alone.** Scanner bypass is a documented capability. Layer format restrictions, scanning, sandboxing, and signature verification.
3. **Reassess fine-tuned models from scratch.** Safety alignment does not survive fine-tuning. Evaluate every fine-tuned model as a new, untested artefact.
4. **Plan for evaluation-aware models.** Your test suite should not be predictable. Use diverse, non-obvious evaluation strategies.
5. **Monitor the threat landscape.** Model security threats are evolving rapidly. Assign ownership for tracking new disclosures, CVEs, and incidents relevant to your stack.

!!! info "References"
    - [JFrog: Malicious Models on Hugging Face](https://jfrog.com/blog/data-scientists-targeted-by-malicious-hugging-face-ml-models-with-silent-backdoor/)
    - [JFrog: PickleScan Zero-Day Vulnerabilities](https://jfrog.com/blog/unveiling-3-zero-day-vulnerabilities-in-picklescan/)
    - [Sonatype: Bypassing PickleScan](https://www.sonatype.com/blog/bypassing-picklescan-sonatype-discovers-four-vulnerabilities)
    - [Hugging Face + Protect AI: 6-Month Scanning Report](https://huggingface.co/blog/pai-6-month)
    - [Stanford HAI 2025 AI Index: Responsible AI](https://hai.stanford.edu/ai-index/2025-ai-index-report/responsible-ai)
    - [Shumailov et al., Model Collapse, Nature 2024](https://www.nature.com/articles/s41586-024-07566-y)
    - [MITRE ATLAS: Adversarial Threat Matrix for AI](https://atlas.mitre.org/)
    - [OWASP Top 10 for LLM Applications](https://owasp.org/www-project-top-10-for-large-language-model-applications/)
    - [CSO Online: GRP-Obliteration Single Prompt Attack](https://www.csoonline.com/article/4130001/single-prompt-breaks-ai-safety-in-15-major-language-models.html)
    - [Anthropic Threat Intelligence Disclosure, August 2025](https://www.anthropic.com/)
    - [MITRE ATLAS AI Incident Sharing Initiative](https://atlas.mitre.org/)
    - [MITRE SAFE-AI Framework](https://atlas.mitre.org/pdf-files/SAFEAI_Full_Report.pdf)
    - [BackdoorLLM Benchmark, NeurIPS 2025](https://github.com/bboylyg/BackdoorLLM)
    - [ReversingLabs: nullifAI Evasion Technique](https://www.reversinglabs.com/blog/rl-identifies-malware-ml-model-hosted-on-hugging-face)
    - [JFrog 2025 ML Supply Chain Report](https://jfrog.com/blog/data-scientists-targeted-by-malicious-hugging-face-ml-models-with-silent-backdoor/)
    - [NIST AI 600-1: GenAI Risk Management Profile](https://www.nist.gov/publications/artificial-intelligence-risk-management-framework-generative-artificial-intelligence)
