---
description: MLOps threat intelligence using MITRE ATLAS, real-world attack patterns, and structured threat mapping across the ML pipeline lifecycle.
---

# MLOps Threat Intelligence

Securing ML pipelines starts with understanding who attacks them, how, and why. Traditional threat intelligence focuses on network intrusions and malware. MLOps threat intelligence extends that to attacks on data, models, training infrastructure, and the pipeline itself. These attacks exploit the unique properties of ML systems: their dependence on external data, their use of serialised model files that can execute code, and the trust organisations place in pre-trained artefacts they did not build.

## The MLOps attack surface

ML pipelines are long. A typical pipeline spans data collection, preparation, model training, evaluation, optimisation, deployment, and monitoring. Vulnerabilities can appear at any point. The challenge is that a compromise at an early stage, such as data collection, may not surface until production, when a poisoned model starts making harmful decisions.

| Pipeline stage | Primary threats | Why it matters |
|---------------|----------------|----------------|
| **Data collection** | Data poisoning, source compromise, crawl manipulation | Corrupted inputs produce corrupted models |
| **Data preparation** | Label manipulation, feature injection, schema attacks | Subtle changes survive validation checks |
| **Model training** | Compute hijacking, dependency attacks, backdoor insertion | The model itself becomes the weapon |
| **Evaluation** | Metric gaming, test set leakage, biased benchmarking | Unsafe models appear to pass validation |
| **Model storage** | Model substitution, serialisation exploits, registry tampering | Deployed artefact is not the approved artefact |
| **Deployment** | Configuration manipulation, serving infrastructure attacks | Correct model, wrong behaviour |
| **Monitoring** | Alert suppression, drift masking, log tampering | Attacks go undetected |

## MITRE ATLAS

MITRE ATLAS (Adversarial Threat Landscape for AI Systems) is the adversarial ML knowledge base, modelled after ATT&CK but focused on machine learning. As of late 2025, it catalogues 15 tactics, 66 techniques, and 46 sub-techniques targeting AI and ML systems, along with 26 mitigations and 33 documented real-world case studies.

### How ATLAS maps to MLOps

Five ATLAS tactics appear most frequently across the MLOps lifecycle:

| ATLAS tactic | MLOps relevance |
|-------------|-----------------|
| **Reconnaissance** | Attacker surveys public model cards, open experiment logs, job postings mentioning frameworks |
| **Resource Development** | Attacker builds poisoned datasets, creates backdoored models, prepares adversarial inputs |
| **Discovery** | Attacker probes exposed MLOps platforms, enumerates API endpoints, identifies data sources |
| **Collection** | Attacker extracts training data, model weights, or experiment metadata |
| **Impact** | Attacker degrades model performance, manipulates outputs, or causes denial of service |

### Key ATLAS techniques for MLOps teams

| Technique | ATLAS ID | What it looks like |
|-----------|----------|-------------------|
| **Data poisoning** | AML.T0020 | Malicious samples inserted into training data to create predictable misclassifications |
| **Model poisoning** | AML.T0018 | Backdoors embedded in pre-trained models distributed through public repositories |
| **Prompt injection** | AML.T0051 | Crafted inputs that override system instructions in LLM-based pipelines |
| **Supply chain compromise** | AML.T0010 | Malicious code in ML frameworks, libraries, or pre-trained model files |
| **Exfiltration via ML API** | AML.T0024 | Model extraction through repeated queries to prediction endpoints |
| **Evasion** | AML.T0015 | Inputs crafted to bypass model detection (adversarial examples) |

!!! tip "Use ATLAS Navigator for threat modelling"
    The ATLAS Navigator tool lets teams map their specific ML architecture against known attack techniques. Use it during threat modelling sessions to identify which techniques apply to your pipeline and which mitigations you have (or lack). Available at [atlas.mitre.org](https://atlas.mitre.org/).

## Real-world MLOps attacks

These are not theoretical. Documented incidents show how MLOps vulnerabilities are exploited in practice.

### ShadowRay (2024)

Attackers exploited CVE-2023-48022 (CVSS 9.8) in Anyscale Ray, a distributed ML framework. Unpatched Ray instances exposed job submission APIs without authentication, allowing attackers to execute arbitrary code on ML training infrastructure. Financially motivated adversaries used this to deploy cryptocurrency miners on GPU clusters, but the same access could have been used to tamper with training jobs or exfiltrate model weights.

**Lesson:** ML infrastructure is infrastructure. It needs patching, authentication, and network segmentation just like any other system.

### Large-scale Wikipedia poisoning (2024)

Researchers demonstrated that attackers could time the insertion of poisoned content into Wikipedia articles to coincide with dataset acquisition windows. Since many training datasets scrape Wikipedia on known schedules, attackers could manipulate training data for specific models by editing articles just before the crawl.

**Lesson:** Data provenance matters. Knowing where your training data came from is not enough. You need to know when it was collected and whether the source was trustworthy at that moment.

### Pickle deserialization attacks

Python's `pickle` format, commonly used to serialise ML models, executes arbitrary code on deserialization. Multiple incidents have involved malicious pickle files uploaded to model repositories. When a user or pipeline loads the model, the embedded code executes. This is not a bug in pickle. It is the intended behaviour of the format.

**Lesson:** Never load untrusted pickle files. Prefer safer serialisation formats like **safetensors** for model weights. Scan model files before loading them.

### Backdoored models on public hubs

Researchers have repeatedly demonstrated that backdoored models can be uploaded to public model hubs (such as Hugging Face) and downloaded by unsuspecting users. The backdoor activates only when specific trigger patterns appear in the input, making it invisible during standard evaluation.

**Lesson:** Public model hubs are a supply chain. Treat models downloaded from them with the same caution you would apply to any third-party dependency.

## Threat categories unique to MLOps

Some threats are familiar from traditional security (credential theft, infrastructure attacks). Others are unique to ML systems.

### Data poisoning

The attacker manipulates training data so the model learns attacker-chosen behaviour. This can be targeted (the model misclassifies specific inputs) or untargeted (the model's overall accuracy degrades). Poisoning can happen at the source (compromising a data provider), during collection (manipulating a web crawl), or during labelling (corrupting annotation workflows).

### Model poisoning

The attacker embeds a backdoor in a model's weights. The model performs normally on standard inputs but produces attacker-controlled outputs when it encounters a specific trigger. This is particularly dangerous with pre-trained models and fine-tuning, because the backdoor can survive the fine-tuning process.

### Cross-tool access exploitation

MLOps environments typically span multiple tools: data versioning, experiment tracking, model registries, orchestrators, serving platforms. Access controls are often inconsistent across these tools. An attacker might have limited permissions in one system but elevated access in another, allowing them to manipulate model deployments indirectly.

### Serialisation attacks

ML models are stored as files. Many serialisation formats (pickle, joblib, certain ONNX configurations) allow arbitrary code execution on load. An attacker who can replace a model file in storage can achieve code execution on any system that loads that model, including production serving infrastructure.

## Building an MLOps threat intelligence practice

### Start with what you have

- Map your ML pipeline stages against the threat table above
- Identify which ATLAS techniques apply to your specific architecture
- Review your existing security monitoring for MLOps-relevant signals (unusual data access, model registry changes, training job anomalies)

### Subscribe to relevant feeds

- [MITRE ATLAS case studies](https://atlas.mitre.org/) for documented ML attacks
- [OWASP ML Security Top 10](https://owasp.org/www-project-machine-learning-security-top-10/) for prioritised risk categories
- [OWASP Top 10 for LLM Applications](https://genai.owasp.org/) if your pipeline includes LLM components
- Vendor security advisories for your ML frameworks (PyTorch, TensorFlow, Ray, MLflow)

### Integrate with existing threat modelling

Do not create a separate MLOps threat model in isolation. Extend your existing threat modelling process to cover ML-specific attack surfaces. The [pipeline threat model](secure-ml-pipelines.md) is a starting point. ATLAS Navigator provides structured guidance for mapping threats to your architecture.

### Red team your pipeline

Standard penetration testing does not cover ML-specific attacks. Extend your red team exercises to include:

- Attempting to poison training data through approved data channels
- Uploading a modified model file to the registry
- Exploiting serialisation vulnerabilities in model loading
- Probing experiment tracking systems for exposed metadata
- Testing access control boundaries across MLOps tools

!!! info "References"
    - [MITRE ATLAS](https://atlas.mitre.org/)
    - [OWASP Machine Learning Security Top 10](https://owasp.org/www-project-machine-learning-security-top-10/)
    - [OWASP Top 10 for LLM Applications](https://genai.owasp.org/)
    - [OpenSSF MLSecOps Whitepaper](https://openssf.org/blog/2025/08/05/visualizing-secure-mlops-mlsecops-a-practical-guide-for-building-robust-ai-ml-pipeline-security/)
    - [CSA: Hidden Security Threats in ML Pipelines](https://cloudsecurityalliance.org/blog/2025/09/11/the-hidden-security-threats-lurking-in-your-machine-learning-pipeline)
    - [Patel et al.: Towards Secure MLOps](https://arxiv.org/html/2506.02032v1)
    - [HiddenLayer: Supply Chain Threats in ML Ops](https://hiddenlayer.com/research/insane-in-the-supply-chain/)
