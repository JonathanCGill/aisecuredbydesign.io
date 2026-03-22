---
description: Mapping AI risk classification to regulatory obligations. EU AI Act risk categories, privacy laws, cyber security requirements, and industry-specific rules that shape your security baseline.
---

# Regulatory Alignment

Risk appetite is yours to define, but the law sets the floor. Before you finalise a [risk classification](risk-classification.md) for your AI system, you need to understand which regulations apply and what they require. Different jurisdictions impose different obligations, and the same AI system may face different requirements depending on where it operates, who it serves, and what data it processes.

This page does not replace legal advice. It provides a structured way to identify which regulatory domains are relevant and how they interact with your risk tier.

## The regulatory stack

AI systems do not exist in a regulatory vacuum. They sit at the intersection of multiple legal domains, each with its own requirements.

| Regulatory domain | What it covers | Examples |
|-------------------|---------------|----------|
| **AI-specific regulation** | Rules targeting AI systems directly: risk classification, transparency, conformity assessment | EU AI Act, Canada AIDA, China AI regulations |
| **Data protection and privacy** | Rules governing personal data processing, consent, transfer, and rights | GDPR, UK Data Protection Act, POPIA, CCPA/CPRA, LGPD |
| **Cyber security** | Requirements for system security, incident reporting, and resilience | NIS2 Directive, DORA, CIRCIA, national cyber security laws |
| **Sector-specific regulation** | Industry rules that apply to AI used in regulated activities | Financial services (SR 11-7, MiFID II), healthcare (HIPAA, MDR), employment law |
| **Consumer protection** | Rules on fairness, transparency, and non-discrimination in automated decisions | ECOA, national consumer protection acts |
| **Intellectual property** | Rules affecting training data, model outputs, and copyright | Copyright law, trade secret protection, patent considerations |

!!! warning "Compliance is cumulative"
    These categories are not alternatives. A financial services AI system processing customer data in the EU may need to comply with the EU AI Act, GDPR, NIS2, DORA, MiFID II, and relevant national laws simultaneously. Your risk tier must account for the strictest applicable requirement across all domains.

## EU AI Act: a worked example

The EU AI Act is the most comprehensive AI-specific regulation currently in force. It provides a useful reference framework even if you do not operate in the EU, because its risk-based approach aligns naturally with the [risk classification](risk-classification.md) used across this site and [AI Runtime Security](https://airuntimesecurity.io/).

### EU AI Act risk categories

The Act classifies AI systems into four categories based on their potential for harm.

| EU AI Act category | Description | Obligations |
|-------------------|-------------|-------------|
| **Unacceptable risk** | AI practices that are prohibited entirely | Banned. No deployment permitted. |
| **High risk** | AI systems listed in Annex III or used as safety components of regulated products | Conformity assessment, risk management system, data governance, technical documentation, human oversight, accuracy/robustness/cybersecurity requirements |
| **Limited risk** | AI systems with specific transparency obligations | Transparency requirements (users must be informed they are interacting with AI) |
| **Minimal risk** | All other AI systems | No specific obligations under the Act (though other laws may still apply) |

### Mapping EU AI Act categories to risk tiers

The EU AI Act categories and the [risk tiers](risk-classification.md) used on this site serve different purposes but overlap significantly.

| EU AI Act category | Typical risk tier mapping | Notes |
|-------------------|--------------------------|-------|
| **Unacceptable risk** | Not applicable | These systems must not be built or deployed. Pre-runtime security here means identifying prohibited use cases early and stopping development. |
| **High risk** | **HIGH** or **CRITICAL** | The Act's requirements for high-risk systems (Articles 9-15) align closely with HIGH and CRITICAL tier controls. Conformity assessment, data governance, logging, human oversight. |
| **Limited risk** | **MEDIUM** or **HIGH** | Transparency obligations are relatively light, but these systems often process data or influence decisions in ways that push the risk tier higher than the Act's category alone would suggest. |
| **Minimal risk** | **LOW** or **MEDIUM** | No obligations under the Act, but other regulations (GDPR, sector rules) may still require controls that push the tier up. |

!!! abstract "The Act sets the floor, not the ceiling"
    The EU AI Act may classify your system as "minimal risk," but if it processes personal data (GDPR applies), operates in financial services (DORA applies), or handles health data (MDR may apply), your actual compliance burden is much higher than the Act alone suggests. Always assess the full regulatory stack.

### EU AI Act obligations for high-risk systems

For systems classified as high-risk under the Act, these are the key obligations and how they map to pre-runtime security activities.

| EU AI Act obligation | Article | Pre-runtime activity |
|---------------------|---------|---------------------|
| **Risk management system** | Art. 9 | [Risk classification](risk-classification.md) and ongoing risk assessment throughout development |
| **Data governance** | Art. 10 | [Data governance](../building/mlops/data-governance.md): training data quality, relevance, representativeness, bias testing |
| **Technical documentation** | Art. 11 | Model cards, architecture documentation, test results, decision logs |
| **Record-keeping** | Art. 12 | [Logging requirements](risk-classification.md#logging) scaled to tier, immutable logs for CRITICAL |
| **Transparency** | Art. 13 | Documentation enabling users to understand AI system capabilities and limitations |
| **Human oversight** | Art. 14 | [Human oversight controls](risk-classification.md#human-oversight) defined before deployment, not retrofitted |
| **Accuracy, robustness, cybersecurity** | Art. 15 | [Adversarial testing](adversarial-testing.md), [vulnerability scanning](../building/model-selection/vulnerability-scanning.md), [resilience planning](../building/devops/resilience.md) |

### General-Purpose AI (GPAI) obligations

The EU AI Act also imposes obligations on providers of general-purpose AI models (foundation models), regardless of how they are used downstream. If you are building on top of a GPAI model, your provider carries certain obligations, but you carry others as the deployer.

**Provider obligations** (the model maker):

- Technical documentation of training and evaluation
- Copyright policy compliance
- Transparency about training data
- Additional obligations for models with systemic risk (compute thresholds)

**Deployer obligations** (you, if you build on top of a GPAI model):

- Ensure your specific use case complies with the Act
- Conduct your own risk assessment for your deployment context
- Implement appropriate human oversight for your use case
- Maintain logs and documentation for your system

!!! tip "Provider compliance does not equal deployer compliance"
    Even if your model provider fully complies with GPAI obligations, you still need to assess and manage the risks of your specific deployment. A fully compliant foundation model can be deployed in a non-compliant way.

## Privacy regulations and AI

Every AI system that processes personal data must comply with applicable privacy laws. The interaction between privacy regulation and AI risk classification is direct.

### Key privacy considerations for AI

| Consideration | Impact on risk tier | Relevant regulations |
|--------------|-------------------|---------------------|
| **Training on personal data** | Pushes tier to HIGH minimum | GDPR Art. 6/9, POPIA, CCPA |
| **Processing PII at inference** | Pushes tier to HIGH minimum | All privacy regulations |
| **Automated decision-making** | May push to CRITICAL | GDPR Art. 22, national equivalents |
| **Cross-border data transfer** | Adds compliance complexity | GDPR Chapter V, POPIA S72, national data localisation laws |
| **Data subject rights** | Requires technical capability to respond | GDPR Arts. 15-22, equivalents in other jurisdictions |
| **Data minimisation** | Constrains what data the system can access | Core principle across all major privacy laws |

### GDPR and automated decision-making

GDPR Article 22 gives individuals the right not to be subject to decisions based solely on automated processing that produce legal or similarly significant effects. This is directly relevant to AI risk classification.

If your AI system makes decisions that are:

- **Solely automated** (no meaningful human involvement), and
- **Produce legal effects** (affect contractual rights, access to services, employment), or
- **Similarly significantly affect** the individual

Then you must provide: the right to human intervention, the right to express a point of view, and the right to contest the decision. These requirements map naturally to CRITICAL tier human oversight controls.

## Cyber security regulation

AI systems are information systems. Cyber security regulations apply regardless of whether they mention AI specifically.

| Regulation | Scope | Key AI-relevant requirements |
|-----------|-------|------------------------------|
| **NIS2 Directive** (EU) | Essential and important entities | Risk management measures, supply chain security, incident reporting |
| **DORA** (EU) | Financial sector | ICT risk management, third-party risk, resilience testing, incident reporting |
| **CIRCIA** (US) | Critical infrastructure | Cyber incident reporting requirements |
| **National cyber laws** | Varies by jurisdiction | Security measures, breach notification, critical infrastructure protection |

These regulations reinforce pre-runtime security requirements: supply chain security for models, incident response planning, resilience (PACE), and third-party risk management for AI service providers.

## Building your compliance baseline

### Step 1: Map your jurisdictions

List every jurisdiction where your AI system operates, where its users are, and where data is processed or stored. Each jurisdiction contributes its own regulatory requirements.

### Step 2: Identify applicable regulations

For each jurisdiction, identify the applicable regulations across all domains: AI-specific, privacy, cyber security, sector-specific, consumer protection.

### Step 3: Extract requirements

For each applicable regulation, extract the specific requirements that affect your AI system. Focus on obligations, not aspirations.

### Step 4: Set the compliance floor

The strictest requirement across all applicable regulations sets the minimum for each control area. Your risk tier cannot be lower than what the law demands.

### Step 5: Factor into risk classification

Take the compliance floor back to [risk classification](risk-classification.md). If regulation requires controls at HIGH tier but your initial assessment was MEDIUM, regulation wins.

!!! tip "Regulation evolves"
    AI regulation is moving fast. The EU AI Act is phasing in through 2027. New national AI laws are being drafted globally. Build your compliance mapping as a living document, reviewed at least quarterly, and set up monitoring for regulatory changes in your jurisdictions.

## Countries without specific AI regulation

Many countries do not yet have AI-specific legislation. This does not mean there are no obligations. Existing privacy law, consumer protection law, professional liability rules, and sector regulation all apply to AI systems even in the absence of dedicated AI law.

In these jurisdictions:

- Use the [risk classification framework](risk-classification.md) as your governance baseline
- Comply with all applicable existing laws (privacy, cyber, sector)
- Monitor for emerging AI regulation in your jurisdiction
- Consider voluntary alignment with recognised standards (NIST AI RMF, ISO 42001) as a defensible governance posture

!!! info "References"
    - [EU AI Act (Regulation 2024/1689)](https://eur-lex.europa.eu/eli/reg/2024/1689)
    - [GDPR (Regulation 2016/679)](https://eur-lex.europa.eu/eli/reg/2016/679)
    - [NIS2 Directive (Directive 2022/2555)](https://eur-lex.europa.eu/eli/dir/2022/2555)
    - [DORA (Regulation 2022/2554)](https://eur-lex.europa.eu/eli/reg/2022/2554)
    - [NIST AI Risk Management Framework](https://www.nist.gov/itl/ai-risk-management-framework)
    - [ISO/IEC 42001: AI Management System](https://www.iso.org/standard/81230.html)
    - [OWASP LLM Top 10](https://owasp.org/www-project-top-10-for-large-language-model-applications/)
    - [AI Runtime Security](https://airuntimesecurity.io/)
