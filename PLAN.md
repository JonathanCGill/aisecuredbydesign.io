# AI Pre-Runtime Security — Site Plan

## Relationship to Existing Sites

| Site | Focus | Phase |
|------|-------|-------|
| **aipreruntimesecurity.io** (this site) | Securing AI *before* it runs — pipelines, data, models, SDLC, governance | Pre-deployment |
| **airuntimesecurity.io** | Securing AI *while* it runs — guardrails, LLM-as-Judge, human oversight | Runtime |
| **airuntimesecurity.co.za** | Learning/training portal — draws content from both sites | Education |

The handoff point: **Pre-runtime security ends where runtime security begins.** Pre-runtime ensures that what gets deployed is trustworthy. Runtime ensures it stays trustworthy.

---

## Tech Stack (matching airuntimesecurity.io)

- **MkDocs** with **Material for MkDocs** theme
- Custom CSS overrides for branding
- SVG diagrams for architecture visualization
- Same navigation patterns and content structure
- MIT License

---

## Content Architecture — Priority Order

The content is ordered by what delivers the most immediate, practical value to readers trying to secure their AI pipelines.

### 1. AI Threat Landscape Before Runtime (Foundation)

*Why this first: Readers need to understand what they're defending against before implementing controls.*

- What is AI Pre-Runtime Security? (mirrors the "What is AI Runtime Security?" page)
- The AI supply chain attack surface
- Threat categories: model poisoning, data poisoning, dependency attacks, prompt template injection, pipeline compromise
- How pre-runtime failures become runtime incidents
- The handoff to AI Runtime Security (explicit link to airuntimesecurity.io)

### 2. Model Supply Chain Security (Highest Risk)

*Why this is priority: A compromised model is a compromised system. No amount of runtime controls fix a backdoored model.*

- **Model provenance and integrity**
  - Model cards, licensing, and origin verification
  - Hash verification and signing (e.g., Sigstore for ML)
  - Model Bill of Materials (ML-BOM)
- **Model selection risk assessment**
  - Open-weight vs. closed API models — different risk profiles
  - Fine-tuned vs. base models — what changes, what risks emerge
  - Evaluating model behaviour before deployment (benchmarks, red-teaming)
- **Model vulnerability scanning**
  - Known attack vectors: backdoors, trojans, adversarial triggers
  - Tools and techniques for model inspection
  - Serialisation risks (pickle, safetensors, ONNX)
- **Model registries and access control**
  - Internal model registries
  - Version pinning and rollback capability
  - Who can approve a model for production?

### 3. Data Security for AI (RAG, Training, Fine-Tuning)

*Why this is priority: Data quality and security directly determine AI output quality and safety.*

- **RAG pipeline security**
  - Document ingestion — sanitisation, validation, provenance tracking
  - Embedding security — adversarial embedding attacks
  - Vector database access control and encryption
  - Retrieval poisoning — how attackers inject malicious context
  - Chunk-level access control (who should see what in retrieved context?)
- **Training and fine-tuning data governance**
  - Data lineage and provenance
  - PII detection and handling
  - Copyright and licensing compliance
  - Data poisoning detection
  - Synthetic data risks
- **Data classification for AI workloads**
  - What data can be used for training/fine-tuning?
  - What data can be stored in vector databases?
  - Cross-border data considerations (POPIA, GDPR, etc.)

### 4. AI-Aware SDLC (Secure Development Lifecycle)

*Why this is priority: The SDLC is where all pre-runtime decisions are made. Get this wrong, everything downstream is compromised.*

- **How AI changes the SDLC**
  - Traditional SDLC vs. AI-augmented SDLC — what's different
  - Non-determinism — you can't fully test what you can't fully predict
  - Continuous evaluation replaces point-in-time testing
  - The "it works on my prompt" problem
- **AI-specific development phases**
  - Requirements: defining acceptable AI behaviour boundaries
  - Design: architecture threat modelling for AI components
  - Build: secure coding with AI assistance (and securing AI-generated code)
  - Test: AI-specific testing — behavioural, adversarial, bias, drift
  - Deploy: pre-deployment checklists and gates
  - Monitor: connecting pre-runtime controls to runtime telemetry
- **Securing AI-generated code**
  - Risks of AI coding assistants (Copilot, Claude, etc.)
  - Code review requirements for AI-generated code
  - Dependency risks introduced by AI suggestions
  - Intellectual property and licensing concerns
- **Prompt engineering as a security discipline**
  - System prompt security and version control
  - Prompt injection testing as part of QA
  - Prompt template management and access control

### 5. MLOps Security

*Why this is priority: MLOps is the pipeline — if the pipeline is insecure, every model it touches is suspect.*

- **Secure ML pipelines**
  - CI/CD for ML — what's different from traditional CI/CD
  - Pipeline integrity — signing, attestation, reproducibility
  - Infrastructure-as-Code for ML environments
  - Secrets management in ML pipelines (API keys, model endpoints, data credentials)
- **Model lifecycle management**
  - Training → validation → staging → production workflow
  - Automated quality gates (accuracy, fairness, safety benchmarks)
  - A/B testing and canary deployment for models
  - Model rollback procedures
- **Experiment tracking security**
  - Securing MLflow, Weights & Biases, etc.
  - Protecting experiment metadata and hyperparameters
  - Access control for experiment results
- **Compute and infrastructure security**
  - GPU cluster security
  - Notebook security (Jupyter, Colab)
  - Container security for ML workloads
  - Cloud ML service configuration (SageMaker, Vertex AI, Azure ML)

### 6. AI Governance Beyond Standard Change Management

*Why this matters: Standard change governance assumes deterministic systems. AI is not deterministic. New governance structures are required.*

- **Why standard change governance is insufficient**
  - Change Advisory Boards (CABs) assume predictable outcomes
  - AI systems can behave differently with identical inputs
  - Model updates ≠ code updates — different risk profiles
  - Prompt changes can alter behaviour more than code changes
- **AI-specific governance structures**
  - AI Ethics/Risk Committee — composition, mandate, authority
  - Model Risk Management (aligned with SR 11-7 where applicable)
  - AI use-case approval process — before a project starts
  - Risk tiering for AI use cases (aligns with airuntimesecurity.io risk tiers)
- **AI change governance**
  - Model change classification (major, minor, patch — but for models)
  - Prompt change management — version control, approval, testing
  - Data change impact assessment — when training/RAG data changes
  - Rollback criteria and procedures specific to AI
  - Post-deployment monitoring handoff (connects to runtime security)
- **Regulatory and compliance alignment**
  - EU AI Act — obligations by risk category
  - NIST AI RMF — mapping to pre-runtime controls
  - ISO 42001 — AI management system requirements
  - South Africa's AI policy landscape
  - Sector-specific requirements (financial services, healthcare, etc.)
- **Accountability and documentation**
  - AI system inventory / register
  - Decision logs — who approved what model, data, and configuration
  - Impact assessments (AIIA, DPIA for AI)
  - Audit trail requirements
  - Third-party AI vendor assessments

### 7. Testing and Validation

- **AI-specific testing approaches**
  - Behavioural testing (CheckList, invariance, directional)
  - Adversarial testing / red-teaming
  - Bias and fairness testing
  - Hallucination rate measurement
  - Performance benchmarking
- **Pre-deployment gates**
  - Minimum quality thresholds
  - Safety evaluation criteria
  - Compliance sign-off checklist
  - Stakeholder acceptance criteria

### 8. Quick Start Guide

*Mirrors the airuntimesecurity.io Quick Start — get from zero to secured pipeline in a structured path.*

- Assess: Map your AI components and classify risk
- Secure the model: Verify provenance, scan, register
- Secure the data: Classify, sanitise, control access
- Secure the pipeline: CI/CD hardening, gates, signing
- Govern: Establish AI change governance
- Hand off: Connect to runtime security controls

---

## Cross-Site Integration

### Content flow to airuntimesecurity.io
- Pre-runtime pages link forward: "Once deployed, see [Runtime Controls](https://airuntimesecurity.io/core/)"
- Runtime pages link backward: "Before deployment, see [Pre-Runtime Security](https://aipreruntimesecurity.io/)"
- Shared risk tier taxonomy
- Shared terminology glossary

### Content flow to airuntimesecurity.co.za
- Both sites feed structured learning paths
- Pre-runtime content maps to "AI Security Foundations" learning track
- Practical exercises and checklists extractable as learning materials

---

## Navigation Structure

```
Home
├── What is AI Pre-Runtime Security?
├── Quick Start
├── Core
│   ├── Threat Landscape
│   ├── Model Supply Chain
│   ├── Data Security
│   │   ├── RAG Security
│   │   ├── Training Data
│   │   └── Data Classification
│   ├── AI-Aware SDLC
│   │   ├── How AI Changes the SDLC
│   │   ├── Securing AI-Generated Code
│   │   └── Prompt Engineering Security
│   ├── MLOps Security
│   │   ├── Secure ML Pipelines
│   │   ├── Model Lifecycle
│   │   └── Infrastructure Security
│   ├── Testing & Validation
│   └── Governance
│       ├── Why Standard Governance Fails
│       ├── AI-Specific Governance
│       ├── AI Change Management
│       ├── Regulatory Alignment
│       └── Accountability
├── Insights
│   └── What Works
├── Stakeholders
│   ├── CISO / Security Leadership
│   ├── ML Engineers
│   ├── Data Engineers
│   ├── Platform / DevOps
│   └── Risk & Compliance
└── Glossary
```

---

## Key Principles

1. **Practical over theoretical** — every page should answer "what do I do Monday morning?"
2. **Tool-agnostic** — reference tools as examples, not prescriptions
3. **Risk-proportionate** — not every AI use case needs every control
4. **Connected** — explicit links to runtime security; pre-runtime is not standalone
5. **Opinionated but honest** — state what works, acknowledge what's uncertain

---

## Implementation Phases

### Phase 1: Foundation (MVP)
- Site scaffold (MkDocs + Material theme, matching airuntimesecurity.io styling)
- Home page, What is AI Pre-Runtime Security?, Quick Start
- Model Supply Chain Security (Section 2)
- AI Governance (Section 6) — the most unique content not covered elsewhere

### Phase 2: Core Content
- Data Security / RAG (Section 3)
- AI-Aware SDLC (Section 4)
- MLOps Security (Section 5)

### Phase 3: Depth
- Testing & Validation (Section 7)
- Stakeholder guides
- Threat Landscape deep-dive
- Glossary
- Cross-site linking integration

---

## What Matters Most to Readers

Based on real-world AI adoption patterns, readers care about these in this order:

1. **"Is the model safe to use?"** → Model Supply Chain Security
2. **"Is our data protected?"** → Data/RAG Security
3. **"What approvals do we need?"** → Governance
4. **"How do we build securely?"** → AI-Aware SDLC
5. **"How do we deploy safely?"** → MLOps + Testing
6. **"How does this connect to production?"** → Handoff to runtime

The site should respect this priority in its information architecture.
